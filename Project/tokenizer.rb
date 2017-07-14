load 'validator.rb'
load 'numbers.rb'

# redefine method in Object class
class Object
  def number?
    to_f.to_s == to_s || to_i.to_s == to_s
  end

  def to_num
    return to_f if to_f.to_s == to_s
    return to_i if to_i.to_s == to_s
  end
  
  def symbol?
    (start_with? '#\\') && (('a'..'z').to_a.include? self[2]) && size == 3
  end
  
  def string?
    (start_with? '"') && (end_with? '"')
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
    return true if token.string?
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
  
  def check_for_symbol(var)
    var = var.join('') if var.is_a? Array
    return true if var == '#\space'
    return true if var.symbol?
    is_instance_var = check_instance_var var
    return true if is_instance_var && (check_for_symbol get_var var)
    false
  end
  
  def divide_number(a, b)
    return a / b if (a / b).to_i.to_f == a / b.to_f
    a / b.to_f
  end
end

# Tokenizer class
class Tokenizer
  include SchemeChecker
  include Validator
  include SchemeNumbers
  
  def initialize
    @tokens = []
    @predefined = []
    File.readlines('functions.txt').each { |l| @predefined << l.chomp }
    @functions = { 'string-length' => 'strlen',
                   'string-upcase' => 'strupcase',
                   'string-contains?' => 'strcontains',
                   'string->list' => 'strlist',
                   'string-split' => 'strsplit',
                   'string-replace' => 'strreplace'}
  end

  def tokenize(token)
    reset
    split_token token
    begin
      puts calc_input_val @tokens
    rescue NameError
      puts 'Not valid name for variable'
    rescue ArgumentError
      puts 'Invalid argument'
    rescue TypeError
      puts 'Invalid argument'
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
        t.to_s.split(%r{(\(|\)|\/)}).each { |p| @tokens << p }
      else
        @tokens << t
      end
    end
    @tokens.delete('')
  end

  def calc_input_val(arr)
    return get_raw_value arr unless (arr.is_a? Array) && arr.size > 1
    token_caller = predefined_method_caller arr
    if token_caller != arr
      send token_caller.to_s, arr
    else
      custom_method_caller arr
    end
  end
  
  def predefined_method_caller(arr)
    arr.each { |t| return t if @predefined.include? t }
    arr.each { |t| return @functions[t] if @functions.key? t }
  end
  
  def custom_method_caller(arr)
    puts 'trying custom methods'
  end

  def get_raw_value(token)
    token = token.join('') if token.is_a? Array
    get_var token.to_s
  end

  def equal?(other)
    other = other[2..other.size - 2]
    first, second, other = (get_k_arguments other, true, 2, false)
    raise 'Too many arguments' unless other.empty?
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

  def get_k_arguments(tokens, return_tokens, k, to_number)
    result = []
    while (k -= 1) >= 0
      x, tokens = find_next_value tokens, to_number
      result << x
    end
    result << tokens if return_tokens
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
  
  def string_getter(tokens, get_tokens)
    str, tokens = find_next_value tokens, false
    raise 'String needed' unless check_for_string str
    [str, get_tokens ? tokens : _]
  end

  def substring_builder(str, from, to)
    '"' + (str[1..-2])[from..(to.nil? ? -1 : to - 1)] + '"'
  end

  def substring(tokens)
    tokens = tokens[2..-2]
    str, tokens = string_getter tokens, true
    from, tokens = find_next_value tokens, true
    to, tokens = find_next_value tokens, true unless tokens.empty?
    raise 'Too much arguments' unless tokens.empty?
    substring_builder str, from, to
  end

  def string?(tokens)
    tokens = tokens[2..-2]
    str, tokens = find_next_value tokens, false
    raise 'Too much arguments' unless tokens.empty?
    result = check_for_string str
    result ? '#t' : '#f'
  end
  
  def strlen(tokens)
    tokens = tokens[2..-2]
    str, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    str[1..-2].length
  end
  
  def strupcase(tokens)
    tokens = tokens[2..-2]
    str, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    str.upcase
  end
  
  def strcontains(tokens)
    tokens = tokens[2..-2]
    string, tokens = string_getter tokens, true
    to_check, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    result = string.include? to_check[1..-2]
    result ? '#t' : '#f'
  end
  
  def remove_carriage(str)
    str = str[1..-2]
    str.gsub('\n', '').
        gsub('\r', '').
        gsub('\t', '').
        strip.
        squeeze(' ')
  end
  
  def strsplit(tokens)
    tokens = tokens[2..-2]
    str, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    str = remove_carriage str
    '\'(' + str.split(' ').
    map { |s| '"'+ s + '"' }.join(' ') + ')'
  end
  
  def strlist(tokens)
    tokens = tokens[2..-2]
    str, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    '\'(' + str[1..-2].chars.
    map { |c| '#\\' + (c == ' ' ? 'space' : c) }.join(' ') + ')'
  end
  
  def strreplace(tokens)
    tokens = tokens[2..-2]
    string, tokens = string_getter tokens, true
    to_replace, tokens = string_getter tokens, true
    replace_with, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    string.gsub(to_replace[1..-2], replace_with[1..-2])
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
      define_function tokens
    else
      define_var tokens
    end
  end

  def define_var(tokens)
    var_name = tokens[0]
    value, tokens = find_next_value tokens[1..-1], false
    raise 'Too much arguments' unless tokens.empty?
    valid = valid_var_name var_name
    valid ? (set_var var_name, value) : (raise 'Incorrect parameter')
  end

  def define_function(tokens)
    puts 'function: ' + tokens.to_s
  end

  def set_var(var, value)
    instance_variable_set("@#{var}", value)
  end

  def get_var(var)
    check = check_instance_var var
    return instance_variable_get("@#{var}") if check
    return var if valid_var var
    raise 'Invalid variable'
  end
end
