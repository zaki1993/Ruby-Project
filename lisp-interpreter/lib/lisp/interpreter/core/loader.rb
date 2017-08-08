require_relative 'object'
require_relative 'stl_functions'
require_relative 'errors'
require_relative 'numbers'
require_relative 'strings'
require_relative 'boolean'
require_relative 'list'
require_relative 'functional'

# Module for loading stl functions and keywords
module StlLoader
  include SchemeStl
  def initialize
    @other = []
    @procs = {}
    @do_not_calculate = init_do_not_calculate_fn
    @reserved = init_reserved_fn
    set_reserved_keywords
    @functions = init_functions.dup
    init_predefined.each { |f| @functions[f] = f }
  end

  def init_do_not_calculate_fn
    DO_NOT_CALCULATE_FUNCTIONS
  end

  def init_functions
    SPECIAL_CHARACTER_FUNCTIONS
  end

  def init_predefined
    PREDEFINED_FUNCTIONS
  end

  def init_reserved_fn
    RESERVED_KEYWORDS
  end

  def set_reserved_keywords
    @reserved.each do |key, value|
      @procs[key.to_s] = value
    end
  end
end
