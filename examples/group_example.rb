#!/usr/bin/env ruby
# frozen_string_literal: true

# Example script demonstrating group functionality
# Usage: ruby examples/group_example.rb

require_relative '../lib/talknote'

def main
  puts "🚀 Talknote Group API Example"
  puts "=" * 50

  begin
    client = Talknote::Client.new
    puts "✅ Successfully initialized Talknote client"
  rescue StandardError => e
    puts "❌ Failed to initialize client: #{e.message}"
    puts "\nMake sure you've run: talknote init -i CLIENT_ID -s CLIENT_SECRET"
    exit 1
  end

  # Example 1: List all groups
  puts "\n📋 Listing all groups..."
  begin
    groups_response = client.group
    groups = groups_response.dig('data', 'groups') || []

    if groups.empty?
      puts "   No groups found"
    else
      puts "   Found #{groups.length} groups:"
      groups.first(3).each do |group|
        puts "   - #{group['name']} (ID: #{group['id']})"
      end
      puts "   ... (showing first 3 groups)" if groups.length > 3
    end
  rescue Talknote::Error => e
    puts "   ❌ Error: #{e.message}"
  end

  # Example 2: Get group details and unread count
  puts "\n📊 Checking unread messages in groups..."
  begin
    groups_response = client.group
    groups = groups_response.dig('data', 'groups') || []

    groups.first(2).each do |group|
      puts "   Group: #{group['name']}"

      # Get unread count
      begin
        unread_response = client.group_unread(group['id'])
        unread_count = unread_response.dig('data', 'unread_count') || 0
        puts "     📬 Unread messages: #{unread_count}"
      rescue Talknote::Error => e
        puts "     ❌ Could not get unread count: #{e.message}"
      end

      # Get messages from the group
      begin
        messages_response = client.group_list(group['id'])
        puts "     � Messages: Available"
      rescue Talknote::Error => e
        puts "     � Messages: Could not retrieve (#{e.message})"
      end

      puts ""
    end
  rescue Talknote::Error => e
    puts "   ❌ Error: #{e.message}"
  end

  # Example 3: Send a test message (commented out for safety)
  puts "\n💬 Example: Sending a message to a group"
  puts "   (This example is commented out for safety)"
  puts "   To send a message, uncomment the code below and specify a group ID:"
  puts ""
  puts "   # group_id = 'your_group_id_here'"
  puts "   # message = 'Hello from TalknoteRb! 🚀'"
  puts "   # result = client.group_post(group_id, message)"
  puts "   # puts \"Message sent successfully!\""

  # Uncomment and modify the following lines to actually send a message:
  # group_id = 'YOUR_GROUP_ID_HERE'
  # message = 'Test message from TalknoteRb example script! 🚀'
  # begin
  #   result = client.group_post(group_id, message)
  #   puts "   ✅ Message sent successfully!"
  #   puts "   Response: #{result}"
  # rescue Talknote::Error => e
  #   puts "   ❌ Failed to send message: #{e.message}"
  # end

  puts "\n🎉 Group API example completed!"
  puts "\nNext steps:"
  puts "- Try running: bundle exec talknote group"
  puts "- Send a message: bundle exec talknote group-post GROUP_ID 'Your message'"

rescue StandardError => e
  puts "\n💥 Unexpected error: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  exit 1
end

if __FILE__ == $0
  main
end
