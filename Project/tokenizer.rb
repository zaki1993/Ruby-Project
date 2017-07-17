load 'validator.rb'
load 'numbers.rb'
load 'strings.rb'
load 'boolean.rb'
load 'list.rb'

# redefine method in Object class
class Object
  def number?
    to_f.to_s == to_s || to_i.to_s == to_s
  end

  def to_num
    return to_f if to_f.to_s == to_s
    return to_i if to_i.to_s == to_s
  end

  def character?
    (start_with? '#\\') && (('a'..'z').to_a.include? self[2]) && size == 3
  end

  def string?
    return false unless self.class == String
    (start_with? '"') && (end_with? '"') && (size != 1)
  end

  def list?
    (self[0..1].join == '\'(' || self[0..1].join == '(list') && self[-1] == ')'
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
  
  def check_for_list(token)
    return true if token[0..1].join == '\'(' && token[-1] == ')'
    result, _ = find_next_value token, false
    result
  end

  def check_instance_var(var)
    return false unless valid_var_name var
    instance_variable_defined?("@#{var}")
  end

  def check_for_symbol(var)
    var = var.join('') if var.is_a? Array
    return true if var == '#\space'
    return true if var.character?
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
  include SchemeStrings
  include SchemeBooleans
  include SchemeLists

  def initialize
    @tokens = []
    @predefined = []
    File.readlines('functions.txt').each { |l| @predefined << l.chomp }
    @functions =
      {
        'string-length' => 'strlen',
        'string-upcase' => 'strupcase',
        'string-downcase' => 'strdowncase',
        'string-contains?' => 'strcontains',
        'string->list' => 'strlist',
        'string-split' => 'strsplit',
        'string-replace' => 'strreplace',
        'string-prefix?' => 'strprefix',
        'string-sufix?' => 'strsufix',
        'string-join' => 'strjoin'
      }
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
    get_raw = (arr.is_a? Array) && arr.size > 1 && arr[0..1].join != '\'('
    return get_raw_value arr unless get_raw
    token_caller = predefined_method_caller arr
    if token_caller != arr
      send token_caller.to_s, arr[2..-2]
    else
      custom_method_caller arr
    end
  end

  def predefined_method_caller(arr)
    operations = ['+', '-', '/', '*', '<', '<=', '>', '>=']
    m_name =
      arr.find { |t| !t.match(/[[:alpha:]]/).nil? } ||
      arr.each { |t| return t if operations.include? t }
    return m_name if @predefined.include? m_name
    return @functions[m_name] if @functions.key? m_name
  end

  def custom_method_caller(arr)
    puts 'trying custom methods: ' + arr.to_s
  end

  def get_raw_value(token)
    if token.list?
      result = do_not_evaluate_list token[2..-2], false
      build_list result
    else
      token = token.join('') if token.is_a? Array
      get_var token.to_s
    end
  end

  def find_bracket_idx(tokens, first_bracket)
    open_br = 0
    tokens[first_bracket..tokens.size - 1].each_with_index do |token, idx|
      open_br += 1 if token == '('
      open_br -= 1 if token == ')'
      return idx + first_bracket if open_br.zero?
    end
  end

  def find_next_function_value(tokens)
    idx = (find_bracket_idx tokens, 0)
    value = calc_input_val tokens[0..idx]
    tokens = tokens[idx + 1..tokens.size]
    [value, tokens]
  end
  
  def size_for_list_elem(values)
    result = []
    values.each do |v|
      if v.include?('(') || v.include?(')')
        v.split(/(\(|\))|\ /).each { |t| result << t unless t == ''}
      else
        result << v
      end
    end
    result.size
  end

  def find_next_value(tokens, is_num)
    if tokens[0] == '('
      value, tokens = find_next_function_value tokens
      [is_num ? value.to_num : value, tokens]
    elsif tokens[0..1].join == '\'('
      value = do_not_evaluate_list tokens[2..(find_bracket_idx tokens, 1) - 1], false
      puts value
      puts tokens[3 + (size_for_list_elem value)..-1]
      [(build_list value), tokens[3 + (size_for_list_elem value)..-1]]
    else
      value = calc_input_val tokens[0..0]
      [is_num ? value.to_num : value, tokens[1..-1]]
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

  def define(tokens)
    fetch_define tokens
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
