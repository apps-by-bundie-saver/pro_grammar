# frozen_string_literal: true

describe ProGrammar do
  describe 'loading rc files' do
    before do
      ProGrammar.config.rc_file = 'spec/fixtures/testrc'
      stub_const('ProGrammar::LOCAL_RC_FILE', 'spec/fixtures/testrc/../testrc')

      ProGrammar.instance_variable_set(:@initial_session, true)
      ProGrammar.config.should_load_rc = true
      ProGrammar.config.should_load_local_rc = true
    end

    after do
      ProGrammar.config.should_load_rc = false
      Object.remove_const(:TEST_RC) if defined?(TEST_RC)
    end

    it "should never run the rc file twice" do
      ProGrammar.start(self, input: StringIO.new("exit-all\n"), output: StringIO.new)
      expect(TEST_RC).to eq [0]

      ProGrammar.start(self, input: StringIO.new("exit-all\n"), output: StringIO.new)
      expect(TEST_RC).to eq [0]
    end

    # Resolving symlinks doesn't work on jruby 1.9 [jruby issue #538]
    unless ProGrammar::Helpers::Platform.jruby_19?
      it "should not load the rc file twice if it's symlinked differently" do
        ProGrammar.config.rc_file = 'spec/fixtures/testrc'
        stub_const('ProGrammar::LOCAL_RC_FILE', 'spec/fixtures/testlinkrc')

        ProGrammar.start(self, input: StringIO.new("exit-all\n"), output: StringIO.new)

        expect(TEST_RC).to eq [0]
      end
    end

    it "should not load the pro_grammarrc if pro_grammarrc's directory permissions do not allow this" do
      Dir.mktmpdir do |dir|
        File.chmod 0o000, dir
        stub_const('ProGrammar::LOCAL_RC_FILE', File.join(dir, '.pro_grammarrc'))
        ProGrammar.config.should_load_rc = true
        expect do
          ProGrammar.start(self, input: StringIO.new("exit-all\n"), output: StringIO.new)
        end.to_not raise_error
        File.chmod 0o777, dir
      end
    end

    it "should not load the pro_grammarrc if it cannot expand ENV[HOME]" do
      old_home = ENV['HOME']
      ENV['HOME'] = nil
      ProGrammar.config.should_load_rc = true
      expect do
        ProGrammar.start(self, input: StringIO.new("exit-all\n"), output: StringIO.new)
      end.to_not raise_error

      ENV['HOME'] = old_home
    end

    it "should not run the rc file at all if ProGrammar.config.should_load_rc is false" do
      ProGrammar.config.should_load_rc = false
      ProGrammar.config.should_load_local_rc = false
      ProGrammar.start(self, input: StringIO.new("exit-all\n"), output: StringIO.new)
      expect(Object.const_defined?(:TEST_RC)).to eq false
    end

    describe "that raise exceptions" do
      before do
        ProGrammar.config.rc_file = 'spec/fixtures/testrcbad'
        ProGrammar.config.should_load_local_rc = false

        putsed = nil

        # YUCK! horrible hack to get round the fact that output is not configured
        # at the point this message is printed.
        (class << ProGrammar; self; end).send(:define_method, :puts) do |str|
          putsed = str
        end

        @doing_it = lambda {
          input = StringIO.new("Object::TEST_AFTER_RAISE=1\nexit-all\n")
          ProGrammar.start(self, input: input, output: StringIO.new)
          putsed
        }
      end

      after do
        Object.remove_const(:TEST_BEFORE_RAISE)
        Object.remove_const(:TEST_AFTER_RAISE)
        (class << ProGrammar; undef_method :puts; end)
      end

      it "should not raise exceptions" do
        expect(&@doing_it).to_not raise_error
      end

      it "should continue to run pro_grammar" do
        @doing_it[]
        expect(Object.const_defined?(:TEST_BEFORE_RAISE)).to eq true
        expect(Object.const_defined?(:TEST_AFTER_RAISE)).to eq true
      end

      it "should output an error" do
        expect(@doing_it.call.split("\n").first).to match(
          %r{Error loading .*spec/fixtures/testrcbad: messin with ya}
        )
      end
    end
  end
end
