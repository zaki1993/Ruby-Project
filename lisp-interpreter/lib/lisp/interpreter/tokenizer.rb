require_relative 'object'
require_relative 'errors'
require_relative 'value_finder'
require_relative 'checker'
require_relative 'validator'
require_relative 'numbers'
require_relative 'strings'
require_relative 'boolean'
require_relative 'list'
require_relative 'functional'

# Tokenizer helper
module TokenizerHelper
  def initialize
    @other = []
    @procs = {}
    @do_not_calculate = init_do_not_calculate_fn
    @reserved = init_reserved_fn
    set_reserved_keywords
    @functions = init_functions
    init_predefined.each { |f| @functions[f] = f }
  end

  def reset
    @other = []
  end

  def init_do_not_calculate_fn
    %w[
      foldl foldr map filter
      if apply numerator denominator
      lambda compose define
    ]
  end

  def init_functions
    {
      'string-downcase'  => 'strdowncase', 'string-upcase'  => 'strupcase',
      'string-contains?' => 'strcontains', 'string-length'  => 'strlen',
      'string->list'     => 'strlist',     'string-split'   => 'strsplit',
      'string-sufix?'    => 'strsufix',    'string-prefix?' => 'strprefix',
      'string-replace'   => 'strreplace',  'string-join'    => 'strjoin',
      'list-ref'         => 'listref',     'list-tail'      => 'listtail'
    }
  end

  def init_predefined
    %w[
      define not equal? if quotient remainder modulo numerator denominator
      min max sub1 add1 abs string? substring null? cons null list car
      cdr list? pair? length reverse remove shuffle map foldl foldr filter
      member lambda apply compose
    ]
  end

  def init_reserved_fn
    {
      'null' => '\'()'
    }
  end

  def set_reserved_keywords
    @reserved.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def set_var_helper(var, value)
    valid = (valid_var value.to_s) || (value.is_a? Proc)
    raise 'Invalid parameter' unless valid
    if value.is_a? Proc
      remove_instance_variable("@#{var}") if check_instance_var var
      @procs[var] = value if value.is_a? Proc
    else
      @procs.delete var
      set_var var, value
    end
  end

  def set_var(var, value)
    raise 'Cannot predefine reserved keyword' if @reserved.key? var
    instance_variable_set("@#{var}", value)
  end

  def get_var(var)
    check = check_instance_var var
    return instance_variable_get("@#{var}") if check
    val = (predefined_method_caller [var])
    return val unless val.nil?
    valid = valid_var var
    valid ? var : (raise 'Invalid data type')
  end
end

# Tokenizer class
class Tokenizer
  include TokenizerHelper
  include ValueFinder
  include SchemeChecker
  include Validator
  include SchemeNumbers
  include SchemeStrings
  include SchemeBooleans
  include SchemeLists
  include FunctionalScheme

  def tokenize(token)
    reset
    token.delete('')
    @other = token
    begin
      calc_input_val @other
    rescue ZeroDivisionError, RuntimeError => e
      e.message
    end
  end

  def check_car_cdr(arr)
    result = arr[1].match(/c[ad]{2,}r/)
    raise 'No procedure found' if result.nil?
    car_cdr_infinite arr
  end

  def calc_input_val(arr)
    get_raw = (arr.is_a? Array) && arr.size > 1 && arr[0..1].join != '\'('
    return get_raw_value arr unless get_raw
    m_name = predefined_method_caller arr
    return check_car_cdr arr if m_name.nil?
    call_predefined_method m_name, arr
  end

  def special_check_proc(m_name, arr)
    if arr[0..1].join == '(('
      idx = find_bracket_idx arr, 1
      func, = valid_function arr[1..idx]
      values = find_all_values arr[idx + 1..-2]
      func.call(*values)
    else
      m_name.call(*arr[2..-2])
    end
  end

  def call_predefined_method(m_name, arr)
    return special_check_proc m_name, arr if m_name.is_a? Proc
    if @do_not_calculate.include? m_name
      send m_name.to_s, arr[2..-2]
    elsif !m_name.nil?
      values = find_all_values arr[2..-2]
      send m_name.to_s, values
    end
  end

  def predefined_method_caller_helper(m_name, operations)
    return m_name if m_name.is_a? Proc
    return @procs[m_name] if @procs.key? m_name
    return m_name if operations.include? m_name
    return @functions[m_name] if @functions.key? m_name
    m_name if @functions.value? m_name
  end

  def method_caller_checker(token, operations)
    !token.to_s.match(/[[:alpha:]]/).nil? || (operations.include? token.to_s)
  end

  def predefined_method_caller(arr)
    operations = ['+', '-', '/', '*', '<', '<=', '>', '>=']
    m_name =
      arr.each do |t|
        break t if t.is_a? Proc
        break t if method_caller_checker t, operations
        break t unless t.match(/[[:digit:]]/).nil?
      end
    predefined_method_caller_helper m_name, operations
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
end
