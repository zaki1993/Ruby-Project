require_relative 'stl_constants'

# Scheme booleans helper
module SchemeBooleansHelper
  def if_idx_helper(other)
    if other[0] == '('
      idx = find_bracket_idx other, 0
      other[idx + 1..-1]
    else
      _, other = find_next_value other
      other
    end
  end

  def if_helper(expr, other)
    if expr == FALSE
      if_idx_helper other
    else
      other
    end
  end
end

# Scheme booleans module
module SchemeBooleans
  include SchemeBooleansHelper
  def equal?(other)
    raise arg_err_build 2, other.size if other.size != 2
    other[0].to_s == other[1].to_s ? TRUE : FALSE
  end

  def not(other)
    raise arg_err_build 1, other.size if other.size != 1
    valid = check_for_bool other[0]
    raise type_err '<boolean>', other[0].type unless valid
    other[0] == TRUE ? FALSE : TRUE
  end

  def if(other)
    raise arg_err_build 3, 0 if other.empty?
    expr, other = find_next_value other
    raise arg_err_build 3, other.size + 1 if other.size < 2
    res = if_helper expr, other
    (find_next_value res)[0]
  end
end
