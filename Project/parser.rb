# ErrorMessages module contains different error messages
module ErrorMessages
  def unbalanced_brackets_error
    'error signaled: unbalanced brackets'
  end

  def unbalanced_quotes_error
    'error signaled: unbalanced quotes'
  end
end

# Validator module is used to validate if the user input is correct
module Validator
  def balanced_brackets?(token)
    strim = token.gsub(/[^\[\]\(\)\{\}]/, '')
    return true if strim.empty?
    return false if strim.size.odd?
    loop do
      s = strim.gsub('()', '').gsub('[]', '').gsub('{}', '')
      return true if s.empty?
      return false if s == strim
      strim = s
    end
  end

  def balanced_quotes?(token)
    token.count('"').even?
  end
end

# Tokenizer class
class Tokenizer
  def initialize
    @tokens = []
    @defined_functions = []
    functions_file = File.readlines('defined_functions.txt')
    functions_file.each { |function| @defined_functions << function }
  end

  def tokenize(token)
    @tokens = []
    split_token token
  end

  def split_token(token)
    token.split(/\s+(?=(?:[^"]*"[^"]*")*[^"]*$)/).each do |t|
       if t.include? '('
         t.to_s.split(/(\()/).each { |p| @tokens << p }
       elsif t.include? ')'
         t.to_s.split(/(\))/).each { |p| @tokens << p }
       else
         @tokens << t
       end
    end
    @tokens.delete('')
  end
end

# Parser is used to validate the user input and parse it to the tokenizer
class Parser
  include ErrorMessages
  include Validator

  def initialize
    @tokenizer = Tokenizer.new
  end

  def run
    loop do
      token = gets.chomp
      parse_token token
    end
  end

  def parse_token(token)
    token_error = validate_token token
    if token_error.nil?
      @tokenizer.tokenize format_token token
    else
      error_printer token_error
    end
  end

  def validate_token(token)
    if !balanced_brackets? token
      unbalanced_brackets_error
    elsif !balanced_quotes? token
      unbalanced_quotes_error
    end
  end

  def format_token(token)
    token.to_s.strip!
    token = remove_whitespace token
    token.tr('{', '(').tr('}', ')')
    token.tr('[', '(').tr(']', ')')
  end

  def remove_whitespace(token)
    token = replace_whitespace_unless_in_quotes token
    token = token.squeeze('@').tr('@', ' ')
    token
  end

  def replace_whitespace_unless_in_quotes(token)
    can_replace = true
    token.each_char.with_index do |c, i|
      if c == '"'
        can_replace = can_replace ? false : true
      end
      token[i] = '@' if c == ' ' && can_replace
    end
    token.to_s
  end

  def error_printer(error)
    puts error
  end
end
