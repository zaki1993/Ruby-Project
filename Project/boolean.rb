# Scheme functions for SchemeBooleans
module SchemeBooleansHelper
  def if_proc_helper(other)
    valid_function other[0]
    values = find_all_values other[1..-1]
    send other[0], values
  end

  def if_result_helper(other)
    values = find_all_values other
    raise 'Incorrect number of arguments' unless values.size == 2
    values
  end

  def if_idx_helper(other)
    other[0] == '(' ? (find_bracket_idx other, 0) : 0
  end

  def if_expr_helper(other, idx)
    if idx.zero?
      (find_next_value other)[0]
    else
      if_proc_helper other[1..idx - 1]
    end
  end
end

# Scheme booleans module
module SchemeBooleans
  include SchemeBooleansHelper
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
    idx = if_idx_helper other
    expr = if_expr_helper other, idx
    raise 'Invalid data type' unless check_for_bool expr
    result = if_result_helper other[idx + 1..-1]
    expr == '#t' ? result[0] : result[1]
  end
end
