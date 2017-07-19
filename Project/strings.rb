# Helper functions for SchemeStrings
module SchemeStringsHelper
  def substring_builder(str, from, to)
    '"' + (str[1..-2])[from..(to.nil? ? -1 : to - 1)] + '"'
  end

  def find_delimeter(other)
    return ' ' if other.nil?
    other[1..-2]
  end

  def build_as_string_helper(tokens, idx)
    value = tokens[0..idx].join(' ').gsub('( ', '(').gsub(' )', ')')
    [value, tokens[idx + 1..-1]]
  end

  def build_next_value_as_string(tokens)
    idx = find_idx_for_list tokens
    if tokens[0] == '('
      build_as_string_helper tokens, idx
    elsif tokens[0..1].join == '\'('
      [(get_raw_value tokens[0..idx]), tokens[idx + 1..-1]]
    else
      [tokens[0], tokens[1..-1]]
    end
  end

  def build_character(char)
    '#\\' + (char == ' ' ? 'space' : char)
  end

  def remove_carriage(str)
    str = str[1..-2]
    str.gsub('\n', '').gsub('\r', '').gsub('\t', '').strip.squeeze(' ')
  end

  def string_getter(tokens, get_tokens)
    str, tokens = find_next_value tokens, false
    raise 'String needed' unless check_for_string str
    [str, get_tokens ? tokens : _]
  end
  
  def arg_function_validator(other, vars = 1)
    raise 'Incorrect number of arguments' if other.size != vars
    result = other[0..vars - 1].all? { |v| check_for_string v } 
    raise 'String needed' unless result
    result
  end
end

# Scheme numbers module
module SchemeStrings
  include SchemeStringsHelper
  
  #TODO Handle incorrect argument type
  def substring(other)
    raise 'Incorrect number of arguments' unless other.size.between? 2, 3
    str, from, to = other
    raise 'Integer needed' unless to.nil? || (check_for_number to.to_s)
    substring_builder str, from.to_num, to.to_num
  end

  def string?(other)
    result = arg_function_validator other
    result ? '#t' : '#f'
  end

  def strlen(other)
    arg_function_validator other
    other[0][1..-2].length
  end

  def strupcase(other)
    arg_function_validator other
    other[0].upcase
  end

  def strdowncase(other)
    one_arg_function_validator other
    other[0].downcase
  end

  def strcontains(other)
    arg_function_validator other, 2
    result = other[0][1..-2].include? other[1][1..-2]
    result ? '#t' : '#f'
  end

  def strsplit(other)
    one_arg_function_validator other
    str = remove_carriage other[0]
    build_list str.split(' ').map { |s| '"' + s + '"' }
  end

  def strlist(other)
    one_arg_function_validator other
    build_list other[0][1..-2].chars.map { |c| build_character c }
  end

  def strreplace(other)
    arg_function_validator other, 3
    str, to_replace, replace_with = other.map { |t| t[1..-2] }
    '"' + (str.gsub to_replace, replace_with) + '"'
  end

  def strprefix(other)
    arg_function_validator other, 2
    str, to_check = other.map { |t| t[1..-2] }
    result = str.start_with? to_check
    result ? '#t' : '#f'
  end

  def strsufix(other)
    arg_function_validator other, 2
    str, to_check = other.map { |t| t[1..-2] }
    result = str.end_with? to_check
    result ? '#t' : '#f'
  end

  def strjoin(other)
    raise 'Incorrect number of arguments' unless other.size.between? 1, 2
    raise 'List needed' unless other[0].to_s.list?
    arg_function_validator [other[1]] if other.size == 2
    values = split_list_as_string other[0].to_s
    delimeter = find_delimeter other[1]
    '"' + (values.join delimeter) + '"'
  end
end
