# frozen_string_literal: true

describe "reload_code" do
  describe "reload_current_file" do
    it 'raises an error source code not found' do
      expect do
        eval <<-RUBY, TOPLEVEL_BINDING, 'does_not_exist.rb', 1
          pro_grammar_eval(binding, "reload-code")
        RUBY
      end.to raise_error(ProGrammar::CommandError)
    end

    it 'raises an error when class not found' do
      expect do
        pro_grammar_eval(
          "cd Class.new(Class.new{ def goo; end; public :goo })",
          "reload-code"
        )
      end.to raise_error(ProGrammar::CommandError)
    end

    it 'reloads pro_grammar commmand' do
      expect(pro_grammar_eval("reload-code reload-code")).to match(/reload-code was reloaded!/)
    end

    it 'raises an error when pro_grammar command not found' do
      expect do
        pro_grammar_eval(
          "reload-code not-a-real-command"
        )
      end.to raise_error(ProGrammar::CommandError, /Cannot locate not-a-real-command!/)
    end
  end
end
