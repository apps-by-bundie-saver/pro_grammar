# frozen_string_literal: true

require 'stringio'

class ProGrammar
  module Testable
    class ProGrammarTester
      extend ProGrammar::Forwardable
      attr_reader :pro_grammar, :out
      def_delegators :@pro_grammar, :eval_string, :eval_string=

      def initialize(target = TOPLEVEL_BINDING, options = {})
        @pro_grammar = ProGrammar.new(options.merge(target: target))
        @history = options[:history]
        @pro_grammar.inject_sticky_locals!
        reset_output
      end

      def eval(*strs)
        reset_output
        result = nil

        strs.flatten.each do |str|
          # Check for space prefix. See #1369.
          str = "#{str.strip}\n" if str !~ /^\s\S/
          @history.push str if @history

          result =
            if @pro_grammar.process_command(str)
              last_command_result_or_output
            else
              # Check if this is a multiline paste.
              begin
                complete_expr = ProGrammar::Code.complete_expression?(str)
              rescue SyntaxError => exception
                @pro_grammar.output.puts(
                  "SyntaxError: #{exception.message.sub(/.*syntax error, */m, '')}"
                )
              end
              @pro_grammar.evaluate_ruby(str) if complete_expr
            end
        end

        result
      end

      def push(*lines)
        Array(lines).flatten.each do |line|
          @pro_grammar.eval(line)
        end
      end

      def push_binding(context)
        @pro_grammar.push_binding context
      end

      def last_output
        @out.string if @out
      end

      def process_command(command_str)
        @pro_grammar.process_command(command_str) || raise("Not a valid command")
        last_command_result_or_output
      end

      def last_command_result
        result = ProGrammar.current[:pro_grammar_cmd_result]
        result.retval if result
      end

      protected

      def last_command_result_or_output
        result = last_command_result
        if result != ProGrammar::Command::VOID_VALUE
          result
        else
          last_output
        end
      end

      def reset_output
        @out = StringIO.new
        @pro_grammar.output = @out
      end
    end
  end
end
