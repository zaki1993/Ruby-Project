# Helper functions for SchemeLists
module SchemeListsHelper
  def evaluate_list(tokens, no_quotes)
    find_all_values_list_evaluate tokens, no_quotes
  end

  def do_not_evaluate_list(tokens, no_quotes)
    result = []
    until tokens.empty?
      value, tokens = find_next_value tokens, false
      value = value[1..-2] if check_for_string value if no_quotes
      result << value
    end
    result
  end

  def find_to_evaluate_or_not(tokens, no_quotes)
    if tokens[0..1].join == '(list'
      evaluate_list tokens[2..-2], no_quotes
    elsif tokens[0..1].join == '(cons'
      # TODO for cons
    else
      do_not_evaluate_list tokens[2..-2], no_quotes
    end
  end

  def find_idx_for_list(tokens)
    if tokens[0] == '('
      find_bracket_idx tokens, 0
    elsif tokens[1] == '('
      find_bracket_idx tokens, 1
    end
  end

  def find_all_values_list_evaluate(tokens, no_quotes)
    result = []
    until tokens.empty?
      x, tokens = find_next_value tokens, false
      x = x[1..-2] if check_for_string x if no_quotes
      result << x
    end
    result
  end
  
  def build_list(values)
    '\'(' + values.join(' ') + ')'
  end
end

# Scheme lists module
module SchemeLists
  include SchemeListsHelper
  def null?(tokens)
    idx = find_idx_for_list tokens
    raise 'List expected' unless tokens[0..idx].list?
    raise 'Too much arguments' unless idx == tokens.size - 1
    tokens.size == 3 ? '#t' : '#f'
  end

  def cons(tokens)
    puts tokens.to_s
    result = []
    until tokens.empty?
      value, tokens = find_next_value tokens, false
      result << value
    end
    raise 'Too little arguments' if result.size != 2
    puts result
    puts tokens.to_s
  end

  def null

  end

  def list(tokens)
    result = find_all_values_list_evaluate tokens, false
    build_list result
  end

  def car(tokens)

  end

  def cdr(tokens)

  end
end
