# redefine method in Object class
class Object
  def number?
    to_f.to_s == to_s || to_i.to_s == to_s
  end

  def to_num
    return to_f if to_f.to_s == to_s
    return to_i if to_i.to_s == to_s
  end
end

# Check if variable is specific type
module SchemeChecker
  def check_for_bool(token)
    return true if ['#t', '#f'].include? token
    is_instance_var = check_instance_var token
    return true if is_instance_var && (check_for_bool get_var token)
    false
  end

  def check_for_string(token)
    return true if token.start_with?('"') && token.end_with?('"')
    is_instance_var = check_instance_var token
    return true if is_instance_var && (check_for_string get_var token)
    false
  end

  def check_for_number(token)
    return true if token.number?
    is_instance_var = check_instance_var token
    return true if is_instance_var && (check_for_number get_var token)
    false
  end

  def check_instance_var(var)
    return false unless valid_var_name var
    instance_variable_defined?("@#{var}")
  end

  def valid_var_name(var)
    !var.match(/^[[:alpha:]]+$/).nil?
  end

  def valid_var(var)
    (check_for_number var) || (check_for_string var) || (check_for_bool var)
  end

  def divide_number(a, b)
    return a / b if (a / b).to_i.to_f == a / b.to_f
    a / b.to_f
  end
end

