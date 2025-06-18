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
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'dm-list ID', 'Show messages from a DM conversation'
    def dm_list(id)
      pp Talknote::Client.new.dm_list(id)
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'dm-unread ID', 'Show unread count for a DM conversation'
    def dm_unread(id)
      pp Talknote::Client.new.dm_unread(id)
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'dm-post ID MESSAGE', 'Send a message to a DM conversation'
    def dm_post(id, message)
      result = Talknote::Client.new.dm_post(id, message)
      puts "Message sent successfully!"
      pp result
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'dm-create USER_ID [MESSAGE]', 'Create a new DM conversation'
    def dm_create(user_id, message = nil)
      result = Talknote::Client.new.dm_create(user_id, message)
      puts "DM conversation created successfully!"
      pp result
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'dm-mark-read ID [MESSAGE_ID]', 'Mark DM conversation as read'
    def dm_mark_read(id, message_id = nil)
      result = Talknote::Client.new.dm_mark_read(id, message_id)
      puts "Messages marked as read!"
      pp result
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'dm-search QUERY', 'Search DM conversations'
    def dm_search(query)
      pp Talknote::Client.new.dm_search(query)
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'dm-members ID', 'Show members of a DM conversation'
    def dm_members(id)
      pp Talknote::Client.new.dm_members(id)
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'dm-leave ID', 'Leave a DM conversation'
    def dm_leave(id)
      puts "Note: Leaving DM conversations is typically not supported."
      puts "DM conversations are usually persistent between participants."
      puts "If you need to stop receiving notifications, consider muting the conversation instead."
      exit 1
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'group', 'Show group list'
    def group
      pp Talknote::Client.new.group
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'group-list ID', 'Show messages from a group'
    def group_list(id)
      pp Talknote::Client.new.group_list(id)
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'group-unread ID', 'Show unread count for a group'
    def group_unread(id)
      pp Talknote::Client.new.group_unread(id)
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'group-post ID MESSAGE', 'Send a message to a group'
    def group_post(id, message)
      result = Talknote::Client.new.group_post(id, message)
      puts "Message sent successfully!"
      pp result
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'group-members ID', 'Show members of a group'
    def group_members(id)
      pp Talknote::Client.new.group_members(id)
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'group-join ID', 'Join a group'
    def group_join(id)
      result = Talknote::Client.new.group_join(id)
      puts "Successfully joined the group!"
      pp result
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'group-leave ID', 'Leave a group'
    def group_leave(id)
      result = Talknote::Client.new.group_leave(id)
      puts "Successfully left the group!"
      pp result
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'group-search QUERY', 'Search groups'
    def group_search(query)
      pp Talknote::Client.new.group_search(query)
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    desc 'group-mark-read ID [MESSAGE_ID]', 'Mark group messages as read'
    def group_mark_read(id, message_id = nil)
      result = Talknote::Client.new.group_mark_read(id, message_id)
      puts "Messages marked as read!"
      pp result
    rescue Talknote::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    class << self
      def exit_on_failure?
        true
      end
    end
  end
end
