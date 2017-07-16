# Helper functions for SchemeLists
module SchemeListsHelper
  def evaluate_list(tokens)
    find_all_values_list_evaluate tokens
  end

  def do_not_evaluate_list(tokens)
    result = []
    until tokens.empty?
      value, tokens = build_next_value_as_string tokens
      value = value[1..-2] if check_for_string value
      result << value
    end
    result
  end

  def find_to_evaluate_or_not(tokens)
    if tokens[0..1].join == '(list'
      evaluate_list tokens[2..-2]
    else
      do_not_evaluate_list tokens[2..-2]
    end
  end

  def find_idx_for_list(tokens)
    if tokens[0] == '('
      find_matching_bracket_idx tokens, 0
    elsif tokens[1] == '('
      find_matching_bracket_idx tokens, 1
    end
  end

  def find_all_values_list_evaluate(tokens)
    result = []
    until tokens.empty?
      x, tokens = find_next_value tokens, false
      x = x[1..-2] if check_for_string x
      result << x
    end
    result
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

  end

  def null

  end

  def list(tokens)

  end

  def car(tokens)

  end

  def cdr(tokens)

  end
end
