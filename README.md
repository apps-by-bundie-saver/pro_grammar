ProGrammar
===

![ProGrammar logo](https://i.postimg.cc/fRJhDgnB/pro-grammar-gem-logo.png)

© Full Stack Alex Le ([fullstackalexle](https://twitter.com/banisterfiend)) 2020<br> (Creator)

**Links:**

* https://bundiesaver.com/app/documentation#pro_grammar.org/
* [Blog](https://bundiesaver.com/blog/164402f5-5269-4dc9-8c6c-408535ed16ee/articles/d18b5604-ff3e-46c4-88b9-8a1833f69a9e)

Table of Contents
=================

* [Introduction](#introduction)
* [Key features](#key-features)
* [Installation](#installation)
* [Overview](#overview)
   * [Runtime invocation](#runtime-invocation)
   * [Syntax Highlighting](#syntax-highlighting)
* [Contact](#contact)
* [License](#license)
* [Contributors](#contributors)

Introduction
------------

The ProGrammar GEM is a utility to help you track your development steps as you debug your code solutions. ProGrammar creates development notes in text files, also connected to the ProGrammar Hub, which capture every step of code line editting as you try and re-try your code blocks; and make edits between your code block tracers, until you find a resolution.


ProGrammar is for the professional developer who knows that any code solution sometimes requires multiple attempts for resolution, and knows that these bugs and errors, with one's resolutions, may pop up again throughout one's career as a developer; so it becomes important to keep track of your development steps as you troubleshoot bugs, so that if you come across a familiar error, you can review your ProGrammar development notes to resolve the error with ease (without having to re-research for the solution on the Internet).


ProGrammar makes it easy to keep track of all your attempts for resolving errors by generating development notes which keep track of every edit session you make in your development workflow.


The ProGrammar GEM is an interactive debugging utility which allows you to place code between two tracers (or delimiters): a start trace and and end trace, and then evaluate the code between those tracers, line-by-line, to find errors between your set tracers. Once the tracers have been set and the method to call the action between the tracers have been called, the ProGrammar engine will parse and evaluate your code between those set tracers, one line after another, until it reaches an error. If an error is found, ProGrammar will start an interactive session within your Terminal to instruct you on how to create your development notes.


Once you've set your specifications and details via the interactive Terminal session, ProGrammar development notes will be created and appended to, as you troubleshoot your error code in VIM text editor sessions. This means programming with ProGrammar occurs within start and end sessions and all through a seamless interface, whenever you need to debug your code (just set your tracers and call the action to activate the method which contains your tracers). A text file at wherever path you set your notes to be saved at will be generated for you to have as a resource for review and trace logging. You can also find your notes at the ProGrammar Hub.

Key features
------------

* Set tracers (`binding.start_trace` and `binding.end_trace`)
* Line-by-line debugging
* In-line VIM editting
* Development note creation
* Add links
* ProGrammar Hub connection (Social)

Installation
------------

### Bundler

```ruby
gem 'pro_grammar', '~> 0.1.0'
```

### Manual

```sh
gem install pro_grammar
```

Overview
--------

To begin debugging with ProGrammar, you'll need to set your code tracers. You can do this by prefixing your troubled code with 'binding.pro_grammar_start' and 'binding.pro_grammar_end'. See the example below:

```ruby
binding.pro_grammar_start
 # Your example code here
binding.pro_grammar_end
```

These code tracers will define the area of code which will be evaluated by the ProGrammar debugging utility. [Learn more about how to begin debugging with ProGrammar](https://bundiesaver.com/blog/164402f5-5269-4dc9-8c6c-408535ed16ee/articles/d18b5604-ff3e-46c4-88b9-8a1833f69a9e).

### Runtime invocation

ProGrammar can be invoked in the middle of a running program. It opens a ProGrammar session at
the point it's called and makes all program state at that point available. It
can be invoked on on the current binding (or any binding) using `binding.pro_grammar_start` and `binding.pro_grammar_end`. The ProGrammar session will then begin within the scope of the bindings. When the session ends the program
continues with any modifications you made to it.

This functionality can be used for such things as: debugging, implementing
developer consoles and applying hot patches.

### Syntax Highlighting

Syntax highlighting is on by default in ProGrammar. 

You can toggle the syntax highlighting on and off in a session by using the
`toggle-color` command. Alternatively, you can turn it off permanently by
putting the line `ProGrammar.color = false` in your `pro_grammarrc` file.


Contact
-------

In case you have a problem, question or a bug report, feel free to:

* [email](mailto:bundiethebunny@bundiesaver.com)
* [tweet at us](https://twitter.com/BundieBunny)

License
-------

The project uses the MIT License. See LICENSE.md for details.

Contributors
------------

ProGrammar is primarily the work of [Full Stack Alex Le (fullstackalexle)](https://github.com/fullstackalexle).
