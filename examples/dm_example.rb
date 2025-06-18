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
  dm_conversations = client.dm
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

    puts "4. Getting members of conversation #{conversation_id}..."
    members = client.dm_members(conversation_id)
    puts "Members: #{members}"
    puts

    # Example of sending a message (commented out to avoid spam)
    # puts "5. Sending a test message..."
    # result = client.dm_post(conversation_id, "Hello from Ruby client!")
    # puts "Message sent: #{result}"
    # puts

    # Example of marking as read (commented out to avoid unintended side effects)
    # puts "6. Marking conversation as read..."
    # client.dm_mark_read(conversation_id)
    # puts "Conversation marked as read"
    # puts

    puts "7. Searching DM conversations..."
    search_results = client.dm_search("test")
    puts "Search results: #{search_results.size} conversations found"
    puts
  else
    puts "No DM conversations found"
  end

  # Example of creating a new DM (commented out to avoid creating unwanted conversations)
  # puts "8. Creating a new DM conversation..."
  # new_dm = client.dm_create("user_id_here", "Hello from Ruby!")
  # puts "New DM created: #{new_dm}"

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
