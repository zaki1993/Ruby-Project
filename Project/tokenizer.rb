# Tokenizer class
class Tokenizer
  def initialize
    @tokens = []
    @def_functions = []
    File.readlines('defined_functions.txt').each { |f| @def_functions << f }
  end

  def tokenize(token)
    @tokens = []
    split_token token
  end

  def split_token(token)
    token.split(/\s+(?=(?:[^"]*"[^"]*")*[^"]*$)/).each do |t|
      if t.include? '('
        t.to_s.split(/(\()/).each { |p| @tokens << p }
      elsif t.include? ')'
        t.to_s.split(/(\))/).each { |p| @tokens << p }
      else
        @tokens << t
      end
    end
    @tokens.delete('')
  end
end
