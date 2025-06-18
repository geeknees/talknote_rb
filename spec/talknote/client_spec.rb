# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Talknote::Client do
  let(:mock_conn) { instance_double(Faraday::Connection) }
  let(:mock_response) { instance_double(Faraday::Response, status: 200, body: '{"result": "success"}') }
  let(:client) do
    client_instance = described_class.allocate
    client_instance.instance_variable_set(:@conn, mock_conn)
    client_instance
  end

  describe 'initialization' do
    it 'raises an error when token file does not exist' do
      expect(File).to receive(:read).with("#{Dir.home}/.config/talknote/token.json").and_raise(Errno::ENOENT)

      expect { Talknote::Client.new }.to raise_error(Errno::ENOENT)
    end

    it 'raises an error when token file contains invalid JSON' do
      expect(File).to receive(:read).with("#{Dir.home}/.config/talknote/token.json").and_return('invalid json')

      expect { Talknote::Client.new }.to raise_error(JSON::ParserError)
    end

    it 'initializes successfully with valid token file' do
      token_json = { access_token: 'test_token' }.to_json
      expect(File).to receive(:read).with("#{Dir.home}/.config/talknote/token.json").and_return(token_json)
      expect(Faraday).to receive(:new).with(
        url: 'https://eapi.talknote.com',
        headers: { 'X-TALKNOTE-OAUTH-TOKEN' => 'test_token' }
      )

      expect { Talknote::Client.new }.not_to raise_error
    end
  end

  describe '#dm_post' do
    it 'sends a POST request to the correct endpoint' do
      expect(mock_conn).to receive(:post).with('api/v1/dm/post/123').and_return(mock_response)

      result = client.dm_post('123', 'Hello World')
      expect(result).to eq({ 'result' => 'success' })
    end

    it 'includes options in the request body' do
      expect(mock_conn).to receive(:post).with('api/v1/dm/post/123') do |&block|
        req = double('request')
        headers = {}
        expect(req).to receive(:headers).and_return(headers)
        expect(req).to receive(:body=).with('message=Hello&priority=high')
        block.call(req)
        expect(headers['Content-Type']).to eq('application/x-www-form-urlencoded')
        mock_response
      end

      client.dm_post('123', 'Hello', { priority: 'high' })
    end

    it 'works with empty options hash' do
      expect(mock_conn).to receive(:post).with('api/v1/dm/post/123') do |&block|
        req = double('request')
        headers = {}
        expect(req).to receive(:headers).and_return(headers)
        expect(req).to receive(:body=).with('message=Hello')
        block.call(req)
        expect(headers['Content-Type']).to eq('application/x-www-form-urlencoded')
        mock_response
      end

      client.dm_post('123', 'Hello', {})
    end
  end

  describe 'error handling' do
    let(:error_response) { instance_double(Faraday::Response, status: 401, body: 'Unauthorized') }

    it 'raises Talknote::Error for 401 responses' do
      expect(mock_conn).to receive(:get).with('api/v1/dm').and_return(error_response)

      expect { client.dm }.to raise_error(Talknote::Error, 'Unauthorized: Please check your access token')
    end

    it 'raises Talknote::Error for 404 responses' do
      not_found_response = instance_double(Faraday::Response, status: 404, body: 'Not Found')
      expect(mock_conn).to receive(:get).with('api/v1/dm').and_return(not_found_response)

      expect { client.dm }.to raise_error(Talknote::Error, 'Not Found: Resource does not exist')
    end

    it 'raises Talknote::Error for 403 responses' do
      forbidden_response = instance_double(Faraday::Response, status: 403, body: 'Forbidden')
      expect(mock_conn).to receive(:get).with('api/v1/dm').and_return(forbidden_response)

      expect { client.dm }.to raise_error(Talknote::Error, 'Forbidden: Insufficient permissions')
    end

    it 'raises Talknote::Error for 429 responses' do
      rate_limit_response = instance_double(Faraday::Response, status: 429, body: 'Rate Limited')
      expect(mock_conn).to receive(:get).with('api/v1/dm').and_return(rate_limit_response)

      expect { client.dm }.to raise_error(Talknote::Error, 'Rate Limited: Too many requests')
    end

    it 'raises Talknote::Error for 500 responses' do
      server_error_response = instance_double(Faraday::Response, status: 500, body: 'Internal Server Error')
      expect(mock_conn).to receive(:get).with('api/v1/dm').and_return(server_error_response)

      expect { client.dm }.to raise_error(Talknote::Error, 'Server Error: 500 - Internal Server Error')
    end

    it 'raises Talknote::Error for other HTTP errors' do
      custom_error_response = instance_double(Faraday::Response, status: 418, body: 'I am a teapot')
      expect(mock_conn).to receive(:get).with('api/v1/dm').and_return(custom_error_response)

      expect { client.dm }.to raise_error(Talknote::Error, 'HTTP Error: 418 - I am a teapot')
    end

    it 'raises Talknote::Error for invalid JSON responses' do
      invalid_json_response = instance_double(Faraday::Response, status: 200, body: 'invalid json')
      expect(mock_conn).to receive(:get).with('api/v1/dm').and_return(invalid_json_response)

      expect { client.dm }.to raise_error(Talknote::Error, /Invalid JSON response/)
    end
  end

  describe '#group' do
    it 'fetches the group list' do
      expect(mock_conn).to receive(:get).with('api/v1/group').and_return(mock_response)

      result = client.group
      expect(result).to eq({ 'result' => 'success' })
    end
  end

  describe '#group_list' do
    it 'fetches messages from a specific group' do
      expect(mock_conn).to receive(:get).with('api/v1/group/list/123').and_return(mock_response)

      result = client.group_list('123')
      expect(result).to eq({ 'result' => 'success' })
    end
  end

  describe '#group_unread' do
    it 'fetches unread count for a specific group' do
      expect(mock_conn).to receive(:get).with('api/v1/group/unread/123').and_return(mock_response)

      result = client.group_unread('123')
      expect(result).to eq({ 'result' => 'success' })
    end
  end

  describe '#group_post' do
    it 'sends a POST request to post a message to a group' do
      expect(mock_conn).to receive(:post).with('api/v1/group/post/123').and_return(mock_response)

      result = client.group_post('123', 'Hello Group!')
      expect(result).to eq({ 'result' => 'success' })
    end

    it 'includes options in the request body' do
      expect(mock_conn).to receive(:post).with('api/v1/group/post/123') do |&block|
        req = double('request')
        headers = {}
        expect(req).to receive(:headers).and_return(headers)
        expect(req).to receive(:body=).with('message=Hello+Group%21&priority=high')
        block.call(req)
        expect(headers['Content-Type']).to eq('application/x-www-form-urlencoded')
        mock_response
      end

      client.group_post('123', 'Hello Group!', { priority: 'high' })
    end

    it 'works with empty options hash' do
      expect(mock_conn).to receive(:post).with('api/v1/group/post/123') do |&block|
        req = double('request')
        headers = {}
        expect(req).to receive(:headers).and_return(headers)
        expect(req).to receive(:body=).with('message=Hello+Group%21')
        block.call(req)
        expect(headers['Content-Type']).to eq('application/x-www-form-urlencoded')
        mock_response
      end

      client.group_post('123', 'Hello Group!', {})
    end
  end

  describe '#dm' do
    it 'fetches the dm list' do
      expect(mock_conn).to receive(:get).with('api/v1/dm').and_return(mock_response)

      result = client.dm
      expect(result).to eq({ 'result' => 'success' })
    end
  end

  describe '#dm_list' do
    it 'fetches messages from a specific dm conversation' do
      expect(mock_conn).to receive(:get).with('api/v1/dm/list/123').and_return(mock_response)

      result = client.dm_list('123')
      expect(result).to eq({ 'result' => 'success' })
    end
  end

  describe '#dm_unread' do
    it 'fetches unread count for a specific dm conversation' do
      expect(mock_conn).to receive(:get).with('api/v1/dm/unread/123').and_return(mock_response)

      result = client.dm_unread('123')
      expect(result).to eq({ 'result' => 'success' })
    end
  end
end
