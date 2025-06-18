[![Gem Version](https://badge.fury.io/rb/talknote_rb.svg)](https://badge.fury.io/rb/talknote_rb)
[![CI](https://github.com/geeknees/talknote_rb/actions/workflows/main.yml/badge.svg)](https://github.com/geeknees/talknote_rb/actions/workflows/main.yml)
[![codecov](https://codecov.io/gh/geeknees/talknote_rb/branch/main/graph/badge.svg?token=7RC22M1SBP)](https://codecov.io/gh/geeknees/talknote_rb)
[![Maintainability](https://api.codeclimate.com/v1/badges/88fc1b8704b06c013b7b/maintainability)](https://codeclimate.com/github/geeknees/talknote_rb/maintainability)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/geeknees/talknote_rb)
![GitHub](https://img.shields.io/github/license/geeknees/talknote_rb)

# TalknoteRb

A Ruby client library for the Talknote API. This gem provides a simple interface to interact with Talknote's REST API, allowing you to access direct messages, groups, and other Talknote features programmatically.

## Features

- 🔐 OAuth 2.0 authentication flow
- 💬 Direct message management
- 👥 Group conversation access
- 📊 Unread message tracking
- 🖥️ Command-line interface
- 💎 Simple Ruby API client

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'talknote_rb'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install talknote_rb

## Quick Start

1. Get your client credentials from the [Talknote Developer Console](https://developer.talknote.com/doc/#intro)
2. Run the authentication setup:
   ```sh
   bundle exec talknote init -i your_client_id -s your_client_secret
   ```
3. Start using the API:
   ```sh
   bundle exec talknote dm
   ```

## Usage

### Authentication

Before using the API, you need to set up authentication. First, obtain your client credentials from the [Talknote Developer Console](https://developer.talknote.com/doc/#intro).

To initialize and authenticate, run:

```sh
bundle exec talknote init -i your_client_id -s your_client_secret
```

This command will:
1. Open your browser to the Talknote OAuth authorization page
2. Start a local server to handle the OAuth callback
3. Save your access token to `~/.config/talknote/token.json`

You can also specify custom host and port for the OAuth callback:

```sh
bundle exec talknote init -i your_client_id -s your_client_secret -h localhost -p 8080
```

### CLI Commands

#### Direct Message Commands

```sh
# View all DM conversations
bundle exec talknote dm

# View messages from a specific DM conversation
bundle exec talknote dm-list CONVERSATION_ID

# Check unread count for a DM conversation
bundle exec talknote dm-unread CONVERSATION_ID

# Send a message to a DM conversation
bundle exec talknote dm-post CONVERSATION_ID "Your message here"

# Create a new DM conversation (optionally with an initial message)
bundle exec talknote dm-create USER_ID
bundle exec talknote dm-create USER_ID "Initial message"

# Mark DM conversation as read
bundle exec talknote dm-mark-read CONVERSATION_ID
bundle exec talknote dm-mark-read CONVERSATION_ID MESSAGE_ID

# Search DM conversations
bundle exec talknote dm-search "search query"

# View members of a DM conversation
bundle exec talknote dm-members CONVERSATION_ID

# Leave a DM conversation
bundle exec talknote dm-leave CONVERSATION_ID
```

### Ruby Client Usage

You can also use the client directly in your Ruby code:

```ruby
require 'talknote_rb'

# Initialize client (requires authentication token to be set up)
client = Talknote::Client.new

# Get direct message conversations
dm_conversations = client.dm
puts "DM Conversations: #{dm_conversations}"

# Get messages from a specific DM conversation
conversation_id = dm_conversations.dig('data', 'threads')&.first&.fetch('id')
dm_messages = client.dm_list(conversation_id)
puts "Messages: #{dm_messages}"

# Send a message to a DM conversation (WORKING)
client.dm_post(conversation_id, "Hello from Ruby!")

# Get conversation members (WORKING)
members = client.dm_members(conversation_id)
puts "Members: #{members}"

# Search DM conversations (WORKING - client-side search)
search_results = client.dm_search("important")
puts "Search results: #{search_results}"

# Get unread messages count for a DM conversation
unread_count = client.dm_unread(conversation_id)
puts "Unread messages: #{unread_count}"

# Note: The following methods have limitations:
# - dm_create: Requires specific user ID format
# - dm_mark_read: Not supported by API
# - dm_leave: Not applicable to DMs

# Group operations
group_id = 'your_group_id'
group_messages = client.group_list(group_id)
puts "Group messages: #{group_messages}"

group_unread = client.group_unread(group_id)
puts "Group unread count: #{group_unread}"
```

### Error Handling

```ruby
require 'talknote_rb'

begin
  client = Talknote::Client.new
  dm_conversations = client.dm
  puts dm_conversations
rescue JSON::ParserError => e
  puts "Error parsing API response: #{e.message}"
rescue Errno::ENOENT => e
  puts "Authentication token not found. Please run 'talknote init' first."
rescue => e
  puts "An error occurred: #{e.message}"
end
```

### Available API Methods

The client provides the following methods:

#### Direct Message Methods
- `dm` - Get list of direct message conversations
- `dm_list(id)` - Get messages from a specific DM conversation
- `dm_unread(id)` - Get unread message count for a DM conversation
- `dm_post(id, message, options = {})` - Send a message to a DM conversation ✅ **Working**
- `dm_create(user_id, message = nil)` - Create a new DM conversation (requires specific user ID format)
- `dm_mark_read(id, message_id = nil)` - Mark DM conversation as read (not supported by API)
- `dm_search(query, options = {})` - Search DM conversations ✅ **Working** (client-side search)
- `dm_members(id)` - Get members of a DM conversation ✅ **Working**
- `dm_leave(id)` - Leave a DM conversation (not supported for DMs)

#### Group Methods
- `group_list(id)` - Get messages from a specific group
- `group_unread(id)` - Get unread message count for a group

### OAuth Scopes

The gem requests the following OAuth scopes by default:

- `talknote.timeline.read` / `talknote.timeline.write`
- `talknote.timeline.message.read` / `talknote.timeline.message.write`
- `talknote.timeline.unread`
- `talknote.group` / `talknote.group.read` / `talknote.group.write`
- `talknote.group.unread`
- `talknote.group.message.read` / `talknote.group.message.write`
- `talknote.direct_message` / `talknote.direct_message.read` / `talknote.direct_message.write`
- `talknote.direct_message.unread`
- `talknote.direct_message.message.read` / `talknote.direct_message.message.write`
- `talknote.user.read` / `talknote.user.write`
- `talknote.allfeed.read` / `talknote.allfeed.unread`

### Configuration

The access token is automatically saved to `~/.config/talknote/token.json` after successful authentication. Make sure this file is kept secure and not committed to version control.

For more information about the Talknote API, visit the [official documentation](https://developer.talknote.com/doc/#top).

## Troubleshooting

### Authentication Issues

If you encounter authentication problems:

1. **Invalid client credentials**: Verify your client ID and secret from the Talknote Developer Console
2. **Token expired**: Re-run the `init` command to refresh your access token
3. **Callback URL issues**: Make sure your OAuth callback URL in the Developer Console matches the host and port you're using (default: `http://127.0.0.1:3000/oauth/callback`)

### Common Errors

- **File not found error**: Make sure you've run `talknote init` first to set up authentication
- **Network errors**: Check your internet connection and Talknote service status
- **Permission errors**: Ensure your access token has the required scopes for the operations you're trying to perform

### Configuration File Location

The authentication token is stored at:
```
~/.config/talknote/token.json
```

If you need to reset your authentication, simply delete this file and run `talknote init` again.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/geeknees/talknote_rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/talknote_rb/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TalknoteRb project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/talknote_rb/blob/master/CODE_OF_CONDUCT.md).
