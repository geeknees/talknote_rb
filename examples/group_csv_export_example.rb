#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Export all group conversations to CSV
require_relative '../lib/talknote'
require 'csv'
require 'time'

def safe_get(hash, key, default = '')
  return default if hash.nil?
  hash[key] || default
end

def format_timestamp(timestamp)
  return '' if timestamp.nil? || timestamp.empty?
  Time.parse(timestamp).strftime('%Y-%m-%d %H:%M:%S')
rescue
  timestamp
end

def export_groups_to_csv(filename = "group_export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv")
  puts "=== Talknote Group CSV Export ==="
  puts "Exporting all group conversations to: #{filename}"
  puts

  begin
    client = Talknote::Client.new
    puts "✅ Successfully initialized Talknote client"
  rescue StandardError => e
    puts "❌ Failed to initialize client: #{e.message}"
    puts "\nMake sure you've run: talknote init -i CLIENT_ID -s CLIENT_SECRET"
    exit 1
  end

  CSV.open(filename, 'w', encoding: 'UTF-8') do |csv|
    # CSV header
    csv << [
      'group_id',
      'group_name',
      'message_id',
      'sender_id',
      'sender_name',
      'message',
      'created_at',
      'message_type',
      'unread_count'
    ]

    begin
      # Get all groups
      puts "📋 Getting all groups..."
      groups_response = client.group
      groups = groups_response.dig('data', 'groups') || []
      puts "Found #{groups.size} groups"

      total_messages = 0

      groups.each_with_index do |group, index|
        group_id = safe_get(group, 'id')
        group_name = safe_get(group, 'name')

        puts "Processing group #{index + 1}/#{groups.size}: #{group_name} (ID: #{group_id})"

        # Get unread count for this group
        unread_count = 0
        begin
          unread_response = client.group_unread(group_id)
          unread_count = unread_response.dig('data', 'unread_count') || 0
          puts "  Unread messages: #{unread_count}"
        rescue Talknote::Error => e
          puts "  ❌ Could not get unread count: #{e.message}"
        end

        begin
          # Get messages from this group
          messages_response = client.group_list(group_id)
          messages = messages_response.dig('data', 'messages') || []

          puts "  Found #{messages.size} messages"
          total_messages += messages.size

          messages.each do |message|
            csv << [
              group_id,
              group_name,
              safe_get(message, 'id'),
              safe_get(message, 'sender_id'),
              safe_get(message, 'sender_name'),
              safe_get(message, 'message'),
              format_timestamp(safe_get(message, 'created_at')),
              safe_get(message, 'type', 'text'),
              unread_count
            ]
          end

        rescue Talknote::Error => e
          puts "  ❌ Error getting messages for group #{group_id}: #{e.message}"
          # Add error row to CSV
          csv << [
            group_id,
            group_name,
            '',
            '',
            '',
            "ERROR: #{e.message}",
            format_timestamp(Time.now.to_s),
            'error',
            unread_count
          ]
        end

        # Add a small delay to avoid rate limiting
        sleep(0.1) if groups.size > 10
      end

      puts
      puts "🎉 Export completed successfully!"
      puts "📊 Total groups: #{groups.size}"
      puts "📊 Total messages exported: #{total_messages}"
      puts "📄 File saved as: #{filename}"

    rescue Talknote::Error => e
      puts "❌ API Error: #{e.message}"
      exit 1
    end
  end

rescue StandardError => e
  puts "💥 Unexpected error: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  exit 1
end

if __FILE__ == $0
  # Allow custom filename as command line argument
  filename = ARGV[0] || "group_export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"
  export_groups_to_csv(filename)
end
