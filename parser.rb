class Parser
  def initialize(entry_string)
    @tokens = []
    @variables = []
    @functions = ['+','-','*','mod','/']
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
      @tokens = string.scan(/\(|\)|\w+|\+|\*|\/|\-/)
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
        display_result display_no_variable_error "#{tokens[0]}"
      end
    end
  end

  def define(tokens)
    if tokens.length < 3
      display_error
    elsif tokens.length == 3
      #define a function without parameters
      variable = tokens[tokens.index(tokens[0]) + 1]
      if (variable =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{variable}")
        Parser.instance_variable_set("@#{tokens[0]}", Parser.instance_variable_get("@#{variable}"))
      else
        Parser.instance_variable_set("@#{tokens[0]}", variable)
      end
    elsif tokens.length == 3 && tokens.index('(')!=4
      #Functions with parameters
      puts "Parameters"
    else
      #TODO
      result = calculate_function_value(tokens[tokens.index(tokens.select{|var| var == '('}.first)..tokens.length])
      Parser.instance_variable_set("@#{tokens[0]}", result)
    end
    #puts Parser.instance_variables
  end

  def calculate_function_value(tokens)
    tokens.each do |func|
      if func == '+'
        return plus(tokens[tokens.index(func) + 1], tokens[tokens.index(func) + 2])
      elsif func == '-'
        return minus(tokens[tokens.index(func) + 1], tokens[tokens.index(func) + 2])
      elsif func == '*'
        return mult(tokens[tokens.index(func) + 1], tokens[tokens.index(func) + 2])
      elsif func == 'mod'
        return partition(tokens[tokens.index(func) + 1], tokens[tokens.index(func) + 2])
      elsif func == '/'
        return tokens[tokens.index(func) + 1] + '/' + tokens[tokens.index(func) + 2]
      end
    end
  end

  def plus(x, y)
    if (x =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{x}")
      x = Parser.instance_variable_get "@#{x}"
    end
    if (y =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{y}")
       y = Parser.instance_variable_get "@#{y}"
    end
    (x.to_i + y.to_i).to_s
  end

  def minus(x, y)
    if (x =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{x}")
      x = Parser.instance_variable_get "@#{x}"
    end
    if (y =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{y}")
       y = Parser.instance_variable_get "@#{y}"
    end
    (x.to_i - y.to_i).to_s
  end

  def mult(x, y)
    if (x =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{x}")
      x = Parser.instance_variable_get "@#{x}"
    end
    if (y =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{y}")
       y = Parser.instance_variable_get "@#{y}"
    end
    (x.to_i * y.to_i).to_s
  end

  def partition(x, y)
    if (x =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{x}")
      x = Parser.instance_variable_get "@#{x}"
    end
    if (y =~ /[[:alpha:]]/) == 0 && Parser.instance_variable_defined?("@#{y}")
       y = Parser.instance_variable_get "@#{y}"
    end
    (x.to_f / y.to_f).to_s
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

while true
  token = gets.chomp
  Parser.new token
end
