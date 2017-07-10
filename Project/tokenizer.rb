# Tokenizer class
class Tokenizer
  def initialize
    @tokens = []
  end

  def tokenize(token)
    reset
    split_token token
    calc_input_val @tokens
  end

  def reset
    @tokens = []
  end

  def split_token(token)
    token.split(/\s+(?=(?:[^"]*"[^"]*")*[^"]*$)/).each do |t|
      if t.include?('(') || t.include?(')')
        t.to_s.split(/(\(|\))/).each { |p| @tokens << p }
      else
        @tokens << t
      end
    end
    @tokens.delete('')
  end

  def calc_input_val(tokens)
    return get_raw_value tokens unless tokens.is_a? Array and tokens.size > 1
    token_caller = ''
    tokens.each do |token|
      next if ['(', ')'].include? token
      result = !File.readlines('functions.txt').grep(/#{token}/).empty?
      token_caller = token if result
      break if result
    end
    send(token_caller.to_s, tokens)
  end

  def get_raw_value(token)
      puts token
  end

  def define(tokens)
    open_br = 0
    tokens.each_with_index do |token, idx|
      open_br += 1 if token == '('
      next unless token == 'define'
      fetch_define tokens, idx + 1, tokens.length - open_br - 1
    end
  end

  def fetch_define(tokens, start_idx, end_idx)
    if tokens[start_idx] == '('
      define_function tokens, start_idx, end_idx
    else
      define_var tokens, start_idx, end_idx
    end
  end

  def define_var(tokens, start_idx, end_idx)
    value =
      if start_idx + 1 == end_idx
        calc_input_val tokens[start_idx + 1]
      else
        calc_input_val tokens[start_idx + 1..end_idx]
      end
    set_var tokens[start_idx], value
  end

  def define_function(tokens, start_idx, end_idx)
  end

  def check_for_boolean(token)

  end

  def check_for_string(token)

  end

  def check_for_number(token)

  end

  def check_for_word(token)

  end

  def check_for_instance_var(token)

  end

  def set_var(var, value)
    instance_variable_set("@#{var}", value)
  end

  def get_var(var)
    instance_variable_get("@#{var}")
  end
end
