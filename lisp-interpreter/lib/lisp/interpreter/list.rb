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

  def find_to_evaluate_or_not(tokens, no_quotes = false)
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

  def find_all_values_list_evaluate(tokens, no_quotes = false)
    result = []
    until tokens.empty?
      x, tokens = find_next_value tokens
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
    values[0].to_s + spacer + values[1][2..-2].to_s
  end

  def cons_helper(values)
    result =
      if values[1].to_s[0..1] == '\'('
        build_cons_from_list values
      else
        values[0].to_s + ' . ' + values[1].to_s
      end
    '\'(' + result + ')'
  end

  def get_cons_values(tokens)
    result = get_k_arguments tokens, false, 2
    raise 'Too little arguments' if result.size != 2
    result
  end

  def split_list_string(list)
    result = list.split(/(\(|\)|\.)|\ /)
    result.delete('')
    result
  end

  def find_list_function_value(other)
    raise 'Incorrect number of arguments' if other.size != 1
    raise 'Invalid data type' unless other[0].list?
    split_list_as_string other[0].to_s
  end

  def split_list_as_string(list_as_string)
    split_value = split_list_string list_as_string.to_s
    no_eval_list split_value[2..-2]
  end

  def car_cdr_values(other)
    raise 'Incorrect number of arguments' if other.size != 1
    return find_list_function_value other if other[0].list?
    (split_list_string other[0].to_s)[2..-2] if other[0].pair?
  end

  def map_helper(lst, func)
    return lst.map { |t| func.call(*t) } if func.is_a? Proc
    lst.map { |t| send func, t }
  end
end

# Scheme lists module
module SchemeLists
  include SchemeListsHelper
  def cons(other)
    raise 'Incorrect number of arguments' if other.size != 2
    cons_helper other
  end

  def list(other)
    build_list other
  end

  def car(other)
    value = car_cdr_values other
    raise 'Cannot apply car on ' + other[0].to_s if value.nil? || value.empty?
    value.shift
  end

  def cdr(other)
    value = car_cdr_values other
    raise 'Cannot apply cdr on ' + other[0].to_s if value.nil? || value.empty?
    idx = value[1] == '.' ? 2 : 1
    build_list value[idx..-1]
  end

  def list?(other)
    raise 'Incorrect number of arguments' if other.size != 1
    other[0].to_s.list? ? '#t' : '#f'
  end

  def pair?(other)
    raise 'Incorrect number of arguments' if other.size != 1
    other[0].to_s.pair? ? '#t' : '#f'
  end

  def null?(other)
    raise 'Incorrect number of arguments' if other.size != 1
    return '#f' unless other[0].to_s.list?
    other[0].to_s.size == 3 ? '#t' : '#f'
  end

  def length(other)
    (find_list_function_value other).size
  end

  def reverse(other)
    value = find_list_function_value other
    build_list value.reverse
  end

  def map(other)
    func, other = valid_function other
    lst = find_all_values other
    lst = lst.map { |t| find_list_function_value [t] }
    lst = (equalize_lists lst).transpose
    build_list map_helper lst, func
  end

  def shuffle(other)
    values = find_list_function_value other
    build_list values.shuffle
  end
end