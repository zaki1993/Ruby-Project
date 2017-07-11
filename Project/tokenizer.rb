# redefine method in Object class
class Object
  def number?
    to_f.to_s == to_s || to_i.to_s == to_s
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
      calc_input_val @tokens, true
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

  def calc_input_val(arr, print)
    return get_raw_value arr, print unless (arr.is_a? Array) && arr.size > 1
    token_caller = ''
    arr.each do |token|
      next if ['(', ')'].include? token
      result = !File.readlines('functions.txt').grep(/[#{token}]/).empty?
      token_caller = token if result
      break if result
    end
    send(token_caller.to_s, arr)
  end

  def get_raw_value(token, print)
    token = token.join('') if token.is_a? Array
    result =
      if check_instance_var token
        get_var token.to_s
      else
        valid = valid_var token
        valid ? token : (raise 'No variable or function with this name')
      end
    print ? (print_result result) : result
  end

  def print_result(result)
    puts result
  end

  def not(tokens)
    open_br = 0
    tokens.each_with_index do |token, idx|
      open_br += 1 if token == '('
      break if token == 'not'
    end
    arr_param = tokens[open_br + 1..tokens.length - open_br - 1]
    result = fetch_not arr_param
    puts result
  end

  def fetch_not(tokens)
    if tokens[0] == '('
      res = calc_input_val tokens[0..tokens.length - 1], false
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
      next unless token == 'define'
      fetch_define tokens, idx + 1, tokens.length - open_br - 1
    end
  end

  def fetch_define(tokens, start_idx, end_idx)
    if tokens[start_idx] == '('
      define_function tokens, start_idx, end_idx
    else
      define_var tokens, start_idx, end_idx
    end
  end

  def define_var(tokens, start_idx, end_idx)
    value =
      if start_idx + 1 == end_idx
        calc_input_val tokens[start_idx + 1], false
      else
        calc_input_val tokens[start_idx + 1..end_idx], false
      end
    valid = valid_var_name tokens[start_idx]
    valid ? (set_var tokens[start_idx], value) : (raise 'Incorrect parameter')
  end

  def define_function(tokens, start_idx, end_idx)
    puts 'function'
  end

  def set_var(var, value)
    instance_variable_set("@#{var}", value)
  end

  def get_var(var)
    (check_instance_var var) ? instance_variable_get("@#{var}") : var
  end
end
