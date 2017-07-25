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

  def valid_var_name(var)
    !var.match(/^[[:alpha:]]+$/).nil?
  end

  def valid_var(var)
    (valid_literals var) || (valid_objects var)
  end

  def valid_function(name)
    res = predefined_method_caller [name]
    raise 'No such procedure' if res.nil?
    true
  end

  private

  def valid_literals(var)
    number = check_for_number var
    string = check_for_string var
    boolean = check_for_bool var
    symbol = check_for_symbol var
    quote = check_for_quote var
    number || string || boolean || symbol || quote
  end

  def valid_objects(var)
    var.list? || var.pair?
  end
end
