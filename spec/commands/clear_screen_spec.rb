# frozen_string_literal: true

RSpec.describe "clear-screen" do
  before do
    @t = pro_grammar_tester
  end

  it 'calls the "clear" command on non-Windows platforms' do
    expect(ProGrammar::Helpers::Platform).to receive(:windows?)
      .at_least(:once).and_return(false)
    expect(ProGrammar.config.system).to receive(:call)
      .with(an_instance_of(ProGrammar::Output), 'clear', an_instance_of(ProGrammar))
    @t.process_command 'clear-screen'
  end

  it 'calls the "cls" command on Windows' do
    expect(ProGrammar::Helpers::Platform).to receive(:windows?)
      .at_least(:once).and_return(true)
    expect(ProGrammar.config.system).to receive(:call)
      .with(an_instance_of(ProGrammar::Output), 'cls', an_instance_of(ProGrammar))
    @t.process_command 'clear-screen'
  end
end
