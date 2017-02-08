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
    x.class == String || x.nil? ? true : false
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
    false
  end

  def get_err_list(tokens)
    idx = find_last_bracket(tokens[1..tokens.length]) + 1
    tokens[1..idx].join('').include?('\'(') ? true : false
  end
end

module SchemeString
  def string_upcase(tokens)
    res = get_string(tokens, 0, find_next_quote(tokens))
    get_err_string(res) ? res : res.upcase
  end

  def string_downcase(tokens)
    res = get_string(tokens, 0, find_next_quote(tokens))
    get_err_string(res) ? res : res.downcase
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
    res.each_with_index do |_v, i|
      res[i].insert(0, '"')
      res[i].insert(res[i].length, '"')
    end
    res = res.join(' ').insert(0, '\'(')
    res.insert(res.length, ')')
  end

  def string?(tokens)
    res = get_string(tokens, 0, find_next_quote(tokens))
    result = get_err_string(res) ? false : true
    convert_boolean_to_scheme result
  end

  def scheme_substring(tokens)
    idx = 0
    quote = find_next_quote(tokens)
    end_idx = quote.zero? ? find_last_bracket(tokens) : quote
    string = get_string(tokens, idx, end_idx).delete('"')
    return string if get_err_string(string)
    x, y, z = get_digits_pair(tokens[end_idx + 1..tokens.length])
    check = !get_err_string(y) ? true : false
    return display_error if get_err_substr(x, y, check, string.length)
    get_substring_result(x.to_i, y.to_i, check, string)
  end

  def get_substring_result(x, y, check, string)
    return '' if x == y && check
    return string[x..y - 1] if check
    string[x..string.length]
  end

  def get_string_sign(tokens)
    idx = tokens.index('?')
    sign = tokens[0..idx - 1]
    i = 0
    tokens = tokens[sign.length + 1..tokens.length]
    x = get_string(tokens, 0, find_next_quote(tokens)).delete('"')
    idx = find_next_quote(tokens)
    idx = (idx.zero? ? find_last_bracket(tokens) + 1 : idx + 1)
    idx = (idx.zero? ? 1 : idx)
    [x, sign, tokens[idx..tokens.length]]
  end

  def scheme_string_equal(tokens)
    x, sign, tokens = get_string_sign(tokens)
    return x if get_err_string(x)
    end_idx = find_next_quote(tokens)
    y = get_string(tokens, 0, end_idx).delete('"')
    return y if get_err_string(y)
    convert_boolean_to_scheme compare_strings(x, y, sign)
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
    puts tokens.join('')
    if tokens.join('').start_with?('\'(')
      idx = find_last_bracket(tokens[1..tokens.length].push(')')) + 1
      res = list(tokens[2..idx]).delete('\'')
      [res, tokens[2..idx].length]
    elsif tokens[0] == '('
      tokens = tokens.push(')')
      idx = find_last_bracket(tokens)
      res = calc_fn_val(tokens[1..idx]).to_s
      res = res.delete('\'') if list?(res.split(''))
      if !get_err_string(list(tokens[0..idx].insert(0, '\'')))
        res = list(tokens[0..idx].insert(0, '\''))
        res = res[2..res.length - 2]
      end
      [res, idx]
    else
      puts "A"
      q = calculate_var(tokens)
      puts q
      q
    end
  end

  def list_helper(tokens, skips)
    result = '\'('
    tokens = tokens[0..tokens.length - 2]
    tokens.each_with_index do |v, i|
      next if (skips -= 1) >= 0 || v == ')'
      res, skips = get_list_elem(tokens[i..tokens.length])
      return res if get_err_string(res.to_s)
      result += res.to_s + ' '
    end
    result.insert(result.length - 1, ')').rstrip
  end

  def list(tokens)
    string = tokens.join('')
    return '\'()' if string == '\'())' || string == '())'
    return display_error if get_err_list(tokens)
    list_helper(tokens, 0)
  end

  def get_first_cons(tokens)
    calculate_var(tokens)[0]
  end

  def get_second_cons_helper(tokens)
    if !tokens.join('').start_with?('(cons')
      idx = find_last_bracket(tokens)
      [calc_fn_val(tokens[1..idx]), false]
    else
      [list(tokens), true]
    end
  end

  def get_second_cons(tokens)
    return '\'()' if tokens.join('') == '\'())' || tokens.join('') == '())'
    if tokens.join('').start_with?('\'(', '(list')
      [list(tokens[0..tokens.length - 1]), true]
    elsif tokens.join('').start_with?('(cons', '\'(')
      get_second_cons_helper(tokens)
    else
      [get_first_cons(tokens), false]
    end
  end

  def list_or_cons_helper(result, second)
    if second[3..second.length - 2].to_s == ''
      result[result.length - 1] = ''
      result + ')'
    else
      result + second[3..second.length - 2].to_s
    end
  end

  def cons_result_helper(result, second, list_or_cons)
    if list_or_cons
      list_or_cons_helper(result, second)
    elsif get_err_digit(second) && second[0] != '('
      result + '. ' + second.to_s + ')'
    else
      result + '. ' + second.to_s + ')'
    end
  end

  def calculate_cons_result(first, second, list_or_cons)
    return display_error if list?(first.to_s.split('')) == '#t'
    return second if get_err_string(second)
    result = '\'('
    result += first.to_s + ' '
    cons_result_helper(result, second, list_or_cons)
  end

  def get_index_cons(tokens, first)
    idx = find_last_bracket(tokens) + 1
    idx = (idx == 1 ? find_next_quote(tokens) + 1 : idx)
    idx == 1 ? first.to_s.length : idx
  end

  def cons(tokens)
    return display_error if tokens.join('').start_with?('\'(')
    first = get_first_cons(tokens)
    return first if get_err_string(first)
    idx = calculate_var(tokens)[1]
    return display_error if tokens[idx] == ')'
    second = get_second_cons(tokens[idx..tokens.length])
    calculate_cons_result(first, second[0], second[1])
  end

  def null
    '\'()'
  end

  def get_first_car(tokens, idx)
    idx = find_index_cdr(tokens, idx)
    tokens = tokens[0..idx]
    result = list(tokens)
    return display_error if get_err_string(result)
    result = result[2..result.length - 2].to_s
    return result.insert(0, '\'') if result.start_with?('(')
    result
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
    return '\'()' if result == '()' || result == '\'()'
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

  def validation_car_cdr_helper(string)
    string.each_char { |v| return false if v != 'd' && v != 'a' }
    true
  end

  def valid_multiple_car_cdr(tokens)
    string = ''
    tokens.join('').each_char do |v|
      string += v
      break if v == 'r'
    end
    return false if string[0] != 'c' && string[string.length] != 'r'
    string = string[1..string.length - 2]
    validation_car_cdr_helper(string)
  end

  def convert_str_to_arr(string)
    string.delete(' ')
    string
  end

  def get_first_second(tokens)
    fn_first = tokens[0]
    fn_second = tokens[1..tokens.length]
    fn_repeat = fn_first[1..fn_first.length - 2]
    [fn_second, fn_repeat.reverse]
  end

  def multi_car_cdr_helper(result)
    if get_err_string(result.to_s)
      display_error
    else
      result
    end
  end

  def multiple_car_cdr(tokens)
    fn_second, fn_repeat = get_first_second(tokens)
    fn_repeat.each_char.each_with_index do |v, i|
      fn_second = car(fn_second) if v == 'a'
      fn_second = cdr(fn_second) if v == 'd'
      break if i == fn_repeat.length - 1
      fn_second = convert_str_to_arr(fn_second.split(''))
    end
    multi_car_cdr_helper(fn_second)
  end
