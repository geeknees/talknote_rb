[![Gem Version](https://badge.fury.io/rb/talknote_rb.svg)](https://badge.fury.io/rb/talknote_rb)
[![CI](https://github.com/geeknees/talknote_rb/actions/workflows/main.yml/badge.svg)](https://github.com/geeknees/talknote_rb/actions/workflows/main.yml)
[![codecov](https://codecov.io/gh/geeknees/talknote_rb/branch/main/graph/badge.svg?token=7RC22M1SBP)](https://codecov.io/gh/geeknees/talknote_rb)
[![Maintainability](https://api.codeclimate.com/v1/badges/88fc1b8704b06c013b7b/maintainability)](https://codeclimate.com/github/geeknees/talknote_rb/maintainability)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/geeknees/talknote_rb)
![GitHub](https://img.shields.io/github/license/geeknees/talknote_rb)

# TalknoteRb

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/talknote_rb`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'talknote_rb'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install talknote_rb

## Usage

### Get code to use API

See doc.
https://developer.talknote.com/doc/#intro

To set it up, run the following command, then the access_token will be saved in `~/.config/talknote/token.json`.

```sh
bundle exec talknote init -i client_id -s client_secret
```

Then, Execute various commands.

```sh
bundle exec talknote dm
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/geeknees/talknote_rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/talknote_rb/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TalknoteRb project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/talknote_rb/blob/master/CODE_OF_CONDUCT.md).
