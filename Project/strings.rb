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
    valid ? result : (raise 'String needed')
  end

  def build_next_value_as_string(tokens)
    if tokens[0] == '('
      idx = find_matching_bracket_idx tokens, 0
      result = tokens[0..idx].join(' ').gsub('( ', '(').gsub(' )', ')')
      [result, tokens[idx + 1..-1]]
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
  def substring(tokens)
    str, tokens = string_getter tokens, true
    from, tokens = find_next_value tokens, true
    to, tokens = find_next_value tokens, true unless tokens.empty?
    raise 'Too much arguments' unless tokens.empty?
    substring_builder str, from, to
  end

  def string?(tokens)
    str, tokens = find_next_value tokens, false
    raise 'Too much arguments' unless tokens.empty?
    result = check_for_string str
    result ? '#t' : '#f'
  end

  def strlen(tokens)
    str, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    str[1..-2].length
  end

  def strupcase(tokens)
    str, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    str.upcase
  end

  def strdowncase(tokens)
    str, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    str.downcase
  end

  def strcontains(tokens)
    string, tokens = string_getter tokens, true
    to_check, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    result = string.include? to_check[1..-2]
    result ? '#t' : '#f'
  end

  def strsplit(tokens)
    str, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    str = remove_carriage str
    '\'(' + str.split(' ').map { |s| '"' + s + '"' }.join(' ') + ')'
  end

  def strlist(tokens)
    str, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    '\'(' + str[1..-2].chars.map { |c| build_character c }.join(' ') + ')'
  end

  def strreplace(tokens)
    string, tokens = string_getter tokens, true
    to_replace, tokens = string_getter tokens, true
    replace_with, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    string.gsub(to_replace[1..-2], replace_with[1..-2])
  end

  def strprefix(tokens)
    string, tokens = string_getter tokens, true
    to_check, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    result = string[1..-1].start_with? to_check[1..-2]
    result ? '#t' : '#f'
  end

  def strsufix(tokens)
    string, tokens = string_getter tokens, true
    to_check, tokens = string_getter tokens, true
    raise 'Too much arguments' unless tokens.empty?
    result = string[1..-1].end_with? to_check[1..-2]
    result ? '#t' : '#f'
  end

  def strjoin(tokens)
    idx = find_idx_for_list tokens
    raise 'List expected' unless tokens[0..idx].list?
    values = find_to_evaluate_or_not tokens[0..idx]
    delimeter = find_delimeter tokens[idx + 1..-1]
    values.join delimeter[1..-2]
  end
end
