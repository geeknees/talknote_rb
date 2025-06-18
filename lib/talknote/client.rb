# frozen_string_literal: true

require 'json'
require 'uri'

module Talknote
  class Client

    def dm
      handle_response(conn.get('api/v1/dm'))
    end

    def dm_list(id)
      handle_response(conn.get("api/v1/dm/list/#{id}"))
    end

    def dm_unread(id)
      handle_response(conn.get("api/v1/dm/unread/#{id}"))
    end

    def dm_post(id, message, options = {})
      # Let's try form-encoded data instead of JSON
      data = { message: message }
      data.merge!(options) if options.any?

      response = conn.post("api/v1/dm/post/#{id}") do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(data)
      end
      handle_response(response)
    end

    def dm_create(user_id, message = nil)
      # Creating DM conversations requires knowing the exact user_id format
      # This might not work without proper user identification
      data = { user_id: user_id }
      data[:message] = message if message

      response = conn.post('api/v1/dm/create') do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(data)
      end
      handle_response(response)
    rescue Talknote::Error => e
      if e.message.include?("Not Found")
        raise Talknote::Error, "DM creation failed. This may require specific user ID format or permissions."
      else
        raise e
      end
    end

    def dm_mark_read(id, message_id = nil)
      # The mark read endpoint might not be available or might use a different path
      raise Talknote::Error, "Mark as read functionality is not available through the API"
    end

    def dm_search(query, options = {})
      # Since there's no server-side search endpoint, implement client-side search
      dm_data = handle_response(conn.get('api/v1/dm'))
      threads = dm_data.dig('data', 'threads') || []

      # Search through titles and member names
      matching_threads = threads.select do |thread|
        title_match = thread['title']&.downcase&.include?(query.downcase)
        member_match = thread['member_names']&.downcase&.include?(query.downcase)
        title_match || member_match
      end

      # Apply limit if specified in options
      limit = options[:limit] || options['limit']
      matching_threads = matching_threads.first(limit) if limit

      {
        'status' => 1,
        'query' => query,
        'total_results' => matching_threads.length,
        'data' => {
          'threads' => matching_threads
        }
      }
    end

    def dm_members(id)
      # Get member information from the main DM list since there's no separate members endpoint
      dm_data = handle_response(conn.get('api/v1/dm'))

      # Find the conversation with the specified ID
      conversation = dm_data.dig('data', 'threads')&.find { |thread| thread['id'] == id.to_s }

      if conversation
        # Return the member names as an array for easier processing
        member_names = conversation['member_names']
        {
          'id' => conversation['id'],
          'title' => conversation['title'],
          'member_names' => member_names,
          'members' => member_names&.split('、') || []
        }
      else
        raise Talknote::Error, "DM conversation with ID #{id} not found"
      end
    end

    def dm_leave(id)
      # Note: DM conversations typically don't support "leaving" in the traditional sense
      # This might not be supported by the Talknote API
      raise Talknote::Error, "Leaving DM conversations is not supported by the Talknote API"
    end

    # Group-related methods
    def group
      handle_response(conn.get('api/v1/group'))
    end

    def group_list(id)
      handle_response(conn.get("api/v1/group/list/#{id}"))
    end

    def group_unread(id)
      handle_response(conn.get("api/v1/group/unread/#{id}"))
    end

    def group_post(id, message, options = {})
      data = { message: message }
      data.merge!(options) if options.any?

      response = conn.post("api/v1/group/post/#{id}") do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(data)
      end
      handle_response(response)
    end

    def group_members(id)
      handle_response(conn.get("api/v1/group/members/#{id}"))
    end

    def group_join(id)
      response = conn.post("api/v1/group/join/#{id}") do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = ''
      end
      handle_response(response)
    end

    def group_leave(id)
      response = conn.post("api/v1/group/leave/#{id}") do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = ''
      end
      handle_response(response)
    end

    def group_search(query, options = {})
      # Client-side search implementation
      group_data = handle_response(conn.get('api/v1/group'))
      groups = group_data.dig('data', 'groups') || []

      # Search through group names and descriptions
      matching_groups = groups.select do |group|
        name_match = group['name']&.downcase&.include?(query.downcase)
        description_match = group['description']&.downcase&.include?(query.downcase)
        name_match || description_match
      end

      # Apply limit if specified in options
      limit = options[:limit] || options['limit']
      matching_groups = matching_groups.first(limit) if limit

      {
        'status' => 1,
        'query' => query,
        'total_results' => matching_groups.length,
        'data' => {
          'groups' => matching_groups
        }
      }
    end

    def group_mark_read(id, message_id = nil)
      data = {}
      data[:message_id] = message_id if message_id

      response = conn.post("api/v1/group/mark_read/#{id}") do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(data)
      end
      handle_response(response)
    end

    private

    attr_reader :conn

    def initialize
      access_token = JSON.parse(
                        File.read("#{Dir.home}/.config/talknote/token.json")
                      )['access_token']
      @conn = Faraday.new(
        url: 'https://eapi.talknote.com',
        headers: {'X-TALKNOTE-OAUTH-TOKEN' => access_token}
      )
    end

    def handle_response(response)
      case response.status
      when 200..299
        JSON.parse(response.body)
      when 401
        raise Talknote::Error, "Unauthorized: Please check your access token"
      when 403
        raise Talknote::Error, "Forbidden: Insufficient permissions"
      when 404
        raise Talknote::Error, "Not Found: Resource does not exist"
      when 429
        raise Talknote::Error, "Rate Limited: Too many requests"
      when 500..599
        raise Talknote::Error, "Server Error: #{response.status} - #{response.body}"
      else
        raise Talknote::Error, "HTTP Error: #{response.status} - #{response.body}"
      end
    rescue JSON::ParserError => e
      raise Talknote::Error, "Invalid JSON response: #{e.message}"
    end

  end
end
