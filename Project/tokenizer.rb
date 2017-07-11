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
    return false if !valid_var_name var
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
    puts 'calc_input_val: ' + arr.to_s
    return get_raw_value arr unless (arr.is_a? Array) && arr.size > 1
    token_caller = ''
    arr.each do |token|
      next if ['(', ')'].include? token
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
  
  def find_matching_bracket_idx(tokens, first_bracket)
    open_br = 0
    tokens[first_bracket..tokens.size - 1].each_with_index do |token, idx|
      open_br += 1 if token == '('
      open_br -= 1 if token == ')'
      return idx + first_bracket if open_br == 0
    end
  end
  
  def find_next_value(tokens)
    if tokens[0] == '('
      idx = (find_matching_bracket_idx tokens, 0)
      value = calc_input_val tokens[0..idx]
      tokens = tokens[idx + 1..tokens.size]
      [value.to_num, tokens]
    else
      [(get_var tokens[0]).to_num, tokens[1..tokens.size]]
    end
  end
  
  def +(tokens)
    tokens = tokens[2..tokens.size - 2]
    return 0 if tokens.size == 0
    result, tokens = find_next_value(tokens)
    while tokens.size > 0 do
      x, tokens = find_next_value(tokens)
      result += x
    end
    result
  end
  
  def -(tokens)
    tokens = tokens[2..tokens.size - 2]
    raise 'Too little arguments' if tokens.size == 0
    result, tokens = find_next_value(tokens)
    while tokens.size > 0 do
      x, tokens = find_next_value(tokens)
      result -= x
    end
    result
  end
  
  def *(tokens)
    tokens = tokens[2..tokens.size - 2]
    return 1 if tokens.size == 0
    result, tokens = find_next_value(tokens)
    while tokens.size > 0 do
      x, tokens = find_next_value(tokens)
      result *= x
    end
    result
  end
  
  def /(tokens)
    tokens = tokens[2..tokens.size - 2]
    raise 'too little arguments' if tokens.size == 0
    result = 1.0 if tokens.size == 1
    result, tokens = find_next_value(tokens) if tokens.size > 1
    while tokens.size > 0 do
      x, tokens = find_next_value(tokens)
      result = divide_number(result, x)
    end
    result
  end

  def not(tokens)
    open_br = 0
    tokens.each_with_index do |token, idx|
      open_br += 1 if token == '('
      break if token == 'not'
    end
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
    raise 'Incorrect boolean' if !check_for_bool var
    (get_var var) == '#t' ? '#f' : '#t'
  end

  def define(tokens)
    open_br = 0
    tokens.each_with_index do |token, idx|
      open_br += 1 if token == '('
      break if token == 'define'
    end
    arr_param = tokens[open_br + 1 .. tokens.length - open_br - 1]
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
    (check_instance_var var) ? instance_variable_get("@#{var}") : var
  end
end
