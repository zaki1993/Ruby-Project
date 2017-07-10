class Object
  def is_number?
    self.to_f.to_s == self.to_s || self.to_i.to_s == self.to_s
  end
end

# Tokenizer class
class Tokenizer
  def initialize
    @tokens = []
  end

  def tokenize(token)
    reset
    split_token token
    calc_input_val @tokens, true
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

  def calc_input_val(tokens, do_print)
    return get_raw_value tokens, do_print unless tokens.is_a? Array and tokens.size > 1
    token_caller = ''
    tokens.each do |token|
      next if ['(', ')'].include? token
      result = !File.readlines('functions.txt').grep(/[#{token}]/).empty?
      token_caller = token if result
      break if result
    end
    send(token_caller.to_s, tokens)
  end

  def get_raw_value(token, do_print)
      token = token.join('') if token.is_a? Array
      result = 
          if check_instance_var token
            get_var token.to_s
          else
            token if valid_var token
          end
      do_print ? (print_result result) : result
  end
  
  def print_result(result)
    puts result
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
        calc_input_val tokens[start_idx + 1], false
      else
        calc_input_val tokens[start_idx + 1..end_idx], false
      end
    set_var tokens[start_idx], value
  end

  def define_function(tokens, start_idx, end_idx)
      puts "function"
  end

  def check_for_bool(token)

  end

  def check_for_string(token)
    return true if token.start_with?('"') && token.end_with?('"')
    return true if (check_instance_var token) && (check_for_string (get_var token))
    false
  end

  def check_for_number(token)
    return true if token.is_number?
    return true if (check_instance_var token) && (check_for_number (get_var token))
    false
  end

  def check_instance_var(var)
    return false unless (var =~ /[[:alpha:]]/) == 0
    instance_variable_defined?("@#{var}")
  end
  
  def valid_var(var)
    (check_for_number var) || (check_for_string var) || (check_for_bool var)
  end

  def set_var(var, value)
    instance_variable_set("@#{var}", value)
  end

  def get_var(var)
    instance_variable_get("@#{var}")
  end
end
