# redefine method in Object class
require 'bigdecimal'

# Object class
class Object
  def number?
    match(/^[\+\-]?\d*\.?\d+(?:[Ee][\+\-]?\d+)?$/)
  end

  def to_num
    return to_f if to_s.include? '.'
    to_i
  end

  def character?
    return true if self == '#\space'
    (start_with? '#\\') && (('a'..'z').to_a.include? self[2]) && size == 3
  end

  def string?
    return false unless self.class == String
    (start_with? '"') && (end_with? '"') && (size != 1)
  end

  def list?
    return false if size < 3
    check_for_list
  end

  def pair?
    res = object_split if is_a? String
    res = to_a if is_a? Array
    return true if res[-3] == '.'
    list? && !res[2..-2].empty?
  end

  def quote?
    start_with? '\''
  end

  def boolean?
    self == TRUE || self == FALSE
  end

  def type
    fns = %w[list pair string number character boolean quote]
    fns.each { |t| return '<' + t + '>' if send t + '?' }
  end

  def to_char
    '#\\' + (self == ' ' ? 'space' : self)
  end

  private

  def object_split
    result = to_s.split(/(\(|\)|\.)|\ /)
    result.delete('')
    result
  end

  def check_for_list
    res = to_a if is_a? Array
    res = object_split if is_a? String
    res[0..1].join == '\'(' && res[-1] == ')' && res[-3] != '.'
  end
end
