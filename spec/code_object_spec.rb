# frozen_string_literal: true

RSpec.describe ProGrammar::CodeObject do
  let(:pro_grammar) do
    ProGrammar.new.tap { |p| p.binding_stack = [binding] }
  end

  describe ".lookup" do
    context "when looking up method" do
      let(:pro_grammar) do
        obj = Class.new.new
        def obj.foo_method; end

        ProGrammar.new.tap { |p| p.binding_stack = [binding] }
      end

      it "finds methods defined on objects" do
        code_object = described_class.lookup('obj.foo_method', pro_grammar)
        expect(code_object).to be_a(ProGrammar::Method)
        expect(code_object.name).to eq('foo_method')
      end
    end

    context "when looking up modules" do
      module FindMeModule; end

      after { Object.remove_const(:FindMeModule) }

      it "finds modules" do
        code_object = described_class.lookup('FindMeModule', pro_grammar)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
      end
    end

    context "when looking up classes" do
      class FindMeClass; end

      after { Object.remove_const(:FindMeClass) }

      it "finds classes" do
        code_object = described_class.lookup('FindMeClass', pro_grammar)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
      end
    end

    context "when looking up procs" do
      let(:test_proc) { proc { :hello } }

      it "finds classes" do
        code_object = described_class.lookup('test_proc', pro_grammar)
        expect(code_object).to be_a(ProGrammar::Method)
        expect(code_object.wrapped.call).to eql(test_proc)
      end
    end

    context "when looking up ProGrammar::BlockCommand" do
      let(:pro_grammar) do
        pro_grammar = ProGrammar.new
        pro_grammar.commands.command('test-block-command') {}
        pro_grammar.binding_stack = [binding]
        pro_grammar
      end

      it "finds ProGrammar:BlockCommand" do
        code_object = described_class.lookup('test-block-command', pro_grammar)
        expect(code_object.command_name).to eq('test-block-command')
      end
    end

    context "when looking up ProGrammar::ClassCommand" do
      class TestClassCommand < ProGrammar::ClassCommand
        match 'test-class-command'
      end

      let(:pro_grammar) do
        pro_grammar = ProGrammar.new
        pro_grammar.commands.add_command(TestClassCommand)
        pro_grammar.binding_stack = [binding]
        pro_grammar
      end

      after { Object.remove_const(:TestClassCommand) }

      it "finds ProGrammar:BlockCommand" do
        code_object = described_class.lookup('test-class-command', pro_grammar)
        expect(code_object.command_name).to eq('test-class-command')
      end
    end

    context "when looking up ProGrammar commands by class" do
      class TestCommand < ProGrammar::ClassCommand
        match 'test-command'
      end

      let(:pro_grammar) do
        pro_grammar = ProGrammar.new
        pro_grammar.commands.add_command(TestCommand)
        pro_grammar.binding_stack = [binding]
        pro_grammar
      end

      after { Object.remove_const(:TestCommand) }

      it "finds ProGrammar::WrappedModule" do
        code_object = described_class.lookup('TestCommand', pro_grammar)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
      end
    end

    context "when looking up ProGrammar commands by listing" do
      let(:pro_grammar) do
        pro_grammar = ProGrammar.new
        pro_grammar.commands.command('test-command', listing: 'test-listing') {}
        pro_grammar.binding_stack = [binding]
        pro_grammar
      end

      it "finds ProGrammar::WrappedModule" do
        code_object = described_class.lookup('test-listing', pro_grammar)
        expect(code_object.command_name).to eq('test-listing')
      end
    end

    context "when looking up 'nil'" do
      it "returns nil" do
        pro_grammar = ProGrammar.new
        pro_grammar.binding_stack = [binding]

        code_object = described_class.lookup(nil, pro_grammar)
        expect(code_object).to be_nil
      end
    end

    context "when looking up 'nil' while being inside a module" do
      let(:pro_grammar) do
        ProGrammar.new.tap { |p| p.binding_stack = [ProGrammar.binding_for(Module)] }
      end

      it "infers the module" do
        code_object = described_class.lookup(nil, pro_grammar)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
      end
    end

    context "when looking up empty string while being inside a module" do
      let(:pro_grammar) do
        ProGrammar.new.tap { |p| p.binding_stack = [ProGrammar.binding_for(Module)] }
      end

      it "infers the module" do
        code_object = described_class.lookup('', pro_grammar)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
      end
    end

    context "when looking up 'nil' while being inside a class instance" do
      let(:pro_grammar) do
        ProGrammar.new.tap { |p| p.binding_stack = [ProGrammar.binding_for(Module.new)] }
      end

      it "infers the module" do
        code_object = described_class.lookup(nil, pro_grammar)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
      end
    end

    context "when looking up empty string while being inside a class instance" do
      let(:pro_grammar) do
        ProGrammar.new.tap { |p| p.binding_stack = [ProGrammar.binding_for(Module.new)] }
      end

      it "infers the module" do
        code_object = described_class.lookup('', pro_grammar)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
      end
    end

    context "when looking up 'nil' while being inside a method" do
      let(:pro_grammar) do
        klass = Class.new do
          def test_binding
            binding
          end
        end

        ProGrammar.new.tap { |p| p.binding_stack = [klass.new.test_binding] }
      end

      it "infers the method" do
        code_object = described_class.lookup(nil, pro_grammar)
        expect(code_object).to be_a(ProGrammar::Method)
      end
    end

    context "when looking up empty string while being inside a method" do
      let(:pro_grammar) do
        klass = Class.new do
          def test_binding
            binding
          end
        end

        ProGrammar.new.tap { |p| p.binding_stack = [klass.new.test_binding] }
      end

      it "infers the method" do
        code_object = described_class.lookup('', pro_grammar)
        expect(code_object).to be_a(ProGrammar::Method)
      end
    end

    context "when looking up instance methods of a class" do
      let(:pro_grammar) do
        instance = Class.new do
          def instance_method; end
        end

        ProGrammar.new.tap { |p| p.binding_stack = [binding] }
      end

      it "finds instance methods" do
        code_object = described_class.lookup('instance#instance_method', pro_grammar)
        expect(code_object).to be_a(ProGrammar::Method)
      end
    end

    context "when looking up instance methods" do
      let(:pro_grammar) do
        instance = Class.new do
          def instance_method; end
        end

        ProGrammar.new.tap { |p| p.binding_stack = [binding] }
      end

      it "finds instance methods via the # notation" do
        code_object = described_class.lookup('instance#instance_method', pro_grammar)
        expect(code_object).to be_a(ProGrammar::Method)
      end

      it "finds instance methods via the . notation" do
        code_object = described_class.lookup('instance.instance_method', pro_grammar)
        expect(code_object).to be_a(ProGrammar::Method)
      end
    end

    context "when looking up anonymous class methods" do
      let(:pro_grammar) do
        klass = Class.new do
          def self.class_method; end
        end

        ProGrammar.new.tap { |p| p.binding_stack = [binding] }
      end

      it "finds instance methods via the # notation" do
        code_object = described_class.lookup('klass.class_method', pro_grammar)
        expect(code_object).to be_a(ProGrammar::Method)
      end
    end

    context "when looking up class methods of a named class" do
      before do
        class TestClass
          def self.class_method; end
        end
      end

      after { Object.remove_const(:TestClass) }

      it "finds instance methods via the # notation" do
        code_object = described_class.lookup('TestClass.class_method', pro_grammar)
        expect(code_object).to be_a(ProGrammar::Method)
      end
    end

    context "when looking up classes by names of variables" do
      let(:pro_grammar) do
        klass = Class.new

        ProGrammar.new.tap { |p| p.binding_stack = [binding] }
      end

      it "finds instance methods via the # notation" do
        code_object = described_class.lookup('klass', pro_grammar)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
      end
    end

    context "when looking up classes with 'super: 0'" do
      let(:pro_grammar) do
        class ParentClass; end
        class ChildClass < ParentClass; end

        ProGrammar.new.tap { |p| p.binding_stack = [binding] }
      end

      after do
        Object.remove_const(:ChildClass)
        Object.remove_const(:ParentClass)
      end

      it "finds the child class" do
        code_object = described_class.lookup('ChildClass', pro_grammar, super: 0)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
        expect(code_object.wrapped).to eq(ChildClass)
      end
    end

    context "when looking up classes with 'super: 1'" do
      let(:pro_grammar) do
        class ParentClass; end
        class ChildClass < ParentClass; end

        ProGrammar.new.tap { |p| p.binding_stack = [binding] }
      end

      after do
        Object.remove_const(:ChildClass)
        Object.remove_const(:ParentClass)
      end

      it "finds the parent class" do
        code_object = described_class.lookup('ChildClass', pro_grammar, super: 1)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
        expect(code_object.wrapped).to eq(ParentClass)
      end
    end

    context "when looking up commands with the super option" do
      let(:pro_grammar) do
        pro_grammar = ProGrammar.new
        pro_grammar.commands.command('test-command') {}
        pro_grammar.binding_stack = [binding]
        pro_grammar
      end

      it "finds the command ignoring the super option" do
        code_object = described_class.lookup('test-command', pro_grammar, super: 1)
        expect(code_object.command_name).to eq('test-command')
      end
    end

    context "when there is a class and a method who is a namesake" do
      let(:pro_grammar) do
        class TestClass
          class InnerTestClass; end
        end
        def TestClass; end

        ProGrammar.new.tap { |p| p.binding_stack = [binding] }
      end

      after { Object.remove_const(:TestClass) }

      it "finds the class before the method" do
        code_object = described_class.lookup('TestClass', pro_grammar)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
      end

      it "finds the method when the look up ends with ()" do
        code_object = described_class.lookup('TestClass()', pro_grammar)
        expect(code_object).to be_a(ProGrammar::Method)
      end

      it "finds the class before the method when it's namespaced" do
        code_object = described_class.lookup('TestClass::InnerTestClass', pro_grammar)
        expect(code_object).to be_a(ProGrammar::WrappedModule)
        expect(code_object.wrapped).to eq(TestClass::InnerTestClass)
      end
    end
  end
end
