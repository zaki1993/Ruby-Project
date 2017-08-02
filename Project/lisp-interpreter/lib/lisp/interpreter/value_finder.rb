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

  def find_next_function_value(other)
    idx = (find_bracket_idx other, 0)
    value = calc_input_val other[0..idx]
    other = other[idx + 1..other.size]
    [value, other]
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

  def find_next_value_helper(other)
    value = no_eval_list other[2..(find_bracket_idx other, 1) - 1]
    [(build_list value), other[3 + (size_for_list_elem value)..-1]]
  end


  def find_next_value(other)
    return [other[0], other[1..-1]] if other[0].is_a? Proc
    if other[0] == '('
      find_next_function_value other
    elsif other[0..1].join == '\'('
      find_next_value_helper other
    else
      value = get_var other[0].to_s
      [value, other[1..-1]]
    end
  end
end
