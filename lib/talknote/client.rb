# frozen_string_literal: true

require 'json'

module Talknote
  class Client

    def dm
      response = conn.get('api/v1/dm')
      JSON.parse(response.body)
    end

    def dm_list(id)
      response = conn.get("api/v1/dm/list/#{id}")
      JSON.parse(response.body)
    end

    def dm_unread(id)
      response = conn.get("api/v1/dm/unread/#{id}")
      JSON.parse(response.body)
    end

    # def dm_post; end

    def group_list(id)
      response = conn.get("api/v1/group/list/#{id}")
      JSON.parse(response.body)
    end

    def group_unread(id)
      response = conn.get("api/v1/group/unread/#{id}")
      JSON.parse(response.body)
    end

    # def group_post; end

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

  end
end
