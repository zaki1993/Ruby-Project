module Display
  def display_result(result)
    puts result
  end

  def display_error
    'Incorrect command'
  end

  def display_no_variable_error(variable)
    'Undefined variable ' + variable
  end

  def get_err_digit(x)
    x.class == String ? true : false
  end

  def get_err_string(x)
    x == display_error || x.include?("Undefined variable") ? true : false
  end

  def get_err_substr(x, y, check, len)
    return false if x.class == String
    x = x.to_i
    return false if y.class == String && !check
    y = y.to_i
    x < 0 || (!check && x < y) || (x > y) || x > len || y > len
  end
end

module SchemeString
  def string_upcase(tokens)
    res = get_string(tokens, 0, find_next_quote(tokens))
    return get_err_string(res) ? res : res.upcase
  end

  def string_downcase(tokens)
    res = get_string(tokens, 0, find_next_quote(tokens))
    return get_err_string(res) ? res : res.downcase
  end

  def string_contains?(tokens)
    x = get_string(tokens, 0, find_next_quote(tokens))
    return x if get_err_string(x)
    idx = find_next_quote(tokens)
    idx = (idx == 0 ? find_last_bracket(tokens) : idx + 1)
    idx = (idx == 0 ? 1 : idx)
    end_idx = find_next_quote(tokens[idx..tokens.length]) + idx
    y = get_string(tokens, idx, end_idx)
    return y if get_err_string(y)
    x.include? y
  end

  def string_list(tokens)
    res = get_string(tokens, 0, find_next_quote(tokens))
    return res if get_err_string(res)
    res = res.delete(' ')
    res.each_char.each_with_index { |v, i| res[i + i*3] = '#\\' + v + ' ' }
    res.insert(0, '\'(')
    res.insert(res.length - 1, ')')
    res
  end

  def string_split(tokens)
    res = get_string(tokens, 0, find_next_quote(tokens))
    return res if get_err_string(res)
    res = res.split(' ')
    res.each_with_index do |v, i|
      res[i].insert(0, '"')
      res[i].insert(res[i].length, '"')
    end
    res = res.join(" ").insert(0, '\'(')
    res.insert(res.length, ')')
  end

  def string?(tokens)
    res = get_string(tokens, 0, find_next_quote(tokens))
    res = calculate_digit_scheme(tokens[0]) if get_err_string(res)
    convert_boolean_to_scheme res.class == String
  end

  def scheme_substring(tokens)
    idx = 0
    quote = find_next_quote(tokens)
    end_idx = quote == 0 ? find_last_bracket(tokens) + 1 : quote
    string = get_string(tokens, idx, end_idx)
    return string if get_err_string(string)
    digit = get_digits_pair(tokens[end_idx + 1..tokens.length])
    x, y = digit
    check = true if !get_err_digit(y)
    return display_error if get_err_substr(x*digit[2], y, check, string.length)
    return get_substring_result(x, y, check, string)
  end

  def get_substring_result(x, y, check, string)
    return '' if x == y && check
    return string[x..y - 1] if check
    return string[x..string.length]
  end

  def get_string_sign(tokens)
    idx = tokens.index('?')
    sign = tokens[0..idx - 1]
    i = 0
    tokens = tokens[sign.length + 1..tokens.length]
    x = get_string(tokens, 0, find_next_quote(tokens))
    idx = find_next_quote(tokens)
    idx = (idx == 0 ? find_last_bracket(tokens) : idx + 1)
    idx = (idx == 0 ? 1 : idx)
    [x, sign, tokens[idx..tokens.length]]
  end

  def scheme_string_equal(tokens)
    x, sign, tokens = get_string_sign(tokens)
    return x if get_err_string(x)
    end_idx = find_next_quote(tokens)
    y = get_string(tokens, 0, end_idx)
    return y if get_err_string(y)
    return convert_boolean_to_scheme compare_strings(x, y, sign)
  end

  def compare_strings(x, y, sign)
    case sign.join('')
    when '=' then x.eql?(y)
    when '<=' then x <= y
    when '>=' then x >= y
    when '<' then x < y
    when '>' then x > y
    end
  end
