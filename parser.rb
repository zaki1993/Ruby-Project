class Parser
  def initialize
    @tokens = []
    @variables = []
    @functions = ['+', '-', '*', 'mod', '/', '<', '<=', '=', '>=', '>', 'string', 'not', 'equal']
  end

  def read(entry_string)
    if valid_brackets?(entry_string) == false
      display_result display_error
    else
      tokenizer(entry_string)
    end
  end

  def valid_brackets?(str)
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
      @tokens = string.scan(/\(|\)|\w+|\+|\*|\/|\-|\<\=|\>\=|\=|\<|\>|\"|\?|\#/)
      parser(@tokens)
    #TODO for % ^
  end

  def parser(tokens)
    if tokens.length == 0 || tokens.all?{|symbol| symbol == '(' || symbol == ')'}
      #Do nothing
    elsif tokens.include?("define")
      #Define a function
      self.define(tokens[tokens.index("define") + 1..tokens.length])
    else
      #Calculate function value
      tokens.each do |func|
        if @functions.include? func
          return display_result calculate_function_value(tokens[tokens.index(func)..tokens.length])
        end
      end

      if tokens[0] != '(' && self.instance_variable_defined?("@#{tokens[0]}")
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
      if tokens[1] == "\"" && tokens[3] == "\""
        variable = tokens[1]
        variable.insert(variable.length, tokens[2])
        variable.insert(variable.length,"\"")
        self.instance_variable_set("@#{tokens[0]}", variable)
      elsif tokens[1] == "\"" && tokens[3] != "\""
        variable = tokens[1]
        tokens[2..tokens.length - 2].each do |val|
          if val != "\""
            variable.insert(variable.length, val)
          end
        end
        variable.insert(variable.length,"\"")
        self.instance_variable_set("@#{tokens[0]}", variable)
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
      if (/[['+' || '-' || '*' || 'mod']]/ =~ func) == 0
        return primary_calculations(tokens[idx + 1], tokens[idx + 2..tokens.length], func)
      elsif func == '/'
        return tokens[idx + 1] + '/' + tokens[idx + 2]
      elsif (/[['<' || '>' || '=' || '>=' || '<=']]/ =~ func) == 0
        return compare(tokens[idx + 1], tokens[idx + 2..tokens.length], func)
      elsif func == 'string' && tokens[idx + 1] == '=' && tokens[idx + 2] == '?'
        x = ""
        y = ""
        checker = false

        if tokens[idx + 3] == "\"" && tokens[idx + 5] == "\""
          x = "\"#{tokens[idx + 4]}\""
          checker = true
        elsif self.instance_variable_defined?("@#{tokens[idx + 3]}")
          x = self.instance_variable_get("@#{tokens[idx + 3]}")
        else
          return display_error
        end

        check_idx_one = 4
        check_idx_two = 6

        if checker == true
          check_idx_one = 6
          check_idx_two = 8
        end
        if tokens[idx + check_idx_one] == "\"" && tokens[idx + check_idx_two] == "\""
          y = "\"#{tokens[idx + check_idx_one + 1]}\""
        elsif self.instance_variable_defined?("@#{tokens[idx + check_idx_one]}")
          y = self.instance_variable_get("@#{tokens[idx + check_idx_one]}")
        else
          return display_error
        end
        return scheme_equal?(x, y)
      elsif func == 'string' && tokens[idx + 1] == '-' && tokens[idx + 2] == 'length'
        return scheme_string_length(tokens[idx + 3.. tokens.length])
      elsif func == 'not'
        result = scheme_not(tokens[idx + 1..tokens.length])
        return display_error if result == display_error
        return result
      elsif func == 'equal' && tokens[idx + 1] == '?'
          return scheme_equal?(tokens[idx + 2..tokens.length])
      else
        return display_error
      end
    end
  end

  def primary_calculations(x, y, sign)
    if y[0] == '('
      y = calculate_function_value(y)
    elsif
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

    case sign
      when '+'
        (x.to_f + y.to_f).to_s
      when '-'
        (x.to_f - y.to_f).to_s
      when '*'
        (x.to_f * y.to_f).to_s
      when 'mod'
        (x.to_f / y.to_f).to_s
    end
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
    if result == true
      result = '#t'
    else
      result = '#f'
    end
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
      idx = idx + 1
    elsif (tokens[idx] =~ /[[:alpha:]]/) == 0 && !self.instance_variable_defined?("@#{tokens[idx]}")
      return display_no_variable_error tokens[idx]
    elsif tokens[idx] == '#' && (tokens[idx + 1] == 't' || tokens[idx + 1] == 'f')
      y = tokens[idx] + tokens[idx + 1]
      idx = idx + 1
    else
      return display_error
    end
    result = x.eql? y
    return '#t' if result
    return '#f'
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
