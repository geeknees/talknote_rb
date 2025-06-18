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
