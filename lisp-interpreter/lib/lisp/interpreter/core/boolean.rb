# Scheme booleans helper
module SchemeBooleansHelper
  def if_idx_helper(other)
    if other[0] == '('
      idx = find_bracket_idx other, 0
      (find_next_value other[idx + 1..-1])[0]
    else
      _, other = find_next_value other
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
end

# Scheme booleans module
module SchemeBooleans
  include SchemeBooleansHelper
  def equal?(other)
    raise arg_err_build 2, other.size if other.size != 2
    other[0].to_s == other[1].to_s ? '#t' : '#f'
  end

  def not(other)
    raise arg_err_build 1, other.size if other.size != 1
    valid = check_for_bool other[0]
    raise data_type_err '<boolean>', other[0].type unless valid
    other[0] == '#t' ? '#f' : '#t'
  end

  def if(other)
    raise arg_err_build 3, 0 if other.empty?
    expr, other = find_next_value other
    raise 3, 1 if other.empty?
    if_helper expr, other
  end
end
