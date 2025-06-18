#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Export all DM conversations to CSV
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

def export_dm_to_csv(filename = "dm_export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv")
  puts "=== Talknote DM CSV Export ==="
  puts "⚠️  注意: APIレート制限（24時間で500回まで）のため、大量のデータがある場合は"
  puts "    制限に達する可能性があります。処理が止まった場合は、時間をおいて再実行してください。"
  puts
  puts "Exporting all DM conversations to: #{filename}"
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
      'conversation_id',
      'conversation_name',
      'message_id',
      'user_id',
      'user_name',
      'message',
      'created_at',
      'message_type'
    ]

    begin
      # Get all DM conversations
      puts "📋 Getting all DM conversations..."
      dm_response = client.dm
      dm_conversations = dm_response.dig('data', 'threads') || []
      puts "Found #{dm_conversations.size} DM conversations"

      total_messages = 0

      dm_conversations.each_with_index do |conversation, index|
        conversation_id = safe_get(conversation, 'id')
        conversation_name = safe_get(conversation, 'title')

        puts "Processing conversation #{index + 1}/#{dm_conversations.size}: #{conversation_name} (ID: #{conversation_id})"

        # 注意: APIレート制限（24時間で500回まで）のため、大量のデータがある場合は制限に達する可能性があります
        # レート制限を回避するため、各会話処理前に最小限の待機時間を設けています

        begin
          # Get messages from this conversation
          messages_response = client.dm_list(conversation_id)
          messages = messages_response.dig('data', 'msg') || []

          puts "  Found #{messages.size} messages"
          total_messages += messages.size

          messages.each do |message|
            csv << [
              conversation_id,
              conversation_name,
              safe_get(message, 'id'),
              safe_get(message, 'user_id'),
              safe_get(message, 'user_name'),
              safe_get(message, 'message'),
              format_timestamp(safe_get(message, 'created_at')),
              safe_get(message, 'type', 'text')
            ]
          end

        rescue Talknote::Error => e
          puts "  ❌ Error getting messages for conversation #{conversation_id}: #{e.message}"
          # Add error row to CSV
          csv << [
            conversation_id,
            conversation_name,
            '',
            '',
            '',
            "ERROR: #{e.message}",
            format_timestamp(Time.now.to_s),
            'error'
          ]
        end

        # レート制限対策: APIの24時間500回制限を考慮し、各会話処理後に最小限の待機時間を設ける
        sleep(0.1)
      end

      puts
      puts "🎉 Export completed successfully!"
      puts "📊 Total conversations: #{dm_conversations.size}"
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
  filename = ARGV[0] || "dm_export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"
  export_dm_to_csv(filename)
end
