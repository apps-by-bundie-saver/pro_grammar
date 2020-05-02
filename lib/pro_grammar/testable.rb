# frozen_string_literal: true

# good idea ???
# if you're testing pro_grammar plugin you should require pro_grammar by yourself, no?
require 'pro_grammar' unless defined?(ProGrammar)

class ProGrammar
  module Testable
    require_relative "testable/pro_grammar_tester"
    require_relative "testable/evalable"
    require_relative "testable/mockable"
    require_relative "testable/variables"
    require_relative "testable/utility"

    #
    # When {ProGrammar::Testable} is included into another module or class,
    # the following modules are also included: {ProGrammar::Testable::Mockable},
    # {ProGrammar::Testable::Evalable}, {ProGrammar::Testable::Variables}, and
    # {ProGrammar::Testable::Utility}.
    #
    # @note
    #   Each of the included modules mentioned above may also be used
    #   standalone or in a pick-and-mix fashion.
    #
    # @param [Module] mod
    #   A class or module.
    #
    # @return [void]
    #
    def self.included(mod)
      mod.module_eval do
        include ProGrammar::Testable::Mockable
        include ProGrammar::Testable::Evalable
        include ProGrammar::Testable::Variables
        include ProGrammar::Testable::Utility
      end
    end

    #
    # Sets various configuration options that make ProGrammar optimal for a test
    # environment, see source code for complete details.
    #
    # @return [void]
    #
    def self.set_testenv_variables
      ProGrammar.config = ProGrammar::Config.new.merge(
        color: false,
        pager: false,
        should_load_rc: false,
        should_load_local_rc: false,
        correct_indent: false,
        collision_warning: false,
        history_save: false,
        history_load: false,
        hooks: ProGrammar::Hooks.new
      )
    end

    #
    # Reset the ProGrammar configuration to their default values.
    #
    # @return [void]
    #
    def self.unset_testenv_variables
      ProGrammar.config = ProGrammar::Config.new
    end
  end
end
