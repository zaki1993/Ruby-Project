# Helper functions for SchemeNumbers
module SchemeNumbersHelper
  def get_one_arg_function(tokens)
    raise 'Incorect number of arguments' if tokens.size != 1
    tokens[0].to_num
  end

  def find_idx_numerators(tokens)
    tokens[0] == '(' ? (find_bracket_idx tokens, 0) + 1 : 1
  end

  def num_denom_helper(tokens)
    if tokens.size == 1
      tokens = tokens[0].split('/')
    else
      _, temp = find_next_value tokens, true
      raise 'Too much arguments' unless temp[0] == '/' || temp.empty?
      i = find_idx_numerators tokens
      tokens.delete_at(i)
    end
    tokens
  end

  def get_num_denom(tokens)
    num, tokens = find_next_value tokens, true
    return [num, 1] if tokens.empty?
    denom, tokens = find_next_value tokens, true
    raise 'Too much arguments' unless tokens.empty?
    [num, denom]
  end

  def primary_func_tokenizer(tokens, oper)
    x, y, tokens = get_k_arguments tokens, true, 2, true
    raise 'Too many arguments' unless tokens.empty?
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
    other = other.map { |t| t.to_num }
    other.reduce(0, :+)
  end

  def -(other)
    return 0 if other.empty?
    other = other.map { |t| t.to_num }
    other[0] + other[1..-1].reduce(0, :-)
  end

  def *(other)
    other = other.map { |t| t.to_num }
    other.reduce(1, :*)
  end

  # TODO: Division by zero
  def /(other)
    raise 'Too few arguments' if other.empty?
    return (divide_number 1, other[0].to_num) if other.size == 1
    other = other.map { |t| t.to_num }
    other[1..-1].inject(other[0], :/)
  end

  def quotient(tokens)
     raise 'Incorect number of arguments' if tokens.size != 2
     x, y = tokens.map { |t| t.to_num }
     result = divide_number x, y
     result < 0 ? result.ceil : result.floor
  end

  def remainder(tokens)
    raise 'Incorect number of arguments' if tokens.size != 2
    x, y = tokens.map { |t| t.to_num }
    (x.abs % y.abs) * (x / x.abs)
  end

  def modulo(tokens)
    raise 'Incorect number of arguments' if tokens.size != 2
    x, y = tokens.map { |t| t.to_num }
    x.modulo y
  end

#TODO
  def numerator(tokens)
    tokens = num_denom_helper tokens
    (get_num_denom tokens)[0].to_num
  end
#TODO
  def denominator(tokens)
    tokens = num_denom_helper tokens
    (get_num_denom tokens)[1].to_num
  end

  def abs(tokens)
    (get_one_arg_function tokens).abs.to_s
  end

  def add1(tokens)
    (get_one_arg_function tokens) + 1
  end

  def sub1(tokens)
    (get_one_arg_function tokens) - 1
  end

  def min(tokens)
    tokens = tokens.map { |t| t.to_num }
    tokens.min
  end

  def max(tokens)
    tokens = tokens.map { |t| t.to_num }
    tokens.max
  end
end