end

module SchemeCalculations
  def single_digit(tokens)
    x = 0
    y = 0
    idx = 0
    minus = 1
    if tokens[idx] == '-'
      minus = -1
      return display_error if tokens[idx + 1] == '('
      if tokens[idx + 2] == '/'
        x = calculate_digit_scheme(tokens, idx + 1)
        y = calculate_digit_scheme(tokens, idx + 3)
      else
        x = calculate_digit_scheme(tokens, idx + 1)
      end
    elsif tokens[idx] == '('
      old_idx = idx + 1
      x = calc_fn_val(tokens[old_idx..tokens.length])
    else
      x = calculate_digit_scheme(tokens, idx)
      y = calculate_digit_scheme(tokens, idx + 2)
      y = 0 if y.class == String
    end
    return display_error if x.class == String || y.class == String
    res = (x.to_f / y.to_f) * minus if y != 0
    res = x.to_f * minus if y.zero?
    res
  end

  def numerator_helper(res)
    if res.class.superclass == Integer
      res
    else
      display_error
    end
  end

  def numerator(tokens)
    if tokens[0] == '('
      calc_fn_val(tokens[1..tokens.length])
    elsif tokens[0] == '-'
      res = calculate_digit_scheme(tokens, 1)
      res *= -1 if res.class.superclass == Integer
    else
      res = calculate_digit_scheme(tokens, 0)
    end
    numerator_helper(res)
  end

  def denominator_helper(tokens, res)
    if numerator(tokens) < 0
      res * -1
    else
      res
    end
  end

  def denominator(tokens)
    return display_error if get_err_digit(numerator(tokens))
    return -1 if !tokens.include?('/') && numerator(tokens) < 0
    return 1 unless tokens.include?('/')
    idx = tokens.index('/') + 1
    res = calculate_digit_scheme(tokens, idx)[0].to_f
    denominator_helper(tokens, res)
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

  def abs_result(result)
    if get_err_string(result)
      result
    else
      result.abs
    end
  end

  def abs(tokens)
    if tokens[0] == '-'
      abs_result(calculate_digit_scheme(tokens, 1)[0].to_f)
    else
      abs_result(calculate_digit_scheme(tokens, 0)[0].to_f)
    end
  end

  def find_first_digit(tokens, start_value, _index, minus)
    if tokens[0] == '('
      idx = find_last_bracket(tokens)
      [calc_fn_val(tokens[0..idx]), idx + 1, 0]
    elsif tokens[0] == '-'
      [calculate_digit_scheme(tokens, 1)[0], 2, 1]
    else
      [calculate_digit_scheme(tokens, 0)[0], 1, 0]
    end
  end

  def find_second_digit(tokens, start_value, index, minus)
    if tokens[index] == '('
      [calc_fn_val(tokens[index + 1..tokens.length]), 1]
    elsif tokens[index] == '-'
      [calculate_digit_scheme(tokens, index + 1)[0], -1]
    else
      [calculate_digit_scheme(tokens, index)[0], 1]
    end
  end

  def gcd_helper(x, y)
    if y.zero?
      x.to_i.gcd(x.to_i)
    else
      x.to_i.gcd(y.to_i)
    end
  end

  def lcm_helper(x, y)
    if y.zero?
      x.to_i.lcm(x.to_i)
    else
      x.to_i.lcm(y.to_i)
    end
  end

  def quotient_helper(x, y, minus)
    truncate((x.to_i / y.to_i).to_s) * minus
  end

  def primary_func_numbers(tokens, sign)
    x, y, minus = get_digits_pair(tokens)
    case sign
    when 'remainder' then (x.abs % y.abs) * (x / x.abs)
    when 'modulo' then x.modulo(y)
    when 'quotient' then quotient_helper(x, y, minus)
    when 'gcd' then gcd_helper(x, y)
    when 'lcm' then lcm_helper(x, y)
    end
  end

  def get_digits_pair(tokens)
    x, idx, minus = find_first_digit(tokens, 0, 0, 1)
    return [x, display_error, minus] if tokens[idx] == ')'
    second = find_second_digit(tokens, 0, idx, minus)
    y = second[0]
    minus *= second[1] if minus == 1
    [x.to_f, y.to_f, minus]
  end
