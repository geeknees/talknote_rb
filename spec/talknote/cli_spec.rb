RSpec.describe Talknote::CLI do
  describe '#exit_on_failure?' do
    it { expect(Talknote::CLI.exit_on_failure?).to be true }
  end
end
