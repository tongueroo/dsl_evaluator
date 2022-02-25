module DslEvaluator
  class Printer
    def initialize(error)
      @error = error
    end

    # Prints out a user friendly task_definition error message
    def print
      info = error_info
      path = info[:path]
      line_number = info[:line_number].to_i

      logger.error "Error evaluating #{pretty_path(path)}".color(:red)
      logger.error "Here's the line with the error:\n\n"

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

    def error_info
      @error.message.include?("syntax") ? info_from_message : info_from_backtrace
    end

    def info_from_message
      error_info = @error.message
      path, line_number, _ = error_info.split(':')
      {path: path, line_number: line_number}
    end

    # Grab info so can print out user friendly error message
    #
    # Backtrace lines are different for OSes:
    #
    #   windows: "C:/Ruby31-x64/lib/ruby/gems/3.1.0/gems/terraspace-1.1.1/lib/terraspace/builder.rb:34:in `build'"
    #   linux: "/home/ec2-user/.rvm/gems/ruby-3.0.3/gems/terraspace-1.1.1/lib/terraspace/compiler/dsl/syntax/mod.rb:4:in `<module:Mod>'"
    #
    def info_from_backtrace
      lines = @error.backtrace
      if ENV['FULL_BACKTRACE']
        logger.error @error.message.color(:red)
        logger.error lines.join("\n")
      end

      lines = reject(lines)
      lines = select(lines)

      error_info = lines.first
      parts = error_info.split(':')
      windows = error_info.match(/^[a-zA-Z]:/)
      path = windows ? parts[1] : parts[0]
      line_number = windows ? parts[2] : parts[1]
      line_number = line_number.to_i

      {path: path, line_number: line_number}
    end

    def reject(lines)
      # Keep DslEvaluator.backtrace_reject for backwards compatibility
      pattern = config.backtrace.reject_pattern || DslEvaluator.backtrace_reject
      return lines unless pattern

      lines.reject! do |l|
        if pattern.is_a?(String)
          l.include?(pattern)
        else
          l.match(pattern)
        end
      end
      # Always ignore internal lib/dsl_evaluator backtrace lines
      lines.reject { |l| l.include?("lib/dsl_evaluator") }
    end

    def select(lines)
      pattern = config.backtrace.select_pattern
      return unless pattern

      lines.select do |l|
        if pattern.is_a?(String)
          l.include?(pattern)
        else
          l.match(pattern)
        end
      end
    end

    def pretty_path(path)
      path.sub("#{config.root}/",'')
    end

    def logger
      config.logger
    end

    def config
      DslEvaluator.config
    end

    def message
      @error.message
    end
  end
end