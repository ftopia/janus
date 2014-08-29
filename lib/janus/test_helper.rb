module Janus
  module TestHelper
    attr_reader :janus

    def self.included(klass)
      klass.class_eval do
        setup { @janus = Janus::Manager.new(request, cookies) }
      end
    end

    def sign_in(user, options = {})
      janus.login(user, options)
    end

    def sign_out(user_or_scope = nil)
      if user_or_scope
        janus.logout(Janus.scope_for(user_or_scope))
      else
        janus.logout
      end
    end

    def assert_authenticated(scope)
      assert janus.authenticated?(scope), "Expected #{scope} to be authenticated."
    end

    def refute_authenticated(scope)
      refute janus.authenticated?(scope), "Expected #{scope} to not be authenticated."
    end

    alias_method :assert_not_authenticated, :refute_authenticated
  end
end
