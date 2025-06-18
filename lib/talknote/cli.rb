# frozen_string_literal: true

require 'talknote'
require 'thor'
require 'webrick'
require 'pp'

module Talknote
  class CLI < Thor
    # default_command :init

    desc 'init', 'Get an access token and save it'
    option 'id', aliases: 'i', type: :string, required: true, banner: 'Client ID'
    option 'secret', aliases: 's', type: :string, required: true, banner: 'Client Secret'
    option 'host', aliases: 'h', type: :string, default: '127.0.0.1', banner: 'Callback host'
    option 'port', aliases: 'p', type: :string, default: '3000', banner: 'Callback port'
    def init
      state = ('a'..'z').to_a.sample(32).join
      path = '/oauth/callback'

      client = OAuth2::Client.new(
        options['id'],
        options['secret'],
        site: 'https://oauth.talknote.com',
        authorize_url: '/oauth/authorize',
        token_url: 'oauth/token'
      )

      redirect_uri = "http://#{options['host']}:#{options['port']}#{path}"
      scope = %w[talknote.timeline.read
                 talknote.timeline.write
                 talknote.timeline.message.read
                 talknote.timeline.message.write
                 talknote.timeline.unread
                 talknote.group
                 talknote.group.read
                 talknote.group.write
                 talknote.group.unread
                 talknote.group.message.read
                 talknote.group.message.write
                 talknote.direct_message
                 talknote.direct_message.read
                 talknote.direct_message.write
                 talknote.direct_message.unread
                 talknote.direct_message.message.read
                 talknote.direct_message.message.write
                 talknote.user.read talknote.user.write
                 talknote.allfeed.read
                 talknote.allfeed.unread].join(' ')

      code_args = {
        redirect_uri: redirect_uri,
        scope: scope,
        state: state
      }

      url = client.auth_code.authorize_url(code_args)

      puts ''
      puts "Go to URL: #{url}"
      puts ''

      puts 'Starting server - use Ctrl+C to stop'
      puts ''

      server_options = {
        Port: options['port']
      }

      server = WEBrick::HTTPServer.new(server_options)

      server.mount_proc('/') do |req, res|
        unless req.path == path
          res.status = 403
          res.body = "Invalid callback path - expecting #{path}"
          next
        end

        unless req.query['state'] == state
          res.status = 400
          res.body = 'Invalid state in callback'
          next
        end

        token = client.auth_code.get_token(
          req.query['code'],
          grant_type: 'authorization_code',
          redirect_uri: redirect_uri
        )

        pp token.to_hash
        puts ''

        config_path = "#{Dir.home}/.config/talknote"
        unless Dir.exists?(config_path)
          Dir.mkdir(config_path)
        end

        File.write("#{config_path}/token.json", token.to_hash.to_json)
        res.status = 200
        res.body = 'You may now close this tab'

        server.shutdown
      end

      trap('INT') do
        server.shutdown
      end

      server.start
    end

    desc 'dm', 'Show dm list'
    def dm
      pp Talknote::Client.new.dm
    end

    class << self
      def exit_on_failure?
        true
      end
    end
  end
end
