# frozen_string_literal: true

describe "disable-pro_grammar" do
  before do
    @t = pro_grammar_tester
  end

  after do
    ENV.delete 'DISABLE_PRY'
  end

  it 'should quit the current session' do
    expect { @t.process_command 'disable-pro_grammar' }.to throw_symbol :breakout
  end

  it "should set DISABLE_PRY" do
    expect(ENV['DISABLE_PRY']).to eq nil
    expect { @t.process_command 'disable-pro_grammar' }.to throw_symbol :breakout
    expect(ENV['DISABLE_PRY']).to eq 'true'
  end
end
