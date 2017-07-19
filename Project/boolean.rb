# Scheme booleans module
module SchemeBooleans
  include SchemeBooleansHelper
  def equal?(other)
    raise 'Incorect number of arguments' if other.size != 2
    other[0].to_s == other[1].to_s ? '#t' : '#f'
  end

  def not(other)
    raise 'Incorect number of arguments' if other.size != 1
    raise 'Boolean needed' unless check_for_bool other[0]
    other[0] == '#t' ? '#f' : '#t'
  end
end
