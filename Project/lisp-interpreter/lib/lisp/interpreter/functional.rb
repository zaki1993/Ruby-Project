# FunctionalScheme helper
module FunctionalSchemeHelper
  def get_fold_values(other)
    values = find_all_values other
    raise 'Incorrect number of arguments' if values.size != 2
    x, y = values
    y = split_list_as_string y.to_s
    [x, y]
  end

  def foldl_helper(func, accum, lst)
    return accum if lst.empty?
    value = func.call lst[0], accum if func.is_a? Proc
    value = send func, [lst[0], accum] if value.nil?
    foldl_helper func, value, lst[1..-1]
  end

  def foldr_helper(func, accum, lst)
    return accum if lst.empty?
    value = foldr_helper func, accum, lst[1..-1]
    return func.call lst[0], value if func.is_a? Proc
    send func, [lst[0], value]
  end

  def equalize_lists(other)
    min = other.map(&:size).min
    other.map { |t| t[0..min - 1] }
  end

  def member_helper(to_check, values)
    return '#f' unless values.include? to_check
    idx = values.index(to_check)
    build_list values[idx..-1]
  end

  def map_helper(lst, func)
    return lst.map { |t| func.call(*t) } if func.is_a? Proc
    lst.map { |t| send func, t }
  end

  def find_params_lambda(other)
    raise 'Unbound symbol ' + other.to_s if other[0] != '('
    idx = find_bracket_idx other, 0
    [other[1..idx - 1], other[idx + 1..-1]]
  end

  def eval_lambda(other)
    idx = find_bracket_idx other.unshift('('), 0
    to_eval = other[1..idx - 1]
    (proc_lambda to_eval).call(*other[idx + 1..-1])
  end
   
  def remove_from_inner_scope(scope, start_idx, end_idx)
    scope.slice!(start_idx..end_idx)
    [end_idx + 1, scope]
  end
  
  def inner_scope_replace(scope, vars)
    scope.each_with_index do |t, i|
      if vars.key? t.to_s
        scope[i] = vars[t.to_s]
      end
    end
    scope.flatten
  end
  
  def fetch_inner_scope(scope, idx = 0, defined_vars = {})
    until idx >= scope.size
      if scope[idx] == 'define'
        i = find_bracket_idx scope, idx - 1
        defined_vars[scope[idx + 1].to_s] = scope[idx + 2..i - 1]
        idx, scope = remove_from_inner_scope scope, idx - 1, i
      else
        idx += 1
      end
    end
    inner_scope_replace scope, defined_vars
  end

  def proc_lambda(other)
    params, other = find_params_lambda other
    other = fetch_inner_scope other
    proc = ->(*args) do
      args = arg_finder args
      raise 'Incorrect number of arguments' unless params.size == args.size
      define_func_helper other.dup, params.dup, args
    end
    proc
  end

  def fetch_define(other)
    if other[0] == '('
      define_function other
    else
      define_var other[0].to_s, (find_all_values other[1..-1])
    end
  end

  def define_var(var, values)
    raise 'Incorrect number of arguments' if values.size != 1
    raise 'Invalid variable name' unless valid_var_name var
    set_var_helper var, values[0]
  end

  def set_values_define(other, params, args)
    args = [args] unless args.is_a? Array
    other.each_with_index do |t, idx|
      if params.include? t
        i = params.index t
        other[idx] = args[i]
      end
    end
    other
  end

  def define_func_helper(other, params, args)
    temp = set_values_define other, params, args
    calc_input_val temp
  end

  def arg_finder_helper(name, args)
    if !name.nil?
      args = args[1..-1]
      [name, args]
    else
      find_next_value args
    end
  end

  def arg_finder(args)
    result = []
    until args.empty?
      name = predefined_method_caller [args[0]]
      temp, args = arg_finder_helper name, args
      result << temp
    end
    result
  end

  def define_function(other)
    idx = find_bracket_idx other, 0
    name, *params = other[1..idx - 1]
    build_fn = ['(', 'lambda', '(', *params, ')', *other[idx + 1..-1], ')']
    define_var name, (find_all_values build_fn)
  end
end

# Functional programming main functions
module FunctionalScheme
  include FunctionalSchemeHelper
  def map(other)
    func, other = valid_function other
    lst = find_all_values other
    lst = lst.map { |t| find_list_function_value [t] }
    lst = (equalize_lists lst).transpose
    build_list map_helper lst, func
  end

  def foldl(other)
    func, other = valid_function other
    val_one, val_two = get_fold_values other
    foldl_helper func, val_one, val_two
  end

  def foldr(other)
    func, other = valid_function other
    val_one, val_two = get_fold_values other
    foldr_helper func, val_one, val_two
  end

  def filter(other)
    func, other = valid_function other
    values = find_all_values other
    values = find_list_function_value [values[0]]
    result =
      if func.is_a? Proc
        values.select { |t| func.call(*t) == '#t' }
      else
        values.select { |t| (send func, [t]) == '#t' }
      end
    build_list result
  end

  def member(other)
    raise 'Incorrect number of arguments' unless other.size == 2
    to_check = other[0]
    split_val = split_list_string other[1]
    raise 'Invalid argument' unless split_val.pair? || split_val.list?
    member_helper to_check, split_val[2..-2]
  end

  def remove(other)
    raise 'Incorrect number of arguments' unless other.size == 2
    to_remove = other[0]
    values = find_list_function_value [other[1]]
    values.delete_at(values.index(to_remove) || values.length)
    build_list values
  end

  def shuffle(other)
    values = find_list_function_value other
    build_list values.shuffle
  end

  def apply(other)
    func, other = valid_function other
    values = find_all_values other
    *vs, lst = values
    raise 'Incorrect data type' unless lst.list?
    (find_list_function_value [lst]).each { |t| vs << t }
    if func.is_a? Proc
      func.call(*vs)
    else
      send func, vs
    end
  end

  def compose(other)
    tmp = ['(', *other[1..-1]]
    idx = find_bracket_idx tmp, 0
    funcs = find_all_values tmp[1..idx - 1]
    value, = find_next_value tmp[idx + 1..-1]
    funcs.reverse.each do |t|
      value = calc_input_val ['(', t, value, ')']
    end
    value
  end

  def lambda(other)
    if other[0] == 'lambda'
      eval_lambda other[1..-1]
    else
      proc_lambda other
    end
  end

  def define(other)
    fetch_define other
  end
end
