if RailsApp::Application.config.respond_to?(:secret_key_base)
  if Rails.version < '4.1.0'
    RailsApp::Application.config.secret_key_base = 'c6a67697877c66be70cdcc4680f37593045a721cf757de4110f9749877cb32f94fe4ddaa5e816af4555d91c4f6142a401972474d50fe620d41ede300d3143d4a'
  end
else
  RailsApp::Application.config.secret_token = 'c6a67697877c66be70cdcc4680f37593045a721cf757de4110f9749877cb32f94fe4ddaa5e816af4555d91c4f6142a401972474d50fe620d41ede300d3143d4a'
end
