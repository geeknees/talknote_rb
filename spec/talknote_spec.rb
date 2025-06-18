# frozen_string_literal: true

RSpec.describe Talknote do
  it 'has a version number' do
    expect(Talknote::VERSION).not_to be nil
  end

  describe '.hello' do
    it 'outputs hello message' do
      expect { Talknote.hello }.to output("\"hello\"\n").to_stdout
    end
  end
end
