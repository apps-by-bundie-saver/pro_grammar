# frozen_string_literal: true

# (C) John Mair (banisterfiend) 2016
# MIT License

require 'pro_grammar/version'
require 'pro_grammar/last_exception'
require 'pro_grammar/forwardable'

require 'pro_grammar/helpers/base_helpers'
require 'pro_grammar/helpers/documentation_helpers'
require 'pro_grammar/helpers'

require 'pro_grammar/basic_object'
require 'pro_grammar/prompt'
require 'pro_grammar/plugins'
require 'pro_grammar/code_object'
require 'pro_grammar/exceptions'
require 'pro_grammar/hooks'
require 'pro_grammar/input_completer'
require 'pro_grammar/command'
require 'pro_grammar/class_command'
require 'pro_grammar/block_command'
require 'pro_grammar/command_set'
require 'pro_grammar/syntax_highlighter'
require 'pro_grammar/editor'
require 'pro_grammar/history'
require 'pro_grammar/color_printer'
require 'pro_grammar/exception_handler'
require 'pro_grammar/system_command_handler'
require 'pro_grammar/control_d_handler'
require 'pro_grammar/command_state'
require 'pro_grammar/warning'
require 'pro_grammar/env'
require 'pro_grammar/engine'
require 'pro_grammar/display'
require 'pro_grammar/note'
require 'pro_grammar/evaluation'

ProGrammar::Commands = ProGrammar::CommandSet.new unless defined?(ProGrammar::Commands)

require 'pro_grammar/evaluation/conditional'
require 'pro_grammar/evaluation/var'

require 'pro_grammar/commands/ls/jruby_hacks'
require 'pro_grammar/commands/ls/methods_helper'
require 'pro_grammar/commands/ls/interrogatable'
require 'pro_grammar/commands/ls/grep'
require 'pro_grammar/commands/ls/formatter'
require 'pro_grammar/commands/ls/globals'
require 'pro_grammar/commands/ls/constants'
require 'pro_grammar/commands/ls/methods'
require 'pro_grammar/commands/ls/self_methods'
require 'pro_grammar/commands/ls/instance_vars'
require 'pro_grammar/commands/ls/local_names'
require 'pro_grammar/commands/ls/local_vars'
require 'pro_grammar/commands/ls/interrogatable'
require 'pro_grammar/commands/ls/ls_entity'
require 'pro_grammar/commands/ls/methods_helper'
require 'pro_grammar/commands/ls'

require 'pro_grammar/config/attributable'
require 'pro_grammar/config/value'
require 'pro_grammar/config/memoized_value'
require 'pro_grammar/config/lazy_value'
require 'pro_grammar/config'

require 'pro_grammar/pro_grammar_class'
require 'pro_grammar/pro_grammar_instance'
require 'pro_grammar/inspector'
require 'pro_grammar/pager'
require 'pro_grammar/indent'
require 'pro_grammar/object_path'
require 'pro_grammar/output'
require 'pro_grammar/input_lock'
require 'pro_grammar/repl'
require 'pro_grammar/code'
require 'pro_grammar/ring'
require 'pro_grammar/method'

require 'pro_grammar/wrapped_module'
require 'pro_grammar/wrapped_module/candidate'

require 'pro_grammar/slop'
require 'pro_grammar/cli'
require 'pro_grammar/core_extensions'
require 'pro_grammar/repl_file_loader'

require 'pro_grammar/code/loc'
require 'pro_grammar/code/code_range'
require 'pro_grammar/code/code_file'

require 'pro_grammar/method/weird_method_locator'
require 'pro_grammar/method/disowned'
require 'pro_grammar/method/patcher'

require 'pro_grammar/commands/amend_line'
require 'pro_grammar/commands/bang'
require 'pro_grammar/commands/bang_pro_grammar'

require 'pro_grammar/commands/cat'
require 'pro_grammar/commands/cat/abstract_formatter.rb'
require 'pro_grammar/commands/cat/input_expression_formatter.rb'
require 'pro_grammar/commands/cat/exception_formatter.rb'
require 'pro_grammar/commands/cat/file_formatter.rb'

require 'pro_grammar/commands/cd'
require 'pro_grammar/commands/change_inspector'
require 'pro_grammar/commands/change_prompt'
require 'pro_grammar/commands/clear_screen'
require 'pro_grammar/commands/code_collector'
require 'pro_grammar/commands/disable_pro_grammar'
require 'pro_grammar/commands/easter_eggs'

require 'pro_grammar/commands/edit'
require 'pro_grammar/commands/edit/exception_patcher'
require 'pro_grammar/commands/edit/file_and_line_locator'

require 'pro_grammar/commands/exit'
require 'pro_grammar/commands/exit_all'
require 'pro_grammar/commands/exit_program'
require 'pro_grammar/commands/find_method'
require 'pro_grammar/commands/fix_indent'
require 'pro_grammar/commands/help'
require 'pro_grammar/commands/hist'
require 'pro_grammar/commands/import_set'
require 'pro_grammar/commands/jump_to'
require 'pro_grammar/commands/list_inspectors'

require 'pro_grammar/commands/nesting'
require 'pro_grammar/commands/play'
require 'pro_grammar/commands/pro_grammar_backtrace'
require 'pro_grammar/commands/pro_grammar_version'
require 'pro_grammar/commands/raise_up'
require 'pro_grammar/commands/reload_code'
require 'pro_grammar/commands/reset'
require 'pro_grammar/commands/ri'
require 'pro_grammar/commands/save_file'
require 'pro_grammar/commands/shell_command'
require 'pro_grammar/commands/shell_mode'
require 'pro_grammar/commands/show_info'
require 'pro_grammar/commands/show_doc'
require 'pro_grammar/commands/show_input'
require 'pro_grammar/commands/show_source'
require 'pro_grammar/commands/stat'
require 'pro_grammar/commands/switch_to'
require 'pro_grammar/commands/toggle_color'

require 'pro_grammar/commands/watch_expression'
require 'pro_grammar/commands/watch_expression/expression.rb'

require 'pro_grammar/commands/whereami'
require 'pro_grammar/commands/wtf'

require_relative 'pro_grammar/strings/ansi'

require File.expand_path('pro_grammar/colorize/class_methods', File.dirname(__FILE__))
require File.expand_path('pro_grammar/colorize/instance_methods', File.dirname(__FILE__))

class String
  extend Colorize::ClassMethods
  include Colorize::InstanceMethods

  color_methods
  modes_methods
end

class ColorizedString < String
  extend Colorize::ClassMethods
  include Colorize::InstanceMethods

  color_methods
  modes_methods

  #
  # Shortcut to create ColorizedString with ColorizedString['test'].
  #
  def self.[](string)
    ColorizedString.new(string)
  end
end



