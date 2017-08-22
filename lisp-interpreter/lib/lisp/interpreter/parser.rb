require_relative 'tokenizer'
require_relative 'helpers/printer'

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
  include Printer

  def initialize(env_type = Environment::TEST)
    @env_type = env_type
    @tokenizer = Tokenizer.new
  end

  def run
    loop do
      print 'zakichan> ' if @env_type == Environment::PROD
      begin
        token = read_input('')
      rescue Interrupt
        puts 'Exiting..!'
        sleep(1)
      end
      parse token
    end
  end

  def read_input(token)
    until (validate_token token).nil? && token != ''
      crr_input = STDIN.gets.chomp
      token << crr_input
      break if crr_input == ''
    end
    token
  end

  def parse(token)
    return read_file token if (token.start_with? 'ghci') && token.size > 4
    token_error = validate_token token
    result =
      if token_error.nil?
        @tokenizer.tokenize split_token token
      else
        token_error
      end
    finalize_result result unless result.to_s.empty?
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

  def read_file_helper(token)
    pattern = /^ghci .*\.[.ss|.scm]+$/
    result = (token =~ pattern)
    return unless result.nil?
    token = token[5..-1].nil? ? token[4..-1] : token[5..-1]
    'File with name "' + token.to_s + '" is not valid scheme file'
  end

  def read_file_execute_lines(f, expr)
    last_value = ''
    f.each do |line|
      expr << line
      if (validate_token expr).nil? && expr != ''
        last_value = parse expr
        expr = ''
      end
    end
    last_value
  end

  def read_file_executor(file)
    f = File.open(file)
    expr = ''
    read_file_execute_lines f, expr
  end

  def read_file(token)
    res = read_file_helper token
    return finalize_result res if res.is_a? String
    filename = token[5..-1]
    return read_file_executor filename if File.exist? filename
    finalize_result 'File with name "' + filename + '" does not exist!'
  end

  def validate_token(token)
    if !balanced_brackets? token
      unbalanced_brackets_error
    elsif !balanced_quotes? token
      unbalanced_quotes_error
    end
  end
end
