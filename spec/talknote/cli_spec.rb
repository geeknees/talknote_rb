RSpec.describe Talknote::CLI do
  let(:cli) { described_class.new }
  let(:mock_client) { instance_double(Talknote::Client) }

  describe '#exit_on_failure?' do
    it { expect(Talknote::CLI.exit_on_failure?).to be true }
  end

  describe '#dm' do
    it 'calls client.dm and outputs the result' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:dm).and_return({ 'result' => 'success' })
      expect { cli.dm }.to output(/result/).to_stdout
    end

    it 'handles Talknote::Error gracefully' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:dm).and_raise(Talknote::Error, 'API Error')
      expect(cli).to receive(:exit).with(1)
      expect { cli.dm }.to output(/Error: API Error/).to_stdout
    end
  end

  describe '#dm_list' do
    it 'calls client.dm_list with the provided ID' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:dm_list).with('123').and_return({ 'result' => 'success' })
      expect { cli.dm_list('123') }.to output(/result/).to_stdout
    end

    it 'handles Talknote::Error gracefully' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:dm_list).with('123').and_raise(Talknote::Error, 'API Error')
      expect(cli).to receive(:exit).with(1)
      expect { cli.dm_list('123') }.to output(/Error: API Error/).to_stdout
    end
  end

  describe '#dm_unread' do
    it 'calls client.dm_unread with the provided ID' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:dm_unread).with('123').and_return({ 'result' => 'success' })
      expect { cli.dm_unread('123') }.to output(/result/).to_stdout
    end

    it 'handles Talknote::Error gracefully' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:dm_unread).with('123').and_raise(Talknote::Error, 'API Error')
      expect(cli).to receive(:exit).with(1)
      expect { cli.dm_unread('123') }.to output(/Error: API Error/).to_stdout
    end
  end

  describe '#dm_post' do
    it 'calls client.dm_post with the provided ID and message' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:dm_post).with('123', 'Hello').and_return({ 'result' => 'success' })
      expect { cli.dm_post('123', 'Hello') }.to output(/Message sent successfully!/).to_stdout
    end

    it 'handles Talknote::Error gracefully' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:dm_post).with('123', 'Hello').and_raise(Talknote::Error, 'API Error')
      expect(cli).to receive(:exit).with(1)
      expect { cli.dm_post('123', 'Hello') }.to output(/Error: API Error/).to_stdout
    end
  end

  describe '#group' do
    it 'calls client.group and outputs the result' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:group).and_return({ 'result' => 'success' })
      expect { cli.group }.to output(/result/).to_stdout
    end

    it 'handles Talknote::Error gracefully' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:group).and_raise(Talknote::Error, 'API Error')
      expect(cli).to receive(:exit).with(1)
      expect { cli.group }.to output(/Error: API Error/).to_stdout
    end
  end

  describe '#group_list' do
    it 'calls client.group_list with the provided ID' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:group_list).with('123').and_return({ 'result' => 'success' })
      expect { cli.group_list('123') }.to output(/result/).to_stdout
    end

    it 'handles Talknote::Error gracefully' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:group_list).with('123').and_raise(Talknote::Error, 'API Error')
      expect(cli).to receive(:exit).with(1)
      expect { cli.group_list('123') }.to output(/Error: API Error/).to_stdout
    end
  end

  describe '#group_unread' do
    it 'calls client.group_unread with the provided ID' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:group_unread).with('123').and_return({ 'result' => 'success' })
      expect { cli.group_unread('123') }.to output(/result/).to_stdout
    end

    it 'handles Talknote::Error gracefully' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:group_unread).with('123').and_raise(Talknote::Error, 'API Error')
      expect(cli).to receive(:exit).with(1)
      expect { cli.group_unread('123') }.to output(/Error: API Error/).to_stdout
    end
  end

  describe '#group_post' do
    it 'calls client.group_post with the provided ID and message' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:group_post).with('123', 'Hello').and_return({ 'result' => 'success' })
      expect { cli.group_post('123', 'Hello') }.to output(/Message sent successfully!/).to_stdout
    end

    it 'handles Talknote::Error gracefully' do
      expect(Talknote::Client).to receive(:new).and_return(mock_client)
      expect(mock_client).to receive(:group_post).with('123', 'Hello').and_raise(Talknote::Error, 'API Error')
      expect(cli).to receive(:exit).with(1)
      expect { cli.group_post('123', 'Hello') }.to output(/Error: API Error/).to_stdout
    end
  end
end
