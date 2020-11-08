# frozen_string_literal: true

require 'oauth2'
require 'faraday'

require 'talknote/version'
require 'talknote/cli'
require 'talknote/client'

module Talknote
  class Error < StandardError; end
  # Your code goes here...
  def self.hello
    p 'hello'
  end
end
