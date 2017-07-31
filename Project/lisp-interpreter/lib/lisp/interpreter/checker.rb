# Check if variable is specific type
module SchemeChecker
  def check_for_bool(token)
    return true if ['#t', '#f'].include? token
    is_instance_var = check_instance_var token
    return true if is_instance_var && (check_for_bool get_var token)
    false
  end

  def check_for_string(token)
    return true if token.string?
    is_instance_var = check_instance_var token
    return true if is_instance_var && (check_for_string get_var token)
    false
  end

  def check_for_number(token)
    return true if token.to_s.number?
    is_instance_var = check_instance_var token
    return true if is_instance_var && (check_for_number get_var token)
    false
  end

  def check_for_quote(token)
    return true if token[0].quote?
    is_instance_var = check_instance_var token
    return true if is_instance_var && (check_for_number get_var token)
    false
  end

  def check_instance_var(var)
    return false if var.is_a? Proc
    return false unless valid_var_name var
    instance_variable_defined?("@#{var}")
  end

  def check_for_symbol(var)
    var = var.join('') if var.is_a? Array
    return true if var == '#\space'
    return true if var.character?
    is_instance_var = check_instance_var var
    return true if is_instance_var && (check_for_character get_var var)
    false
  end
end
