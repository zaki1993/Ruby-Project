# Value finder module
module ValueFinder
  def find_all_values(other)
    result = []
    until other.empty?
      x, other = find_next_value other
      result << x
    end
    result
  end

  def find_bracket_idx(other, first_bracket)
    open_br = 0
    other[first_bracket..other.size - 1].each_with_index do |token, idx|
      open_br += 1 if token == '('
      open_br -= 1 if token == ')'
      return idx + first_bracket if open_br.zero?
    end
  end

  def size_for_list_elem(values)
    result = []
    values.each do |v|
      if v.include?('(') || v.include?(')')
        v.split(/(\(|\))|\ /).each { |t| result << t unless t == '' }
      else
        result << v
      end
    end
    result.size
  end

  def find_list_value(other)
    value = no_eval_list other[2..(find_bracket_idx other, 1) - 1]
    [(build_list value), other[3 + (size_for_list_elem value)..-1]]
  end

  def find_next_raw_value(other)
    [(get_var other[0].to_s), other[1..-1]]
  end

  def find_value_helper(other)
    if other[0] == '('
      idx = find_idx_for_list other
      [(calc_input_val other[0..idx]), other[idx + 1..-1]]
    elsif other[0..1].join == '\'('
      find_list_value other
    else
      find_next_raw_value other
    end
  end

  def find_next_value(other)
    return [other[0], other[1..-1]] if other[0].is_a? Proc
    match_inf = other[0].to_s.match(/c[ad]{2,}r/)
    return [(generate_infinite_car_cdr other[0]), other[1..-1]] if match_inf
    find_value_helper other
  end

  def set_var(var, value)
    valid = (valid_var value.to_s) || (value.is_a? Proc)
    raise 'Invalid parameter' unless valid || (value.is_a? Symbol)
    return if var == value.to_s
    @procs[var] = value
  end

  def get_var(var)
    check = check_instance_var var
    return @procs[var.to_s] if check
    val = (predefined_method_caller [var])
    return val unless val.nil?
    valid = valid_var var
    var = var.to_num.to_s if check_for_num var
    valid ? var : (raise unbound_symbol_err var)
  end

  def get_raw_value(token)
    if token.pair? || token.list?
      build_list no_eval_list token[2..-2]
    else
      return if token.empty?
      token = token.join('') if token.is_a? Array
      return (generate_infinite_car_cdr token) if token =~ /c[ad]{2,}r/
      get_var token.to_s
    end
  end
end