end

module SchemeList

end

module SchemeCalculations
  def single_digit(tokens)
    x, y, idx, minus = 0, 0, 0, 1
    if tokens[idx] == '-'
      minus = -1
      return display_error if tokens[idx + 1] == '('
      if tokens[idx + 2] == '/'
        x = calculate_digit_scheme(tokens[idx + 1])
        y = calculate_digit_scheme(tokens[idx + 3])
      else
        x = calculate_digit_scheme(tokens[idx + 1])
      end
    elsif tokens[idx] == '('
      old_idx = idx + 1
      x = calc_fn_val(tokens[old_idx..tokens.length])
    else
      x = calculate_digit_scheme(tokens[idx])
      y = calculate_digit_scheme(tokens[idx + 2])
      y = 0 if y.class == String
    end
    return display_error if x.class == String || y.class == String
    res = (x.to_f / y.to_f) * minus if y != 0
    res = x.to_f * minus if y == 0
    res
  end

  def numerator(tokens)
    if tokens[0] == '('
      calc_fn_val(tokens[1..tokens.length])
    elsif tokens[0] == '-'
      res = calculate_digit_scheme(tokens[1])
      res *= -1 if res.class.superclass == Integer
    else
      res = calculate_digit_scheme(tokens[0])
    end
    (res.class.superclass == Integer ? res : display_error)
  end

  def denominator(tokens)
    return display_error if numerator(tokens).class == String
    return -1 if !tokens.include?('/') && numerator(tokens) < 0
    return 1 if !tokens.include?('/')
    idx = tokens.index('/') + 1
    res =
    if tokens[idx] == '('
      calc_fn_val(tokens[idx + 1..tokens.length])
    else
      calculate_digit_scheme(tokens[idx])
    end
    (numerator(tokens) < 0 ? res * -1 : res)
  end

  def truncate(tokens)
    temp = single_digit(tokens)
    return display_error if temp.class == String
    minus = (temp < 0 ? -1 : 1)
    temp.abs.floor * minus
  end

  def ceiling(tokens)
    temp = single_digit(tokens)
    return display_error if temp.class == String
    temp.ceil
  end

  def abs(tokens)
    result =
    calc_fn_val(tokens[1..tokens.length]) if tokens[0] == '('
    result =
    calculate_digit_scheme(tokens[0]) if tokens[0] != '-'
    result =
    calculate_digit_scheme(tokens[1]) if tokens[0] == '-'
    return (result.class == String ? result : result.abs)
  end

  def find_first_digit(tokens, start_value, index, minus)
    if tokens[0] == '('
      start_value = calc_fn_val(tokens)
    elsif tokens[0] == '-'
      start_value = calculate_digit_scheme(tokens[1])
      minus = -1
    else
      start_value = calculate_digit_scheme(tokens[0])
    end
    [start_value, (minus == -1 ? 1 : 0), minus]
  end

  def find_second_digit(tokens, start_value, index, minus)
    if tokens[index] == '('
    start_value = calc_fn_val(tokens[index + 1..tokens.length])
    elsif tokens[index] == '-'
      start_value = calculate_digit_scheme(tokens[index + 1])
      minus = -1
    else
      start_value = calculate_digit_scheme(tokens[index])
    end
    [start_value, minus]
  end

  def primary_func_numbers(tokens, sign)
    x, y, minus = get_digits_pair(tokens)
    case sign
    when 'remainder' then (x.abs % y.abs) * (x / x.abs)
    when 'modulo' then x.modulo(y)
    when 'quotient' then truncate((x.to_i/y.to_i).to_s) * minus
    when 'gcd' then y == 0 ? x.to_i.gcd(x.to_i) : x.to_i.gcd(y.to_i)
    when 'lcm' then y == 0 ? x.to_i.lcm(x.to_i) : x.to_i.lcm(y.to_i)
    end
  end

  def get_digits_pair(tokens)
    first = find_first_digit(tokens, 0, 0, 1)
    x = first[0]
    idx = first[1]
    minus = first[2]
    idx += find_last_bracket(tokens) + 1
    second = find_second_digit(tokens, 0, idx, minus)
    y = second[0]
    minus *= second[1] if minus == 1
    [x, y, minus]
  end