# Tokenizer class
class Tokenizer
  include SchemeChecker
  def initialize
    @tokens = []
  end

  def tokenize(token)
    reset
    split_token token
    begin
      puts calc_input_val @tokens
    rescue NameError
      puts 'Not valid name for variable'
    rescue RuntimeError
      puts 'No variable or function with this name'
    end
  end

  def reset
    @tokens = []
  end

  def split_token(token)
    token.split(/\s+(?=(?:[^"]*"[^"]*")*[^"]*$)/).each do |t|
      if t.include?('(') || t.include?(')')
        t.to_s.split(/(\(|\))/).each { |p| @tokens << p }
      else
        @tokens << t
      end
    end
    @tokens.delete('')
  end

  def calc_input_val(arr)
    return get_raw_value arr unless (arr.is_a? Array) && arr.size > 1
    token_caller = ''
    arr.each do |token|
      next if token == '('
      result = !File.readlines('functions.txt').grep(/[#{token}]/).empty?
      token_caller = token if result
      break if result
    end
    send(token_caller.to_s, arr)
  end

  def get_raw_value(token)
    token = token.join('') if token.is_a? Array
    result =
      if check_instance_var token
        get_var token.to_s
      else
        valid = valid_var token
        valid ? token : (raise 'No variable or function with this name')
      end
    result
  end

  def equal?(other)
    other = other[2..other.size - 2]
    first, other = find_next_value other, false
    second, other = find_next_value other, false
    raise 'Too many arguments' unless other.empty?
    raise 'Unbound symbol' unless (valid_var first) && (valid_var second)
    first.to_s == second.to_s ? '#t' : '#f'
  end

  def find_matching_bracket_idx(tokens, first_bracket)
    open_br = 0
    tokens[first_bracket..tokens.size - 1].each_with_index do |token, idx|
      open_br += 1 if token == '('
      open_br -= 1 if token == ')'
      return idx + first_bracket if open_br.zero?
    end
  end
  
  def find_next_function_value(tokens)
    idx = (find_matching_bracket_idx tokens, 0)
    value = calc_input_val tokens[0..idx]
    tokens = tokens[idx + 1..tokens.size]
    [value, tokens]
  end

  def find_next_value(tokens, is_num)
    if tokens[0] == '('
      value, tokens = find_next_function_value tokens
      [is_num ? value.to_num : value, tokens]
    else
      value = get_var tokens[0]
      [is_num ? value.to_num : value, tokens[1..tokens.size]]
    end
  end
  
  def calculate_value_arithmetic(tokens, result, sign)
    until tokens.empty?
      x, tokens = find_next_value tokens, true
      case sign
      when '+' then result += x
      when '-' then result -= x
      when '*' then result *= x
      when '/' then result = divide_number(result, x)
      end
    end
    result
  end

  def +(other)
    other = other[2..other.size - 2]
    return 0 if other.size.zero?
    result, other = find_next_value other, true
    calculate_value_arithmetic other, result, '+'
  end

  def -(other)
    other = other[2..other.size - 2]
    raise 'Too little arguments' if other.empty?
    result, other = find_next_value other, true
    calculate_value_arithmetic other, result, '-'
  end

  def *(other)
    other = other[2..other.size - 2]
    return 1 if other.empty?
    result, other = find_next_value other, true
    calculate_value_arithmetic other, result, '*'
  end

  #TODO division by zero
  def /(other)
    other = other[2..other.size - 2]
    raise 'too little arguments' if other.empty?
    result = 1 if other.size == 1
    result, other = find_next_value other, true if other.size > 1
    calculate_value_arithmetic other, result, '/'
  end
  
  def get_args_primary_fun_numbers(tokens, return_tokens)
    tokens = tokens[2..tokens.size - 2]
    raise 'Too little arguments' if tokens.empty?
    x, tokens = find_next_value tokens, true
    raise 'Too little arguments' if tokens.empty?
    y, tokens = find_next_value tokens, true
    raise 'Too much arguments' unless tokens.empty? || return_tokens
    raise 'Number required' unless (check_for_number x) && (check_for_number y)
    return_tokens ? [x, y, tokens] : [x, y]
  end
  
  def primary_func_numbers(tokens, oper)
    x, y = get_args_primary_fun_numbers tokens, false
    case oper
    when 'remainder' then (x.abs % y.abs) * (x / x.abs)
    when 'modulo' then x.modulo(y)
    when 'quotient' then quotient_helper(x, y, minus)
    end
  end
  
  def quotient(tokens)
    primary_func_numbers(tokens, 'quotient')
  end
  
  def remainder(tokens)
    primary_func_numbers(tokens, 'remainder')
  end
  
  def modulo(tokens)
    primary_func_numbers(tokens, 'modulo')
  end
  
  def get_real_number(tokens)
    if tokens.size == 1 && (check_for_number tokens[0])
      [(get_var tokens[0]), 1]
    elsif tokens.size == 1 && (tokens[0].include? '/')
      split_values = tokens[0].split('/')
      [(get_var split_values[0]), (get_var split_values[1])]
    else
      first, tokens = find_next_value tokens, true
      second, tokens = find_next_value tokens, true unless tokens.empty?
      [first, second.nil? ? 1 : second]
    end
  end
  
  def numerator(tokens)
    puts tokens.to_s
    tokens = tokens[2..tokens.size - 2]
    (get_real_number tokens)[0].to_num
  end
  
  def denominator(tokens)
    puts tokens.to_s
    tokens = tokens[2..tokens.size - 2]
    (get_real_number tokens)[1].to_num
  end
  
  def get_one_arg_function(tokens)
    tokens = tokens[2..tokens.size - 2]
    raise 'Too little arguments' if tokens.empty?
    x, tokens = find_next_value tokens, true
    raise 'Too much arguments' unless tokens.empty?
    x
  end
  
  def abs(tokens)
    x = get_one_arg_function tokens
    x.abs
  end
  
  def add1(tokens)
    x = get_one_arg_function tokens
    x + 1
  end
  
  def sub1(tokens)
    x = get_one_arg_function tokens
    x - 1
  end
  
  def min(tokens)
    x, y, tokens = get_args_primary_fun_numbers tokens, true
    result = x < y ? x : y
    unless tokens.empty?
      next_val, tokens = find_next_value tokens, true
      result = next_val if result > next_val
    end
    result
  end
  
  def max(tokens)
    x, y, tokens = get_args_primary_fun_numbers tokens, true
    result = x > y ? x : y
    unless tokens.empty?
      next_val, tokens = find_next_value tokens, true
      result = next_val if result < next_val
    end
    result
  end

  def not(tokens)
    open_br = 0
    tokens.each do |token|
      open_br += 1 if token == '('
      break if token == 'not'
    end
    raise 'Incorrect function' if open_br != 1
    arr_param = tokens[open_br + 1..tokens.length - open_br - 1]
    fetch_not arr_param
  end

  def fetch_not(tokens)
    if tokens[0] == '('
      res = calc_input_val tokens[0..tokens.size - 1]
      not_var res
    else
      tokens.size == 1 ? (not_var tokens[0]) : (raise 'Incorrect parameter')
    end
  end

  def not_var(var)
    raise 'Incorrect boolean' unless check_for_bool var
    (get_var var) == '#t' ? '#f' : '#t'
  end

  def define(tokens)
    open_br = 0
    tokens.each do |token|
      open_br += 1 if token == '('
      break if token == 'define'
    end
    raise 'Incorrect function' if open_br != 1
    arr_param = tokens[open_br + 1..tokens.length - open_br - 1]
    fetch_define arr_param
  end

  def fetch_define(tokens)
    if tokens[0] == '('
      define_function tokens[0..tokens.size - 1]
    else
      define_var tokens
    end
  end

  def define_var(tokens)
    value =
      if tokens.size == 2
        get_var tokens[1]
      else
        calc_input_val tokens[1..tokens.size - 1]
      end
    valid = valid_var_name tokens[0]
    valid ? (set_var tokens[0], value) : (raise 'Incorrect parameter')
  end

  def define_function(tokens)
    puts 'function: ' + tokens.to_s
  end

  def set_var(var, value)
    instance_variable_set("@#{var}", value)
  end

  def get_var(var)
    check = check_instance_var var
    check ? instance_variable_get("@#{var}") : var
  end
end
