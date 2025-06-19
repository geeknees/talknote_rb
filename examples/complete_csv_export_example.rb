#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Export all Talknote conversations (DMs and Groups) to separate CSV files
require_relative '../lib/talknote'
require 'csv'
require 'time'
require 'fileutils'

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

def export_all_to_csv(output_dir = "talknote_export_#{Time.now.strftime('%Y%m%d_%H%M%S')}")
  puts "🚀 Talknote Complete CSV Export"
  puts "=" * 50
  puts "⚠️  注意: APIレート制限（24時間で500回まで）のため、大量のデータがある場合は"
  puts "    制限に達する可能性があります。処理が止まった場合は、時間をおいて再実行してください。"
  puts
  puts "Exporting all conversations to directory: #{output_dir}"
  puts

  # Create output directory
  FileUtils.mkdir_p(output_dir)

  begin
    client = Talknote::Client.new
    puts "✅ Successfully initialized Talknote client"
  rescue StandardError => e
    puts "❌ Failed to initialize client: #{e.message}"
    puts "\nMake sure you've run: talknote init -i CLIENT_ID -s CLIENT_SECRET"
    exit 1
  end

  total_conversations = 0
  total_messages = 0

  # Export DM conversations
  puts "\n📱 Exporting DM conversations..."
  dm_filename = File.join(output_dir, "dm_conversations.csv")

  CSV.open(dm_filename, 'w', encoding: 'UTF-8') do |csv|
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
      dm_response = client.dm
      dm_conversations = dm_response.dig('data', 'threads') || []
      puts "Found #{dm_conversations.size} DM conversations"
      total_conversations += dm_conversations.size

      dm_conversations.each_with_index do |conversation, index|
        conversation_id = safe_get(conversation, 'id')
        conversation_name = safe_get(conversation, 'title')

        print "  Processing DM #{index + 1}/#{dm_conversations.size}: #{conversation_name}"

        # 注意: APIレート制限（24時間で500回まで）のため、大量のデータがある場合は制限に達する可能性があります
        # レート制限を回避するため、各会話処理間に最小限の待機時間を設けています

        begin
          messages_response = client.dm_list(conversation_id)
          messages = messages_response.dig('data', 'msg') || []
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

          puts " (#{messages.size} messages)"

        rescue Talknote::Error => e
          puts " ❌ Error: #{e.message}"
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

    rescue Talknote::Error => e
      puts "❌ DM API Error: #{e.message}"
    end
  end

  # Export Group conversations
  puts "\n👥 Exporting group conversations..."
  group_filename = File.join(output_dir, "group_conversations.csv")

  CSV.open(group_filename, 'w', encoding: 'UTF-8') do |csv|
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
      groups_response = client.group
      groups = groups_response.dig('data', 'groups') || []
      puts "Found #{groups.size} groups"
      total_conversations += groups.size

      groups.each_with_index do |group, index|
        group_id = safe_get(group, 'id')
        group_name = safe_get(group, 'name')

        print "  Processing group #{index + 1}/#{groups.size}: #{group_name}"

        # 注意: APIレート制限（24時間で500回まで）のため、大量のデータがある場合は制限に達する可能性があります
        # レート制限を回避するため、各グループ処理間に最小限の待機時間を設けています

        # Get unread count
        unread_count = 0
        begin
          unread_response = client.group_unread(group_id)
          unread_count = unread_response.dig('data', 'unread_count') || 0
        rescue Talknote::Error
          # Ignore unread count errors
        end

        begin
          messages_response = client.group_list(group_id)
          messages = messages_response.dig('data', 'msg') || []
          total_messages += messages.size

          messages.each do |message|
            csv << [
              group_id,
              group_name,
              safe_get(message, 'id'),
              '', # sender_id - not available in API response
              '', # sender_name - not available in API response
              safe_get(message, 'message'),
              '', # created_at - not available in API response
              'text', # type - default to 'text'
              unread_count
            ]
          end

          puts " (#{messages.size} messages, #{unread_count} unread)"

        rescue Talknote::Error => e
          puts " ❌ Error: #{e.message}"
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

        # レート制限対策: APIの24時間500回制限を考慮し、各グループ処理後に最小限の待機時間を設ける
        sleep(0.1)
      end

    rescue Talknote::Error => e
      puts "❌ Group API Error: #{e.message}"
    end
  end

  # Create summary file
  summary_filename = File.join(output_dir, "export_summary.txt")
  File.write(summary_filename, <<~SUMMARY)
    Talknote Export Summary
    =======================
    Export Date: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}

    Files Created:
    - dm_conversations.csv (Direct Messages)
    - group_conversations.csv (Group Messages)
    - export_summary.txt (This file)

    Statistics:
    - Total Conversations: #{total_conversations}
    - Total Messages Exported: #{total_messages}

    CSV Format:

    DM Conversations:
    - conversation_id: Unique identifier for the DM conversation
    - conversation_name: Name of the conversation
    - message_id: Unique identifier for the message
    - sender_id: ID of the message sender
    - sender_name: Name of the message sender
    - message: The message content
    - created_at: Timestamp when the message was created
    - message_type: Type of message (text, image, etc.)

    Group Conversations:
    - group_id: Unique identifier for the group
    - group_name: Name of the group
    - message_id: Unique identifier for the message
    - sender_id: ID of the message sender
    - sender_name: Name of the message sender
    - message: The message content
    - created_at: Timestamp when the message was created
    - message_type: Type of message (text, image, etc.)
    - unread_count: Number of unread messages in the group
  SUMMARY

  puts
  puts "🎉 Complete export finished!"
  puts "📊 Total conversations: #{total_conversations}"
  puts "📊 Total messages exported: #{total_messages}"
  puts "📁 Files saved in directory: #{output_dir}"
  puts
  puts "Files created:"
  puts "  - #{dm_filename}"
  puts "  - #{group_filename}"
  puts "  - #{summary_filename}"

rescue StandardError => e
  puts "💥 Unexpected error: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  exit 1
end

if __FILE__ == $0
  # Allow custom output directory as command line argument
  output_dir = ARGV[0] || "talknote_export_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
  export_all_to_csv(output_dir)
end
