# Helper functions for SchemeLists
module SchemeListsHelper
  def evaluate_list(tokens, no_quotes)
    find_all_values_list_evaluate tokens, no_quotes
  end

  def no_eval_list(tokens, no_quotes = false)
    result = []
    until tokens.empty?
      value, tokens = build_next_value_as_string tokens
      value = value[1..-2] if no_quotes && (check_for_string value.to_s)
      result << value
    end
    result
  end

  def find_to_evaluate_or_not(tokens, no_quotes)
    if tokens[0..1].join == '(list'
      evaluate_list tokens[2..-2], no_quotes
    elsif tokens[0..1].join == '(cons'
      result = cons tokens[2..-2]
      result[2..-2].split(' ')
    else
      no_eval_list tokens[2..-2], no_quotes
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
      x = x[1..-2] if no_quotes && (check_for_string x.to_s)
      result << x
    end
    result
  end

  def build_list(values)
    '\'(' + values.join(' ') + ')'
  end

  def build_cons_from_list(values)
    spacer = values[1].size == 3 ? '' : ' '
    values[0] + spacer + values[1][2..-2]
  end

  def cons_helper(values)
    result =
      if values[1].split('').pair?
        build_cons_from_list values
      else
        values[0] + ' . ' + values[1]
      end
    '\'(' + result + ')'
  end

  def get_cons_values(tokens)
    result = get_k_arguments tokens, false, 2, false
    raise 'Too little arguments' if result.size != 2
    result
  end
end

# Scheme lists module
module SchemeLists
  include SchemeListsHelper
  def null?(tokens)
    value, tokens = find_next_value tokens, false
    raise 'Too much arguments' unless tokens.empty?
    value == '\'()' ? '#t' : '#f'
  end

  def cons(tokens)
    result = get_cons_values tokens
    cons_helper result
  end

  def null
  end

  def list(tokens)
    result = find_all_values_list_evaluate tokens, false
    build_list result
  end

  def car(tokens) end

  def cdr(tokens) end
end