end

module ToScheme
  include SchemeCalculations
  def convert_calculation_to_scheme(sign, x, y)
    case sign
    when '+' then x + y
    when '-' then x - y
    when '*' then x * y
    when '/' then x / y
    end
  end

  def compare(tokens, sign)
    x, y, idx = 0, 0, 0
    if tokens[idx] == '('
      old_idx = idx
      idx += find_last_bracket(tokens) + 1
      x = calc_fn_val(tokens[old_idx + 1..idx]).to_i
    else
      x = calculate_digit_scheme(tokens[idx]).to_i
    end
    if tokens[idx + 1] == '('
      old_idx = idx + 1
      idx += find_last_bracket(tokens[old_idx..tokens.length]) + 2
      y = calc_fn_val(tokens[old_idx + 1..idx]).to_i
    else
      y = calculate_digit_scheme(tokens[idx + 1]).to_i
    end
    return display_error if x.class.superclass != Integer || y.class.superclass != Integer
    return convert_compare_to_scheme(sign, x.to_i, y.to_i)
  end

  def calculate_digit_scheme(value)
    if (value=~ /[[:alpha:]]/) == 0
      if instance_variable_defined?("@#{value}")
        result = instance_variable_get "@#{value}"
        if (result =~ /[[:digit:]]/) != 0 && result.class == String
          return display_error
        end
      else
        return display_no_variable_error value
      end
    elsif (value =~ /[[:digit:]]/) == 0
      result = value
    else
      return display_error
    end
    return result.to_i
  end

  def convert_compare_to_scheme(sign, x, y)
    result = case sign
             when '<' then x < y
             when '>' then x > y
             when '=' then x == y
             when '<=' then x <= y
             else x >= y
             end
    convert_boolean_to_scheme result
  end
end

