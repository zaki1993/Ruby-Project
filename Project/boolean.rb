# Scheme booleans module
module SchemeBooleans
  def equal?(other)
    raise 'Incorrect number of arguments' if other.size != 2
    other[0].to_s == other[1].to_s ? '#t' : '#f'
  end

  def not(other)
    raise 'Incorrect number of arguments' if other.size != 1
    raise 'Invalid data type' unless check_for_bool other[0]
    other[0] == '#t' ? '#f' : '#t'
  end
  
  def if_idx_helper(other)
    if other[0] == '('
      idx = find_bracket_idx other, 0
      (find_next_value other[idx + 1..-1])[0]
    else
      _,other = find_next_value other
      (find_next_value other)[0]
    end
  end
  
  def if_helper(expr, other)
    if expr == '#f'
      if_idx_helper other
    else
      (find_next_value other)[0]
    end
  end

  def if(other)
    raise 'Incorrect number of arguments' if other.empty?
    expr, other = find_next_value other
    raise 'Incorrect number of arguments' if other.empty?
    if_helper expr, other
  end
end
