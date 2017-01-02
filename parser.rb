class Parser
  def initialize(entry_string)
    @tokens = []
    @variables = []
    @functions = ['+', '-', '*', 'mod', '/', '<', '<=', '=', '>=', '>', 'equal', 'not']
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
      @functions.each do |func|
        if tokens.include? func
          return display_result calculate_function_value(tokens[tokens.index(func)..tokens.length])
        end
      end
      if tokens[0] != '(' && Parser.instance_variable_defined?("@#{tokens[0]}")
        display_result Parser.instance_variable_get("@#{tokens[0]}")
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
        Parser.instance_variable_set("@#{tokens[0]}",variable)
      elsif (variable =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{variable}")
        Parser.instance_variable_set("@#{tokens[0]}", Parser.instance_variable_get("@#{variable}"))
      elsif (variable =~ /[[:alpha:]]/) == 0
        display_no_variable_error variable
      else
        Parser.instance_variable_set("@#{tokens[0]}", variable)
      end
    else
      result = calculate_function_value(tokens[tokens.index(tokens.select{|var| var == '('}.first)..tokens.length])
      Parser.instance_variable_set("@#{tokens[0]}", result)
    end
  end

  def calculate_function_value(tokens)
    tokens.each do |func|
      idx = tokens.index func
      if func == '+'
        return plus(tokens[idx + 1], tokens[idx + 2..tokens.length])
      elsif func == '-'
        return minus(tokens[idx + 1], tokens[idx + 2..tokens.length])
      elsif func == '*'
        return mult(tokens[idx + 1], tokens[idx + 2..tokens.length])
      elsif func == 'mod'
        return partition(tokens[idx + 1], tokens[idx + 2..tokens.length])
      elsif func == '/'
        return tokens[idx + 1] + '/' + tokens[idx + 2]
      elsif (/[['<' || '>' || '=' || '>=' || '<=']]/ =~ func) == 0
        return compare(tokens[idx + 1], tokens[idx + 2..tokens.length], func)
      elsif func == 'equal' && tokens[idx + 1] == '?'
        x = ""
        y = ""
        checker = false
        if tokens[idx + 2] == "\"" && tokens[idx + 4] == "\""
          x = "\"#{tokens[idx + 3]}\""
          checker = true
        elsif Parser.instance_variable_defined?("@#{tokens[idx + 2]}")
          x = Parser.instance_variable_get("@#{tokens[idx + 2]}")
        else
          return display_error
        end
        check_idx_one = 3
        check_idx_two = 5
        if checker == true
          check_idx_one = 5
          check_idx_two = 7
        end
        if tokens[idx + check_idx_one] == "\"" && tokens[idx + check_idx_two] == "\""
          y = "\"#{tokens[idx + check_idx_one + 1]}\""
        elsif Parser.instance_variable_defined?("@#{tokens[idx + check_idx_one]}")
          y = Parser.instance_variable_get("@#{tokens[idx + check_idx_one]}")
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

  def plus(x, y)
    if y[0] == '('
      y = calculate_function_value(y)
    else
      y = y[0..y.index(')') - 1]
      y = y[0]
    end
    if (x =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{x}")
      x = Parser.instance_variable_get "@#{x}"
    end
    if (y =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{y}")
       y = Parser.instance_variable_get "@#{y}"
    end
    (x.to_i + y.to_i).to_s
  end

  def minus(x, y)
    if y[0] == '('
      y = calculate_function_value(y)
    else
      y = y[0..y.index(')') - 1]
      y = y[0]
    end
    if (x =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{x}")
      x = Parser.instance_variable_get "@#{x}"
    end
    if (y =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{y}")
       y = Parser.instance_variable_get "@#{y}"
    end
    (x.to_i - y.to_i).to_s
  end

  def mult(x, y)
    if y[0] == '('
      y = calculate_function_value(y)
    else
      y = y[0..y.index(')') - 1]
      y = y[0]
    end
    if (x =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{x}")
      x = Parser.instance_variable_get "@#{x}"
    end
    if (y =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{y}")
       y = Parser.instance_variable_get "@#{y}"
    end
    (x.to_i * y.to_i).to_s
  end

  def partition(x, y)
    if y[0] == '('
      y = calculate_function_value(y)
    else
      y = y[0..y.index(')') - 1]
      y = y[0]
    end
    if (x =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{x}")
      x = Parser.instance_variable_get "@#{x}"
    end
    if (y =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{y}")
       y = Parser.instance_variable_get "@#{y}"
    end
    (x.to_f / y.to_f).to_s
  end

  def compare(x, y, sign)
    if y[0] == '('
      y = calculate_function_value(y)
    else
      y = y[0..y.index(')') - 1]
      y = y[0]
    end
    if (x =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{x}")
      x = Parser.instance_variable_get "@#{x}"
    else
      return display_error
    end
    if (y =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{y}")
       y = Parser.instance_variable_get "@#{y}"
    else
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

while true
  token = gets.chomp
  Parser.new token
end
