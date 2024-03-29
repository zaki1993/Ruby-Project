require_relative 'stl_constants'

# Optimization module
module Optimize
  include SchemeStl
  def fold_values_helper(other)
    other = other.map { |t| find_list_function_value [t] }
    (equalize_lists other).transpose
  end

  def get_fold_values(other)
    values = find_all_values other
    raise arg_err_build 'at least 2', 0 if values.empty?
    x = values[0]
    y = fold_values_helper values[1..-1]
    [x, y]
  end

  def rm_from_in_scope(scope, idx, def_vars)
    i = find_bracket_idx scope, idx
    def_vars[scope[idx + 2].to_s] = scope[idx + 3..i - 1]
    scope.slice!(idx..i)
    [i + 1, scope, def_vars]
  end

  def inner_scope_replace(scope, vars)
    scope.each_with_index do |t, i|
      scope[i] = vars[t.to_s] if vars.key? t.to_s
    end
    scope.flatten
  end

  def fetch_inner_scope(scope, idx = 0, def_vars = {})
    until idx >= scope.size
      if scope[idx] == 'define'
        idx, scope, def_vars = rm_from_in_scope scope, idx - 1, def_vars
      else
        idx += 1
      end
    end
    inner_scope_replace scope, def_vars
  end

  def filter_helper(func, values)
    result =
      if func.is_a? Proc
        values.select { |t| func.call(*t) == TRUE }
      else
        values.select { |t| (send func, [t]) == FALSE }
      end
    build_list result
  end

  def apply_helper(func, values)
    *vs, lst = values
    raise 'Incorrect data type' unless lst.list?
    (find_list_function_value [lst]).each { |t| vs << t }
    return func.call(*vs) if func.is_a? Proc
    send func, vs
  end

  def call_compose_helper(other)
    tmp = ['(', *other[1..-1]]
    idx = find_bracket_idx tmp, 0
    funcs = find_all_values tmp[1..idx - 1]
    return '' if tmp[idx + 1..-1].nil? && funcs.empty?
    [funcs, idx, tmp]
  end

  def call_compose(other)
    funcs, idx, tmp = call_compose_helper other
    value = find_all_values tmp[idx + 1..-1]
    funcs.reverse.each do |t|
      value = value.to_s unless value.is_a? Array
      value = calc_input_val ['(', t, *value, ')']
    end
    is_arr = value.is_a? Array
    is_arr ? value[0] : value
  end

  def build_compose_expr(funcs)
    expr = ['(', 'x', ')']
    funcs.each do |f|
      expr << '('
      expr << f
    end
    expr << 'x'
    funcs.size.times { expr << ')' }
    expr
  end

  def do_not_call_compose(other)
    funcs = find_all_values other
    raise 'Incorrect data type' if funcs.any? { |t| t.to_s.number? }
    expr = build_compose_expr funcs
    proc_lambda expr
  end

  def define_var_stl(var, values)
    valid_stl = methods.include? values.to_s[2..-3].to_sym
    return set_var var, values.to_s[2..-3].to_sym if valid_stl
    set_var var, values[0]
  end
end

# FunctionalScheme helper
module FunctionalSchemeHelper
  include Optimize
  def foldl_helper(func, accum, lst)
    return accum if lst.empty?
    value = func.call(*lst[0], accum.to_s) if func.is_a? Proc
    value = send func, [*lst[0], accum] if value.nil?
    foldl_helper func, value.to_s, lst[1..-1]
  end

  def foldr_helper(func, accum, lst)
    return accum if lst.empty?
    value = foldr_helper func, accum, lst[1..-1]
    return func.call(*lst[0], value.to_s) if func.is_a? Proc
    send func, [*lst[0], value.to_s]
  end

  def equalize_lists(other)
    min = other.map(&:size).min
    other.map { |t| t[0..min - 1] }
  end

  def member_helper(to_check, values)
    return FALSE unless values.include? to_check
    idx = values.index(to_check)
    build_list values[idx..-1]
  end

  def find_params_lambda(other)
    raise 'Invalid syntax' if other[0] != '('
    idx = find_bracket_idx other, 0
    [other[1..idx - 1], other[idx + 1..-1]]
  end

  def eval_lambda(other)
    idx = find_bracket_idx other.unshift('('), 0
    to_eval = other[1..idx - 1]
    (proc_lambda to_eval, true).call(*other[idx + 1..-1])
  end

  def proc_lambda_helper(other, params, args)
    args = arg_finder args
    raise arg_err_build params.size, args.size unless params.size == args.size
    define_func_helper other.dup, params.dup, args
  end

  def proc_lambda(other, is_call = false)
    params, other = find_params_lambda other
    other = fetch_inner_scope other
    valid = params.all? { |t| valid_var_name t } || is_call
    raise 'Invalid syntax' unless valid
    to_return = other[0..1].join == '(compose' && params.empty?
    return calc_input_val other if to_return
    proc = proc do |*args|
      proc_lambda_helper other, params, args
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
    raise arg_err_build 1, values.size if values.size != 1
    raise var.to_s + ' is not valid variable name' unless valid_var_name var
    define_var_stl var, values
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
    (find_all_values temp)[-1]
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
  def foldl(other)
    raise arg_err_build 'at least 2', other.size if other.size < 2
    func, other = valid_function other
    val_one, val_two = get_fold_values other
    foldl_helper func, val_one, val_two
  end

  def foldr(other)
    raise arg_err_build 'at least 2', other.size if other.size < 2
    func, other = valid_function other
    val_one, val_two = get_fold_values other
    foldr_helper func, val_one, val_two
  end

  def filter(other)
    raise arg_err_build 2, other.size if other.size < 2
    func, other = valid_function other
    raise arg_err_build 2, 1 if other.empty?
    values = find_all_values other
    values = find_list_function_value [values[0]]
    filter_helper func, values
  end

  def member(other)
    raise arg_err_build 2, other.size unless other.size == 2
    to_check = other[0]
    split_val = split_list_string other[1]
    raise 'Invalid argument' unless split_val.pair? || split_val.list?
    values = find_all_values split_val[2..-2]
    member_helper to_check, values
  end

  def remove(other)
    raise arg_err_build 2, other.size unless other.size == 2
    to_remove = other[0]
    values = find_list_function_value [other[1]]
    values.delete_at(values.index(to_remove) || values.length)
    build_list values
  end

  def apply(other)
    raise arg_err_build 'at least 2', 0 if other.nil? || other.empty?
    func, other = valid_function other
    raise arg_err_build 'at least 2', 1 if other.empty?
    values = find_all_values other
    apply_helper func, values
  end

  def compose(other)
    if other[0] != 'compose'
      do_not_call_compose other
    else
      call_compose other
    end
  end

  def lambda(other)
    if other[0] == 'lambda'
      eval_lambda other[1..-1]
    else
      proc_lambda other
    end
  end

  def define(other)
    raise arg_err_build 2, other.size if other.size < 2
    fetch_define other
  end
end
