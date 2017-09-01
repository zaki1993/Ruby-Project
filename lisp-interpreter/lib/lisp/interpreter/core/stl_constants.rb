# STL constants
module SchemeStl
  DO_NOT_CALCULATE_FUNCTIONS =
    %w[
      foldl foldr map filter
      if apply numerator denominator
      lambda compose define
    ].freeze

  SPECIAL_CHARACTER_FUNCTIONS =
    {
      'string-downcase'  => 'strdowncase', 'string-upcase'  => 'strupcase',
      'string-contains?' => 'strcontains', 'string-length'  => 'strlen',
      'string->list'     => 'strlist',     'string-split'   => 'strsplit',
      'string-sufix?'    => 'strsufix',    'string-prefix?' => 'strprefix',
      'string-replace'   => 'strreplace',  'string-join'    => 'strjoin'
    }.freeze

  PREDEFINED_FUNCTIONS =
    %w[
      define not equal? if quotient remainder modulo numerator denominator
      min max sub1 add1 abs string? substring null? cons null list car
      cdr list? pair? length reverse remove shuffle map foldl foldr filter
      member lambda apply compose
    ].freeze

  RESERVED_KEYWORDS =
    {
      'null' => '\'()'
    }.freeze
end

class Object
  TRUE = '#t'.freeze
  FALSE = '#f'.freeze
end
