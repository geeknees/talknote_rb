# frozen_string_literal: true

module Talknote
  class Client
    attr_accessor :client_id, :client_secret, :client_access_token,
                  :client_refresh_token, :client_token_expires_at

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      yield(self) if block_given?
    end

    def oauth_client
      options = { site: 'https://oauth.talknote.com',
                  authorize_url: '/oauth/authorize',
                  token_url: 'oauth/token' }
      @oauth_client ||= ::OAuth2::Client.new(client_id,
                                             client_secret,
                                             options)
    end

    def access_token
      @access_token ||= ::OAuth2::AccessToken.new(oauth_client,
                                                  client_access_token,
                                                  refresh_token: client_refresh_token,
                                                  expires_at: client_token_expires_at)
    end
  end
end
