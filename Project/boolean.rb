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

  def if(other)
    raise 'Incorrect number of arguments' if other.empty?
    expr, other = find_next_value other
    raise 'Incorrect number of arguments' if other.empty?
    return (find_all_values other)[1] if expr == '#f'
    (find_next_value other)[0]
  end
end