class Parser
  include Display
  include ToScheme
  include SchemeString
  def initialize
    @tokens = []
    @defined_functions = []
    @functions = ['+', '-', '*', '/', 'remainder', 'modulo', 'truncate', 'ceiling', 'quotient', 'abs', 'gcd', 'lcm', 'numerator', 'denominator' , '<', '<=', '=', '>=', '>', 'string', 'not', 'equal', 'if', 'substring']
    @space = '$'
  end

  def read(entry_string)
    if valid_brackets?(entry_string) == false
      display_result display_error
    else
      tokenizer(entry_string)
    end
  end

  def valid_brackets?(str)
    can_place_space = false
    str.each_char.each_with_index do |symbol, idx|
      if can_place_space
        if symbol == ' '
          str[idx] = @space
        end
        if symbol == "\""
          can_place_space = false
        end
      else
        if symbol == "\""
          can_place_space = true
        end
      end
    end
    strim = str.gsub(/[^\[\]\(\)\{\}]/, '')
    return true if strim.empty?
    return false if strim.size.odd?
    loop do
      s = strim.gsub('()', '').gsub('[]', '').gsub('{}', '')
      return true if s.empty?
      return false if s == strim
      strim = s
    end
  end

  def tokenizer(string)
      @tokens = string.scan(/\(|\)|\w+|\+|\-|\*|\/|\<\=|\>\=|\=|\<|\>|\"|\?|\#|\$/)
      @tokens.each do |val|
        if val == @space
          @tokens[@tokens.index(val)] = ' '
        end
      end
      parser(@tokens)
    # TODO for % ^
  end

  def parser(tokens)
    if tokens.length.zero?

    elsif tokens.length != 0 && check_for_default_print(tokens)

    elsif tokens.all? { |symbol| symbol == '(' || symbol == ')' }
      # ok
    elsif tokens.include?('define')
      # Define a function
      define(tokens[tokens.index('define') + 1..tokens.length])
    else
      # Calculate function value
      tokens.each do |func|
        if @functions.include? func
          arr = tokens[tokens.index(func)..tokens.length]
          return display_result calc_fn_val(arr)
        end
      end

      if tokens[0] != '(' && tokens.length == 1 && instance_variable_defined?("@#{tokens[0]}")
        display_result instance_variable_get("@#{tokens[0]}")
      else
        display_result display_no_variable_error "#{tokens[0]}"
      end
    end
  end

  def define(tokens)
    if tokens.length < 3
      display_result display_error
    elsif tokens[0] == '('
      # function with parameters
      puts "Parameters"
    elsif (/[[:alpha:]]/ =~ tokens[0]) != 0
      display_result display_error
    elsif tokens[1] != '('
      # define a function without parameters
      variable = tokens[tokens.index(tokens[0]) + 1]
      if tokens[1] == "\"" && tokens[2..tokens.length].include?("\"")
        variable = tokens[1]
        tokens[2..tokens.length].each do |val|
          break if val == "\""
          variable.insert(variable.length, val)
        end
        variable.insert(variable.length, "\"")
        instance_variable_set("@#{tokens[0]}", variable)
      elsif tokens[1] == "\"" && !tokens[2..tokens.length].include?("\"")
        display_result display_error
      elsif tokens[1] == '#'
        if (tokens[2] == 't' || tokens[2] == 'f') && tokens[3] == ')'
          variable = "\##{tokens[2]}"
          instance_variable_set("@#{tokens[0]}", variable)
        else
          display_result display_error
        end
      elsif (variable =~ /[[:alpha:]]/) == 0 && instance_variable_defined?("@#{variable}")
        instance_variable_set("@#{tokens[0]}", instance_variable_get("@#{variable}"))
      elsif (variable =~ /[[:alpha:]]/) == 0
        display_result display_no_variable_error variable
      else
        instance_variable_set("@#{tokens[0]}", variable)
      end
    else
      result = calc_fn_val(tokens[tokens.index(tokens.select{ |var| var == '(' }.first) + 1..tokens.length])
      if result.class == Integer
        result = result.to_i
      elsif result.class == String
        if result == display_error || result.include?("Undefined variable")
          return display_result result
        end
      end
      instance_variable_set("@#{tokens[0]}", result)
    end
  end

  def calc_fn_val(tokens)
    tokens.each do |func|
      idx = tokens.index func
      if func == '-'
        # TODO FIX THIS
        return primary_calculations(tokens[idx + 1..tokens.length], func)
      elsif func == 'not'
         result = scheme_not(tokens[idx + 1..tokens.length])
        return display_error if result == display_error
        return result
      elsif func == 'equal' && tokens[idx + 1] == '?'
        return scheme_equal?(tokens[idx + 2..tokens.length])
      elsif func == 'if'
        return scheme_if(tokens[idx + 1.. tokens.length])
      elsif func == 'truncate'
        return truncate(tokens[idx + 1..tokens.length])
      elsif func == 'ceiling'
        return lcm(tokens[idx + 1..tokens.length])
      elsif func == 'numerator'
        return numerator(tokens[idx + 1..tokens.length])
      elsif func == 'denominator'
        return denominator(tokens[idx + 1..tokens.length])
      elsif func == 'abs'
        return abs(tokens[idx + 1..tokens.length])
      elsif (/[['-' | '+' | '*' | '\/']]/ =~ func) == 0
        return primary_calculations(tokens[idx + 1..tokens.length], func)
      elsif (/[['modulo' | 'remainder | 'quotient' | 'gcd' | 'lcm']]/ =~ func) == 0
        return primary_func_numbers(tokens[idx + 1..tokens.length], func)
      elsif (/[['<' | '>' | '=' | '>=' | '<=']]/ =~ func) == 0
        return compare(tokens[1..tokens.length], func)
      elsif func == 'string' && tokens.join('').start_with?('string<?', 'string>?', 'string=?', 'string>=?', 'string<=?')
        return scheme_string_equal(tokens[idx + 1..tokens.length])
      elsif func == 'string' && tokens[idx + 1] == '-' && tokens[idx + 2] == 'length'
        return scheme_string_length(tokens[idx + 3.. tokens.length])
      elsif func == 'string' && tokens[idx + 1] == '-' && tokens[idx + 2] == 'upcase'
        return string_upcase(tokens[idx + 3..tokens.length])
      elsif func == 'string' && tokens[idx + 1] == '-' && tokens[idx + 2] == 'downcase'
        return string_downcase(tokens[idx + 3..tokens.length])
      elsif func == 'string' && tokens.join('').start_with?('string-contains?')
        return string_contains?(tokens[idx + 4..tokens.length])
      elsif func == 'string' && tokens.join('').start_with?('string->list')
        return string_list(tokens[idx + 4..tokens.length])
      elsif func == 'string' && tokens.join('').start_with?('string-split')
        return string_split(tokens[idx + 3..tokens.length])
      elsif func == 'string' && tokens[idx + 1] == '?'
        return string?(tokens[idx + 2..tokens.length])
      elsif func == 'substring'
        return scheme_substring(tokens[idx + 1..tokens.length])
      else
        return display_error
      end
    end
  end

  def primary_calculations(tokens, sign)
    x, y, idx = 0, 0, 0
    if tokens[idx] != '('
      x = calculate_digit_scheme(tokens[idx]).to_i
      idx += 1
    else
      old_idx = idx
      idx += find_last_bracket(tokens[idx..tokens.length]) + 2
      x = calc_fn_val(tokens[old_idx + 1..idx]).to_i
    end
    tokens = tokens[idx..tokens.length]
    if tokens.length < 2
      y = 0
    elsif tokens.length == 2
      y = calculate_digit_scheme(tokens[0]).to_i
    else
      idx = find_last_bracket(tokens) + 1
      if tokens[0] == '(' && idx != 1
        y = calc_fn_val(tokens[1..tokens.length])
      else
        if sign == '-'
          tokens.unshift('+')
        elsif sign == '/'
          tokens.unshift('*')
        else
          tokens.unshift(sign)
        end
        y = calc_fn_val(tokens).to_i
      end
    end
    return convert_calculation_to_scheme(sign, x, y)
  end

  def scheme_equal?(tokens)
    x, y = '', ''
    idx = 0
    if tokens[idx] == '('
      x = get_boolean_scheme_bracket(tokens, idx)
    else
      x = get_boolean_scheme(tokens, idx)
    end
    idx = idx + find_last_bracket(tokens[idx..tokens.length]) + 2
    if tokens[idx] == '('
      y = get_boolean_scheme_bracket(tokens, idx)
    else
      y = get_boolean_scheme(tokens, idx)
    end
    return convert_boolean_to_scheme x.eql? y
  end

  def get_boolean_scheme_bracket(tokens, idx)
    calc_fn_val(tokens[idx + 1..tokens.length])
  end

  def get_boolean_scheme(tokens, idx)
    y = ''
    if (tokens[idx] =~ /[[:alpha:]]/) == 0
      if instance_variable_defined?("@#{tokens[idx]}")
        y = instance_variable_get("@#{tokens[idx]}")
      else
        return display_no_variable_error tokens[idx]
      end
      return display_error if !(y.start_with?('#t', '#f')) && y.length == 2
    elsif tokens[idx..tokens.length].start_with?('#t', '#f')
      y = tokens[idx] + tokens[idx + 1]
    else
      return display_error
    end
    return y
  end

  def convert_boolean_to_scheme(statement)
    statement ? '#t' : '#f'
  end

  def scheme_if(tokens)
    # CHECK FOR CORRECTNESS
    if tokens[0] != '('
      return display_error
    end
    # EVERYTHING IS OK WE CAN CONTINUE
    idx_last = find_last_bracket(tokens) + 1
    val = calc_fn_val(tokens[1..idx_last])
    return display_error if val != '#t' && val != '#f'
    # CALCULATE THE RESULT IF THE STATEMENT IS TRUE
    true_res = ''
    idx_last_true = 0
    if tokens[idx_last + 1] == '('
      idx_last_true = find_last_bracket(tokens[idx_last + 1..tokens.length]) + idx_last + 2
      true_res = calc_fn_val(tokens[idx_last + 2 ..idx_last_true])
    elsif (/[[:alpha:]]/ =~ tokens[idx_last + 1]) == 0
      if instance_variable_defined?("@#{tokens[idx_last + 1]}")
        true_res = instance_variable_get("@#{tokens[idx_last + 1]}")
      else
        return display_error
      end
    elsif (/[[:digit:]]/ =~ tokens[idx_last + 1])
      true_res = tokens[idx_last + 1]
    elsif tokens[idx_last + 1] == "\""
      if !tokens[idx_last + 2..tokens.length].include?("\"")
        return display_error
      else
        true_res = "\""
        tokens[idx_last + 2..tokens.length].each_with_index do |v, i|
          if v == "\""
            idx_last_true = idx_last + i + 2
            break
          end
          true_res.insert(true_res.length, v)
        end
        true_res.insert(true_res.length, "\"")
      end
    elsif tokens[idx_last + 1] == '#'
      if tokens[idx_last + 2] == 't' || tokens[idx_last + 2] == 'f'
        true_res = tokens[idx_last + 1] + tokens[idx_last + 2]
        idx_last_true = idx_last + 2
      else
        return display_error
      end
    else
      return display_error
    end
    # CALCULATE THE RESULT IF THE STATEMENT IS FALSE
    false_res = ''
    idx_last_false = 0
    if tokens[idx_last_true + 1] == '('
      idx_last_false = find_last_bracket(tokens[idx_last_true + 1..tokens.length]) + idx_last_true + 2
      false_res = calc_fn_val(tokens[idx_last_true + 2 ..idx_last_false])
    elsif (/[[:alpha:]]/ =~ tokens[idx_last_true + 1]) == 0
      if instance_variable_defined?('@#{tokens[idx_last_true + 1]}')
        false_res = instance_variable_get('@#{tokens[idx_last_true + 1]}')
      else
        return display_error
      end
    elsif (/[[:digit:]]/ =~ tokens[idx_last_true + 1])
      false_res = tokens[idx_last_true + 1]
    elsif tokens[idx_last_true + 1] == "\""
      if !tokens[idx_last_true + 2..tokens.length].include?("\"")
        return display_error
      else
        false_res = "\""
        tokens[idx_last_true + 2..tokens.length].each do |v|
          break if v == "\""
          false_res.insert(false_res.length, v)
        end
        false_res.insert(false_res.length, "\"")
      end
    elsif tokens[idx_last_true + 1] == '#'
      if tokens[idx_last_true + 2] == 't' || tokens[idx_last_true + 2] == 'f'
        false_res = tokens[idx_last_true + 1] + tokens[idx_last_true + 2]
      else
        return display_error
      end
    else
      return display_error
    end
    return (val == '#t' ? true_res : false_res)
  end

  def scheme_not(tokens)
    if tokens.include? display_no_variable_error ''
      return tokens.split(' ')[2]
    end
    return display_error if tokens == display_error
    x = ''
    if tokens[0] == '('
      x = calc_fn_val(tokens[1..tokens.length])
      return scheme_not(x)
    elsif (tokens[0] =~ /[[:alpha:]]/) == 0 && !instance_variable_defined?('@#{tokens[0]}')
      return (display_no_variable_error tokens[0])
    elsif (tokens[0] =~ /[[:alpha:]]/) == 0&& instance_variable_defined?('@#{tokens[0]}')
      if tokens[1] != ')'
        return display_error
      else
        x = instance_variable_get('@#{tokens[0]}')
        return scheme_not(x)
      end
    elsif (tokens[0] =~ /[[:alpha:]]/) != 0 && tokens[0] == '#' && (tokens[1] == 't' || tokens[1] == 'f') && (tokens[2] == ')' || tokens[2].nil?)
      return (tokens[1] == 't' ? '#f' : '#t')
    else
      return display_error
    end
  end

  def scheme_string_length(tokens)
    result = 0
    if tokens[0] != "\"" && tokens[2] != "\""
      if (/[[:alpha:]]/ =~ tokens[0]) == 0 && instance_variable_defined?("@#{tokens[0]}")
        temp = instance_variable_get("@#{tokens[0]}")
        result = temp[1..temp.length - 2].length
        if result.class.superclass != Integer
          return display_error
        end
        return result
      elsif (/[[:alpha:]]/ =~ tokens[0]) == 0 && !instance_variable_defined?("@#{tokens[0]}")
        return display_no_variable_error tokens[0]
      else
        return display_error
      end
    elsif tokens[0] == "\"" && tokens[1..tokens.length].include?("\"")
      tokens[1..tokens.length].each do |val|
        if val == "\""
          break
        else
          result += val.length
        end
      end
      return result.to_s
    else
      return display_error
    end
  end

  def find_next_quote(tokens)
    return 0 if tokens[0] != "\""
    tokens[1..tokens.length].each_with_index do |v, i|
      return i + 1 if v == "\""
    end
  end

  def get_string(tokens, start, end_idx)
    res = ''
    if tokens[start] == '('
      idx = find_last_bracket(tokens[start..tokens.length])
      res = calc_fn_val(tokens[start + 1..idx])
    elsif tokens[start] == "\"" && tokens[end_idx] == "\""
      tokens[start + 1..end_idx - 1].each { |v| res.insert(res.length, v) }
    elsif /[[:alpha:]]/ =~ tokens[0] && start == 0
      if instance_variable_defined?("@#{tokens[start]}")
        temp = instance_variable_get("@#{tokens[start]}")
        if (/[[:digit:]]/ =~ temp) == 0 || (/[[ '#' ]]/ =~ temp) == 0
          return display_error
        end
        temp[1..temp.length - 2].each_char { |v| res.insert(res.length, v) }
      else
        return display_no_variable_error tokens[start]
      end
    else
      return display_error
    end
    res
  end

  def check_for_default_print(tokens)
    if tokens[0] != '('
      if tokens[0] == '#'
        if (tokens[1] == 't' || tokens[1] == 'f') && tokens.length == 2
          display_result(tokens[0] + tokens[1])
          return true
        else
          display_result display_error
          return true
        end
      elsif /[[:digit:]]/ =~ tokens[0]
        if tokens.length == 1
          display_result tokens[0]
          return true
        else
          display_result display_error
          return true
        end
      elsif tokens[0] == "\""
        if tokens[tokens.length - 1] == "\""
          result = "\""
          tokens[1..tokens.length].each_with_index do |val, _|
            break if val == "\""
            if val == ' '
              result.insert(result.length, ' ')
            else
              result.insert(result.length, val)
            end
          end
          result.insert(result.length, "\"")
          if tokens[1..tokens.length].index("\"") != tokens.length - 2
            display_result display_error
            return true
          else
            display_result result
            return true
          end
        else
          display_result display_error
          return true
        end
      end
    else
      return false
    end
  end

  def find_last_bracket(tokens)
    return 0 if tokens[0] != '('
    left_brackets = 1
    right_brackets = 0
    tokens[1..tokens.length].each_with_index do |v, i|
      left_brackets += 1 if v == '('
      right_brackets += 1 if v == ')'
      return i if left_brackets == right_brackets
    end
  end
end
