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

#### Authentication
```sh
# Initialize authentication (run this first)
talknote init -i CLIENT_ID -s CLIENT_SECRET

# Optional: specify custom callback host/port
talknote init -i CLIENT_ID -s CLIENT_SECRET -h localhost -p 9000
```

#### Direct Messages
```sh
# List all DM conversations
talknote dm

# Show messages from a specific DM conversation
talknote dm-list DM_ID

# Show unread count for a DM conversation
talknote dm-unread DM_ID

# Send a message to a DM conversation
talknote dm-post DM_ID "Your message here"
```

#### Groups
```sh
# List all groups
talknote group

# Show messages from a specific group
talknote group-list GROUP_ID

# Show unread count for a group
talknote group-unread GROUP_ID

# Send a message to a group
talknote group-post GROUP_ID "Your message here"
```

## Library Usage

### Setup

```ruby
require 'talknote_rb'

# Client will automatically load token from ~/.config/talknote/token.json
client = Talknote::Client.new
```

### Direct Messages

```ruby
# Get all DM conversations
conversations = client.dm

# Get messages from a specific conversation
messages = client.dm_list('conversation_id')

# Send a message
result = client.dm_post('conversation_id', 'Hello!')
```

### Groups

```ruby
# Get all groups
groups = client.group

# Get messages from a specific group
messages = client.group_list('group_id')

# Get unread count
unread_count = client.group_unread('group_id')

# Send a message to a group
result = client.group_post('group_id', 'Hello group!')
```

### Error Handling

```ruby
begin
  result = client.dm
rescue Talknote::Error => e
  puts "API Error: #{e.message}"
end
```

## Configuration

The authentication token is stored in `~/.config/talknote/token.json` after running the `init` command. The file contains the OAuth 2.0 access token and refresh token.

## API Endpoints

This gem supports the following Talknote API endpoints:

### Direct Messages
- `GET /api/v1/dm` - List DM conversations
- `GET /api/v1/dm/list/:id` - Get messages from a conversation
- `GET /api/v1/dm/unread/:id` - Get unread count
- `POST /api/v1/dm/post/:id` - Send a message

### Groups
- `GET /api/v1/group` - List groups
- `GET /api/v1/group/list/:id` - Get messages from a group
- `GET /api/v1/group/unread/:id` - Get unread count
- `POST /api/v1/group/post/:id` - Send a message to group

## Permissions

Make sure your Talknote application has the necessary scopes:

### DM Permissions
- `talknote.direct_message`
- `talknote.direct_message.read`
- `talknote.direct_message.write`
- `talknote.direct_message.unread`
- `talknote.direct_message.message.read`
- `talknote.direct_message.message.write`

### Group Permissions
- `talknote.group`
- `talknote.group.read`
- `talknote.group.write`
- `talknote.group.unread`
- `talknote.group.message.read`
- `talknote.group.message.write`

### Additional Permissions
- `talknote.user.read`
- `talknote.user.write`
- `talknote.timeline.read`
- `talknote.timeline.write`
- `talknote.timeline.message.read`
- `talknote.timeline.message.write`
- `talknote.timeline.unread`
- `talknote.allfeed.read`
- `talknote.allfeed.unread`

## Examples

### Example: Send a daily report to a group

```ruby
require 'talknote_rb'

client = Talknote::Client.new

# Get all groups and find the right one
groups = client.group
group = groups.dig('data', 'groups')&.find { |g| g['name'].include?('Daily Reports') }

if group
  # Send daily report
  report = "📊 Daily Report (#{Date.today})\n\n" \
           "- Tasks completed: 15\n" \
           "- Issues resolved: 3\n" \
           "- New features deployed: 2"

  client.group_post(group['id'], report)
  puts "Daily report sent to #{group['name']}!"
else
  puts "Daily Reports group not found"
end
```

### Example: Monitor unread messages

```ruby
require 'talknote_rb'

client = Talknote::Client.new

# Check unread DMs
dm_conversations = client.dm
dm_conversations.dig('data', 'threads')&.each do |dm|
  unread = client.dm_unread(dm['id'])
  unread_count = unread.dig('data', 'unread_count')

  if unread_count && unread_count > 0
    puts "📩 #{dm['title']}: #{unread_count} unread messages"
  end
end

# Check unread group messages
groups = client.group
groups.dig('data', 'groups')&.each do |group|
  unread = client.group_unread(group['id'])
  unread_count = unread.dig('data', 'unread_count')

  if unread_count && unread_count > 0
    puts "👥 #{group['name']}: #{unread_count} unread messages"
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/geeknees/talknote_rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/geeknees/talknote_rb/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TalknoteRb project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/geeknees/talknote_rb/blob/main/CODE_OF_CONDUCT.md).
