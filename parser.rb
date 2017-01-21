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
end

module ToScheme
  def convert_calculation_to_scheme(sign, x, y)
    case sign
    when '+' then x + y
    when '-' then x - y
    when '*' then x * y
    end
  end

  def compare(tokens, sign)
    x = 0
    y = 0
    idx = 0
    if tokens[idx] == '('
      idx = find_last_bracket(tokens)
      x = calculate_function_value(tokens[1..idx])
      idx += 1
    else
      x = calculate_digit_scheme(tokens[0])
    end
    if tokens[idx + 1] == '('
      oldidx += 1
      idx = find_last_bracket(tokens[oldIdx..tokens.length]) + oldIdx
      y = calculate_function_value(tokens[oldIdx + 1..idx])
    else
      y = calculate_digit_scheme(tokens[idx + 1])
    end
    return convert_compare_to_scheme(sign, x, y)
  end

  def calculate_digit_scheme(value)
    if (value=~ /[[:alpha:]]/) == 0
      if instance_variable_defined?("@#{value}")
        result = instance_variable_get "@#{value}"
        return display_error if (result =~ /[[:digit:]]/) != 0
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
    result =
    case sign
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
  def initialize
    @tokens = []
    @defined_functions = []
    @functions = ['+', '-', '*', 'div', 'mod', '/', '<', '<=', '=', '>=', '>', 'string', 'not', 'equal', 'if', 'substring']
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
          str[idx] = @SPACE
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
          return display_result calculate_function_value(arr)
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
      result = calculate_function_value(tokens[tokens.index(tokens.select{|var| var == '('}.first) + 1..tokens.length])
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

  def calculate_function_value(tokens)
    tokens.each do |func|
      idx = tokens.index func
      if func == '-'
        # TODO FIX THIS
        return primary_calculations(tokens[idx + 1..tokens.length], func)
      elsif func == 'if'
        return scheme_if(tokens[idx + 1.. tokens.length])
      elsif (/[['-' | '+' | '*' ]]/ =~ func) == 0
        return primary_calculations(tokens[idx + 1..tokens.length], func)
      elsif (/[['mod' | 'div']]/ =~ func) == 0
        return calculate_mod_div(tokens[idx + 1..tokens.length], func)
      elsif func == '/'
        return tokens[idx + 1] + '/' + tokens[idx + 2]
      elsif (/[['<' | '>' | '=' | '>=' | '<=']]/ =~ func) == 0
        return compare(tokens[1..tokens.length], func)
      elsif func == 'string' && tokens[idx + 1] == '=' && tokens[idx + 2] == '?'
        return scheme_string_equal(tokens, idx)
      elsif func == 'string' && tokens[idx + 1] == '-' && tokens[idx + 2] == 'length'
        return scheme_string_length(tokens[idx + 3.. tokens.length])
      elsif func == 'not'
        result = scheme_not(tokens[idx + 1..tokens.length])
        return display_error if result == display_error
        return result
      elsif func == 'equal' && tokens[idx + 1] == '?'
        return scheme_equal?(tokens[idx + 2..tokens.length])
      elsif func == 'substring'
        return scheme_substring(tokens[idx + 1..tokens.length])
      else
        return display_error
      end
    end
  end

  def primary_calculations(tokens, sign)
    x = 0
    y = 0
    idx = 0
    if tokens[idx] != '('
      x = calculate_digit_scheme(tokens[idx]).to_i
      idx += 1
    else
      oldIdx = idx
      idx = find_last_bracket(tokens[idx..tokens.length]) + oldIdx + 1
      x = calculate_function_value(tokens[oldIdx + 1..idx]).to_i
    end
    tokens = tokens[idx..tokens.length]
    if tokens.length < 2
      y = 0
    elsif tokens.length == 2
      y = calculate_digit_scheme(tokens[0]).to_i
    else
      if sign == '-'
        tokens.unshift('+')
      else
        tokens.unshift(sign)
      end
      y = calculate_function_value(tokens).to_i
    end
    return convert_calculation_to_scheme(sign, x, y)
  end

  def calculate_mod_div(tokens, sign)
      idx = 0
      x = calculate_digit_scheme(tokens[idx])
      idx = idx + find_last_bracket(tokens[idx..tokens.length]) + 1
      y = calculate_digit_scheme(tokens[idx])
      idx = idx + find_last_bracket(tokens[idx..tokens.length]) + 1
      if (calculate_digit_scheme(tokens[idx]) != display_error)
        return display_error
      else
        if sign == 'mod'
          return x % y
        else
          return x / y
        end
      end
  end

  def scheme_string_equal(tokens, idx)
    x = ''
    y = ''
    checker = false
    first_q_idx = 0
    if tokens[idx + 3] == "\"" && tokens[idx + 4..tokens.length].include?("\"")
      x = "\""
      tokens[idx+4..tokens.length].each do |val|
        break if val == "\""
        x.insert(x.length, val)
      end
      x.insert(x.length, "\"")
      first_q_idx = idx + tokens[idx + 4..tokens.length].index("\"") + 5
    elsif instance_variable_defined?("@#{tokens[idx + 3]}")
      x = instance_variable_get("@#{tokens[idx + 3]}")
      first_q_idx = idx + 5
    else
      return display_no_variable_error tokens[idx + 3]
    end
    if tokens[first_q_idx] == "\"" && tokens[first_q_idx + 1.. tokens.length].include?("\"")
      y = "\""
      tokens[first_q_idx + 1..tokens.length].each do |val|
        break if val == "\""
        y.insert(y.length, val)
      end
      y.insert(y.length, "\"")
    elsif instance_variable_defined?("@#{tokens[first_q_idx]}")
      y = instance_variable_get("@#{tokens[first_q_idx]}")
    else
      return display_error
    end
    x convert_boolean_to_scheme x.eql? y
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
    x = calculate_function_value(tokens[idx + 1..tokens.length])
    return x if x == display_error || x.include?("Undefined variable")
    x
  end

  def get_boolean_scheme(tokens, idx)
    y = ''
    if (tokens[idx] =~ /[[:alpha:]]/) == 0
      if instance_variable_defined?("@#{tokens[idx]}")
        y = instance_variable_get("@#{tokens[idx]}")
      else
        return display_no_variable_error tokens[idx]
      end
      if !(y[0] == '#' && (y[1] == 't' || y[1] == 'f') && y.length == 2)
        return display_error
      end
    elsif tokens[idx] == '#' && (tokens[idx + 1] == 't' || tokens[idx + 1] == 'f')
      y = tokens[idx] + tokens[idx + 1]
    else
      return display_error
    end
    return y
  end

  def convert_boolean_to_scheme(statement)
    return '#t' if statement
    return '#f'
  end

  def scheme_if(tokens)
    # CHECK FOR CORRECTNESS
    if tokens[0] != '('
      return display_error
    end
    # EVERYTHING IS OK WE CAN CONTINUE
    idx_last = find_last_bracket(tokens) + 1
    val = calculate_function_value(tokens[1..idx_last])
    return display_error if val != '#t' && val != '#f'
    # CALCULATE THE RESULT IF THE STATEMENT IS TRUE
    true_res = ''
    idx_last_true = 0
    if tokens[idx_last + 1] == '('
      idx_last_true = find_last_bracket(tokens[idx_last + 1..tokens.length]) + idx_last + 2
      true_res = calculate_function_value(tokens[idx_last + 2 ..idx_last_true])
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
      false_res = calculate_function_value(tokens[idx_last_true + 2 ..idx_last_false])
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
    if val == '#t'
      return true_res
    elsif val == '#f'
      return false_res
    end
  end

  def scheme_not(tokens)
    if tokens.include? display_no_variable_error ''
      return tokens.split(' ')[2]
    end
    return display_error if tokens == display_error
    x = ''
    if tokens[0] == '('
      x = calculate_function_value(tokens[1..tokens.length])
      return scheme_not(x)
    elsif (tokens[0] =~ /[[:alpha:]]/) == 0 && !instance_variable_defined?('@#{tokens[0]}')
      return (display_no_variable_error tokens[0])
    elsif (tokens[0] =~ /[[:alpha:]]/).zero? && instance_variable_defined?('@#{tokens[0]}')
      if tokens[1] != ')'
        return display_error
      else
        x = instance_variable_get('@#{tokens[0]}')
        return scheme_not(x)
      end
    elsif (tokens[0] =~ /[[:alpha:]]/) != 0 && tokens[0] == '#' && (tokens[1] == 't' || tokens[1] == 'f') && (tokens[2] == ')' || tokens[2].nil?)
        if tokens[1] == 't'
          return '#f'
        else
          return '#t'
        end
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

  def get_string(tokens, start, endIdx)
    res = ''
    if tokens[start] == "\"" && tokens[endIdx] == "\""
      tokens[start + 1..endIdx - 1].each { |v| res.insert(res.length, v) }
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

  def scheme_substring(tokens)
    idx, param_one, param_two = 0
    check = false
    endIdx = find_next_quote(tokens)
    string = get_string(tokens, idx, endIdx)
    return display_error if string == display_error
    return display_no_variable_error "" if string.include?("Undefined variable")
    idx += endIdx + 1
    if tokens[idx] == ')'
      return display_error
    end
    param_one = calculate_digit_scheme(tokens[idx])
    return display_error if param_one.class.superclass != Integer
    idx += find_last_bracket(tokens[idx..tokens.length]) + 1
    if tokens[idx] == ')'
      param_two = 0
    elsif tokens[idx] == '('
      param_two = calculate_function_value(tokens[idx + 1..tokens.length])
      check = true
    else
      param_two = calculate_digit_scheme(tokens[idx])
      return display_error if param_two.class.superclass != Integer
      check = true
    end
    if param_one < 0 || param_two < 0 || (param_one < param_two && !check) ||
      param_one > string.length || param_two > string.length
      return display_error
    end
    return '' if param_one == param_two && check
    return string[param_one..param_two - 1] if check
    return string[param_one..string.length]
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
