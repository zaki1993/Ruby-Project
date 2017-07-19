# Helper functions for SchemeStrings
module SchemeStringsHelper
  def substring_builder(str, from, to)
    '"' + (str[1..-2])[from..(to.nil? ? -1 : to - 1)] + '"'
  end

  def find_delimeter(tokens)
    return ' ' if tokens.empty?
    result, tokens = find_next_value tokens, false
    raise 'Too much arguments' unless tokens.empty?
    valid = check_for_string result
    valid ? result[1..-2] : (raise 'String needed')
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
    raise 'Incorrect number of arguments' if other.size != 1
    result = check_for_string other[0]
    result ? '#t' : '#f'
  end

  def strlen(other)
    raise 'Incorrect number of arguments' if other.size != 1
    raise 'String needed' unless check_for_string other[0]
    other[0][1..-2].length
  end

  def strupcase(other)
    raise 'Incorrect number of arguments' if other.size != 1
    raise 'String needed' unless check_for_string other[0]
    other[0].upcase
  end

  def strdowncase(other)
    raise 'Incorrect number of arguments' if other.size != 1
    raise 'String needed' unless check_for_string other[0]
    other[0].downcase
  end

  def strcontains(other)
    raise 'Incorrect number of arguments' if other.size != 2
    valid = valid = other.all? { |t| check_for_string t }
    raise 'String needed' unless valid
    result = other[0][1..-2].include? other[1][1..-2]
    result ? '#t' : '#f'
  end

  def strsplit(other)
    raise 'Incorrect number of arguments' if other.size != 1
    raise 'String needed' unless check_for_string other[0]
    str = remove_carriage other[0]
    build_list str.split(' ').map { |s| '"' + s + '"' }
  end

  def strlist(other)
    raise 'Incorrect number of arguments' if other.size != 1
    raise 'String needed' unless check_for_string other[0]
    build_list other[0][1..-2].chars.map { |c| build_character c }
  end

  def strreplace(other)
    raise 'Incorrect number of arguments' if other.size != 3
    valid = other.all? { |t| check_for_string t }
    raise 'String needed' unless valid
    str, to_replace, replace_with = other.map { |t| t[1..-2] }
    '"' + (str.gsub to_replace, replace_with) + '"'
  end

  def strprefix(other)
    raise 'Incorrect number of arguments' if other.size != 2
    valid = other.all? { |t| check_for_string t }
    raise 'String needed' unless valid
    str, to_check = other.map { |t| t[1..-2] }
    result = str.start_with? to_check
    result ? '#t' : '#f'
  end

  def strsufix(tokens)
    raise 'Incorrect number of arguments' if other.size != 2
    valid = other.all? { |t| check_for_string t }
    raise 'String needed' unless valid
    str, to_check = other.map { |t| t[1..-2] }
    result = str.end_with? to_check
    result ? '#t' : '#f'
  end

#TODO
  def strjoin(tokens)
    puts tokens.to_s
    value, tokens = find_next_value tokens, false
    split_value = split_list_string value
    raise 'List expected' unless check_for_list split_value
    delimeter = find_delimeter tokens
    '"' + (split_value[2..-2].join delimeter) + '"'
  end
end
