require_relative 'errors'
require_relative 'validator'
require_relative 'tokenizer'

# Environment type
module Environment
  TEST = 1
  PROD = 2
end

# Parser is used to validate the user input and parse it to the tokenizer
class Parser
  include ErrorMessages
  include Validator
  include Environment

  def initialize(env_type = Environment::TEST)
    @ENV_TYPE = env_type
    @tokenizer = Tokenizer.new
  end

  def run
    loop do
      print 'zakichan> ' if @ENV_TYPE == Environment::PROD
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
    puts result if @ENV_TYPE == Environment::PROD
    result
  end
end
