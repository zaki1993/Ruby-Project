# Helper functions for SchemeNumbers
module SchemeNumbersHelper
  def get_one_arg_function(other)
    raise 'Incorrect number of arguments' if other.size != 1
    raise 'Invalid data type' unless check_for_number other[0]
    other[0].to_num
  end

  def find_idx_numerators(other)
    other[0] == '(' ? (find_bracket_idx other, 0) + 1 : 1
  end

  def num_denom_helper(other)
    raise 'Incorrect number of arguments' if other.empty?
    if other.size == 1
      other = other[0].split('/')
    else
      _, temp = find_next_value other
      raise 'Incorrect number of arguments' unless temp[0] == '/' || temp.empty?
      i = find_idx_numerators other
      other.delete_at(i)
    end
    other
  end

  def get_num_denom(other)
    num, other = find_next_value other
    raise 'Invalid data type' unless check_for_number num
    return [num, 1] if other.empty?
    denom, other = find_next_value other
    raise 'Incorrect number of arguments' unless other.empty?
    [num, denom]
  end

  def compare_value_arithmetic(other, oper)
    raise 'Incorrect number of arguments' if other.size < 2
    other = convert_to_num other
    result = other.each_cons(2).all? { |x, y| x.public_send oper, y }
    result ? '#t' : '#f'
  end

  def convert_to_num(other)
    other.each do |t|
      raise 'Invalid data type' unless check_for_number t
    end
    other.map(&:to_num)
  end

  def divide_special_convert(other)
    other = convert_to_num other
    return [0] if other.size == 1 && other[0] == 0.0
    other
  end

  def divide_number(a, b)
    return a / b if (a / b).to_i.to_f == a / b.to_f
    a / b.to_f
  end
end

# Scheme numbers module
module SchemeNumbers
  include SchemeNumbersHelper

  def <(other)
    compare_value_arithmetic other, '<'
  end

  def >(other)
    compare_value_arithmetic other, '>'
  end

  def <=(other)
    compare_value_arithmetic other, '<='
  end

  def >=(other)
    compare_value_arithmetic other, '>='
  end

  def +(other)
    other = convert_to_num other
    other.reduce(0, :+)
  end

  def -(other)
    return 0 if other.empty?
    other = convert_to_num other
    return -other[0] if other.size == 1
    other[0] + other[1..-1].reduce(0, :-)
  end

  def *(other)
    other = convert_to_num other
    other.reduce(1, :*)
  end

  def /(other)
    raise 'Incorrect number of arguments' if other.empty?
    other = divide_special_convert other
    return (divide_number 1, other[0].to_num) if other.size == 1
    other[1..-1].inject(other[0]) { |res, t| divide_number res, t }
  end

  def quotient(other)
    raise 'Incorrect number of arguments' if other.size != 2
    x, y = convert_to_num other
    result = divide_number x, y
    result < 0 ? result.ceil : result.floor
  end

  def remainder(other)
    raise 'Incorrect number of arguments' if other.size != 2
    x, y = convert_to_num other
    (x.abs % y.abs) * (x / x.abs)
  end

  def modulo(other)
    raise 'Incorrect number of arguments' if other.size != 2
    x, y = convert_to_num other
    x.modulo y
  end

  def numerator(other)
    other = num_denom_helper other
    result = (get_num_denom other)[0]
    raise 'Invalid data type' unless check_for_number result
    result.to_num
  end

  def denominator(other)
    other = num_denom_helper other
    result = (get_num_denom other)[1]
    raise 'Invalid data type' unless check_for_number result
    result.to_num
  end

  def abs(other)
    (get_one_arg_function other).abs
  end

  def add1(other)
    (get_one_arg_function other) + 1
  end

  def sub1(other)
    (get_one_arg_function other) - 1
  end

  def min(other)
    raise 'Incorrect number of arguments' if other.empty?
    other = convert_to_num other
    other.min
  end

  def max(other)
    raise 'Incorrect number of arguments' if other.empty?
    other = convert_to_num other
    other.max
  end
end