end

module SchemeBoolean
  def get_boolean_scheme_bracket(tokens)
    tokens = tokens[1..find_last_bracket(tokens)]
    [calc_fn_val(tokens), tokens.length + 1]
  end

  def check_for_instance_var(tokens, idx)
    return false unless tokens[idx] =~ /[[:alpha:]]/
    instance_variable_defined?("@#{tokens[idx]}")
  end

  def get_instance_var(tokens, idx)
    instance_variable_get("@#{tokens[idx]}")
  end

  def get_boolean_scheme(tokens)
    if check_for_instance_var(tokens, 0)
      [get_instance_var(tokens, 0), 1]
    elsif tokens.join('').start_with?('#t', '#f')
      [tokens[0..1].join(''), 2]
    end
  end

  def convert_boolean_to_scheme(statement)
    statement ? '#t' : '#f'
  end

  def calculate_bool_scheme(tokens)
    if tokens[0] == '('
      get_boolean_scheme_bracket(tokens)
    else
      get_boolean_scheme(tokens)
    end
  end

  def scheme_not(tokens)
    return display_error if get_err_string(tokens)
    res = calculate_bool_scheme(tokens)[0]
    return res if get_err_string(res)
    (res == '#t' ? '#f' : '#t')
  end
end

module ToScheme
  include SchemeCalculations
  def zero_division(x, y)
    if y.to_f.zero?
      '+inf.0'
    else
      x.to_f / y.to_f
    end
  end

  def convert_calculation_to_scheme(sign, x, y)
    case sign
    when '+' then x.to_f + y.to_f
    when '-' then x.to_f - y.to_f
    when '*' then x.to_f * y.to_f
    when '/' then zero_division(x, y)
    end
  end

  def compare(tokens, sign)
    x, idx = calculate_digit_scheme(tokens, 0)
    y = calculate_digit_scheme(tokens, idx)[0].to_i
    return display_error if get_err_digit(x.to_i) || get_err_digit(y)
    convert_compare_to_scheme(sign, x.to_i, y)
  end

  def calculate_digit_bracket(tokens, idx)
    tokens = tokens[idx + 1..find_last_bracket(tokens)]
    [calc_fn_val(tokens), tokens.length + 1]
  end

  def check_for_dot(tokens, idx)
    if tokens[idx + 1] == '.'
      result = tokens[idx].to_s
      result += '.'
      result += tokens[idx + 2].to_s
      [result, 3]
    else
      [tokens[idx], 1]
    end
  end

  def calculate_digit_scheme(tokens, idx)
    if check_for_instance_var(tokens, idx)
      [get_instance_var(tokens, idx), 1]
    elsif tokens[idx] =~ /[[:digit:]]/
      check_for_dot(tokens, idx)
    elsif tokens[idx] == '('
      calculate_digit_bracket(tokens, idx)
    else
      display_error
    end
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
        if symbol == '"'
          can_place_space = false
        end
      else
        if symbol == '"'
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
    default = check_for_default_print(tokens)
    if tokens.length.zero?

    elsif tokens.length != 0 && default != false
      display_result default
    elsif tokens.all? { |symbol| symbol == '(' || symbol == ')' }
      # ok
    elsif tokens.include?('define')
      # Define a function
      define(tokens[tokens.index('define') + 1..tokens.length])
    else
      if tokens[0] != '(' && tokens.length == 1 && instance_variable_defined?("@#{tokens[0]}")
        display_result instance_variable_get("@#{tokens[0]}")
      else
          # Calculate function value
          arr = tokens[1..tokens.length]
          result = calc_fn_val(arr)
          if result == []
            display_result display_no_variable_error "#{tokens[0]}"
          elsif get_err_string(result) || result.nil?
            display_result display_error
          else
            display_result result
          end
      end
    end
  end

  def set_instance_var(var, value)
    instance_variable_set("@#{var}", value)
  end

  def define(tokens)
    if tokens.length < 3
      display_result display_error
    elsif tokens[0] == '('
      # function with parameters
      puts "Parameters"
    elsif not /[[:alpha:]]/ =~ tokens[0]
      display_result display_error
    elsif tokens[1] != '('
      # define a function without parameters
      variable = tokens[tokens.index(tokens[0]) + 1]
      if tokens[1] == '"' && tokens[2..tokens.length].include?('"')
        variable = tokens[1]
        tokens[2..tokens.length].each do |val|
          break if val == '"'
          variable.insert(variable.length, val)
        end
        variable.insert(variable.length, '"')
        set_instance_var(tokens[0], variable)
      elsif tokens[1] == '"' && !tokens[2..tokens.length].include?('"')
        display_result display_error
      elsif tokens[1] == '#'
        if (tokens[2] == 't' || tokens[2] == 'f') && tokens[3] == ')'
          variable = "\##{tokens[2]}"
          set_instance_var(tokens[0], variable)
        else
          display_result display_error
        end
      elsif check_for_instance_var(variable.split(''), 0)
        set_instance_var(tokens[0], instance_variable_get("@#{variable}"))
      elsif (variable =~ /[[:alpha:]]/) == 0
        display_result display_no_variable_error variable
      else
        set_instance_var(tokens[0], variable)
      end
    else
      result = calc_fn_val(tokens[tokens.index(tokens.select{ |var| var == '(' }.first) + 1..tokens.length])
      if result.class == Integer
        result = result.to_i
      elsif result.class == String
        return display_result result if get_err_string(result)
      end
      set_instance_var(tokens[0], result)
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
      elsif func == 'null' && tokens[idx + 1] == '?'
        return null?(tokens[idx + 2..tokens.length])
      elsif func == 'null'
        return null
      elsif func == 'cons' && tokens[idx + 1] == '?'
        return cons?(tokens[idx + 2..tokens.length])
      elsif func == 'cons'
        return cons(tokens[idx + 1..tokens.length])
      elsif func == 'car'
        return car(tokens[idx + 1..tokens.length])
      elsif func == 'cdr'
        return cdr(tokens[idx + 1..tokens.length])
      elsif valid_multiple_car_cdr(tokens)
        return multiple_car_cdr(tokens[0..tokens.length - 2])
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

  def change_sign(sign)
    case sign
    when '-' then '+'
    when '/' then '*'
    else sign
    end
  end

  def get_sign_value(sign)
    if sign == '*' || sign == '/'
      1
    else
      0
    end
  end

  def primary_calc_helper(tokens, sign)
    if tokens.length < 2
      get_sign_value(sign)
    elsif tokens.length == 2 || (tokens[1] == '.' && tokens.length <= 4)
      calculate_digit_scheme(tokens, 0)[0]
    else
      primary_calculations(tokens, change_sign(sign))
    end
  end

  def primary_calculations(tokens, sign)
    x, idx = calculate_digit_scheme(tokens, 0)
    tokens = tokens[idx..tokens.length]
    y = primary_calc_helper(tokens, sign)
    convert_calculation_to_scheme(sign, x, y)
  end

  def scheme_equal?(tokens)
    x, idx = calculate_bool_scheme(tokens)
    y = calculate_bool_scheme(tokens[idx..tokens.length])[0]
    return display_error if get_err_bool(x) || get_err_bool(y)
    convert_boolean_to_scheme x == y
  end

  def calculate_other(tokens)
    if tokens[0] == '#'
      calculate_bool_scheme(tokens)
    elsif tokens[0] == '"'
      idx = find_next_quote(tokens)
      [get_string(tokens, 0, idx), idx + 1]
    else
      result = calculate_digit_scheme(tokens, 0)
      [result[0].to_f, result[1]]
    end
  end

  def calculate_var(tokens)
    if check_for_instance_var(tokens, 0)
      [get_instance_var(tokens, 0), 1]
    elsif tokens[0] == '('
      idx = find_last_bracket(tokens)
      [calc_fn_val(tokens[1..idx]), idx + 1]
    elsif tokens[0] =~ /[[:digit:]]/ || tokens[0] == '#' || tokens[0] == '"'
      calculate_other(tokens)
    else
      display_no_variable_error tokens[0]
    end
  end

  def calculate_if(tokens)
    first, idx = calculate_var(tokens)
    second = calculate_var(tokens[idx..tokens.length])[0]
    [first, second]
  end

  def scheme_if_result(result, first, second)
    return first if get_err_string(first)
    return second if get_err_string(second)
    result == '#t' ? first : second
  end

  def scheme_if(tokens)
    result, idx = calculate_bool_scheme(tokens)
    first, second = calculate_if(tokens[idx..tokens.length])
    scheme_if_result(result, first, second)
  end

  def scheme_string_length(tokens)
    idx = find_next_quote(tokens)
    string = get_string(tokens, 0, idx).delete('"')
    return string if get_err_string(string)
    string.length
  end

  def find_next_quote(tokens)
    return 0 if tokens[0] != '"'
    tokens[1..tokens.length].each_with_index do |v, i|
      return i + 1 if v == '"'
    end
  end

  def get_string_quote(tokens)
    res = ''
    tokens.each do |v|
      res.insert(res.length, v)
    end
    res
  end

  def get_string_helper(tokens, start, end_idx)
    if tokens[start] == '"' && tokens[end_idx] == '"'
      get_string_quote(tokens[start + 1..end_idx - 1])
    elsif check_for_instance_var(tokens, 0) && start.zero?
      get_instance_var(tokens, 0)
    else
      display_error
    end
  end

  def get_string(tokens, start, end_idx)
    if tokens[start] == '('
      idx = find_last_bracket(tokens[start..tokens.length])
      calc_fn_val(tokens[start + 1..idx])
    else
      get_string_helper(tokens, start, end_idx)
    end
  end

  def check_for_default_print(tokens)
    if tokens[0] != '('
      holder = calculate_var(tokens)
      return holder if get_err_string(holder)
      holder[0]
    else
      false
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
