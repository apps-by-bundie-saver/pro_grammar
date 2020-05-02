# frozen_string_literal: true

require "readline" unless defined?(Readline)
require "pro_grammar/input_completer"

def completer_test(bind, pro_grammar = nil, assert_flag = true)
  test = proc do |symbol|
    input = pro_grammar || Readline
    input_completer = ProGrammar::InputCompleter.new(input, pro_grammar)
    completions = input_completer.call(symbol[0..-2], target: ProGrammar.binding_for(bind))
    expect(completions.include?(symbol)).to eq(assert_flag)
  end
  proc { |*symbols| symbols.each(&test) }
end

describe ProGrammar::InputCompleter do
  before do
    # The AMQP gem has some classes like this:
    #  pro_grammar(main)> AMQP::Protocol::Test::ContentOk.name
    #  => :content_ok
    module SymbolyName
      def self.name
        :symboly_name
      end
    end

    @before_completer = ProGrammar.config.completer
    ProGrammar.config.completer = ProGrammar::InputCompleter
  end

  after do
    ProGrammar.config.completer = @before_completer
    Object.remove_const :SymbolyName
  end

  it "should not crash if there's a Module that has a symbolic name." do
    skip unless ProGrammar::Helpers::Platform.jruby?
    expect do
      ProGrammar::InputCompleter.new(Readline).call(
        "a.to_s.", target: ProGrammar.binding_for(Object.new)
      )
    end.not_to raise_error
  end

  it 'should take parenthesis and other characters into account for symbols' do
    expect do
      ProGrammar::InputCompleter.new(Readline).call(
        ":class)", target: ProGrammar.binding_for(Object.new)
      )
    end.not_to raise_error
  end

  it 'should complete instance variables' do
    object = Class.new.new

    # set variables in appropriate scope
    object.instance_variable_set(:'@name', 'ProGrammar')
    object.class.send(:class_variable_set, :'@@number', 10)

    # check to see if variables are in scope
    expect(object.instance_variables
      .map(&:to_sym)
      .include?(:'@name')).to eq true

    expect(object.class.class_variables
      .map(&:to_sym)
      .include?(:'@@number')).to eq true

    # Complete instance variables.
    b = ProGrammar.binding_for(object)
    completer_test(b).call('@name', '@name.downcase')

    # Complete class variables.
    b = ProGrammar.binding_for(object.class)
    completer_test(b).call('@@number', '@@number.class')
  end

  it 'should complete for stdlib symbols' do
    o = Object.new
    # Regexp
    completer_test(o).call('/foo/.extend')

    # Array
    completer_test(o).call('[1].push')

    # Hash
    completer_test(o).call('{"a" => "b"}.keys')

    # Proc
    completer_test(o).call('{2}.call')

    # Symbol
    completer_test(o).call(':symbol.to_s')

    # Absolute Constant
    completer_test(o).call('::IndexError')
  end

  it 'should complete for target symbols' do
    o = Object.new

    # Constant
    module Mod
      remove_const :CON if defined? CON
      CON = 'Constant'.freeze
      module Mod2
      end
    end

    completer_test(Mod).call('CON')

    # Constants or Class Methods
    completer_test(o).call('Mod::CON')

    # Symbol
    _foo = :symbol
    completer_test(o).call(':symbol')

    # Variables
    class << o
      attr_accessor :foo
    end
    o.foo = 'bar'
    completer_test(binding).call('o.foo')

    # trailing slash
    expect(ProGrammar::InputCompleter.new(Readline).call('Mod2/', target: ProGrammar.binding_for(Mod))
      .include?('Mod2/')).to eq(true)
  end

  it 'should complete for arbitrary scopes' do
    module Bar
      @barvar = :bar
    end

    module Baz
      remove_const :CON if defined? CON
      @bar = Bar
      @bazvar = :baz
      CON = :constant
    end

    pro_grammar = ProGrammar.new(target: Baz)
    pro_grammar.push_binding(Bar)

    b = ProGrammar.binding_for(Bar)
    completer_test(b, pro_grammar).call("../@bazvar")
    completer_test(b, pro_grammar).call('/CON')
  end

  it 'should complete for stdlib symbols' do
    o = Object.new
    # Regexp
    completer_test(o).call('/foo/.extend')

    # Array
    completer_test(o).call('[1].push')

    # Hash
    completer_test(o).call('{"a" => "b"}.keys')

    # Proc
    completer_test(o).call('{2}.call')

    # Symbol
    completer_test(o).call(':symbol.to_s')

    # Absolute Constant
    completer_test(o).call('::IndexError')
  end

  it 'should complete for target symbols' do
    o = Object.new

    # Constant
    module Mod
      remove_const :CON if defined? CON
      CON = 'Constant'.freeze
      module Mod2
      end
    end

    completer_test(Mod).call('CON')

    # Constants or Class Methods
    completer_test(o).call('Mod::CON')

    # Symbol
    _foo = :symbol
    completer_test(o).call(':symbol')

    # Variables
    class << o
      attr_accessor :foo
    end
    o.foo = 'bar'
    completer_test(binding).call('o.foo')

    # trailing slash
    expect(ProGrammar::InputCompleter.new(Readline).call('Mod2/', target: ProGrammar.binding_for(Mod))
      .include?('Mod2/')).to eq(true)
  end

  it 'should complete for arbitrary scopes' do
    module Bar
      @barvar = :bar
    end

    module Baz
      remove_const :CON if defined? CON
      @bar = Bar
      @bazvar = :baz
      CON = :constant
    end

    pro_grammar = ProGrammar.new(target: Baz)
    pro_grammar.push_binding(Bar)

    b = ProGrammar.binding_for(Bar)
    completer_test(b, pro_grammar).call("../@bazvar")
    completer_test(b, pro_grammar).call('/CON')
  end

  it 'should not return nil in its output' do
    pro_grammar = ProGrammar.new
    expect(ProGrammar::InputCompleter.new(Readline, pro_grammar).call("pro_grammar.", target: binding))
      .not_to include nil
  end

  it 'completes expressions with all available methods' do
    completer_test(self).call("[].size.chars")
  end

  it 'does not offer methods from restricted modules' do
    require 'irb'
    completer_test(self, nil, false).call("[].size.parse_printf_format")
  end

  unless ProGrammar::Helpers::Platform.jruby?
    # Classes that override .hash are still hashable in JRuby, for some reason.
    it 'ignores methods from modules that override Object#hash incompatibly' do
      require 'irb'

      m = Module.new do
        def self.hash; end

        def aaaa; end
      end

      completer_test(m, nil, false).call("[].size.aaaa")
    end
  end
end
