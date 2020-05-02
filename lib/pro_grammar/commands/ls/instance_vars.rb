# frozen_string_literal: true

class ProGrammar
  class Command
    class Ls < ProGrammar::ClassCommand
      class InstanceVars < ProGrammar::Command::Ls::Formatter
        include ProGrammar::Command::Ls::Interrogatable

        def initialize(interrogatee, no_user_opts, opts, pro_grammar_instance)
          super(pro_grammar_instance)
          @interrogatee = interrogatee
          @no_user_opts = no_user_opts
          @default_switch = opts[:ivars]
        end

        def correct_opts?
          super || @no_user_opts
        end

        def output_self
          ivars = if Object === @interrogatee # rubocop:disable Style/CaseEquality
                    ProGrammar::Method.safe_send(@interrogatee, :instance_variables)
                  else
                    [] # TODO: BasicObject support
                  end
          kvars = ProGrammar::Method.safe_send(interrogatee_mod, :class_variables)
          ivars_out = output_section('instance variables', format(:instance_var, ivars))
          kvars_out = output_section('class variables', format(:class_var, kvars))
          ivars_out + kvars_out
        end

        private

        def format(type, vars)
          vars.sort_by { |var| var.to_s.downcase }.map { |var| color(type, var) }
        end
      end
    end
  end
end
