require 'active_support'
require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'dsl_evaluator/version'
require 'memoist'
require 'rainbow/ext/string'

require "dsl_evaluator/autoloader"
DslEvaluator::Autoloader.setup

module DslEvaluator
  extend Memoist

  class Error < StandardError; end

  def evaluate_file(path)
    return unless path && File.file?(path)
    instance_eval(IO.read(path), path)
  rescue Exception => e
    Printer.new(e).print
    case config.on_exception
    when :rescue
      # do nothing
    when :exit
      exit 1
    else # :raise
      raise
    end
  end

  mattr_accessor :backtrace_reject

  def logger
    config.logger
  end

  def configure(&block)
    App.instance.configure(&block)
  end

  def config
    App.instance.config
  end
  memoize :config

  # So other libraries can use this method
  def print_code(path, line_number)
    check_line_number!(line_number)
    line_number = line_number.to_i
    contents = IO.read(path)
    content_lines = contents.split("\n")
    context = 5 # lines of context
    top, bottom = [line_number-context-1, 0].max, line_number+context-1
    lpad = content_lines.size.to_s.size
    content_lines[top..bottom].each_with_index do |line_content, index|
      current_line = top+index+1
      if current_line == line_number
        printf("%#{lpad}d %s\n".color(:red), current_line, line_content)
      else
        printf("%#{lpad}d %s\n", current_line, line_content)
      end
    end

    logger.info "Rerun with FULL_BACKTRACE=1 to see full backtrace" unless ENV['FULL_BACKTRACE']
  end

  def check_line_number!(line_number)
    return line_number unless line_number.is_a?(String)
    integer = line_number.to_i
    if integer == 0
      logger.error "ERROR: Think you accidentally passed in a String for the line_number: #{line_number}".color(:red)
      puts caller
      exit 1
    end
  end

  extend self
end
