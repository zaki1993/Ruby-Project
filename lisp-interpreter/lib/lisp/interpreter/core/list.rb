# Helper functions for SchemeLists
module SchemeListsHelper
  def no_eval_list(tokens, no_quotes = false)
    result = []
    until tokens.empty?
      value, tokens = build_next_value_as_string tokens
      value = value[1..-2] if no_quotes && (check_for_string value.to_s)
      result << value
    end
    result
  end

  def find_idx_for_list(tokens)
    if tokens[0] == '('
      find_bracket_idx tokens, 0
    elsif tokens[1] == '('
      find_bracket_idx tokens, 1
    end
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
    raise arg_err_build 2, result.size if result.size != 2
    result
  end

  def split_list_string(list)
    result = list.split(/(\(|\)|\.)|\ /)
    result.delete('')
    result
  end

  def find_list_function_value(other)
    raise arg_err_build 1, other.size if other.size != 1
    raise type_err '<list>', other[0].type unless other[0].list?
    split_list_as_string other[0].to_s
  end

  def split_list_as_string(list_as_string)
    split_value = split_list_string list_as_string.to_s
    no_eval_list split_value[2..-2]
  end

  def car_cdr_values(other)
    raise arg_err_build 1, other.size if other.size != 1
    return find_list_function_value other if other[0].list?
    (split_list_string other[0].to_s)[2..-2] if other[0].pair?
  end

  def map_helper(lst, func)
    return lst.map { |t| func.call(*t) } if func.is_a? Proc
    lst.map { |t| send func, t }
  end

  def map_validate_helper(other)
    raise arg_err_build 'at least 2', 0 if other.empty?
    func, other = valid_function other
    raise arg_err_build 'at least 2', 1 if other.empty?
    [func, other]
  end

  def build_function_car_cdr(fn)
    prepare_call = ['(', fn, 'x', ')']
    fn[1..-2].each_char do |t|
      prepare_call += (t == 'a' ? ['(', 'car'] : ['(', 'cdr'])
    end
    prepare_call << 'x'
    (fn.size - 2).times { prepare_call << ')' }
    prepare_call
  end

  def generate_infinite_car_cdr(fn)
    prepare_call = build_function_car_cdr fn
    define_function prepare_call
  end

  def call_car_cdr_infinite(fn, values)
    @procs[fn.to_s].call values
  end
end

# Scheme lists module
module SchemeLists
  include SchemeListsHelper
  def cons(other)
    raise arg_err_build 2, other.size if other.size != 2
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
    raise arg_err_build 1, other.size if other.size != 1
    other[0].to_s.list? ? TRUE : FALSE
  end

  def pair?(other)
    raise arg_err_build 1, other.size if other.size != 1
    other[0].to_s.pair? ? TRUE : FALSE
  end

  def null?(other)
    raise arg_err_build 1, other.size if other.size != 1
    other[0] == '\'()' ? TRUE : FALSE
  end

  def length(other)
    (find_list_function_value other).size
  end

  def reverse(other)
    value = find_list_function_value other
    build_list value.reverse
  end

  def map(other)
    func, other = map_validate_helper other
    lst = find_all_values other
    lst = lst.map { |t| find_list_function_value [t] }
    lst = (equalize_lists lst).transpose
    build_list map_helper lst, func
  end

  def shuffle(other)
    values = find_list_function_value other
    build_list values.shuffle
  end

  def car_cdr_infinite(other)
    fn = other[1]
    values = find_all_values other[2..-2]
    return call_car_cdr_infinite fn, values if @procs.key? fn.to_s
    raise arg_err_build 1, values.size unless values.size == 1
    (generate_infinite_car_cdr fn).call values[0]
  end
end
