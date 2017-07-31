# Helper functions for SchemeStrings
module SchemeStringsHelper
  def substring_builder(str, from, to)
    result = (str[1..-2])[from..(to.nil? ? -1 : to - 1)]
    return '""' if result.nil?
    '"' + result + '"'
  end

  def find_delimeter(other)
    return ' ' if other.nil?
    other[1..-2]
  end

  def build_as_string_helper(other, idx)
    value = other[0..idx].join(' ').gsub('( ', '(').gsub(' )', ')')
    [value, other[idx + 1..-1]]
  end

  def build_next_value_as_string(other)
    idx = find_idx_for_list other
    if other[0] == '('
      build_as_string_helper other, idx
    elsif other[0..1].join == '\'('
      [(get_raw_value other[0..idx]), other[idx + 1..-1]]
    else
      [other[0], other[1..-1]]
    end
  end

  def build_character(char)
    '#\\' + (char == ' ' ? 'space' : char)
  end

  def remove_carriage(str)
    str = str[1..-2]
    str.gsub('\n', '').gsub('\r', '').gsub('\t', '').strip.squeeze(' ')
  end

  def string_getter(other, get_other)
    str, other = find_next_value other
    raise 'String needed' unless check_for_string str
    [str, get_other ? other : _]
  end

  def arg_function_validator(other, vars = 1)
    raise 'Incorrect number of arguments' if other.size != vars
    result = other[0..vars - 1].all? { |v| check_for_string v }
    raise 'Invalid data type' unless result
    result
  end

  def string_join_helper(other, dilimeter)
    values = split_list_as_string other.to_s
    delim_result = find_delimeter dilimeter
    '"' + (values.join delim_result) + '"'
  end
end

# Scheme numbers module
module SchemeStrings
  include SchemeStringsHelper
  def substring(other)
    raise 'Incorrect number of arguments' unless other.size.between? 2, 3
    str, from, to = other
    arg_function_validator [str]
    valid = (check_for_number from) && (to.nil? || (check_for_number to))
    raise 'Incorrect parameter type' unless valid
    substring_builder str, from.to_num, to.to_num
  end

  def string?(other)
    raise 'Incorrect number of arguments' if other.size != 1
    result = check_for_string other[0].to_s
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
    arg_function_validator other
    other[0].downcase
  end

  def strcontains(other)
    arg_function_validator other, 2
    result = other[0][1..-2].include? other[1][1..-2]
    result ? '#t' : '#f'
  end

  def strsplit(other)
    arg_function_validator other
    str = remove_carriage other[0]
    result = str.split(' ').map { |s| '"' + s + '"' }
    build_list result
  end

  def strlist(other)
    arg_function_validator other
    result = other[0][1..-2].chars.map { |c| build_character c }
    build_list result
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
    raise 'Invalid data type' unless other[0].to_s.list?
    arg_function_validator [other[1]] if other.size == 2
    string_join_helper other[0], other[1]
  end
end
