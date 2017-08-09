require_relative 'object'
require_relative 'stl_constants'
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
    @functions = SPECIAL_CHARACTER_FUNCTIONS.dup
    PREDEFINED_FUNCTIONS.each { |f| @functions[f] = f }
    RESERVED_KEYWORDS.each { |key, value| @procs[key.to_s] = value }
  end
end
