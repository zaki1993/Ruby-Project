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

  def remove_carriage(str)
    str = str[1..-2]
    str.gsub('\n', '').gsub('\r', '').gsub('\t', '').strip.squeeze(' ')
  end

  def arg_function_validator(other, vars = 1)
    raise arg_err_build other.size, vars if other.size != vars
    res = other[0..vars - 1].reject(&:string?)
    raise type_err '<string>', res[0].type unless res.empty?
    res
  end

  def string_join_helper(other, dilimeter)
    values = split_list_as_string other.to_s
    delim_result = find_delimeter dilimeter
    '"' + (values.join delim_result) + '"'
  end

  def strjoin_validate(other)
    raise arg_err_build '[1, 2]', other.size unless other.size.between? 1, 2
    raise type_err '<list>', other[0].type unless other[0].to_s.list?
  end

  def substring_validator(from, to)
    valid = from.number? && (to.nil? || to.number?)
    type = [from, to].first { |t| t.type if t.type != 'number' }
    raise type_err '<number>', type unless valid
  end
end

# Scheme numbers module
module SchemeStrings
  include SchemeStringsHelper
  def substring(other)
    raise arg_err_build '[2, 3]', other.size unless other.size.between? 2, 3
    str, from, to = other
    arg_function_validator [str]
    substring_validator from, to
    substring_builder str, from.to_num, to.to_num
  end

  def string?(other)
    raise arg_err_build 1, other.size if other.size != 1
    other[0].string? ? TRUE : FALSE
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
    result ? TRUE : FALSE
  end

  def strsplit(other)
    arg_function_validator other
    str = remove_carriage other[0]
    result = str.split(' ').map { |s| '"' + s + '"' }
    build_list result
  end

  def strlist(other)
    arg_function_validator other
    result = other[0][1..-2].chars.map(&:to_char)
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
    result ? TRUE : FALSE
  end

  def strsufix(other)
    arg_function_validator other, 2
    str, to_check = other.map { |t| t[1..-2] }
    result = str.end_with? to_check
    result ? TRUE : FALSE
  end

  def strjoin(other)
    strjoin_validate other
    arg_function_validator [other[1]] if other.size == 2
    string_join_helper other[0], other[1]
  end
end
