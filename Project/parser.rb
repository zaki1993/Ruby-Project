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
      token = ''
      until (validate_token token).nil? && token != ''
        crr_input = gets.chomp
        token << crr_input
        break if crr_input == ''
      end
      result = parse token
      print_result result unless token.empty?
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
    to_remove = result.to_s.list? || result.to_s.pair? || result.to_s.quote?
    result = result.delete('\'') if to_remove
    puts result
    result
  end
end
