module DslEvaluator
  class Printer
    def initialize(error)
      @error = error
    end

    def message
      @error.message
    end

    # Prints out a user friendly task_definition error message
    def print
      print_source(info)
    end

    def info
      @error.message.include?("syntax") ? info_from_message : info_from_backtrace
    end

    def info_from_message
      error_info = @error.message
      path, line_number, _ = error_info.split(':')
      {path: path, line_number: line_number}
    end

    def info_from_backtrace
      lines = @error.backtrace

      backtrace_reject = DslEvaluator.backtrace_reject
      lines = lines.reject { |l| l.include?(backtrace_reject) } if backtrace_reject
      lines = lines.reject { |l| l.include?("lib/dsl_evaluator") } # ignore internal lib/dsl_evaluator backtrace lines

      error_info = lines.first
      path, line_number, _ = error_info.split(':')
      {path: path, line_number: line_number}
    end

    def print_source(info={})
      path = info[:path]
      line_number = info[:line_number].to_i

      puts "Error evaluating #{path}:".color(:red)
      puts @error.message
      puts "Here's the line in #{path} with the error:\n\n"

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
    end
  end
end