module Display
  def display_result(result)
    puts result
  end

  def display_error
    "Incorrect command"
  end

  def display_no_variable_error(variable)
    "Undefined variable #{variable}"
  end
end

class Parser
  include Display
  def initialize
    @tokens = []
    @defined_functions = []
    @functions = ['+', '-', '*', 'div', 'mod', '/', '<', '<=', '=', '>=', '>', 'string', 'not', 'equal', 'if', 'substring']
    @SPACE = '자'
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
    str.each_char.each_with_index do |symbol,idx|
      if can_place_space
        if symbol == " "
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
    strim = str.gsub(/[^\[\]\(\)\{\}]/,'')
    return true if strim.empty?
    return false if strim.size.odd?
    loop do
      s = strim.gsub('()','').gsub('[]','').gsub('{}','')
      return true if s.empty?
      return false if s == strim
      strim = s
    end
  end

  def tokenizer(string)
      @tokens = string.scan(/\(|\)|\w+|\+|\-|\*|\/|\<\=|\>\=|\=|\<|\>|\"|\?|\#|\자/)
      @tokens.each do |val|
        if val == @SPACE
          @tokens[@tokens.index(val)] = " "
        end
      end
      parser(@tokens)
    #TODO for % ^
  end

  def parser(tokens)
    if tokens.length == 0

    elsif tokens.length != 0 && check_for_default_print(tokens)

    elsif tokens.all?{|symbol| symbol == '(' || symbol == ')'}
      #ok
    elsif tokens.include?("define")
      #Define a function
      self.define(tokens[tokens.index("define") + 1..tokens.length])
    else
      #Calculate function value
      tokens.each do |func|
        if @functions.include? func
          arr = tokens[tokens.index(func)..tokens.length]
          return display_result calculate_function_value(arr)
        end
      end

      if tokens[0] != '(' && tokens.length == 1 && self.instance_variable_defined?("@#{tokens[0]}")
        display_result self.instance_variable_get("@#{tokens[0]}")
      else
        display_result display_no_variable_error "#{tokens[0]}"
      end
    end
  end

  def define(tokens)
    if tokens.length < 3
      display_result display_error
    elsif tokens[0] == '('
      #function with parameters
      puts "Parameters"
    elsif (/[[:alpha:]]/ =~ tokens[0]) != 0
      display_result display_error
    elsif tokens[1] != '('
      #define a function without parameters
      variable = tokens[tokens.index(tokens[0]) + 1]
      if tokens[1] == "\"" && tokens[2..tokens.length].include?("\"")
        variable = tokens[1]
        tokens[2..tokens.length].each do |val|
          break if val == "\""
          variable.insert(variable.length, val)
        end
        variable.insert(variable.length,"\"")
        self.instance_variable_set("@#{tokens[0]}", variable)
      elsif tokens[1] == "\"" && !tokens[2..tokens.length].include?("\"")
        display_result display_error
      elsif tokens[1] == '#'
        if (tokens[2] == 't' || tokens[2] == 'f') && tokens[3] == ')'
          variable = "\##{tokens[2]}"
          self.instance_variable_set("@#{tokens[0]}", variable)
        else
          display_result display_error
        end
      elsif (variable =~ /[[:alpha:]]/) == 0 && self.instance_variable_defined?("@#{variable}")
        self.instance_variable_set("@#{tokens[0]}", self.instance_variable_get("@#{variable}"))
      elsif (variable =~ /[[:alpha:]]/) == 0
        display_result display_no_variable_error variable
      else
        self.instance_variable_set("@#{tokens[0]}", variable)
      end
    else
      result = calculate_function_value(tokens[tokens.index(tokens.select{|var| var == '('}.first) + 1..tokens.length])
      if result == display_error || result.include?("Undefined variable")
        display_result result
      else
        self.instance_variable_set("@#{tokens[0]}", result)
      end
    end
  end

  def calculate_function_value(tokens)
    tokens.each do |func|
      idx = tokens.index func
      if func == '-'
        #TODO FIX THIS
        return primary_calculations(tokens[1..tokens.length], func)
      elsif func == 'if'
        return scheme_if(tokens[idx + 1.. tokens.length])
      elsif (/[['-' || '+' || '*' || 'div' || 'mod']]/ =~ func) == 0
        return primary_calculations(tokens[1..tokens.length], func)
      elsif func == '/'
        return tokens[idx + 1] + '/' + tokens[idx + 2]
      elsif (/[['<' || '>' || '=' || '>=' || '<=']]/ =~ func) == 0
        return compare(tokens[idx + 1], tokens[idx + 2..tokens.length], func)
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
    left_brackets = 0
    right_brackets = 0
    idx = 0
    skips = 0
    #FIND X
      if tokens[idx] != '('
        if (tokens[idx] =~ /[[:alpha:]]/) == 0 && self.instance_variable_defined?("@#{tokens[0]}")
          if self.instance_variable_get("@#{tokens[0]}").to_i.is_a? Integer
            x = self.instance_variable_get("@#{tokens[0]}").to_i
          else
            return display_error
          end
        elsif (tokens[idx] =~ /[[:alpha:]]/) == 0 && !self.instance_variable_defined?("@#{tokens[0]}")
          return display_no_variable_error tokens[idx]
        elsif tokens[idx].to_i.is_a? Integer
          x = tokens[idx].to_i
        else
          return display_error
        end
        idx = idx + 1
      else
        left_brackets = 0
        right_brackets = 0
        tokens.each_with_index do |val,idxx|
          if val == '('
            left_brackets = left_brackets + 1
          end
          if val == ')'
            right_brackets = right_brackets + 1
          end
          if left_brackets == right_brackets
            idx = idx + idxx
            x_check = 1
            break
          end
        end
        x = calculate_function_value(tokens[1..idx]).to_i
      end

    #FIND Y
    tokens[idx..tokens.length].each_with_index do |var, index|
      if skips != 0
        skips = skips - 1
        next
      end
      if var == ')' && index == find_last_bracket(tokens[idx - 1..tokens.length])
         break
      end
      if var != '(' && var != ')'
        if (var =~ /[[:alpha:]]/) == 0 && self.instance_variable_defined?("@#{var}")
          if self.instance_variable_get("@#{var}").to_i.is_a? Integer
            y = self.instance_variable_get("@#{var}").to_i
          else
            return display_error
          end
        elsif (var =~ /[[:alpha:]]/) == 0 && !self.instance_variable_defined?("@#{var}")
          return display_no_variable_error var
        elsif var.to_i.is_a? Integer
          y = var.to_i
        else
          return display_error
        end
        case sign
          when '+'
            x = x + y
          when '-'
            x = x - y
          when '*'
            x = x * y
          when 'div'
            x = x / y
          when 'mod'
            x = x % y
        end
      elsif var == '('
        left_brackets = 0
        right_brackets = 0
        find_close_bracket = 0
        tokens[idx + index..tokens.length].each_with_index do |v,i|
          if v == '('
            left_brackets = left_brackets + 1
          end
          if v == ')'
            right_brackets = right_brackets + 1
          end
          if left_brackets == right_brackets
            find_close_bracket = idx + index + i
            break
          end
        end
        y = calculate_function_value(tokens[idx + index + 1..find_close_bracket]).to_s.to_i
        skips = find_close_bracket - idx - index
        case sign
          when '+'
            x = x + y
          when '-'
            x = x - y
          when '*'
            x = x * y
          when 'div'
            x = x / y
          when 'mod'
            x = x % y
        end
      end
    end
   return x
  end

  def compare(x, y, sign)
    if y[0] == '('
      y = calculate_function_value(y[1..y.length])
    else
      y = y[0..y.index(')') - 1]
      y = y[0]
    end
    if (x =~ /[[:alpha:]]/) == 0 && self.instance_variable_defined?("@#{x}")
      x = self.instance_variable_get "@#{x}"
    elsif not x.to_i.is_a? Integer
      return display_error
    end
    if (y =~ /[[:alpha:]]/) == 0 && self.instance_variable_defined?("@#{y}")
       y = self.instance_variable_get "@#{y}"
    elsif not y.to_i.is_a? Integer
      return display_error
    end
      result = case sign
        when '<'
          x < y
        when '>'
          x > y
        when '='
          x == y
        when '<='
          x <= y
        else
          x >= y
      end
    return convert_boolean_to_scheme result
  end

  def scheme_string_equal(tokens, idx)
    x = ""
    y = ""
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
    elsif self.instance_variable_defined?("@#{tokens[idx + 3]}")
      x = self.instance_variable_get("@#{tokens[idx + 3]}")
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
    elsif self.instance_variable_defined?("@#{tokens[first_q_idx]}")
      y = self.instance_variable_get("@#{tokens[first_q_idx]}")
    else
      return display_error
    end
    x convert_boolean_to_scheme x.eql? y
  end

  def scheme_equal?(tokens)
    x, y = '', ''
    idx = 0
    if tokens[idx] == '('
      x = calculate_function_value(tokens[idx + 1..tokens.length])
      tokens = tokens[tokens.index(')')..tokens.length]
      tokens.each do |val|
        if val != ')'
          idx = tokens.index(val)
          break
        end
      end
      if x == display_error || x.include?("Undefined variable")
        return x
      end
    elsif (tokens[idx] =~ /[[:alpha:]]/) == 0 && self.instance_variable_defined?("@#{tokens[idx]}")
      x = self.instance_variable_get("@#{tokens[idx]}")
      if !(x[0] == '#' && (x[1] == 't' || x[1] == 'f') && x.length == 2)
        return display_error
      end
      idx = idx + 1
    elsif (tokens[idx] =~ /[[:alpha:]]/) == 0 && !self.instance_variable_defined?("@#{tokens[idx]}")
      return display_no_variable_error tokens[idx]
    elsif tokens[idx] == '#' && (tokens[idx + 1] == 't' || tokens[idx + 1] == 'f')
      x = tokens[idx] + tokens[idx + 1]
      idx = idx + 2
    else
      return display_error
    end
    if tokens[idx] == '('
      tokens = tokens[idx + 1..tokens.length]
      y = calculate_function_value(tokens)
      tokens = tokens[tokens.index(')')..tokens.length]
      idx = tokens.index('(')
      if y == display_error || y.include?("Undefined variable")
        return y
      end
    elsif (tokens[idx] =~ /[[:alpha:]]/) == 0 && self.instance_variable_defined?("@#{tokens[idx]}")
      y = self.instance_variable_get("@#{tokens[idx]}")
      if !(y[0] == '#' && (y[1] == 't' || y[1] == 'f') && y.length == 2)
        return display_error
      end
      idx = idx + 1
    elsif (tokens[idx] =~ /[[:alpha:]]/) == 0 && !self.instance_variable_defined?("@#{tokens[idx]}")
      return display_no_variable_error tokens[idx]
    elsif tokens[idx] == '#' && (tokens[idx + 1] == 't' || tokens[idx + 1] == 'f')
      y = tokens[idx] + tokens[idx + 1]
      idx = idx + 1
    else
      return display_error
    end
    return convert_boolean_to_scheme x.eql? y
  end

  def convert_boolean_to_scheme(statement)
    return '#t' if statement
    return '#f'
  end

  def scheme_if(tokens)
    #CHECK FOR CORRECTNESS
    if tokens[0] != '('
      return display_error
    end
    #EVERYTHING IS OK WE CAN CONTINUE
    idx_last = find_last_bracket(tokens) + 1
    val = calculate_function_value(tokens[1..idx_last])
    return display_error if val != '#t' && val != '#f'
    #CALCULATE THE RESULT IF THE STATEMENT IS TRUE
    true_res = ""
    idx_last_true = 0
    if tokens[idx_last + 1] == '('
      idx_last_true = find_last_bracket(tokens[idx_last + 1..tokens.length]) + idx_last + 2
      true_res = calculate_function_value(tokens[idx_last + 2 ..idx_last_true])
    elsif (/[[:alpha:]]/ =~ tokens[idx_last + 1]) == 0
      if self.instance_variable_defined?("@#{tokens[idx_last + 1]}")
        true_res = self.instance_variable_get("@#{tokens[idx_last + 1]}")
      else
        return display_error
      end
    elsif (/[[:digit:]]/ =~ tokens[idx_last + 1])
      true_res = tokens[idx_last + 1]
    elsif tokens[idx_last + 1] == "\""
      if !tokens[idx_last + 2 .. tokens.length].include?("\"")
        return display_error
      else
        true_res = "\""
        tokens[idx_last + 2..tokens.length].each_with_index do |v,i|
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
    #CALCULATE THE RESULT IF THE STATEMENT IS FALSE
    false_res = ""
    idx_last_false = 0
    if tokens[idx_last_true + 1] == '('
      idx_last_false = find_last_bracket(tokens[idx_last_true + 1..tokens.length]) + idx_last_true + 2
      false_res = calculate_function_value(tokens[idx_last_true + 2 ..idx_last_false])
    elsif (/[[:alpha:]]/ =~ tokens[idx_last_true + 1]) == 0
      if self.instance_variable_defined?("@#{tokens[idx_last_true + 1]}")
        false_res = self.instance_variable_get("@#{tokens[idx_last_true + 1]}")
      else
        return display_error
      end
    elsif (/[[:digit:]]/ =~ tokens[idx_last_true + 1])
      false_res = tokens[idx_last_true + 1]
    elsif tokens[idx_last_true + 1] == "\""
      if !tokens[idx_last_true + 2 .. tokens.length].include?("\"")
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
    if tokens.include? "Undefined variable"
      return tokens.split(" ")[2]
    end
    return display_error if tokens == display_error
    x = ''
    if tokens[0] == '('
      x = calculate_function_value(tokens[1..tokens.length])
      return scheme_not(x)
    elsif (tokens[0] =~ /[[:alpha:]]/) == 0 && !self.instance_variable_defined?("@#{tokens[0]}")
      return (display_no_variable_error tokens[0])
    elsif (tokens[0] =~ /[[:alpha:]]/) == 0 && self.instance_variable_defined?("@#{tokens[0]}")
      if tokens[1] != ')'
        return display_error
      else
        x = self.instance_variable_get("@#{tokens[0]}")
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
    if tokens[0] !="\"" && tokens[2] != "\""
      if (/[[:alpha:]]/ =~ tokens[0]) == 0 && self.instance_variable_defined?("@#{tokens[0]}")
        result = self.instance_variable_get("@#{tokens[0]}").length
        if result.to_i.is_a? Integer
          return display_error
        end
        return result
      elsif (/[[:alpha:]]/ =~ tokens[0]) == 0 && !self.instance_variable_defined?("@#{tokens[0]}")
        return display_no_variable_error tokens[0]
      else
        return display_error
      end
    elsif tokens[0] == "\"" && tokens[1..tokens.length].include?("\"")
      tokens[1..tokens.length].each do |val|
        if val == "\""
          break
        else
          result = result + val.length
        end
      end
      return result.to_s
    else
      return display_error
    end
  end

  def scheme_substring(tokens)
    #EXTRACT THE STRING STRING
    string = ""
    idx = 0
    if tokens[0] == "\""
      if tokens[1..tokens.length].include?("\"")
        tokens[1..tokens.length].each_with_index do |v,i|
          if v == "\""
            idx = i + 2
            break
          end
          string.insert(string.length, v)
        end
      else
        return display_error
      end
    elsif /[[:alpha:]]/ =~ tokens[0]
      if self.instance_variable_defined?("@#{tokens[0]}")
        string = self.instance_variable_get("@#{tokens[0]}")
        if (/[[:digit:]]/ =~ string) == 0 || (/[[ '#' ]]/ =~ string) == 0
          return display_error
        end
        idx = idx + 1
      else
        return display_no_variable_error tokens[0]
      end
    else
      return display_error
    end
    #DETERMINE WHICH OF THE SUBSTRING FUNCTIONS WE NEED
    param_one = ""
    param_two = ""
    if tokens[idx] == ')'
      return display_error
    end
    if (/[[:digit:]]/ =~ tokens[idx]) == 0
      param_one = tokens[idx].to_i
      idx = idx + 1
    elsif (/[[:alpha:]]/ =~ tokens[idx]) == 0
      if self.instance_variable_defined?("@#{tokens[idx]}")
        param_one = self.instance_variable_get("@#{tokens[idx]}")
        if (/[[:digit:]]/ =~ param_one) != 0
          return display_error
        end
        idx = idx + 1
      end
    elsif tokens[idx] == '('
      bracket = find_last_bracket(tokens[idx..tokens.length]) + 1 + idx
      param_one = calculate_function_value(tokens[idx + 1..bracket]).to_s
      if (/[[:digit:]]/ =~ param_one) != 0
        return display_error
      end
      idx = bracket + 1
    else
      return display_error
    end
    #CALCULATED THE START VALUE
    #NOW CHECK IF THERE IS AN END VALUE
    check = false
    if (/[[:digit:]]/ =~ tokens[idx]) == 0
      param_two = tokens[idx].to_i
      idx = idx + 1
      check = true
    elsif (/[[:alpha:]]/ =~ tokens[idx]) == 0
      if self.instance_variable_defined?("@#{tokens[idx]}")
        param_two = self.instance_variable_get("@#{tokens[idx]}")
        if (/[[:digit:]]/ =~ param_one) != 0
          return display_error
        end
        idx = idx + 1
        check = true
      end
    elsif tokens[idx] == '('
      bracket = find_last_bracket(tokens[idx..tokens.length]) + 1 + idx
      param_two = calculate_function_value(tokens[idx + 1..bracket]).to_s
      if (/[[:digit:]]/ =~ param_two) != 0
        return display_error
      end
      check = true
    elsif tokens[idx] == ')'
      #EVERYTHING IS OK
      #WE HAVE ONLY START PARAMETER
    else
      return display_error
    end
    param_one = param_one.to_i
    param_two = param_two.to_i
    if param_one < 0 || param_two < 0 || (param_one < param_two && !check) ||
      param_one > string.length || param_two > string.length
      return display_error
    end
    return "" if param_one == param_two
    return string[param_one..param_two - 1] if check
    return string[param_one..string.length]
  end

  def check_for_default_print(tokens)
    if tokens[0] != "("
      if tokens[0] == '#'
        if (tokens[1] == 't' || tokens[1] == 'f') && tokens.length == 2
          display_result (tokens[0] + tokens[1])
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
          tokens[1..tokens.length].each_with_index do |val,index|
            break if val == "\""
            if (val == " ")
              result.insert(result.length, " ")
            else
              result.insert(result.length, val)
            end
          end
          result.insert(result.length,"\"")
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
    left_brackets = 1
    right_brackets = 0
      tokens[1..tokens.length].each_with_index do |v,i|
        if v == '('
          left_brackets = left_brackets + 1
        end
        if v == ')'
          right_brackets = right_brackets + 1
        end
        return i if left_brackets == right_brackets
      end
  end
end
