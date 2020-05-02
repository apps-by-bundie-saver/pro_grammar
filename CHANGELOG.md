### master

### [v0.13.1][v0.13.1] (April 12, 2020)

#### Bug fixes

* Fixed bug where on invalid input only the last syntax error is displayed
  (instead of all of them) ([#2117](https://github.com/pro_grammar/pro_grammar/pull/2117))
* Fixed `ProGrammar::Config` raising `NoMethodError` on undefined option instead of
  returning `nil` (usually invoked via `ProGrammar.config.foo_option` calls)
  ([#2126](https://github.com/pro_grammar/pro_grammar/pull/2126))
* Fixed `help` command not displaying regexp aliases properly
  ([#2120](https://github.com/pro_grammar/pro_grammar/pull/2120))
* Fixed `pro_grammar-backtrace` not working ([#2122](https://github.com/pro_grammar/pro_grammar/pull/2122))

### [v0.13.0][v0.13.0] (March 21, 2020)

#### Features

* Added metadata to the gem (such as changelog URI, source code URI & bug
  tracker URI), so it shows on https://rubygems.org/gems/pro_grammar
  ([#1869](https://github.com/pro_grammar/pro_grammar/pull/1869))
* Added ability to forward ARGV to a ProGrammar session via `--` (or `-`) when
  launching ProGrammar from shell
  ([#1902](https://github.com/pro_grammar/pro_grammar/commit/5cd65d3c0eb053f6edcdf571eea5d0cd990626ed))
* Added `ProGrammar::Config::LazyValue` & `ProGrammar::Config::MemoizedValue`, which allow
  storing callable procs in the config
  ([#2024](https://github.com/pro_grammar/pro_grammar/pull/2024))
* Added the `rc_file` config option that tells ProGrammar the path to `pro_grammarrc`
  ([#2027](https://github.com/pro_grammar/pro_grammar/pull/2027))
* Added the `--code` flag to the `wtf` command, which shows code for each
  backtrace frame ([#2037](https://github.com/pro_grammar/pro_grammar/pull/2037))
* Added the ability to paste method call chains with leading dots
  ([#2060](https://github.com/pro_grammar/pro_grammar/pull/2060))

#### API changes

* `ProGrammar::Prompt` is a class now and it can be instantiated to create new prompts
  on the fly that are not registered with `ProGrammar::Prompt#add`. Learn more about
  its API in the docs ([#1877](https://github.com/pro_grammar/pro_grammar/pull/1877))

#### Deprecations

* Deprecated `ProGrammar.config.exception_whitelist` in favor of
  `ProGrammar.config.unrescued_exceptions`
  ([#1874](https://github.com/pro_grammar/pro_grammar/pull/1874))
* Deprecated `ProGrammar.config.prompt = ProGrammar::Prompt[:simple][:value]` in favor of
  `ProGrammar.config.prompt = ProGrammar::Prompt[:simple]` when setting ProGrammar prompt via
  `pro_grammarrc`. `ProGrammar::Prompt[:simple]` would return an instance of `ProGrammar::Prompt`
  instead of `Hash` ([#1877](https://github.com/pro_grammar/pro_grammar/pull/1877))
* Deprecated setting prompt via an array of two procs:
  ([#1877](https://github.com/pro_grammar/pro_grammar/pull/1877))

  ```ruby
  # Deprecated, emits a warning.
  ProGrammar.config.prompt = [proc {}, proc {}]
  ```

  This will be removed in the next release.
* Deprecated the `show-doc` command. The `show-source -d` is the new recommended
  way of reading docs ([#1934](https://github.com/pro_grammar/pro_grammar/pull/1934))
* Deprecated `ProGrammar::Command#_pro_grammar_`. Use `ProGrammar::Command#pro_grammar_instance` instead
  ([#1989](https://github.com/pro_grammar/pro_grammar/pull/1989))

#### Breaking changes

* Deleted deprecated `ProGrammar::Platform`
  ([#1863](https://github.com/pro_grammar/pro_grammar/pull/1863))
* Deleted deprecated `ProGrammar#{input/output}_array`
  ([#1884](https://github.com/pro_grammar/pro_grammar/pull/1864))
* Deleted deprecated `ProGrammar::Prompt::MAP`
  ([#1866](https://github.com/pro_grammar/pro_grammar/pull/1866))
* Deleted deprecated methods of `ProGrammar::Helpers::BaseHelpers` such as `mac_osx?`,
  `linux?`, `windows?`, `windows_ansi?`, `jruby?`, `jruby_19?`, `mri?`,
  `mri_19?`, `mri_2?` ([#1867](https://github.com/pro_grammar/pro_grammar/pull/1867))
* Deleted deprecated `ProGrammar::Command#text`
  ([#1865](https://github.com/pro_grammar/pro_grammar/pull/1865))
* Deleted deprecated `ProGrammar::Method#all_from_common`
  ([#1868](https://github.com/pro_grammar/pro_grammar/pull/1868))
* Deleted `install-command` ([#1979](https://github.com/pro_grammar/pro_grammar/pull/1979))
* Deleted `ProGrammar::Helpers::BaseHelpers#command_dependencies_met?`
  ([#1979](https://github.com/pro_grammar/pro_grammar/pull/1979))
* Deleted commands: `gem-cd`, `gem-install`, `gem-list`, `gem-open`,
  `gem-readme`, `gem-search`, `gem-stats`
  ([#1981](https://github.com/pro_grammar/pro_grammar/pull/1981))
* Deleted deprecated commands: `edit-method` and `show-command`
  ([#2001](https://github.com/pro_grammar/pro_grammar/pull/2001))
* Deleted `ProGrammar::Command#disabled_commands`
  ([#2001](https://github.com/pro_grammar/pro_grammar/pull/2001))
* Deleted `ProGrammar::BlockCommand#opts` (use `#context` instead)
  ([#2003](https://github.com/pro_grammar/pro_grammar/pull/2003))
* Deleted `ProGrammar.lazy` (use `ProGrammar::Config::LazyValue` instead)
  ([#2024](https://github.com/pro_grammar/pro_grammar/pull/2024))

#### Bug fixes

* Fixed bug where using `ProGrammar.config.prompt_name` can return a
  `ProGrammar::Config::Lazy` instead of expected instance of `String`
  ([#1890](https://github.com/pro_grammar/pro_grammar/commit/c8f23b3464d596c08922dc923c64bb57488e6227))
* Fixed `LoadError` being raised when using auto completions and Bundler
  ([#1896](https://github.com/pro_grammar/pro_grammar/commit/85850f47e074fe01f93e5cb7d561e7c2de7aede9))
* Fixed bug where `ProGrammar.input_ring` doesn't append duplicate elements
  ([#1898](https://github.com/pro_grammar/pro_grammar/pull/1898))
* Fixed Ruby 2.6 warning about `Binding#source_location`
  ([#1904](https://github.com/pro_grammar/pro_grammar/pull/1904))
* Fixed wrong `winsize` when custom `output` is passed to ProGrammar
  ([#2045](https://github.com/pro_grammar/pro_grammar/pull/2045))
* Fixed `XDG_CONFIG_HOME` & `XDG_DATA_HOME` precedence. When these env variables
  are set, ProGrammar no longer uses traditional files like `~/.pro_grammarrc` &
  `~/.pro_grammar_history`. Instead, the env variable paths are loaded first
  ([#2056](https://github.com/pro_grammar/pro_grammar/pull/2056))
* Fixed the `$SAFE will become a normal global variable in Ruby 3.0` warning on
  Ruby 2.7 ([#2107](https://github.com/pro_grammar/pro_grammar/pull/2107))
* Fixed bug when `whereami -c` cannot show beginning of the class, which is on
  the same line as another expression
  ([#2098](https://github.com/pro_grammar/pro_grammar/pull/2098))
* Fixed bug when `Object#owner` is defined, which results into somewhat broken
  method introspection ([#2113](https://github.com/pro_grammar/pro_grammar/pull/2113))
* Fixed bug when indentation leaves parts of input after pressing enter when
  Readline is enabled with mode indicators for vi mode. This was supposed to be
  fixed in v0.12.2 but it regressed
  ([#2114](https://github.com/pro_grammar/pro_grammar/pull/2114))

### [v0.12.2][v0.12.2] (November 12, 2018)

#### Bug fixes

* Restore removed deprecations, which were removed by accident due to a bad
  rebase.

### [v0.12.1][v0.12.1] (November 12, 2018)

#### Bug fixes

* Stopped creating a new hash each time `ProGrammar::Prompt#[]` is invoked
  ([#1855](https://github.com/pro_grammar/pro_grammar/pull/1855))
* Fixed `less` pager not working when it's available
  ([#1861](https://github.com/pro_grammar/pro_grammar/pull/1861))

### [v0.12.0][v0.12.0] (November 5, 2018)

#### Major changes

* Dropped support for Rubinius ([#1785](https://github.com/pro_grammar/pro_grammar/pull/1785))

#### Features

* Added a new command, `clear-screen`, that clears the content of the screen ProGrammar
  is running in regardless of platform (Windows or UNIX-like)
  ([#1723](https://github.com/pro_grammar/pro_grammar/pull/1723))
* Added a new command, `gem-stat`, that prints gem statistics such as gem
  dependencies and downloads ([#1707](https://github.com/pro_grammar/pro_grammar/pull/1707))
* Added support for nested exceptions for the `wtf` command
  ([#1791](https://github.com/pro_grammar/pro_grammar/pull/1791))
* Added support for dynamic prompt names
  ([#1833](https://github.com/pro_grammar/pro_grammar/pull/1833))

  ```rb
  # pro_grammarrc
  ProGrammar.config.prompt_name = ProGrammar.lazy { rand(100) }

  # Session
  [1] 80(main)>
  [2] 87(main)>
  [3] 30(main)>
  ```
* Added support for XDG Base Directory Specification
  ([#1609](https://github.com/pro_grammar/pro_grammar/pull/1609),
  [#1844](https://github.com/pro_grammar/pro_grammar/pull/1844),
  ([#1848](https://github.com/pro_grammar/pro_grammar/pull/1848)))
* Removed the `simple-prompt`. Use `change-prompt simple` instead. The
  `list-prompt` command was removed and embedded as `change-prompt --list`
  ([#1849](https://github.com/pro_grammar/pro_grammar/pull/1849))

#### API changes

* The following methods started accepting the new optional `config` parameter
  ([#1809](https://github.com/pro_grammar/pro_grammar/pull/1809)):
  * `ProGrammar::Helpers.tablify(things, line_length, config = ProGrammar.config)`
  * `ProGrammar::Helpers.tablify_or_one_line(heading, things, config = ProGrammar.config)`
  * `ProGrammar::Helpers.tablify_to_screen_width(things, options, config = ProGrammar.config)`
  * `ProGrammar::Helpers::Table.new(items, args, config = ProGrammar.config)`

  You are expected to pass a session-local `_pro_grammar_.config` instead of the global
  one.

* Added new method `ProGrammar::Config.assign`, for creating a Config non-recursively
  ([#1725](https://github.com/pro_grammar/pro_grammar/issues/1725))
* Added `ProGrammar.lazy`, which is a helper method for values that need to be
  calculated dynamically. Currently, only `config.prompt_name` supports it
  ([#1833](https://github.com/pro_grammar/pro_grammar/pull/1833))
* `ProGrammar::Prompt` responds to `.[]`, `.all` & `.add` now. The `ProGrammar::Prompt.add`
  method must be used for implementing custom prompts. See the API in the
  documentation for the class ([#1846](https://github.com/pro_grammar/pro_grammar/pull/1846))

#### Breaking changes

* Deleted the `ProGrammar::Helpers::Text.bright_default` alias for
  `ProGrammar::Helpers::Text.bold` ([#1795](https://github.com/pro_grammar/pro_grammar/pull/1795))
* `ProGrammar::Helpers.tablify_to_screen_width(things, options, config = ProGrammar.config)`
  requires `options` or `nil` in place of them.
* `ProGrammar::Helpers::Table.new(items, args, config = ProGrammar.config)` requires `args`
  or `nil` in place of them.
* Completely revamped `ProGrammar::HistoryArray`
  ([#1818](https://github.com/pro_grammar/pro_grammar/pull/1818)).
  * It's been renamed to `ProGrammar::Ring`
    ([#1817](https://github.com/pro_grammar/pro_grammar/pull/1817))
  * The implementation has changed and as result, the following methods were
    removed:
    * `ProGrammar::Ring#length` (use `ProGrammar::Ring#count` instead)
    * `#empty?`, `#each`, `#inspect`, `#pop!`, `#to_h`
  * To access old Enumerable methods convert the ring to Array with `#to_a`
  * Fixed indexing for elements (e.g. `_pro_grammar_.input_ring[0]` always return some
    element and not `nil`)
* Renamed `ProGrammar.config.prompt_safe_objects` to `ProGrammar.config.prompt_safe_contexts`
* Removed deprecated `ProGrammar::CommandSet#before_command` &
  `ProGrammar::CommandSet#after_command` ([#1838](https://github.com/pro_grammar/pro_grammar/pull/1838))

#### Deprecations

* Deprecated `_pro_grammar_.input_array` & `_pro_grammar_.output_array` in favour of
  `_pro_grammar_.input_ring` & `_pro_grammar_.output_ring` respectively
  ([#1814](https://github.com/pro_grammar/pro_grammar/pull/1814))
* Deprecated `ProGrammar::Command#text`. Please use `#black`, `#white`, etc. directly
  instead (as you would with helper functions from `BaseHelpers` and
  `CommandHelpers`) ([#1701](https://github.com/pro_grammar/pro_grammar/pull/1701))
* Deprecated `_pro_grammar_.input_array` & `_pro_grammar_.output_array` in favour of
  `_pro_grammar_.input_ring` and `_pro_grammar_.output_ring` respectively
  ([#1817](https://github.com/pro_grammar/pro_grammar/pull/1817))
* Deprecated `ProGrammar::Platform`. Use `ProGrammar::Helpers::Platform` instead. Note that
  `ProGrammar::Helpers::BaseHelpers` still includes the `Platform` methods but emits a
  warning. You must switch to `ProGrammar::Helpers::Platform` in your code
  ([#1838](https://github.com/pro_grammar/pro_grammar/pull/1838),
  ([#1845](https://github.com/pro_grammar/pro_grammar/pull/1845)))
* Deprecated `ProGrammar::Prompt::MAP`. You should use `ProGrammar::Prompt.all` instead to
  access the same map ([#1846](https://github.com/pro_grammar/pro_grammar/pull/1846))

#### Bug fixes

* Fixed a bug where `cd Hash.new` reported `self` as an instance of ProGrammar::Config
  in the prompt ([#1725](https://github.com/pro_grammar/pro_grammar/pull/1725))
* Silenced the `Could not find files for the given pattern(s)` error message
  coming from `where` on Windows, when `less` or another pager is not installed
  ([#1767](https://github.com/pro_grammar/pro_grammar/pull/1767))
* Fixed possible double loading of ProGrammar plugins' `cli.rb` on Ruby (>= 2.4) due to
  [the `realpath` changes while invoking
  `require`](https://bugs.ruby-lang.org/issues/10222)
  ([#1762](https://github.com/pro_grammar/pro_grammar/pull/1762),
  [#1774](https://github.com/pro_grammar/pro_grammar/pull/1762))
* Fixed `NoMethodError` on code objects that have a comment but no source when
  invoking `show-source` ([#1779](https://github.com/pro_grammar/pro_grammar/pull/1779))
* Fixed `negative argument (ArgumentError)` upon pasting code with tabs, which
  used to confuse automatic indentation
  ([#1771](https://github.com/pro_grammar/pro_grammar/pull/1771))
* Fixed ProGrammar not being able to load history on Ruby 2.4.4+ when it contains the
  null character ([#1789](https://github.com/pro_grammar/pro_grammar/pull/1789))
* Fixed ProGrammar raising errors on `cd`'ing into some objects that redefine
  `method_missing` and `respond_to?`
  ([#1811](https://github.com/pro_grammar/pro_grammar/pull/1811))
* Fixed bug when indentation leaves parts of input after pressing enter when
  Readline is enabled with mode indicators for vi mode
  ([#1813](https://github.com/pro_grammar/pro_grammar/pull/1813),
  [#1820](https://github.com/pro_grammar/pro_grammar/pull/1820),
  [#1825](https://github.com/pro_grammar/pro_grammar/pull/1825))
* Fixed `edit` not writing to history
  ([#1749](https://github.com/pro_grammar/pro_grammar/issues/1749))

#### Other changes

* Deprecated the `Data` constant to match Ruby 2.5 in the `ls` command
  ([#1731](https://github.com/pro_grammar/pro_grammar/pull/1731))

### 0.11.3

#### Features

* Add ProGrammar::Testable, an improved modular replacement for ProGrammarTestHelpers.
  **breaking change**.

See pull request [#1679](https://github.com/pro_grammar/pro_grammar/pull/1679).

* Add a new category module: "ProGrammar::Platform". Loosely related to #1668 below.

See pull request [#1670](https://github.com/pro_grammar/pro_grammar/pull/1670)

* Add `mac_osx?` and `linux?` utility functions to ProGrammar::Helpers::BaseHelpers.

See pull request [#1668](https://github.com/pro_grammar/pro_grammar/pull/1668).

* Add utility functions for drawing colorised text on a colorised background.

See pull request [#1673](https://github.com/pro_grammar/pro_grammar/pull/1673).

#### Bug fixes

* Fix a case of infinite recursion in `ProGrammar::Method::WeirdMethodLocator#find_method_in_superclass`
  that users of the [Hanami](http://hanamirb.org/) web framework experienced and
  reported since 2015.

See pull request [#1689](https://github.com/pro_grammar/pro_grammar/pull/1689).

* Fix a bug where Method objects were not returned for setters inherited
  from a default (ProGrammar::Config::Default). Eg, this is no longer an error:

      pro_grammar(main)> d = ProGrammar::Config.from_hash({}, ProGrammar::Config::Default.new)
      pro_grammar(main)> d.method(:exception_whitelist=) # Error

See pull request [#1688](https://github.com/pro_grammar/pro_grammar/pull/1688).

* Do not capture unused Proc objects in Text helper methods `no_color` and `no_paging`,
  for performance reasons. Improve the documentation of both methods.

See pull request [#1691](https://github.com/pro_grammar/pro_grammar/pull/1691).

* Fix `String#pp` output color.

See pull request [#1674](https://github.com/pro_grammar/pro_grammar/pull/1674).


### 0.11.0

* Add alias 'whereami[?!]+' for 'whereami' command. ([#1597](https://github.com/pro_grammar/pro_grammar/pull/1597))
* Improve Ruby 2.4 support ([#1611](https://github.com/pro_grammar/pro_grammar/pull/1611)):
  * Deprecated constants are hidden from `ls` output by default, use the `-d` switch to see them.
  * Fix warnings that originate in ProGrammar while using the repl.
* Improve completion speed in large applications. ([#1588](https://github.com/pro_grammar/pro_grammar/pull/1588))
* ProGrammar::ColorPrinter.pp: add `newline` argument and pass it on to PP. ([#1603](https://github.com/pro_grammar/pro_grammar/pull/1603))
* Use `less` or system pager pager on MS Windows if it is available. ([#1512](https://github.com/pro_grammar/pro_grammar/pull/1512))
* Add `ProGrammar.configure` as an alternative to the current way of changing configuration options in `.pro_grammarrc` files. ([#1502](https://github.com/pro_grammar/pro_grammar/pull/1502))
* Add `ProGrammar::Config::Behavior#eager_load!` to add a possible workaround for issues like ([#1501](https://github.com/pro_grammar/pro_grammar/issues/1501))
* Remove Slop as a runtime dependency by vendoring v3.4 as ProGrammar::Slop.
  People can depend on Slop v4 and ProGrammar at the same time without running into version conflicts. ([#1497](https://github.com/pro_grammar/pro_grammar/issues/1497))
* Fix auto-indentation of code that uses a single-line rescue ([#1450](https://github.com/pro_grammar/pro_grammar/issues/1450))
* Remove "ProGrammar::Config#refresh", please use "ProGrammar::Config#clear" instead.
* Defining a method called "ls" no longer breaks the "ls" command ([#1407](https://github.com/pro_grammar/pro_grammar/issues/1407))
* Don't raise when directory permissions don't allow file expansion ([#1432](https://github.com/pro_grammar/pro_grammar/issues/1432))
* Syntax highlight &lt;tt&gt; tags in documentation output.
* Add support for BasicObject subclasses who implement their own #inspect (#1341)
* Fix 'include RSpec::Matchers' at the top-level (#1277)
* Add 'gem-readme' command, prints the README file bundled with a rubygem
* Add 'gem-search' command, searches for a gem with the rubygems.org HTTP API
* Fixed bug in the `cat` command where it was impossible to use line numbers with files ([#1349](https://github.com/pro_grammar/pro_grammar/issues/1349))
* Fixed uncaught Errno::EOPNOTSUPP exception when $stdout is a socket ([#1352](https://github.com/pro_grammar/pro_grammar/issues/1352))
* Display a warning when you cd'ed inside a C object and executed 'show-source' without arguments ([#691](https://github.com/pro_grammar/pro_grammar/issues/691))
* Make the stagger_output method more reliable by reusing possibly available ProGrammar instance ([#1364](https://github.com/pro_grammar/pro_grammar/pull/1364))
* Make the 'gem-install' message less confusing by removing backticks ([#1350](https://github.com/pro_grammar/pro_grammar/pull/1350))
* Fixed error when ProGrammar was trying to load incompatible versions of plugins ([#1312](https://github.com/pro_grammar/pro_grammar/issues/1312))
* Fixed bug when `hist --clear` led to ArgumentError ([#1340](https://github.com/pro_grammar/pro_grammar/pull/1340))
* Fixed the "uninitialized constant ProGrammar::ObjectPath::StringScanner" exception during autocomplete ([#1330](https://github.com/pro_grammar/pro_grammar/issues/1330))
* Secured usage of colours with special characters (RL_PROMPT_START_IGNORE and RL_PROMPT_END_IGNORE) in ProGrammar::Helpers::Text ([#493](https://github.com/pro_grammar/pro_grammar/issues/493#issuecomment-39232771))
* Fixed regression with `pro_grammar -e` when it messes the terminal ([#1387](https://github.com/pro_grammar/pro_grammar/issues/1387))
* Fixed regression with space prefixes of expressions ([#1369](https://github.com/pro_grammar/pro_grammar/issues/1369))
* Introduced the new way to define hooks for commands (with `ProGrammar.hooks.add_hook("{before,after}_commandName")`). The old way is deprecated, but still supported (with `ProGrammar.commands.{before,after}_command`) ([#651](https://github.com/pro_grammar/pro_grammar/issues/651))
* Removed old API's using `ProGrammar::Hooks.from_hash` altogether
* Removed hints on Foreman support (see [this](https://github.com/ddollar/foreman/pull/536))
* Fixed support for the tee command ([#1334](https://github.com/pro_grammar/pro_grammar/issues/1334))
* Implemented support for CDPATH for ShellCommand ([#1433](https://github.com/pro_grammar/pro_grammar/issues/1433), [#1434](https://github.com/pro_grammar/pro_grammar/issues/1434))
* `ProGrammar::CLI.parse_options` does not start ProGrammar anymore ([#1393](https://github.com/pro_grammar/pro_grammar/pull/1393))
* The gem uses CPU-less platforms for Windows now ([#1410](https://github.com/pro_grammar/pro_grammar/pull/1410))
* Add `ProGrammar::Config::Memoization` to make it easier to implement your own `ProGrammar::Config::Default` class.([#1503](https://github.com/pro_grammar/pro_grammar/pull/1503/))
* Lazy load the config defaults for `ProGrammar.config.history` and `ProGrammar.config.gist`.

### 0.10.1

* Fix bugs with jruby
* Move to rspec for testing (from bacon)
* Clean up ruby warnings

### 0.10.0

#### Features
* Added a `watch` command that lets you see how values change over time.
* Added an experimental `ProGrammar.auto_resize!` method
  * Makes ProGrammar notice that your window has resized and tell Readline about it
  * Fixes various bugs with command history after a window resize
  * Off by default, but can be called from your `.pro_grammarrc` if you're brave
* `play` now has an `-e`/`--expression` flag
  * Evaluates until the end of the first valid expression
* History gets appended to `~/.pro_grammar_history` after every input, not just at quit
* Return values render with more accurate syntax highlighting
* Return values start rendering immediately and stream into the pager
* User can override `.pro_grammarrc` location by setting `$PRYRC` env var (#893)
* User can whitelist objects whose inspect output should appear in prompt (#885)
  * See `ProGrammar.config.prompt_safe_objects`
* `whereami` is now aliased to `@`
* Added  arguments to `whereami`:
  * `-m` shows the surrounding method
  * `-c` shows the surrounding class
  * `-f` shows the entire file
* Lazy load configuration values (ProGrammar.config). (#1096)
* Defer requiring `readline` until ProGrammar is started for the first time. (#1117)
* Add option to disable input completer through `_pro_grammar_.config.completer = nil`
* Add `list-prompts` command. (#1175)
  * Lists the available prompts available for use.
* Add `change-prompt` command. (#1175)
  * Switches the current prompt, by name.
* Add `list-inspectors` command. (#1176)
  * Lists the inspectors available to print Ruby return values.
* Add `change-inspector` command. (#1176)
  * Switches the current inspector, by name.
* Add `show-source -e`. (#1185)
  * Evaluate the given Ruby expression and show the source of its return value.
* Add `ProGrammar.config.windows_console_warning`(#1218)
  * Windows JRuby users who don't want warnings about ansicon can set
    `ProGrammar.config.windows_console_warning = false`.
* Add arguments to `play` command.
  * `-p` prints the code before playing it.
  * `-e` allows you to play expressions from your session.
* Add `cd -` to switch to the previous binding.
* Allow pro_grammaring into frozen objects.

#### Dependency changes

* Remove dependency on `ffi` gem on JRuby ([#1158](https://github.com/pro_grammar/pro_grammar/issues/1158))
* Remove optional dependency on Bond ([#1166](https://github.com/pro_grammar/pro_grammar/issues/1166))
  * Bond support has been extracted to the `pro_grammar-bond` plugin
* Remove dependency on `openstruct` ([#1096](https://github.com/pro_grammar/pro_grammar/issues/1096))
* Drop support for Ruby 1.8.7 (0.9.12.x will continue to be available)
* Add support for Ruby 2.1
* Require Coderay `~> 1.1.0`
* Remove deprecated hooks API ([#1209](https://github.com/pro_grammar/pro_grammar/pull/1209))
* Add 64-bit windows support.

#### Bug fixes, etc.
* The `gem-install` command can require gems like `net-ssh` thanks to better
  logic for guessing what path to require. (#1188)
* `toggle-color` command toggles the local `_pro_grammar_.color` setting instead of the
  global `ProGrammar.color`.
* Update `ProGrammar::CLIPPED_PRINT` to include a hex representation of object ID when
  printing a return value. (#1162)
* Wrap exceptions in a proxy instead of adding singleton methods. (#1145)
  * `ProGrammar#last_exception=` now supports exception objects that have been frozen.
* `binding.pro_grammar` inside `.pro_grammarrc` file now works, with some limitations (@richo / #1118)
* Add support for BasicObjects to `ls` (#984)
* Allow `ls -c <anything>` (#891)
* Fix indentation not working if the `mathn` stdlib was loaded (#872)
* Fix `hist`'s `--exclude-pro_grammar` switch (#874)
* Fix `gem-install` on JRuby (#870)
* Fix source lookup for instrumented classes (#923)
* Improved thread safety when multiple instances are running (#944)
* Make `edit` ignore `-n`/`--no-reload` flag and `disable_auto_reload` config
  in cases where the user was editing a tempfile
* Make `gem-cd` use the most recent gem, not the oldest
* Make `install-command` honor `.gemrc` switches (#666)
* Make `hist` with no parameters show just the current session's history (#205)
  * `hist --all` shows older history
* Make `-s`/`--super` flag of `show-source`/`show-doc` work when method name is
  being inferred from context (#877)
* Rename `--installed-plugins` flag to `--plugins`
* Strip ANSI codes from prompt before measuring length for indentation (#493)
* Fix bug in `edit` regarding recognition of file names without suffix.
* Reduced download size by removing tests etc. from distributed gem.

#### Dev-facing changes
* `CommandSet#commands`, sometimes referenced through `ProGrammar.commands.commands`,
  renamed to `CommandSet#to_hash`. It returns a duplicate of the internal hash
  a CommandSet uses.
* `CommandSet#keys` is now an alias of `CommandSet#list_commands`.
* All commands should now reference configuration values via `_pro_grammar_.config`
  (local) and not `ProGrammar.config` (global). (#1096)
  * This change improves support for concurrent environments and
    context-specific ProGrammar sessions. `_pro_grammar_.config` inherits default values from
    `ProGrammar.config` but can override them locally.
* `rake pro_grammar` now accepts switches prefixed with `_` (e.g., `rake pro_grammar _v`)
* Pagers now act like `IO`s and accept streaming output
  * See `_pro_grammar_.pager.page` and `_pro_grammar_.pager.open`.
* The `ProGrammar` class has been broken up into two smaller classes.
  * `ProGrammar` represents non-UI-specific session state, including the eval string
  * `ProGrammar::REPL` controls the user-facing interface
  * This should make it easier to drive ProGrammar from alternative interfaces
  * `ProGrammar.start` now has a `:driver` option that defaults to `ProGrammar::REPL`
  * This involved a lot of refactoring and may break plugins that depend on
    the old layout
* Add `ColorPrinter` subclass of `PP` for colorized object inspection
* Add `[]` and `[]=` methods to `CommandSet`, which find and replace commands
  * Example: `ProGrammar.commands["help"] = MyHelpCommand`
* The completion API has been refactored (see fdb703a8de4ef3)
* `ProGrammar.config.input_stack` (and the input stack concept in general) no longer
  exists
* There's a new `ProGrammar::Terminal` class that implements a number of different
  methods of determining the terminal's dimensions
* Add `ReplTester` class for high-level simulation of ProGrammar sessions in tests
* Add `ProGrammar.main`. Returns the special instance of Object referenced by self of
  `TOPLEVEL_BINDING`: "main".
* Changed second argument of `ProGrammar.view_clip()` from Fixnum to Hash to support
  returning a string with or without a hex representation of object ID. (#1162)
* The `output` and `pager` objects will now strip color-codes, so commands should
  always print in color.
* Commands now have a `state` hash that is persistent across invocations of the command
  in the same pro_grammar session.

### 0.9.12.6 (2014/01/28)
* Don't fail if Bond is not installed (#1106)

### 0.9.12.5 (2014/01/27)
* Fix early readline errors by deferring require of readline (#1081, #1095)

### 0.9.12.4 (2013/11/23)
* Fix issue with Coderay colors being black, even when on a black background (#1016)

### 0.9.12.3 (2013/09/11)
* Bump Coderay dependency (#987)
* Fix consecutive newlines in heredocs being collapsed (#962)
* Fix pager not working in JRuby > 1.7.5 (#992)

### 0.9.12.2 (2013/05/10)
* Make `reload-code` with no args reload "current" file (#920)

### 0.9.12.1 (2013/04/21)
* Add workaround for JRuby crashing bug (#890)
  * Related to http://jira.codehaus.org/browse/JRUBY-7114

### 0.9.12 (2013/02/12)
#### Features
* `pro_grammar --gem` (see 19bfc13aa)
* `show-source` now works on commands created with `create_command`
* `whereami` now has `-m` (method), `-c` (class), and `-f` (file) options
* `show-source` now falls back to superclass (and displays warning) if it
  can't find class code
* `show-source`/`show-doc` now indicate when `-a` option is available

#### Bug fixes, etc.
* Fix commands breaking due to Slop looking at `ARGV` instead of command
  parameters (#828)
* Fix pager breaking in some situations (#845)
* Fix broken rendering of some docs (#795)
* Silence warnings during failed tab-completion attempts
* Fix broken prompt when prompt is colored (#822 / #823)
* Added `reload-method` as alias for `reload-code` (for backwards
  compatibility)
* Reopen `Readline.output` if it is not a tty (see 1538bc0990)

### 0.9.11.4 (2013/01/20)
* Fix pager not rendering color codes in some circumstances
* Add `ProGrammar.last_internal_error`, useful for devs debugging commands

### 0.9.11.3 (2013/01/17)
* Fix `ProGrammar.run_command`
* Improve `ls` output
* Add `:requires_gem => "jist"` to `gist` command (so dependencies can be
  installed via `install-command`)
* Improve help for `edit` command

### 0.9.11.2 (2013/01/16)
* Fix minor bug in `gist` on Windows: rescue `Jist::ClipboardError` rather
  than letting the scary error spill out to users and potentially having them
  think the gist didn't post.

### 0.9.11.1 (2013/01/16)
* Fix minor bug in `gist` command where I neglected to remove
  a call to a non-existent method (`no_arg`) which was called when
  `gist` is invoked with no parameters

### 0.9.11 (2013/01/16)
#### Dependency changes
* Upgrade `slop` to `~> 3.4`
* New optional dependency: `bond`
  * You'll need to perform `gem install bond`
  * It improves autocompletion if you use Readline
  * Does not work for libedit
    (More info: https://github.com/pro_grammar/pro_grammar/wiki/FAQ#wiki-readline)
  * Big thanks to cldwalker

#### Features
* Basic Ruby 2.0 support (#738)
* JRuby 1.7.0+ support (#732)
* New `reload-code` command
  * Reload code for methods, classes, commands, objects and so on
  * Examples: `reload-code MyClass`, `reload-code my_method`,
    `reload-code my_obj`
* Bond tab completion (see "Dependency changes")
* Consolidate "show" commands into `show-source`
  * `show-source` can now extract source for:
    * Classes
    * Methods
    * Procs
    * ProGrammar commands
    * Arbitrary objects (it shows the source for the class of the object)
  * As a result, `show-command` is now removed
* `gist`, `play`, and `save-file` now infer object type without requiring flags
  * Examples: `play MyClass`, `play my_file.rb`, `play my_method`
* Consolidate editing commands into `edit`
  * `edit` can now edit:
    * Files
    * Methods
    * Classes
    * ProGrammar commands
  * As a result, `edit-method` is now removed
  * Examples: `edit MyClass`, `edit my_file.rb`, `edit my_method`
* `amend-line` and `play` now properly indent code added to input buffer
* Support for multiple require switches (`pro_grammar -rubygems -r./a.rb`) (#674)
* Support for multiple exec switches (`pro_grammar -e ':one' -e ':two'`)
* Ability to customize the name displayed in the prompt (#695)
* `--patch` switch for `edit --ex` command (#716)
* Respect the `$PAGER` environment variable (#736)
* `disable-pro_grammar` command (#497)
* Two new hooks, `before_eval` and `after_eval`
* Tab completion for `Array#<tab>` in `show-source` and `show-doc`
* `gem-install` immediately requires gems
* `-l` switch for `ls` command (displays local variables)
* `gem-open` command
* `fix-indent` command
* Subcommands API
* Public test API for plugin writers (see d1489a)
* Tabular `ls` output
* `--no-line-numbers` switch for `whereami` command
* `--lines` switch for `play` command

#### Bug fixes, etc.
* Use single escape instead of double in `find-method` (#652)
* Fix blank string delimiters (#657)
* Fix unwanted `binding_impl_method` local in scratch bindings (#622)
* Fix `edit-method -p` changing constant lookup (#645)
* Fix `.pro_grammarrc` loading twice when invoked from `$HOME` directory (#682)
* Fix ProGrammar not remembering initial `pwd` (#675)
* Fix multiline object coloring (#717)
* Fix `show-method` not supporting `String::new` notation (#719)
* Fix `whereami` command not showing correct line numbers (#754)
* Fix buggy Cucumber AST output (#751)
* Fix `while/until do` loops indentation (#787)
* Fix `--no-plugins` switch (#526)
* Ensure all errors go to the error handler (#774)
* Fix `.pro_grammarrc` loading with wrong `__FILE__`
* Fix pager not working if `less` is not available
* Fix `^D` in nested REPL
* Many small improvements to error message clarity and documentation formatting

### 0.9.10 (2012/07/04)
#### Dependency changes
* Upgrade `slop` to version 3 (#561)
* Switch from `gist` gem to `jist` (#590)
* Upgrade `method_source` to 0.8

#### Features
* Add `--hist`, `-o` and `-k` flags to `gist` command (#572)
* Support `show-source`/`show-doc` on methods defined in `class_eval` (#584)
* Support `show-source`/`show-doc` on gem methods defined in C (#585)
* Add `--disable-plugin` and `--select-plugin` options (#596)
* Allow `cd -` to switch between bindings (#597)
* Add `ProGrammar.config.should_load_local_rc` to turn off `./.pro_grammarrc` (#612)
* Allow running a file of ProGrammar input with `pro_grammar <file>`
* Support colours in `ri` command
* Add `before_eval` hook
* The prompt proc now gets a lot more data when its arity is 1

#### Bug fixes, etc.
* Removed the `req` command (#554)
* Fix rendering bugs when starting ProGrammar (#567)
* Fix `Array#pretty_print` on Jruby (#568)
* Fix `edit` on Windows (#575)
* Fix `find-method` in the presence of badly behaved objects (#576)
* Fix `whereami` in ERb files on Rails (#580)
* Raise fewer exceptions while tab completing (#632)
* Don't immediately quit ProGrammar when an error happens in Readline (#605)
* Support for `ansicon` to give JRuby Windows users colour (#606)
* Massive speed improvements to `show-source` for modules (#613)
* Improve `whereami` command when not in a `binding.pro_grammar` (#620)
* Support embedded documents (`=begin` ... `=end`) (#622)
* Support editing files with spaces in the name (#627)
* Renamed `__binding_impl__` to `__pro_grammar__`
* Support for absolute paths in `$EDITOR`
* Fix `cat` command on files with unknown extensions
* Many, many internal refactorings and tidyings

### 0.9.9.6 (2012/05/09)
* Fix `ZeroDivisionError` in `correct_indentation` (#558)

### 0.9.9.5 (2012/05/09)
* Fix `ZeroDivisionError` in `correct_indentation` (#558)
* Fix double highlighting in RDoc (#562)
* Automatically create configuration for plugins (#548)

### 0.9.9.4 (2012/04/26)
* Fix `NoMethodError: undefined method `winsize' for #<IO:<STDOUT>>` (#549)
* Fixes for JRuby
* Fix syntax error on `exit` (550)
* Heredoc content no longer auto-indented

### 0.9.9.3 (2012/04/19)
* Fix `show-doc` failing on some core classes, like `Bignum`

### 0.9.9.2 (2012/04/18)
* Make `correct_indentation`'s auto-colorization respect `ProGrammar.color`

### 0.9.9.1 (2012/04/18)
* Clear up confusion in `show-source`/`show-doc` docs
  * `-a` switch applies to classes as well as modules

### 0.9.9 (2012/04/18)
#### New features
* Lines of input are syntax highlighted upon Enter keypress
* `show-source` command can now show class/module source code
  * Use `-a` to see all monkeypatches
  * Hard dependency on `ruby18_source_location` gem in MRI 1.8
* `show-doc` command can now show class/module docs
  * Use `-a` to see docs for all monkeypatches
  * Hard dependency on `ruby18_source_location` gem in MRI 1.8
* New `find-method` command
  * Performs a recursive search in a namespace for the existence of methods
  * Can find methods whose names match a regex or methods which contain
    provided code
  * This command is like a ruby-aware `grep`, very cool (thanks swarley)
* [`pro_grammar-coolline`](https://github.com/pro_grammar/pro_grammar-coolline) now works properly
* `alias_command` method now much more powerful
  * Example: `alias_command "lM", "ls -M"`
* `whereami` is now more intelligent
  * Automatically shows entire source code of current method if current
    context is a method (thanks robgleeson)
* New `raise-up` command
  * Allows you to raise an exception that will bubble out of pro_grammar (ending the
    session) and escape into enclosing program

#### Bug fixes, etc.
* Fixed crash when paging under Windows
* Lines ending with `\` are incomplete (kudos to fowl)
* `edit-method -n` no longer blocks (thanks misfo)
* Show instance methods of modules by default in `ls`
* Docs for REPL-defined methods can now be displayed using `show-doc`
* Autoload `ruby18_source_location` on MRI 1.8, when available
  * See https://github.com/conradirwin/ruby18_source_location
* Tab completion should work on first line now (historic bug fixed)
* `:quiet => true` option added to `ProGrammar.start`, turns off `whereami`
* Another easter egg added
* Show unloaded constants in yellow for `ls`
* Improved documentation for `ProGrammar.config` options
* Improved auto-indentation
* JRuby: heuristics used to clean up `ls` output
  * Fewer internal methods polluting output

### 0.9.8.4 (2012/6/3)
* ~/.pro_grammar_history wasn't being created (if it did not exist)! FIXED
* `hist --save` saved colors! FIXED
* added ProGrammar#add_sticky_local API for adding sticky locals to individual pro_grammar instances

### 0.9.8.3 (2012/3/2)
* various tweaks to improve rbx support
* commands now support optional block arguments
* much improved help command
* updated method_source dependency
* added wtf command
* jruby should now work in windows (though without color)

### 0.9.8.2 (2012/2/9)
* fixed bugs related to --super
* upgraded slop dependency
* added edit -c (edit current line)
* edit now respects ProGrammar.config.disable_autoreload option

### 0.9.8.1 (2012/1/30)
* fixed broken --no-plugins option
* Ensure ARGV is not mutated during option parsing.
* Use a more rbx-friendly test for unicodeness
* Use rbx-{18,19}mode as indicated  http://about.travis-ci.org/docs/user/languages/ruby/
* Don't explode in gem-list [Fixes #453, #454]
* Check for command-name collision on assignment [Fixes #450]

### 0.9.8 (2012/1/25)

MAJOR NEW FEATURES
- upgraded command api, https://github.com/pro_grammar/pro_grammar/wiki/Custom-commands
- added a system of hooks for customizing pro_grammar behaviour
- changed syntax checking to use eval() for improved accuracy
- added save-file command
- added gist command (removed gist-method, new gist command is more general)

complete CHANGELOG:
* CommandError's no longer cause the current input to be discarded
* Better syntax highlighting for rbx code code
* added cat --in to show pro_grammar input history
* prefixed temporary file names with 'pro_grammar'
* show-doc now supports -l and -b options (line numbers)
* play now supports -i and -d options
* moved UserCommandAPI command-set to pro_grammar-developer_tools plugin
* added :when_started event for hooks, called in ProGrammar.start
* added a man page
* added rename method to ProGrammar::CommandSet (commands can be renamed)
* added CommandSet#{before_command,after_command} for enhancing builtin commands
* added checking for namespace collisions with pro_grammar commands, set ProGrammar.config.collision_warning
* work around namespace collisions by ensuring lines starting with a space are executed as
* ruby.work around namespace collisions by pressuring lines starting with a space are executed as ruby
* added handlers for Ctrl+C (SIGINT) on jruby, these are now caught as in other ruby versions
* removed dependency on ruby_parser
* prevented colours leaking across the pro_grammar prompt
* fixed edge cases in ProGrammar::Method, for methods with crazy names and methods that have been 'undef'd
* refactored history handling code for clarity and correctness
* added ProGrammar::WrappedModule as a counterpart to ProGrammar::Method
* made a trailing , cause pro_grammar to wait for further input
* removed gist-method command, added gist command
* added pro_grammar-backtrace command to show history of current session
* fixed whereami within 'super' methods
* replaced inline version guards by ProGrammar::Helpers::BaseHelpers.{rbx?,jruby?,windows?} etc.
* removed the CommandProcessor, its functionality is part of the new Command class
* changed cd .. at the top level so it doesn't quit pro_grammar.
* changed edit-command to no-longer need a command set argument
* fixed empty lines so that they don't replace _ by nil
* fixed SyntaxErrors at the REPL level so they don't replace _ex_.

### 0.9.7.4 (2011/11/5)
* ls -M now works in modules (bugfix)
* added exception message for bad cd object/path
* no longer die when encounter exceptions in .pro_grammarrc
* baked in CoolLine support
* ProGrammar.config.input in .pro_grammarrc now respected

### 0.9.7.3 (2011/10/28)
* really fixed indentation for 'super if' and friends
* Fixed indentation for tmux
* added ProGrammar.config.correct_indent option (to toggle whether indentation
* corrected optional param behaviour for method signatures: e.g Signature meth(param1=?, param2=?)

### 0.9.7.2 (2011/10/27)
* fixed indentation for 'super if' and 'ensure', 'next if', etc
* refactored ProGrammar#run_command so it can accept an eval_string parameter (so amend-line and so on can work with it)
* changed ^D so it no longer resets indent level automatically

### 0.9.7.1 (2011/10/26)
* fixed gem dependency issues

### 0.9.7 (2011/10/25)

MAJOR NEW FEATURES:
- upgraded ls command to have a more intuitive interface
- added automatic indentation (thanks YorickPeterse!)
- added ProGrammar::Method wrapper class to encapsulate method-related functionality

complete CHANGELOG:
* fixed syntax highlighting for object literals
* fixed ActiveSupport method-naming conflict with "in?"
* added --super option to edit-method, show-method, and friends -  making it easier to operate on superclass methods
* officially added edit --in to open previous expressions in an editor
* whereami now works for REPL-defined code
* started using JRuby parser for input validation in JRuby (thanks pangloss!)
* fixed bug where ~/.pro_grammarrc could be loaded more than once (thanks kelseyjudson!)
* added parse_options! helper to pull option parsing out of commands
* ProGrammar now respects the terminal's input encoding
* moved some requires out of the startup process for improved speed
* added input_array info to DEFAULT_PROMPT, e.g [1] pro_grammar(main)>
* added --no-history option to pro_grammar binary (prevent history being LOADED, history will still be saved)

### 0.9.6.2 (2011/9/27)
* downgrading to CodeRay 0.9.8 due to problems with 1.0 and rails (autoloading problem) see #280 on pro_grammar and #6 on CodeRay
* also added (as a minor feature) cirwin's implementation of edit --in
* added early break/exit for objectpath errors (the 'cd 34/@hello/bad_path/23')

### 0.9.6 (2011/9/19)
* restored previous behavior of command-line switches (allowing "-rfilename")
* removed -p option (--play) from edit command
* `edit` with no arguments now edits the current or most recent expression
* `edit` auto-reloads .rb files (need to specify -n to suppress)
* added -p option (--patch) to edit-method command, which allows
    monkeypatching methods without touching the original file
* edit-method can now edit REPL-defined methods
* cat --ex now works on exceptions in REPL-defined code
* play -m now uses eval_string.replace()
* play -m --open uses show-input to show play'd code
* added "unindent" helper to make adding help to commands easier
* local ./.pro_grammarrc now loaded after ~/.pro_grammarrc if it exists
* cat --ex N and edit --ex N now can navigate through backtrace, where cat --ex (with no args) moves through successive levels of the backtrace automatically with state stored on the exception object itself
* new option ProGrammar.config.exception_window_size determines window size for cat --ex
* input_stack now implemented - pushing objects onto a pro_grammar instance's input_stack causes the instance to read from those objects in turn as it encounters EOF on the previous object. On finishing the input_stack the input object for the pro_grammar instance is set back to ProGrammar.config.input, if this fails, pro_grammar breaks out of the REPL (throw(:breakout)) with an error message
* ProGrammar.config.system() defines how pro_grammar runs system commands
* now injecting target_self method into command scope
* play now performs 'show-input' always unless eval_string contains a valid expression (i.e it's about to be eval'd)
* play and hist --replay now push the current input object onto the input_stack before redirecting input to a StringIO (works much better with pro_grammar-remote now)

### 0.9.5 (2011/9/8)

MAJOR NEW FEATURES:
- JRuby support, including show-method/edit-method and editor integration on both 1.8 and 1.9 versions
- extended cd syntax: cd ../@x/y
- play command now works much better with _in_ array (this is a very powerful feature, esp with ProGrammar::NAV_PROMPT)
- history saving/loading is now lightning fast
- 'edit' (entered by itself) now opens current lines in input buffer in an editor, and evals on exit
- 'edit' command is also, in general more intelligent
- ls output no longer in array format, and colors can be configured, e.g: ProGrammar.config.ls.ivar_color = :bright_blue
- new switch-to command for moving around the binding stack without exiting out of sessions
- more sophisticated prompts, ProGrammar::NAV_PROMPT to ease deep spelunking of code
- major bug fix for windows systems
- much better support for huge objects, should no longer hang pro_grammar (see #245)
- cat --ex and edit --ex now work better

complete CHANGELOG:
* tempfile should end in .rb (for edit -t)
* ls output should not be in array format
* fix history saving (should not save all of Readline::HISTORY, but only what changed)
* prevent blank lines going to Readline::HISTORY (thanks cirwin!)
* ensure that cat --ex emulates the `whereami` format - includes line numbers and formatted the same, etc
* fixed bug #200 ( https://github.com/pro_grammar/pro_grammar/issues/200 )- string interpolation bug (thanks to ryanf)
* show-doc and stat now display method visibility (update WIKI)
* got rid of warnings caused by stricter ruby 1.9.3 rules
* remove interpolation of command names and fix interpolation error message (update WIKI) (thanks ryanf!)
* 'nested sessions' now use binding stacks (so each instance manages its own collection of bindings without spawning other instances)
* 'cd ..' just pops a binding off the binding_stack with special behaviour when only one binding in stack - it breaks out of the repl loop
* added switch-to command (like jump-to but doesn't unwind the stack)
* show-method and show-doc now accept multiple method names
* control_d hook added (ProGrammar.config.control_d_handler)
* behaviour of ^d is now to break out of current expr if in multi-line expr, or break out of current context if nested, or break out of pro_grammar repl loop if at top-level
* can no longer interpolate command name itself e.g #{x}-#{y} where x = "show" and y = "doc"
* ^C no longer captured
* got rid of ProGrammar.active_instance, ProGrammar.last_exception and friends.
* also special locals now shared among bindings in a pro_grammar instance (i.e _ex_ (and friends) re-injected into new binding entered with 'cd')
* renamed inp and out to _in_ and _out_ (to avoid collisions with actual locals in debugging scope)
* added third parameter to prompts, the pro_grammar instance itself (_pro_grammar) see https://github.com/pro_grammar/pro_grammar/issues/233 for why it's important
* cd behaviour when no args performs the same as `cd /`
* commands with keep_retval can now return nil (to suppress output now return 'void' instead)
* ProGrammar::CommandProcessor::Result introduced
* ProGrammar.view_clip() modified to be more robust and properly display Class#name
* edit command when invoked with no args now works like edit -t
* when edit is invoked (with no args or with -t) inside a multi-line expression input buffer, it dumps that buffer into a temp file and takes you to it
* got rid of ProGrammar#null_input? since all that was needed was eval_string.empty?
* cd command now supports complex syntax: cd ../@y/y/../z
* JRuby is no longer a 2nd class citizen, almost full JRuby support, passing 100% tests
* added ProGrammar::NAV_PROMPT (great new navigation prompt, per robgleeson) and ProGrammar::SIMPLE_PRINT for simple (IRB-style) print output (just using inspect)
* _pro_grammar_ now passed as 3rd parameter to :before_session hook
* ls colors now configurable via ProGrammar.config.ls.local_var_color = :bright_red etc
* ls separator configurable via, e.g ProGrammar.config.ls.separator = "  "
* ProGrammar.view_clip() now only calls inspect on a few immediates, otherwise uses the #<> syntax, which has been truncated further to exclude teh mem address, again related to #245

### 0.9.3 (2011/7/27)
* cat --ex (cats 5 lines above and below line in file where exception was raised)
* edit --ex (edits line in file where exception was raised)
* edit -t (opens a temporary file and evals it in current context when closed)
* `pro_grammar -r` requires now happen after plugin loading (so as not to interfere with
* new ProGrammar.config.disable_auto_reload option, for turning off auto reloading by edit-method and related (thanks ryanf)
* add better error messages for `cd` command
* fixed exotic object regression - BasicObject.new etc now return "=> unknown"
* added reload-method command (reloads the associated file of a method)
* converted: import => import-set, version => pro_grammar-version, install => install-command
* ProGrammar.config.command_prefix support (thanks ryanf!)
* fixed indentation for simple-prompt
* hist command now excludes last line of input (the command invocation itself)
* hist now has `history` alias
* missing plugins no longer raise exception, just print a warning to $stderr
* fixed jedit editor support

### 0.9.2 (2011/6/21)
* fixed string interpolation bug (caused valid ruby code not to execute, sorry!)
* fixed `ls` command, so it can properly display members of Object and classes, and BasicObject, etc
* added a few git related commands to experimental command set, blame and diff

### 0.9.0 (2011/6/17)
* plugin system
* regex commands
* show-method works on methods defined in REPL
* new command system/API
* rubinius core support
* more backports to ruby 1.8
* inp/out special locals
* _ex_ backtrace navigation object (_ex_.line, _ex_.file)
* readline history saving/loading
* prompt stack
* more hooks
* amend-line
* play
* show-input
* edit
* much more comprehensive test suite
* support for new and old rubygems API
* changed -s behaviour of ls (now excludes Object methods)
* removed eval-file, lls, lcd, and a few other commands


### 0.7.6.1 (2011/3/26)
* added slightly better support for YARD
* now @param and @return tags are colored green and markdown `code` is syntax highlighted using coderay

### 0.7.6 (2011/3/26)
* `whereami` command now accepts parameter AROUND, to display AROUND lines on eitherside of invocation line.
* made it so `whereami` is invoked even if no method exists in current context (i.e in rspec tests)
* added rubinius support for `whereami` invocation in HOOKS by checking for __unknown__.rb rather than just <main>

### 0.7.0 (2011/3/15)
* add pro_grammar-doc support with syntax highlighting for docs
* add 'mj' option to ls (restrict to singleton methods)
* add _ex_ local to hold last exception raised in an exception

### 0.6.8 (2011/3/6)
* add whereami command, a la the `ir_b` gem
* make whereami run at the start of every session
* make .pro_grammarrc be loaded by run-time pro_grammar sessions

### 0.6.7 (2011/3/4)
* color support
* --simple-prompt for pro_grammar commandline
* -I mode for pro_grammar commandline
* --color mode for pro_grammar commandline
* clean up requires (put them all in one place)
* simple-prompt command and toggle-color command.

### 0.6.3 (2011/2/28)
* Using MethodSource 0.3.4 so 1.8 show-method support provided
* `Set` class added to list of classes that are inspected

### 0.6.1 (2011/2/26)
* !@ command alias for exit_all
* `cd /` for breaking out to pro_grammar top level (jump-to 0)
* made `-e` option work in a more effective way for `pro_grammar` command line invocation
* exit and exit-all commands now accept a parameter, this parameter becomes the return value of repl()
* `command` method from CommandBase now accepts a :keep_retval arg that determines if command value is returned to pro_grammar session or just `nil` (`nil` was old behaviour)
* tests for new :keep_retval and exit-all/exit behaviour; :keep_retval will remain undocumented.

### 0.5.8 (2011/2/22)
* Added -c (context) option to show-doc, show-methods and eval-file
* Fixed up ordering issue of -c and -r parameters to command line pro_grammar

### 0.5.7 (2011/2/21)
* Added pro_grammar executable, auto-loads .pro_grammarrc in user's home directory, if it
	exists.

### 0.5.5 (2011/2/19)
* Added ProGrammar.run_command
* More useful error messages
* Easter eggs (game and cohen-poem)

### 0.5.0 (2011/2/17)
* Use clipped version of ProGrammar.view() for large objects
* Exit ProGrammar session on ^d
* Use Shellwords for breaking up parameters to pro_grammar commands
* Use OptionParser to parse options for default pro_grammar commands
* Add version command
* Refactor 'status' command: add current method info
* Add meth_name_from_binding utility lambda to commands.rb
* Add -M, -m, -v(erbose), -a(ll), -s(uper), -l(ocals), -i(ivars), -k(klass
	vars), etc options to ls
* add -M(instance method) options to show-method and show-doc
* add --help option to most commands
* Get rid of ls_method and ls_imethods (subsumed by more powerful ls)
* Get rid of show_idoc and show_imethod
* Add special eval-file command that evals target file in current context

### 0.4.5 (2011/1/27)
* fixed show_method (though fragile as it references __binding_impl__
	directly, making a name change to that method difficult

### 0.4.4 (2011/1/27)
* oops, added examples/ directory

### 0.4.3 (2011/1/26)
* added alias_command and desc methods to ProGrammar::CommandBase
* changed behaviour of ls_methods and ls_imethods to return sorted lists
	of methods

### 0.4.1 (2011/1/23)
* made it so a 'def meth;end' in an object ProGrammar session defines singleton
	methods, not methods on the class (except in the case of
	immediates)
* reorganized documentation, moving customization to a separate wiki file
* storing wiki in a nested git repo, as github wiki pages have their own
	repo
* added more tests for new method definition behaviour

### 0.4.0 (2011/1/21)
* added command API
* added many new commands, i.e ls_methods and friends
* modified other commands
* now accepts greater customization, can modify: input, output, hooks,
	prompt, print object
* added tab completion (even completes commands)
* added extensive tests
* added examples
* many more changes

### 0.1.3 (2010/12/9)
* Got rid of rubygems dependency, refactored some code.

### 0.1.2 (2010/12/8)
* now rescuing SyntaxError as well as Racc::Parser error in valid_expression?

### 0.1.0 (2010/12/8)
* release!

[v0.12.0]: https://github.com/pro_grammar/pro_grammar/releases/tag/v0.12.0
[v0.12.1]: https://github.com/pro_grammar/pro_grammar/releases/tag/v0.12.1
[v0.12.2]: https://github.com/pro_grammar/pro_grammar/releases/tag/v0.12.2
[v0.13.0]: https://github.com/pro_grammar/pro_grammar/releases/tag/v0.13.0
[v0.13.1]: https://github.com/pro_grammar/pro_grammar/releases/tag/v0.13.1
