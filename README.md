# DslEvaluator

Small module to help with DSL evaluation. Notably, it produces a human-friendly backtrace error showing the original user-provided source code if there's a syntax error.

## Usage

```ruby
require "dsl_evaluator"
DslEvaluator.backtrace_reject = "lib/my_gem" # optional

class DslBuilder
  def build
    path = "/path/to/user/provided/dsl/file.rb"
    evaluate_file(path)
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dsl_evaluator'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dsl_evaluator

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tongueroo/dsl_evaluator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
