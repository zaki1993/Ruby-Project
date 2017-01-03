class Parser
  def initialize
    @tokens = []
    @variables = []
    @functions = ['+', '-', '*', 'mod', '/', '<', '<=', '=', '>=', '>', 'equal', 'not']
  end

  def read(entry_string)
    if valid_brackets?(entry_string) == false
      display_error
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
        display_no_variable_error "#{tokens[0]}"
      end
    end
  end

  def define(tokens)
    if tokens.length < 3
      display_error
    elsif tokens[0] == '('
      #function with parameters
      puts "Parameters"
    elsif tokens[1] != '('
      #define a function without parameters
      variable = tokens[tokens.index(tokens[0]) + 1]

      if tokens[1] == "\"" && tokens[3] == "\""
        variable = tokens[2]
        variable.insert(0, "\"")
        variable.insert(variable.length,"\"")
        self.instance_variable_set("@#{tokens[0]}", variable)
      elsif tokens[1] == '#' && tokens[2] == 't' || tokens[2] == 'f'
        variable = "\##{tokens[2]}"
        self.instance_variable_set("@#{tokens[0]}", variable)
      elsif (variable =~ /[[:alpha:]]/) == 0 && self.instance_variable_defined?("@#{variable}")
        self.instance_variable_set("@#{tokens[0]}", self.instance_variable_get("@#{variable}"))
      elsif (variable =~ /[[:alpha:]]/) == 0
        display_no_variable_error variable
      else
        self.instance_variable_set("@#{tokens[0]}", variable)
      end
    else
      result = calculate_function_value(tokens[tokens.index(tokens.select{|var| var == '('}.first)..tokens.length])
      self.instance_variable_set("@#{tokens[0]}", result)
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
      elsif func == 'string' && tokens[idx + 2] == '=' && tokens[idx + 3] == '?'
        x = ""
        y = ""
        checker = false

        if tokens[idx + 3] == "\"" && tokens[idx + 5] == "\""
          x = "\"#{tokens[idx + 3]}\""
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
      elsif func == 'not'
        if tokens[idx + 1] == '#' && tokens[idx + 2] == 't' || tokens[idx + 2] == 'f'
          return scheme_not(tokens[idx + 1].to_s + tokens[idx + 2].to_s)
        else
          return display_error
        end
      else
        display_error
      end
    end
  end
  def primary_calculations(x, y, sign)
    if y[0] == '('
      y = calculate_function_value(y)
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
      y = calculate_function_value(y)
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
      result =  case sign
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

  def scheme_equal?(x, y)
    return x.eql? y
  end

  def scheme_not(x)
    if x == '#t'
      '#f'
    elsif x == '#f'
      '#t'
    else
      display_error
    end
  end

  def display_result(result)
    puts result
  end

  def display_error
    display_result "Incorrect command"
  end

  def display_no_variable_error(variable)
    display_result "Undefined variable #{variable}"
  end
end
