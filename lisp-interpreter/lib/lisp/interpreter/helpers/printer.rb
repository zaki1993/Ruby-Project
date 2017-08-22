# Module used to display result
module Printer
  def finalize_result(result)
    result = format_result result
    display_result result if @env_type == Environment::PROD
    result
  end

  def format_result(result)
    to_remove = result.to_s.list? || result.to_s.pair? || result.to_s.quote?
    result = result.delete('\'') if to_remove
    result
  end

  def find_result_type(res, methods)
    return '#<Closure>' if res.is_a? Proc
    is_func = (methods.key? res.to_s)
    return '#<Function ' + res.to_s + '>' if is_func
    res.to_s
  end

  def display_result(result)
    to_print = find_result_type result, @tokenizer.syntax_methods
    puts to_print
  end
end
