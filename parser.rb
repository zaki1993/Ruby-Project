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
    x = x.to_s
    x == display_error || x.include?("Undefined variable") ? true : false
  end

  def get_err_substr(x, y, check, len)
    return false if x.class == String
    x = x.to_i
    return false if y.class == String && !check
    y = y.to_i
    x < 0 || (!check && x < y) || (x > y) || x > len || y > len
  end

  def get_err_bool(x)
    return true if x != '#t' && x != '#f'
    return false
  end

  def get_err_list(tokens)
    idx = find_last_bracket(tokens[1..tokens.length]) + 1
    tokens[1..idx].join('').include?('\'(') ? true : false
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
    x = get_string(tokens, 0, find_next_quote(tokens)).delete('"')
    return x if get_err_string(x)
    idx = find_next_quote(tokens)
    idx = (idx == 0 ? find_last_bracket(tokens) : idx + 1)
    idx = (idx == 0 ? 1 : idx)
    end_idx = find_next_quote(tokens[idx..tokens.length]) + idx
    y = get_string(tokens, idx, end_idx).delete('"')
    return y if get_err_string(y)
    convert_boolean_to_scheme x.include? y
  end

  def string_list(tokens)
    res = get_string(tokens, 0, find_next_quote(tokens)).delete('"')
    return res if get_err_string(res)
    res = res.delete(' ')
    res.each_char.each_with_index do |v, i|
      res[i + i*3] = '#\\' + v + ' '
    end
    res.insert(0, '\'(')
    res.insert(res.length - 1, ')')
    res
  end

  def string_split(tokens)
    res = get_string(tokens, 0, find_next_quote(tokens)).delete('"')
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
    return res if get_err_string(res)
    convert_boolean_to_scheme res.class == String
  end

  def scheme_substring(tokens)
    idx = 0
    quote = find_next_quote(tokens)
    end_idx = quote == 0 ? find_last_bracket(tokens) : quote
    string = get_string(tokens, idx, end_idx).delete('"')
    return string if get_err_string(string)
    x, y, z = get_digits_pair(tokens[end_idx + 1..tokens.length])
    check = true if !get_err_digit(y)
    return display_error if get_err_substr(x*z, y, check, string.length)
    return get_substring_result(x, y, check, string)
  end

  def get_substring_result(x, y, check, string)
    return '""' if x == y && check
    return '"' + string[x..y - 1] + '"' if check
    return '"' + string[x..string.length] + '"'
  end

  def get_string_sign(tokens)
    idx = tokens.index('?')
    sign = tokens[0..idx - 1]
    i = 0
    tokens = tokens[sign.length + 1..tokens.length]
    x = get_string(tokens, 0, find_next_quote(tokens)).delete('"')
    idx = find_next_quote(tokens)
    idx = (idx == 0 ? find_last_bracket(tokens) + 1 : idx + 1)
    idx = (idx == 0 ? 1 : idx)
    [x, sign, tokens[idx..tokens.length]]
  end

  def scheme_string_equal(tokens)
    x, sign, tokens = get_string_sign(tokens)
    return x if get_err_string(x)
    end_idx = find_next_quote(tokens)
    y = get_string(tokens, 0, end_idx).delete('"')
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
  def null?(tokens)
    return '#t' if tokens.join('') == 'null)'
    res = tokens.join('').start_with?('\'()')
    convert_boolean_to_scheme res
  end

  def list?(tokens)
    string = tokens.join('')
    return '#t' if string == '\'()' || string == 'null)'
    res = display_error
    if string.start_with?('\'(', '(')
      res = list(tokens)
    end
    convert_boolean_to_scheme !get_err_string(res) ? true : false
  end

  def cons?(tokens)
    string = tokens.join('')
    res = display_error
    if string.start_with?('(cons')
      res = cons(tokens[2..tokens.length])
    elsif string.start_with?('(list', '\'(')
      res = list?(tokens)
    else
      res = cons(tokens[1..tokens.length])
    end
    convert_boolean_to_scheme !get_err_string(res) ? true : false
  end

  def helper_digit_bool_string(token)
    return display_error if !check_for_instance_var(token, 0)
    return instance_variable_get("@#{token}")
  end

  def get_list_elem(tokens)
    if tokens.join('').start_with?('\'(')
      idx = find_last_bracket(tokens[1..tokens.length]) + 1
      res = list(tokens[2..idx]).delete('\'')
      return [res, tokens[2..idx].length]
    elsif tokens[0] == '('
      idx = find_last_bracket(tokens)
      res = calc_fn_val(tokens[1..idx]).to_s
      res = res.delete('\'') if list?(res.split(''))
      if !get_err_string(list(tokens[0..idx].insert(0, '\'')))
        res = list(tokens[0..idx].insert(0, '\''))
        res = res[2..res.length - 2]
      end
      return [res, idx]
    elsif tokens[0] == '"'
      idx = find_next_quote(tokens)
      return [get_string(tokens, 0, idx).to_s, idx]
    elsif tokens[0] == '#'
      return [get_boolean_scheme(tokens, 0), 1]
    elsif (tokens[0] =~ /[[:alpha:]]/) == 0
      return [helper_digit_bool_string(tokens[0]).to_s, 0]
    else
      return [calculate_digit_scheme(tokens[0]).to_s, 0]
    end
  end

  def list(tokens)
    string = tokens.join('')
    return '\'()' if string == '\'())' || string == '())'
    return display_error if get_err_list(tokens)
    result = '\'('
    skips = 0
    tokens[0..tokens.length - 2].each_with_index do |v, i|
      next if (skips -= 1) >= 0 || v == ')'
      res = get_list_elem(tokens[i..tokens.length])
      return res[0] if get_err_string(res[0].to_s)
      result += res[0] + ' '
      skips = res[1]
    end
    result.insert(result.length - 1, ')').rstrip
  end

 def get_first_cons(tokens)
    if tokens[0] == '('
      calc_fn_val(tokens[1..find_last_bracket(tokens)])
    else
      res = calculate_digit_scheme(tokens[0])
      res = get_boolean_scheme(tokens, 0) if get_err_string(res)
      idx = find_next_quote(tokens)
      res = get_string(tokens, 0, idx) if get_err_string(res) && get_err_bool(res)
      res
    end
  end

  def get_second_cons(tokens)
    return '\'()' if tokens.join('') == '\'())' || tokens.join('') == '())'
    if tokens.join('').start_with?('\'(', '(list')
      [list(tokens[0..tokens.length - 1]), true]
    else
      res = get_first_cons(tokens)
      if list?(tokens) == '#t'
        if !tokens.join('').start_with?('(cons')
          res = calc_fn_val(tokens[1..tokens.length])
          [res, false]
        else
          res = list(tokens)
          [res, true]
        end
      else
        [get_first_cons(tokens), false]
      end
    end
  end

  def calculate_cons_result(first, second, list_or_cons)
    return display_error if list?(first.to_s.split('')) == '#t'
    return second if get_err_string(second)
    result = '('
    result += first.to_s + ' '
    if list_or_cons
      if second[3..second.length - 2].to_s == ''
        result[result.length - 1] = ''
        result += ')'
      else
        result += second[3..second.length - 2].to_s
      end
    elsif second[0] != '('
      result += '. ' + second.to_s + ')'
    else
      puts "A"
      result += ' . ' + second.to_s + ')'
    end
  end

  def get_index_cons(tokens, first)
    idx = find_last_bracket(tokens) + 1
    idx = (idx == 1 ? find_next_quote(tokens) + 1: idx)
    idx = (idx == 1 ? first.to_s.length : idx)
  end

  def cons(tokens)
    return display_error if tokens.join('').start_with?('\'(')
    first = get_first_cons(tokens)
    return first if get_err_string(first)
    idx = get_index_cons(tokens, first)
    return display_error if tokens[idx] == ')'
    second = get_second_cons(tokens[idx..tokens.length])
    calculate_cons_result(first, second[0], second[1])
  end

  def null
    '\'()'
  end

  def get_first_car(tokens, idx)
    if tokens[idx] == '('
      get_first_car_method(tokens[0..find_last_bracket(tokens)])
    else
      get_first_car_variable(tokens, idx)
    end
  end

  def check_for_brackets_only(tokens)
    left_brackets = 0
    right_brackets = 0
    tokens.each do |v|
      left_brackets += 1 if v == '('
      right_brackets += 1 if v == ')'
      return false if v != '(' && v != ')'
    end
    left_brackets == right_brackets ? true : false
  end

  def get_first_car_method(tokens)
    if check_for_brackets_only(tokens)
      tokens[0..tokens.length - 1].join('')
    elsif cons?(tokens) == '#t' || list?(tokens) == '#t'
      res = list(tokens)
      res[2..res.length - 2].insert(0, '\'')
    else
      calc_fn_val(tokens[1..tokens.length].split(''))
    end
  end

  def get_first_car_variable(tokens, idx)
    if check_for_instance_var(tokens, idx)
      get_instance_var(tokens, idx)
    elsif tokens[idx] == '"'
      get_string(tokens, idx, find_next_quote(tokens))
    elsif tokens[idx] == '#'
      get_boolean_scheme(tokens, idx)
    else
      calculate_digit_scheme(tokens[idx])
    end
  end

  def find_index_cdr(tokens, idx)
    if tokens[idx] == '('
      find_last_bracket(tokens) + 1
    elsif tokens[idx] == '"'
      find_next_quote(tokens) + 1
    elsif tokens[idx] == '#'
      2
    else
      1
    end
  end

  def get_second_cdr(tokens)
    idx = find_index_cdr(tokens, 0)
    tokens = tokens[idx..tokens.length].insert(0, '(')
    result = list(tokens).delete('\'')
    return display_error if get_err_string(result)
    result = result[1..result.length - 2].insert(0, '\'')
    result
  end

  def car(tokens)
    return display_error if list?(tokens) == '#f'
    return display_error if tokens.join('') == '\'())'
    get_first_car(tokens[2..tokens.length - 2], 0)
  end

  def cdr(tokens)
    return display_error if list?(tokens) == '#f'
    return display_error if tokens.join('') == '\'())'
    get_second_cdr(tokens[2..tokens.length])
  end

  def multiple_car_cdr(tokens)

  end
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

