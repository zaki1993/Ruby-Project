# Helper functions for SchemeNumbers
module SchemeNumbersHelper
  def get_one_arg_function(other)
    raise 'Incorect number of arguments' if other.size != 1
    other[0].to_num
  end

  def find_idx_numerators(other)
    other[0] == '(' ? (find_bracket_idx other, 0) + 1 : 1
  end

  def num_denom_helper(other)
    if other.size == 1
      other = other[0].split('/')
    else
      _, temp = find_next_value other, true
      raise 'Too much arguments' unless temp[0] == '/' || temp.empty?
      i = find_idx_numerators other
      other.delete_at(i)
    end
    other
  end

  def get_num_denom(other)
    num, other = find_next_value other, true
    return [num, 1] if other.empty?
    denom, other = find_next_value other, true
    raise 'Too much arguments' unless other.empty?
    [num, denom]
  end

  def primary_func_tokenizer(other, oper)
    x, y, other = get_k_arguments other, true, 2, true
    raise 'Too many arguments' unless other.empty?
    primary_func_parser(oper, x, y)
  end

  def compare_value_arithmetic(other, oper)
    raise 'Very few arguments' if other.size < 2
    result = other.each_cons(2).all? { |x, y| x.public_send oper, y }
    result ? '#t' : '#f'
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
    other = other.map(&:to_num)
    other.reduce(0, :+)
  end

  def -(other)
    raise 'Too few arguments' if other.empty?
    other = other.map(&:to_num)
    return -other[0] if other.size == 1
    other[0] + other[1..-1].reduce(0, :-)
  end

  def *(other)
    other = other.map(&:to_num)
    other.reduce(1, :*)
  end

  # TODO: Division by zero
  def /(other)
    raise 'Too few arguments' if other.empty?
    return (divide_number 1, other[0].to_num) if other.size == 1
    other = other.map(&:to_num)
    other[1..-1].inject(other[0]) { |res, t| divide_number res, t }
  end

  def quotient(other)
    raise 'Incorect number of arguments' if other.size != 2
    x, y = other.map(&:to_num)
    result = divide_number x, y
    result < 0 ? result.ceil : result.floor
  end

  def remainder(other)
    raise 'Incorect number of arguments' if other.size != 2
    x, y = other.map(&:to_num)
    (x.abs % y.abs) * (x / x.abs)
  end

  def modulo(other)
    raise 'Incorect number of arguments' if other.size != 2
    x, y = other.map(&:to_num)
    x.modulo y
  end

  # TODO
  def numerator(other)
    other = num_denom_helper other
    (get_num_denom other)[0].to_num
  end

  # TODO
  def denominator(other)
    other = num_denom_helper other
    (get_num_denom other)[1].to_num
  end

  def abs(other)
    (get_one_arg_function other).abs.to_s
  end

  def add1(other)
    (get_one_arg_function other) + 1
  end

  def sub1(other)
    (get_one_arg_function other) - 1
  end

  def min(other)
    other = other.map(&:to_num)
    other.min
  end

  def max(other)
    other = other.map(&:to_num)
    other.max
  end
end
