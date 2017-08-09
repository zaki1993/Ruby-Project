require_relative 'core/loader'
require_relative 'helpers/value_finder'
require_relative 'helpers/checker'
require_relative 'helpers/validator'

# Tokenizer class
class Tokenizer
  include StlLoader
  include ErrorMessages
  include ValueFinder
  include SchemeChecker
  include Validator
  include SchemeNumbers
  include SchemeStrings
  include SchemeBooleans
  include SchemeLists
  include FunctionalScheme

  def syntax_methods
    @functions
  end

  def tokenize(token)
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
    raise no_procedure_build arr[1].to_s if result.nil?
    car_cdr_infinite arr
  end

  def calc_input_val(arr)
    get_raw = (arr.is_a? Array) && arr.size > 1 && arr[0..1].join != '\'('
    return get_raw_value arr unless get_raw
    m_name = predefined_method_caller arr
    return check_car_cdr arr if m_name.nil?
    call_predefined_method m_name, arr
  end

  def check_for_stl_function(arr)
    idx = find_bracket_idx arr, 1
    func, = valid_function arr[1..idx]
    values = find_all_values arr[idx + 1..-2]
    return func.call(*values) if func.is_a? Proc
    calc_input_val ['(', func, *values, ')']
  end

  def special_check_proc(m_name, arr)
    if arr[0..1].join == '(('
      check_for_stl_function arr
    else
      m_name.call(*arr[2..-2])
    end
  end

  def validate_call_method(m_name)
    raise no_procedure_build m_name.to_s if valid_var m_name.to_s
  end

  def call_predefined_method(m_name, arr)
    return special_check_proc m_name, arr if m_name.is_a? Proc
    if DO_NOT_CALCULATE_FUNCTIONS.include? m_name
      send m_name.to_s, arr[2..-2]
    elsif !m_name.nil?
      values = find_all_values arr[2..-2]
      validate_call_method m_name
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
end
