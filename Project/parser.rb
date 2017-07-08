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
      parse_token token
    end
  end

  def parse_token(token)
    token_error = validate_token token
    if token_error.nil?
      @tokenizer.tokenize token
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

  def error_printer(error)
    puts error
  end
end
