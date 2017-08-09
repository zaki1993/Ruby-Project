# redefine method in Object class
class Object
  def number?
    to_f.to_s == to_s || to_i.to_s == to_s
  end

  def to_num
    return to_f if to_f.to_s == to_s
    to_i if to_i.to_s == to_s
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
    ['#t', '#f'].include? self
  end

  def type
    fns = %w[list pair string number character boolean quote]
    fns.each { |t| return '<' + t + '>' if send t + '?' }
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
