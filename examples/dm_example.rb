#!/usr/bin/env ruby
# frozen_string_literal: true

# Example usage of the Talknote DM API
require_relative '../lib/talknote'

begin
  # Initialize the client
  client = Talknote::Client.new

  puts "=== Talknote DM API Example ==="
  puts

  # Get all DM conversations
  puts "1. Getting all DM conversations..."
  dm_response = client.dm
  dm_conversations = dm_response.dig('data', 'threads') || []
  puts "Found #{dm_conversations.size} DM conversations"
  puts

  if dm_conversations.any?
    # Get the first conversation ID for examples
    first_conversation = dm_conversations.first
    conversation_id = first_conversation['id']

    puts "2. Getting messages from conversation #{conversation_id}..."
    messages = client.dm_list(conversation_id)
    puts "Found #{messages.size} messages in this conversation"
    puts

    puts "3. Getting unread count for conversation #{conversation_id}..."
    unread_count = client.dm_unread(conversation_id)
    puts "Unread messages: #{unread_count}"
    puts

    # Example of sending a message (commented out to avoid spam)
    # puts "4. Sending a test message..."
    # result = client.dm_post(conversation_id, "Hello from Ruby client!")
    # puts "Message sent: #{result}"
    # puts
  else
    puts "No DM conversations found"
  end

rescue Talknote::Error => e
  puts "Talknote API Error: #{e.message}"
  exit 1
rescue Errno::ENOENT => e
  puts "Authentication token not found. Please run 'bundle exec talknote init' first."
  exit 1
rescue => e
  puts "Unexpected error: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end
