# frozen_string_literal: true

describe "ProGrammar.run_command" do
  before do
    o = Object.new
    def o.drum
      "roken is dodelijk"
    end
    @context = ProGrammar.binding_for(o)
  end

  it 'performs a simple ls' do
    @context.eval("hokey_pokey = 10")
    ProGrammar.run_command "ls", context: @context, output: out = StringIO.new
    expect(out.string).to match(/hokey_pokey/)
  end

  # This is a regression test as 0.9.11 broke this behaviour
  it 'can perform a show-source' do
    ProGrammar.run_command "show-source drum", context: @context, output: out = StringIO.new
    expect(out.string).to match(/roken is dodelijk/)
  end
end
