# Check if variable is specific type
module SchemeChecker
  def check_for_bool(token)
    return true if token.boolean?
    is_instance_var = check_instance_var token
    return (check_for_bool get_var token) if is_instance_var
    false
  end

  def check_for_string(token)
    return true if token.string?
    is_instance_var = check_instance_var token
    return (check_for_string get_var token) if is_instance_var
    false
  end

  def check_for_num(token)
    return true if token.to_s.number?
    is_instance_var = check_instance_var token
    return (check_for_num get_var token) if is_instance_var
    false
  end

  def check_for_quote(token)
    return true if token[0].quote?
    is_instance_var = check_instance_var token
    return (check_for_num get_var token) if is_instance_var
    false
  end

  def check_for_symbol(var)
    var = var.join('') if var.is_a? Array
    return true if var.character?
    is_instance_var = check_instance_var var
    return (check_for_character get_var var) if is_instance_var
    false
  end

  def check_instance_var(var)
    return false if var.is_a? Proc
    return false unless valid_var_name var
    @procs.key? var.to_s
  end
end
