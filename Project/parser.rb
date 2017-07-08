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
