# frozen_string_literal: true

describe "ls" do
  describe "bug #1407" do
    it "behaves as usual when a method of the same name exists." do
      expect(
        pro_grammar_eval("def ls; 5; end", "ls")
      ).to match(/self\.methods: /)
      pro_grammar_eval("undef ls")
    end
  end

  describe "below ceiling" do
    it "should stop before Object by default" do
      expect(pro_grammar_eval("cd Class.new{ def goo; end }.new", "ls")).not_to match(/Object/)
      expect(pro_grammar_eval("cd Class.new{ def goo; end }", "ls -M")).not_to match(/Object/)
    end

    it "should include object if -v is given" do
      expect(pro_grammar_eval("cd Class.new{ def goo; end }.new", "ls -m -v")).to match(/Object/)
      expect(pro_grammar_eval("cd Class.new{ def goo; end }", "ls -vM")).to match(/Object/)
    end

    it "should include super-classes by default" do
      expect(
        pro_grammar_eval(
          "cd Class.new(Class.new{ def goo; end; public :goo }).new",
          "ls"
        )
      ).to match(/goo/)

      expect(
        pro_grammar_eval(
          "cd Class.new(Class.new{ def goo; end; public :goo })",
          "ls -M"
        )
      ).to match(/goo/)
    end

    it "should not include super-classes when -q is given" do
      expect(pro_grammar_eval("cd Class.new(Class.new{ def goo; end }).new", "ls -q"))
        .not_to match(/goo/)
      expect(pro_grammar_eval("cd Class.new(Class.new{ def goo; end })", "ls -M -q"))
        .not_to match(/goo/)
    end
  end

  describe "help" do
    it 'should show help with -h' do
      expect(pro_grammar_eval("ls -h")).to match(/Usage: ls/)
    end
  end

  describe "BasicObject" do
    it "should work on BasicObject" do
      expect(pro_grammar_eval("ls BasicObject.new")).to match(/BasicObject#methods:.*__send__/m)
    end

    it "should work on subclasses of BasicObject" do
      expect(
        pro_grammar_eval(
          "class LessBasic < BasicObject; def jaroussky; 5; end; end",
          "ls LessBasic.new"
        )
      ).to match(/LessBasic#methods:.*jaroussky/m)
    end
  end

  describe "immediates" do
    # Ruby 2.4+
    if 5.class.name == 'Integer'
      it "should work on Integer" do
        expect(pro_grammar_eval("ls 5")).to match(/Integer#methods:.*modulo/m)
      end
    else
      it "should work on Fixnum" do
        expect(pro_grammar_eval("ls 5")).to match(/Fixnum#methods:.*modulo/m)
      end
    end
  end

  describe "methods" do
    it "should show public methods by default" do
      output = pro_grammar_eval("ls Class.new{ def goo; end; public :goo }.new")
      expect(output).to match(/methods: goo/)
    end

    it "should not show protected/private by default" do
      expect(pro_grammar_eval("ls -M Class.new{ def goo; end; private :goo }"))
        .not_to match(/goo/)
      expect(pro_grammar_eval("ls Class.new{ def goo; end; protected :goo }.new"))
        .not_to match(/goo/)
    end

    it "should show public methods with -p" do
      expect(pro_grammar_eval("ls -p Class.new{ def goo; end }.new")).to match(/methods: goo/)
    end

    it "should show protected/private methods with -p" do
      expect(pro_grammar_eval("ls -pM Class.new{ def goo; end; protected :goo }"))
        .to match(/methods: goo/)
      expect(pro_grammar_eval("ls -p Class.new{ def goo; end; private :goo }.new"))
        .to match(/methods: goo/)
    end

    it "should work for objects with an overridden method method" do
      require 'net/http'
      # This doesn't actually touch the network, promise!
      expect(pro_grammar_eval("ls Net::HTTP::Get.new('localhost')"))
        .to match(/Net::HTTPGenericRequest#methods/)
    end

    it(
      "should work for objects which instance_variables returns array of " \
      "symbol but there is no Symbol#downcase"
    ) do
      test_case = "class Object; alias :fg :instance_variables; " \
                  "def instance_variables; fg.map(&:to_sym); end end;"
      normalize = "class Object; def instance_variables; fg; end end;"

      test = lambda do
        begin
          pro_grammar_eval(
            test_case, "class GeFromulate2; @flurb=1.3; end", "cd GeFromulate2", "ls"
          )
          pro_grammar_eval(normalize)
        rescue StandardError
          pro_grammar_eval(normalize)
          raise
        end
      end

      expect(test).to_not raise_error
    end

    it "should show error message when instance is given with -M option" do
      expect { pro_grammar_eval("ls -M String.new") }
        .to raise_error(ProGrammar::CommandError, /-M only makes sense with a Module or a Class/)
    end

    it "should handle classes that (pathologically) define .ancestors" do
      output = pro_grammar_eval("ls Class.new{ def self.ancestors; end; def hihi; end }")
      expect(output).to match(/hihi/)
    end
  end

  describe 'with -l' do
    focus 'should find locals and sort by descending size' do
      result = pro_grammar_eval(Object.new, "aa = 'asdf'; bb = 'xyz'", 'ls -l')
      expect(result).not_to match(/=>/)
      expect(result).not_to match(/0x\d{5}/)
      expect(result).to match(/asdf.*xyz/m)
    end

    it 'should not list pro_grammar noise' do
      expect(pro_grammar_eval('ls -l')).not_to match(/_(?:dir|file|ex|pro_grammar|out|in)_/)
    end
  end

  describe "when inside Modules" do
    it "should still work" do
      expect(
        pro_grammar_eval(
          "cd Module.new{ def foobie; end; public :foobie }",
          "ls -M"
        )
      ).to match(/foobie/)
    end

    it "should work for ivars" do
      expect(
        pro_grammar_eval(
          "module StigmaT1sm; def foobie; @@gharble = 456; end; end",
          "Object.new.tap{ |o| o.extend(StigmaT1sm) }.foobie",
          "cd StigmaT1sm",
          "ls -i"
        )
      ).to match(/@@gharble/)
    end

    it "should include instance methods by default" do
      output = pro_grammar_eval(
        "ls Module.new{ def shinanagarns; 4; end; public :shinanagarns }"
      )
      expect(output).to match(/shinanagarns/)
    end

    it "should behave normally when invoked on Module itself" do
      expect(pro_grammar_eval("ls Module")).not_to match(/ProGrammar/)
    end
  end

  describe "constants" do
    it "works on top-level" do
      toplevel_consts = pro_grammar_eval('ls -c')
      [/RUBY_PLATFORM/, /ARGF/, /STDOUT/].each do |const|
        expect(toplevel_consts).to match(const)
      end
    end

    it "should show constants defined on the current module" do
      expect(pro_grammar_eval("class TempFoo1; BARGHL = 1; end", "ls TempFoo1"))
        .to match(/BARGHL/)
    end

    it "should not show constants defined on parent modules by default" do
      output = pro_grammar_eval(
        "class TempFoo2; LHGRAB = 1; end; " \
        "class TempFoo3 < TempFoo2; BARGHL = 1; end", "ls TempFoo3"
      )
      expect(output).not_to match(/LHGRAB/)
    end

    it "should show constants defined on ancestors with -v" do
      output = pro_grammar_eval(
        "class TempFoo4; LHGRAB = 1; end; " \
        "class TempFoo5 < TempFoo4; BARGHL = 1; end", "ls -v TempFoo5"
      )
      expect(output).to match(/LHGRAB/)
    end

    it "should not autoload constants!" do
      autoload :McflurgleTheThird, "/tmp/this-file-d000esnat-exist.rb"
      expect { pro_grammar_eval("ls -c") }.to_not raise_error
    end

    it "should show constants for an object's class regardless of mixins" do
      expect(
        pro_grammar_eval(
          "cd ProGrammar.new",
          "extend Module.new",
          "ls -c"
        )
      ).to match(/Method/)
    end
  end

  describe "grep" do
    it "should reduce the number of outputted things" do
      expect(pro_grammar_eval("ls -c Object")).to match(/ArgumentError/)
      expect(pro_grammar_eval("ls -c Object --grep Run")).not_to match(/ArgumentError/)
    end

    it "should still output matching things" do
      expect(pro_grammar_eval("ls -c Object --grep Run")).to match(/RuntimeError/)
    end
  end

  describe "when no arguments given" do
    describe "when at the top-level" do
      it "should show local variables" do
        expect(pro_grammar_eval("ls")).to match(/pro_grammar_instance/)
        expect(pro_grammar_eval("arbitrar = 1", "ls")).to match(/arbitrar/)
      end
    end

    describe "when in a class" do
      it "should show constants" do
        output = pro_grammar_eval(
          "class GeFromulate1; FOOTIFICATE=1.3; end", "cd GeFromulate1", "ls"
        )
        expect(output).to match(/FOOTIFICATE/)
      end

      it "should show class variables" do
        output = pro_grammar_eval(
          "class GeFromulate2; @@flurb=1.3; end", "cd GeFromulate2", "ls"
        )
        expect(output).to match(/@@flurb/)
      end

      it "should show methods" do
        output = pro_grammar_eval(
          "class GeFromulate3; def self.mooflight; end ; end",
          "cd GeFromulate3",
          "ls"
        )
        expect(output).to match(/mooflight/)
      end
    end

    describe "when in an object" do
      it "should show methods" do
        expect(pro_grammar_eval("cd Class.new{ def self.fooerise; end; self }", "ls"))
          .to match(/fooerise/)
      end

      it "should show instance variables" do
        expect(pro_grammar_eval("cd Class.new", "@alphooent = 1", "ls")).to match(/@alphooent/)
      end
    end
  end

  describe 'on java objects', skip: !ProGrammar::Helpers::Platform.jruby? do
    it 'should omit java-esque aliases by default' do
      expect(pro_grammar_eval('ls java.lang.Thread.current_thread'))
        .to match(/\bthread_group\b/)
      expect(pro_grammar_eval('ls java.lang.Thread.current_thread'))
        .not_to match(/\bgetThreadGroup\b/)
    end

    it 'should include java-esque aliases if requested' do
      expect(pro_grammar_eval('ls java.lang.Thread.current_thread -J'))
        .to match(/\bthread_group\b/)
      expect(pro_grammar_eval('ls java.lang.Thread.current_thread -J'))
        .to match(/\bgetThreadGroup\b/)
    end
  end
end
