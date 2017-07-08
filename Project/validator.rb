# Validator module is used to validate if the user input is correct
module Validator
  def balanced_brackets?(token)
    strim = token.gsub(/[^\[\]\(\)\{\}]/, '')
    return true if strim.empty?
    return false if strim.size.odd?
    loop do
      s = strim.gsub('()', '').gsub('[]', '').gsub('{}', '')
      return true if s.empty?
      return false if s == strim
      strim = s
    end
  end

  def balanced_quotes?(token)
    token.count('"').even?
  end
end