module SchemeBoolean
  def get_boolean_scheme_bracket(tokens, idx)
    calc_fn_val(tokens[idx + 1..tokens.length])
  end

  def check_for_instance_var(tokens, idx)
    (tokens[idx] =~ /[[:alpha:]]/) == 0 && instance_variable_defined?("@#{tokens[idx]}")
  end

  def get_instance_var(tokens, idx)
      return instance_variable_get("@#{tokens[idx]}")
  end

  def get_boolean_scheme(tokens, idx)
    y = display_error
    if check_for_instance_var(tokens, idx)
      y = get_instance_var(tokens, idx)
    elsif tokens[idx..tokens.length].join('').start_with?('#t', '#f')
      y = tokens[idx..idx + 1].join('')
    end
    return y if get_err_bool(y)
    y
  end

  def convert_boolean_to_scheme(statement)
    statement ? '#t' : '#f'
  end

  def calculate_bool_scheme(tokens)
    res = tokens.join('')
    return res[0..1] if res.start_with?('#t', '#f')
    if tokens[0] == '('
      res = get_boolean_scheme_bracket(tokens, 0)
    else
      res = get_boolean_scheme(tokens, 0)
    end
    res
  end

  def scheme_not(tokens)
    return display_error if get_err_string(tokens)
    res = calculate_bool_scheme(tokens)
    return res if get_err_string(res)
    res == '#t' ? '#f' : '#t'
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
      idx += find_last_bracket(tokens)
      x = calc_fn_val(tokens[old_idx + 1..idx]).to_i
    else
      x = calculate_digit_scheme(tokens[idx]).to_i
    end
    puts tokens[idx]
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
    puts x, y
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
  include SchemeBoolean
  include SchemeList
  def initialize
    @tokens = []
    @defined_functions = []
    @functions = ['+', '-', '*', '/', 'remainder', 'modulo', 'truncate', 'ceiling', 'quotient', 'abs', 'gcd', 'lcm', 'numerator', 'denominator' , '<', '<=', '=', '>=', '>', 'string', 'not', 'equal', 'if', 'substring', 'null', 'list', 'cons', 'car', 'cdr']
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
      @tokens = string.scan(/\(|\)|\w+|\+|\-|\*|\/|\<\=|\>\=|\=|\<|\>|\"|\?|\#|\$|\'|\./)
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
      elsif func == 'list' && tokens.join('').start_with?('list?')
        return list?(tokens[idx + 2..tokens.length])
      elsif func == 'list'
        return list(tokens[idx + 1..tokens.length])
      elsif func == 'null' && tokens[1] == '?'
        return null?(tokens[idx + 2..tokens.length])
      elsif func == 'null'
        return null
      elsif func == 'cons' && tokens[1] == '?'
        return cons?(tokens[idx + 2..tokens.length])
      elsif func == 'cons'
        return cons(tokens[idx + 1..tokens.length])
      elsif func == 'car'
        return car(tokens[idx + 1..tokens.length])
      elsif func == 'cdr'
        return cdr(tokens[idx + 1..tokens.length])
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
    idx = 0
    x = calculate_bool_scheme(tokens)
    idx = find_last_bracket(tokens) + 1
    check = check_for_instance_var(tokens, idx)
    idx = (idx == 1 && check ? idx : idx + 1)
    idx = (idx == 0 ? idx + 1 : idx)
    y = calculate_bool_scheme(tokens[idx..tokens.length])
    return display_error if get_err_bool(x) || get_err_bool(y)
    return convert_boolean_to_scheme x.eql? y
  end

  def scheme_if(tokens)
    # CHECK FOR CORRECTNESS
    if tokens[0] != '('
      return display_error
    end
    # EVERYTHING IS OK WE CAN CONTINUE
    idx_last = find_last_bracket(tokens)
    val = calc_fn_val(tokens[1..idx_last])
    return display_error if val != '#t' && val != '#f'
    # CALCULATE THE RESULT IF THE STATEMENT IS TRUE
    true_res = ''
    idx_last_true = 0
    if tokens[idx_last + 1] == '('
      idx_last_true = find_last_bracket(tokens[idx_last + 1..tokens.length]) + idx_last + 1
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
      idx_last_false = find_last_bracket(tokens[idx_last_true + 1..tokens.length]) + idx_last_true + 1
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

  def scheme_string_length(tokens)
    string = get_string(tokens, 0, find_next_quote(tokens)).delete('"')
    return string if get_err_string(string)
    string.length
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
      tokens[start..end_idx].each { |v| res.insert(res.length, v) }
    elsif /[[:alpha:]]/ =~ tokens[0] && start == 0
      if instance_variable_defined?("@#{tokens[start]}")
        res = instance_variable_get("@#{tokens[start]}")
        if (/[[:digit:]]/ =~ res) == 0 || (/[[ '#' ]]/ =~ res) == 0
          return display_error
        end
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
      return i + 1 if left_brackets == right_brackets
    end
  end
end
