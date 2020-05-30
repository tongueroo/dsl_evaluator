require "dsl_evaluator/version"
require "rainbow/ext/string"

module DslEvaluator
  autoload :Printer, "dsl_evaluator/printer"

  class Error < StandardError; end

  def evaluate_file(path)
    return unless path && File.file?(path)
    instance_eval(IO.read(path), path)
  rescue Exception => e
    Printer.new(e).print
    puts "\nFull error:"
    raise
  end

  @@backtrace_reject = nil
  def backtrace_reject
    @@backtrace_reject
  end

  def backtrace_reject=(v)
    @@backtrace_reject = v
  end

  extend self
end
