require 'lisp/interpreter/errors.rb'
require 'lisp/interpreter/validator.rb'
require 'lisp/interpreter/tokenizer.rb'

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
        crr_input = STDIN.gets.chomp
        token << crr_input
        break if crr_input == ''
      end
      parse token
    end
  end

  def split_token(token)
    result = []
    token.split(/\s+(?=(?:[^"]*"[^"]*")*[^"]*$)/).each do |t|
      if !t.string? && (t.include?('(') || t.include?(')'))
        t.to_s.split(/(\(|\))/).each { |p| result << p }
      else
        result << t
      end
    end
    result
  end

  def parse(token)
    token_error = validate_token token
    result =
      if token_error.nil?
        @tokenizer.tokenize split_token token
      else
        token_error
      end
    print_result result unless result.to_s.empty?
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
    result
  end
end
