load 'errors.rb'
load 'validator.rb'
load 'tokenizer.rb'

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
      result = parse token
      print_result result
    end
  end

  def parse(token)
    token_error = validate_token token
    result =
      if token_error.nil?
        @tokenizer.tokenize token
      else
        token_error
      end
    result
  end

  def validate_token(token)
    if !balanced_brackets? token
      unbalanced_brackets_error
    elsif !balanced_quotes? token
      unbalanced_quotes_error
    end
  end

  def print_result(result)
    result = result.gsub('\'(', '(')
    puts result
    result
  end
end
