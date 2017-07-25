load 'errors.rb'
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
    return false if size < 3
    check_for_list
  end

  def pair?
    res = object_split if is_a? String
    res = to_a if is_a? Array
    return true if res[-3] == '.'
    list? && !res[2..-2].empty?
  end

  private

  def object_split
    result = to_s.split(/(\(|\)|\.)|\ /)
    result.delete('')
    result
  end

  def check_for_list
    res = to_a if is_a? Array
    res = object_split if is_a? String
    res[0..1].join == '\'(' && res[-1] == ')' && res[-3] != '.'
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

  def check_for_quote(token)
    return true if token[0] == '\''
    is_instance_var = check_instance_var token
    return true if is_instance_var && (check_for_number get_var token)
    false
  end

  def check_for_list(other)
    if other[0..1].join == '\'('
      other.list?
    else
      result, = find_next_function_value other
      split_result = split_list_string result
      split_result.list?
    end
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
    return true if is_instance_var && (check_for_character get_var var)
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
    @other = []
    @custom = []
    @procs = {}
    @predefined = []
    @do_not_calculate =
      [
        'define',
        'foldl',
        'foldr',
        'map',
        'filter',
        'if',
        'numerator',
        'apply',
        'lambda',
        'denominator'
      ]
    @reserved =
      {
        'null' => '\'()'
      }
    set_reserved_keywords
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
        'string-join' => 'strjoin',
        'list-ref' => 'listref',
        'list-tail' => 'listtail'
      }
  end

  # /c[ad]{2,}r/

  def set_reserved_keywords
    @reserved.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def tokenize(token)
    reset
    split_token token
    begin
      calc_input_val @other
    rescue RuntimeError => e
      e.message
    end
  end

  def reset
    @other = []
  end

  def split_token(token)
    token.split(/\s+(?=(?:[^"]*"[^"]*")*[^"]*$)/).each do |t|
      if t.include?('(') || t.include?(')')
        t.to_s.split(%r{(\(|\)|\/)}).each { |p| @other << p }
      else
        @other << t
      end
    end
    @other.delete('')
  end

  def calc_input_val(arr)
    get_raw = (arr.is_a? Array) && arr.size > 1 && arr[0..1].join != '\'('
    return get_raw_value arr unless get_raw
    m_name = predefined_method_caller arr
    call_predefined_method m_name, arr[2..-2]
  end

  def find_all_values(other)
    result = []
    until other.empty?
      x, other = find_next_value other
      result << x
    end
    result
  end

  def call_predefined_method(m_name, arr)
    return m_name.call *arr if m_name.is_a? Proc
    if @do_not_calculate.include? m_name
      send m_name.to_s, arr
    elsif !m_name.nil?
      values = find_all_values arr
      send m_name.to_s, values
    else
    end
  end

  def predefined_method_caller(arr)
    operations = ['+', '-', '/', '*', '<', '<=', '>', '>=']
    m_name =
      arr.each do |t|
        break t if !t.match(/[[:alpha:]]/).nil? || (operations.include? t)
      end
    return @procs[m_name] if @procs.key? m_name
    return m_name if @custom.include? m_name
    return m_name if operations.include? m_name
    return m_name if @predefined.include? m_name
    return @functions[m_name] if @functions.key? m_name
  end

  def get_raw_value(token)
    if token.pair? || token.list?
      build_list no_eval_list token[2..-2]
    else
      return if token.empty?
      token = token.join('') if token.is_a? Array
      get_var token.to_s
    end
  end

  def find_bracket_idx(other, first_bracket)
    open_br = 0
    other[first_bracket..other.size - 1].each_with_index do |token, idx|
      open_br += 1 if token == '('
      open_br -= 1 if token == ')'
      return idx + first_bracket if open_br.zero?
    end
  end

  def find_next_function_value(other)
    idx = (find_bracket_idx other, 0)
    value = calc_input_val other[0..idx]
    other = other[idx + 1..other.size]
    [value, other]
  end

  def size_for_list_elem(values)
    result = []
    values.each do |v|
      if v.include?('(') || v.include?(')')
        v.split(/(\(|\))|\ /).each { |t| result << t unless t == '' }
      else
        result << v
      end
    end
    result.size
  end

  def find_next_value_helper(other)
    value = no_eval_list other[2..(find_bracket_idx other, 1) - 1]
    [(build_list value), other[3 + (size_for_list_elem value)..-1]]
  end

  def find_next_value(other)
    if other[0] == '('
      find_next_function_value other
    elsif other[0..1].join == '\'('
      find_next_value_helper other
    else
      value = get_var other[0].to_s
      [value, other[1..-1]]
    end
  end

  def get_k_arguments(other, return_other, k)
    result = []
    while (k -= 1) >= 0
      x, other = find_next_value other
      result << x
    end
    result << other if return_other
    result
  end

  def define(other)
    fetch_define other
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
    valid = (valid_var values[0].to_s) || (values[0].is_a? Proc)
    raise 'Invalid parameter' unless valid
    @procs[var] = values[0] if values[0].is_a? Proc
    set_var var, values[0]
  end

  def set_values_define(other, params, args)
    other.each_with_index do |t, idx|
      if params.include? t
        i = params.index t
        other[idx] = args[i]
      end
    end
    other
  end

  def define_function(other)
    idx = find_bracket_idx other, 0
    name, *params = other[1..idx - 1]
    @custom << name
    define_singleton_method name.to_sym do |args|
      raise 'Invalid number of arguments' if args.size != params.size
      local_params = params
      temp = set_values_define other[idx + 1..-1], local_params, args
      calc_input_val temp
    end
  end

  def set_var(var, value)
    raise 'Cannot predefine reserved keyword' if @reserved.key? var
    instance_variable_set("@#{var}", value)
  end

  def get_var(var)
    check = check_instance_var var
    return instance_variable_get("@#{var}") if check
    valid = valid_var var
    valid ? var : (raise 'Invalid data type')
  end
end
