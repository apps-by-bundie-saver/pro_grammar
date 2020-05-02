# frozen_string_literal: true

class ProGrammar
  # @api private
  # @since v0.13.0
  module ControlDHandler
    # Deal with the ^D key being pressed. Different behaviour in different
    # cases:
    #   1. In an expression behave like `!` command.
    #   2. At top-level session behave like `exit` command.
    #   3. In a nested session behave like `cd ..`.
    def self.default(pro_grammar_instance)
      if !pro_grammar_instance.eval_string.empty?
        # Clear input buffer.
        pro_grammar_instance.eval_string = ''
      elsif pro_grammar_instance.binding_stack.one?
        pro_grammar_instance.binding_stack.clear
        throw(:breakout)
      else
        # Otherwise, saves current binding stack as old stack and pops last
        # binding out of binding stack (the old stack still has that binding).
        cd_state = ProGrammar::CommandState.default.state_for('cd')
        cd_state.old_stack = pro_grammar_instance.binding_stack.dup
        pro_grammar_instance.binding_stack.pop
      end
    end
  end
end
