# Helper functions for SchemeBooleans
module SchemeBooleansHelper
  def fetch_not(tokens)
    if tokens[0] == '('
      res = calc_input_val tokens[0..tokens.size - 1]
      not_var res
    else
      tokens.size == 1 ? (not_var tokens[0]) : (raise 'Incorrect parameter')
    end
  end

  def not_var(var)
    raise 'Incorrect boolean' unless check_for_bool var
    (get_var var) == '#t' ? '#f' : '#t'
  end
end

# Scheme booleans module
module SchemeBooleans
  include SchemeBooleansHelper
  def equal?(other)
    first, second, other = (get_k_arguments other, true, 2, false)
    raise 'Too many arguments' unless other.empty?
    first.to_s == second.to_s ? '#t' : '#f'
  end

  def not(tokens)
    fetch_not tokens
  end
end