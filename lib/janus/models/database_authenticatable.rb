require 'bcrypt'

module Janus
  module Models
    # = DatabaseAuthenticatable
    # 
    # This is the initial part and is required for email + password registration
    # and logins. Passwords are automatically encrypted following Devise's
    # default encryption logic, which relies on bcrypt.
    # 
    # == Required columns:
    # 
    # - email
    # - encrypted_password
    # 
    # == Configuration
    # 
    # - +stretches+
    # - +pepper+
    # - +authentication_keys+ - required keys for authenticating a user, defaults to <tt>[:email]</tt>
    # 
    module DatabaseAuthenticatable
      extend ActiveSupport::Concern

      included do
        attr_protected :encrypted_password, :reset_password_token, :reset_password_sent_at
        attr_reader   :password
        attr_accessor :current_password
        
        validates :password, :presence => true, :confirmation => true, :if => :password_required?
        validate :validate_current_password, :on => :update, :if => :current_password
        
        janus_config(:authentication_keys, :stretches, :pepper)
      end

      def password=(password)
        @password = password
        self.encrypted_password = digest_password(@password) unless @password.blank?
      end

      # Checks if a given password matches this user password.
      def valid_password?(password)
        ::BCrypt::Password.new(encrypted_password) == "#{password}#{self.class.pepper}"
      end

      def digest_password(password)
        ::BCrypt::Password.create("#{password}#{self.class.pepper}", :cost => self.class.stretches).to_s
      end

      def clean_up_passwords
        self.current_password = self.password = self.password_confirmation = nil
      end

      def generate_reset_password_token!
        self.reset_password_token = self.class.generate_token(:reset_password_token)
        self.reset_password_sent_at = Time.now
        save
      end

      def reset_password!(params)
        params.each do |key, value|
          send("#{key}=", value) if [:password, :password_confirmation].include?(key.to_sym)
        end
        
        self.reset_password_sent_at = self.reset_password_token = nil
        save
      end

      protected
        def password_required?
          !persisted? || !!password || !!password_confirmation
        end

        def validate_current_password
          errors.add(:current_password, :invalid) unless valid_password?(current_password)
        end

      module ClassMethods
        def find_for_database_authentication(params)
          params = params.reject { |k,v| !authentication_keys.include?(k.to_sym) }
          where(params).first
        end

        def find_for_password_reset(token)
          user = find_by_reset_password_token(token) unless token.blank?
          
          if user && user.reset_password_sent_at < 2.days.ago
            user.reset_password_token = user.reset_password_sent_at = nil
            user.save
            user = nil
          end
          
          user
        end
      end
    end
  end
end
