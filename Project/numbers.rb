# Scheme numbers functions module
module SchemeNumbers
  def calculate_value_arithmetic(tokens, result, sign)
    until tokens.empty?
      x, tokens = find_next_value tokens, true
      case sign
      when '+' then result += x
      when '-' then result -= x
      when '*' then result *= x
      when '/' then result = divide_number(result, x)
      end
    end
    result
  end

  def +(other)
    other = other[2..other.size - 2]
    return 0 if other.size.zero?
    result, other = find_next_value other, true
    calculate_value_arithmetic other, result, '+'
  end

  def -(other)
    other = other[2..other.size - 2]
    result, other = find_next_value other, true
    calculate_value_arithmetic other, result, '-'
  end

  def *(other)
    other = other[2..other.size - 2]
    return 1 if other.empty?
    result, other = find_next_value other, true
    calculate_value_arithmetic other, result, '*'
  end

  # TODO: Division by zero
  def /(other)
    other = other[2..other.size - 2]
    result = 1 if other.size == 1
    result, other = find_next_value other, true if other.size > 1
    calculate_value_arithmetic other, result, '/'
  end

  def primary_func_parser(oper, x, y)
    case oper
    when 'remainder' then (x.abs % y.abs) * (x / x.abs)
    when 'modulo' then x.modulo(y)
    when 'quotient' then (x / y).floor
    end
  end

  def primary_func_tokenizer(tokens, oper)
    tokens = tokens[2..tokens.size - 2]
    x, y, tokens = get_k_arguments tokens, true, 2, true
    raise 'Too many arguments' unless tokens.empty?
    primary_func_parser(oper, x, y)
  end

  def quotient(tokens)
    primary_func_tokenizer(tokens, 'quotient')
  end

  def remainder(tokens)
    primary_func_tokenizer(tokens, 'remainder')
  end

  def modulo(tokens)
    primary_func_tokenizer(tokens, 'modulo')
  end

  def get_num_denom(tokens)
    num, tokens = find_next_value tokens, true
    return [num, 1] if tokens.empty?
    denom, tokens = find_next_value tokens, true
    raise 'Too much arguments' unless tokens.empty?
    [num, denom]
  end

  def find_idx_numerators(tokens)
    tokens[0] == '(' ? (find_matching_bracket_idx tokens, 0) + 1 : 1
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

  def numerator(tokens)
    tokens = tokens[2..tokens.size - 2]
    tokens = num_denom_helper tokens
    (get_num_denom tokens)[0].to_num
  end

  def denominator(tokens)
    tokens = tokens[2..tokens.size - 2]
    tokens = num_denom_helper tokens
    (get_num_denom tokens)[1].to_num
  end

  def get_one_arg_function(tokens)
    tokens = tokens[2..tokens.size - 2]
    x, tokens = find_next_value tokens, true
    raise 'Too much arguments' unless tokens.empty?
    x
  end

  def abs(tokens)
    x = get_one_arg_function tokens
    x.abs
  end

  def add1(tokens)
    x = get_one_arg_function tokens
    x + 1
  end

  def sub1(tokens)
    x = get_one_arg_function tokens
    x - 1
  end

  def min(tokens)
    tokens = tokens[2..tokens.size - 2]
    x, y, tokens = get_k_arguments tokens, true, 2, true
    result = x < y ? x : y
    until tokens.empty?
      next_val, tokens = find_next_value tokens, true
      result = next_val if result > next_val
    end
    result
  end

  def max(tokens)
    tokens = tokens[2..tokens.size - 2]
    x, y, tokens = get_k_arguments tokens, true, 2, true
    result = x > y ? x : y
    until tokens.empty?
      next_val, tokens = find_next_value tokens, true
      result = next_val if result < next_val
    end
    result
  end
end
