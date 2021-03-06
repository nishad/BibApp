require 'omniauth-oauth2'

# OmniAuth strategy for connecting to the ORCID contributor ID service via the OAuth 2.0 protocol

module OmniAuth
  module Strategies
    class ORCID < OmniAuth::Strategies::OAuth2

      DEFAULT_SCOPE = '/authenticate'

      option :client_options, {
        :site => 'http://api.orcid.org',
        :authorize_url => 'http://orcid.org/oauth/authorize',
        :token_url => 'https://pub.orcid.org/oauth/token',
        :scope => '/authenticate',
        :response_type => 'code',
        :mode => :header
      }

      # Pull out unique ID for the user in the external system
      uid { access_token.params["orcid"] }

      info do
        { name: access_token.params["name"],
          email: access_token.params["email"],
          scope: access_token.params["scope"] }
      end

      # Customize the parameters passed to the OAuth provider in the authorization phase
      def authorize_params

        # Trick shamelessly borrowed from the omniauth-facebook gem!
        super.tap do |params|
          %w[scope].each { |v| params[v.to_sym] = request.params[v] if request.params[v] }
          params[:scope] ||= DEFAULT_SCOPE # ensure that we're always request *some* default scope
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'orcid', 'ORCID'
