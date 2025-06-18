# frozen_string_literal: true

require 'talknote'
require 'thor'
require 'webrick'
require 'pp'
require 'oauth2'
require 'fileutils'
require 'json'

module Talknote
  class CLI < Thor
    # default_command :init

    desc 'init', 'Get an access token and save it'
    option 'id', aliases: 'i', type: :string, required: true, banner: 'Client ID'
    option 'secret', aliases: 's', type: :string, required: true, banner: 'Client Secret'
    option 'host', aliases: 'h', type: :string, default: '127.0.0.1', banner: 'Callback host'
    option 'port', aliases: 'p', type: :string, default: '8080', banner: 'Callback port'
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
      scope = [
        'talknote.timeline.read',
        'talknote.timeline.write',
        'talknote.timeline.message.read',
        'talknote.timeline.message.write',
        'talknote.timeline.unread',
        'talknote.group',
        'talknote.group.read',
        'talknote.group.write',
        'talknote.group.unread',
        'talknote.group.message.read',
        'talknote.group.message.write',
        'talknote.direct_message',
        'talknote.direct_message.read',
        'talknote.direct_message.write',
        'talknote.direct_message.unread',
        'talknote.direct_message.message.read',
        'talknote.direct_message.message.write',
        'talknote.user.read',
        'talknote.user.write',
        'talknote.allfeed.read',
        'talknote.allfeed.unread'
      ].join(' ')

      code_args = {
        redirect_uri: redirect_uri,
        scope: scope,
        state: state
      }

      url = client.auth_code.authorize_url(code_args)

      puts ''
      puts "Authorization URL: #{url}"
      puts ''

      # Automatically open the URL in the default browser
      begin
        if RUBY_PLATFORM =~ /darwin/  # macOS
          system("open '#{url}'")
          puts "Opening browser automatically..."
        elsif RUBY_PLATFORM =~ /linux/
          system("xdg-open '#{url}'")
          puts "Opening browser automatically..."
        elsif RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i
          system("start '#{url}'")
          puts "Opening browser automatically..."
        else
          puts "Please manually open the URL above in your browser."
        end
      rescue => e
        puts "Could not open browser automatically: #{e.message}"
        puts "Please manually open the URL above in your browser."
      end

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

        begin
          token = client.auth_code.get_token(
            req.query['code'],
            grant_type: 'authorization_code',
            redirect_uri: redirect_uri
          )

          pp token.to_hash
          puts ''

          config_path = "#{Dir.home}/.config/talknote"
          FileUtils.mkdir_p(config_path) unless Dir.exist?(config_path)

          File.write("#{config_path}/token.json", token.to_hash.to_json)
          res.status = 200
          res.body = 'You may now close this tab'

          server.shutdown
        rescue OAuth2::Error => e
          puts "OAuth2 Error: #{e.message}"
          puts "Error Code: #{e.code}" if e.respond_to?(:code)
          puts "Error Description: #{e.description}" if e.respond_to?(:description)
          res.status = 400
          res.body = "OAuth Error: #{e.message}"
        rescue => e
          puts "General Error: #{e.message}"
          puts e.backtrace.join("\n")
          res.status = 500
          res.body = "Server Error: #{e.message}"
        end
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
