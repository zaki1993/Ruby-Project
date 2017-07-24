# Scheme booleans module
module SchemeBooleans
  def equal?(other)
    raise 'Incorect number of arguments' if other.size != 2
    other[0].to_s == other[1].to_s ? '#t' : '#f'
  end

  def not(other)
    raise 'Incorect number of arguments' if other.size != 1
    raise 'Boolean needed' unless check_for_bool other[0]
    other[0] == '#t' ? '#f' : '#t'
  end
  
  def if(other)
    raise 'Incorrect number of arguments' unless other.size == 3
    raise 'Invalid parameter type' unless check_for_bool other[0]
    other[0] == '#t' ? other[1] : other[2]
  end
end
