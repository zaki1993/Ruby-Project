load 'parser.rb'

RSpec.describe 'LispInterpreter' do
  before do
    @parser = Parser.new
    @parser.parse('(define x 5)')
    @parser.parse('(define y 0.999)')
    @msg =
      {
        'inc_number' => 'Incorrect number of arguments',
        'zero_div' => 'divided by 0',
        'inv_type' => 'Invalid data type'
      }
  end

  describe 'Literals' do
    it 'throws invalid variable error when the data is invalid' do
      expect(@parser.parse('#\invalid')).to eq @msg['inv_type']
    end

    it 'can parse integers' do
      expect(@parser.parse('1')).to eq '1'
    end

    it 'can parse floats' do
      expect(@parser.parse('1.5')).to eq '1.5'
    end

    it 'can parse strings' do
      expect(@parser.parse('"Sample"')).to eq '"Sample"'
    end

    it 'can parse booleans' do
      expect(@parser.parse('#t')).to eq '#t'
      expect(@parser.parse('#f')).to eq '#f'
    end

    it 'can parse characters' do
      expect(@parser.parse('#\t')).to eq '#\t'
      expect(@parser.parse('#\space')).to eq '#\space'
    end

    it 'can parse quotes' do
      expect(@parser.parse('\'(1 2)')).to eq '\'(1 2)'
      expect(@parser.parse('\'QUOTE')).to eq '\'QUOTE'
    end
  end

  describe '+' do
    it 'throws type error when the data is invalid' do
      expect(@parser.parse('(+ "not number")')).to eq @msg['inv_type']
    end

    it 'sums with no arguments' do
      expect(@parser.parse('(+)')).to eq 0
    end

    it 'sums with single argument' do
      expect(@parser.parse('(+ 1)')).to eq 1
      expect(@parser.parse('(+ 5.0)')).to eq 5.0
    end

    it 'sums with multiple arguments' do
      expect(@parser.parse('(+ 1 2)')).to eq 3
      expect(@parser.parse('(+ 1 2.0 3)')).to eq 6.0
      expect(@parser.parse('(+ 1 0 3 4.4)')).to eq 8.4
      expect(@parser.parse('(+ 1 2 3 4 5)')).to eq 15
    end

    it 'sums with functions as argument' do
      expect(@parser.parse('(+ 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 15
      expect(@parser.parse('(+ 1.2 (*) (- 0) (+))')).to eq 2.2
      expect(@parser.parse('(+ (length (list 1 2)))')).to eq 2
    end
  end

  describe '-' do
    it 'throws type error when the data is invalid' do
      expect(@parser.parse('(- "not number")')).to eq @msg['inv_type']
    end

    it 'subtracts with no arguments' do
      expect(@parser.parse('(-)')).to eq 0
    end

    it 'subtracts with single argument' do
      expect(@parser.parse('(- 1)')).to be '-1'.to_i
      expect(@parser.parse('(- 5.0)')).to eq '-5'.to_f
    end

    it 'subtracts with multiple arguments' do
      expect(@parser.parse('(- 1 2)')).to eq '-1'.to_i
      expect(@parser.parse('(- 1 2 0.0)')).to eq '-1'.to_f
      expect(@parser.parse('(- 1 2 3 4 5)')).to eq '-13'.to_i
      expect(@parser.parse('(- -1 2 3 4 5)')).to eq '-15'.to_i
    end

    it 'subtracts with functions as argument' do
      expect(@parser.parse('(- 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq '-13'.to_i
      expect(@parser.parse('(- 1.2 (*) (+))')).to eq 0.19999999999999996
      expect(@parser.parse('(- (length (list 1 2)))')).to eq '-2'.to_i
    end
  end

  describe '*' do
    it 'throws type error when the data is invalid' do
      expect(@parser.parse('(* "not number")')).to eq @msg['inv_type']
    end

    it 'multiplies with no arguments' do
      expect(@parser.parse('(*)')).to eq 1
    end

    it 'multiplies with single argument' do
      expect(@parser.parse('(* 1)')).to eq 1
      expect(@parser.parse('(* 0.0)')).to eq 0.0
    end

    it 'multiplies with multiple arguments' do
      expect(@parser.parse('(* 8.0 9)')).to eq 72.0
      expect(@parser.parse('(* 1 2 0.0)')).to eq 0.0
      expect(@parser.parse('(* 1 2 3 4)')).to eq 24
      expect(@parser.parse('(* 1 2 3 4.0 5)')).to eq 120.0
    end

    it 'multiplies with functions as argument' do
      expect(@parser.parse('(* 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 120
      expect(@parser.parse('(* 1.2 (*) (+))')).to eq 0.0
      expect(@parser.parse('(* (length (list 1 2)))')).to eq 2
    end
  end

  describe '/' do
    it 'throws type error when the data is invalid' do
      expect(@parser.parse('(/ "not number")')).to eq @msg['inv_type']
    end

    it 'throws ZeroDivisionError' do
      expect(@parser.parse('(/ 0)')).to eq @msg['zero_div']
    end

    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(/)')).to eq @msg['inc_number']
    end

    it 'divides with single argument' do
      expect(@parser.parse('(/ 1)')).to eq 1
      expect(@parser.parse('(/ 10.0)')).to eq 0.1
      expect(@parser.parse('(/ 0.0)')).to eq 'Infinity'
    end

    it 'divides with multiple arguments' do
      expect(@parser.parse('(/ 81 3.0)')).to eq 27.0
      expect(@parser.parse('(/ 1 2 3 4 5)')).to eq 0.008333333333333333
    end

    it 'divides with functions as argument' do
      expect(@parser.parse('(/ 1 (+ 2) (+ 2 1))')).to eq 0.16666666666666666
      expect(@parser.parse('(/ (* 0.33 6) (/ 22 7))')).to eq 0.63
      expect(@parser.parse('(/ (length (list 1 2)))')).to eq 0.5
    end
  end

  describe 'not' do
    it 'throws type error when the data is invalid' do
      expect(@parser.parse('(not 3)')).to eq @msg['inv_type']
    end

    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(quotient 10)')).to eq @msg['inc_number']
      expect(@parser.parse('(quotient)')).to eq @msg['inc_number']
      expect(@parser.parse('(quotient 1 3 3)')).to eq @msg['inc_number']
    end

    it 'can negate with literals' do
      expect(@parser.parse('(not #t)')).to eq '#f'
      expect(@parser.parse('(not #f)')).to eq '#t'
    end

    it 'can negate with functions' do
      expect(@parser.parse('(not (not #t))')).to eq '#t'
      expect(@parser.parse('(not (not #f))')).to eq '#f'
    end
  end

  describe 'equal?' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(quotient 10)')).to eq @msg['inc_number']
      expect(@parser.parse('(quotient)')).to eq @msg['inc_number']
      expect(@parser.parse('(quotient 1 3 3)')).to eq @msg['inc_number']
    end

    it 'can compare with literals' do
      expect(@parser.parse('(equal? 1 1.0)')).to eq '#f'
      expect(@parser.parse('(equal? 1 1)')).to eq '#t'
      expect(@parser.parse('(equal? "Sample" "Sample")')).to eq '#t'
      expect(@parser.parse('(equal? #t #f)')).to eq '#f'
      expect(@parser.parse('(equal? \'yes \'yes)')).to eq '#t'
      expect(@parser.parse('(equal? #\a #\b)')).to eq '#f'
    end

    it 'can compare with functions' do
      expect(@parser.parse('(equal? (cons 1 2) (cons 1 2))')).to eq '#t'
      expect(@parser.parse('(equal? (cons 1 2) \'(1 . 2))')).to eq '#t'
      expect(@parser.parse('(equal? (not #t) (not #f))')).to eq '#f'
    end
  end

  describe 'quotient' do
    it 'throws ZeroDivisionError if second argument is 0' do
      expect(@parser.parse('(quotient 1 0)')).to eq @msg['zero_div']
    end

    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(quotient 10)')).to eq @msg['inc_number']
      expect(@parser.parse('(quotient)')).to eq @msg['inc_number']
      expect(@parser.parse('(quotient 1 3 3)')).to eq @msg['inc_number']
    end

    it 'can calculate quotient with integers' do
      expect(@parser.parse('(quotient 10 3)')).to eq 3
      expect(@parser.parse('(quotient -10 3)')).to eq '-3'.to_i
      expect(@parser.parse('(quotient 10 -3)')).to eq '-3'.to_i
      expect(@parser.parse('(quotient -10 -3)')).to eq 3
    end

    it 'can calculate quotient with floats' do
      expect(@parser.parse('(quotient 10 3.0)')).to eq 3.0
      expect(@parser.parse('(quotient -10.0 3)')).to eq '-3'.to_f
      expect(@parser.parse('(quotient -10 3.0)')).to eq '-3'.to_f
      expect(@parser.parse('(quotient -10.0 -3.0)')).to eq 3.0
    end
  end

  describe 'remainder' do
    it 'throws ZeroDivisionError if second argument is 0' do
      expect(@parser.parse('(remainder 1 0)')).to eq @msg['zero_div']
      expect(@parser.parse('(remainder 1 0.0)')).to eq @msg['zero_div']
    end

    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(remainder 10)')).to eq @msg['inc_number']
      expect(@parser.parse('(remainder)')).to eq @msg['inc_number']
      expect(@parser.parse('(remainder 1 3 3)')).to eq @msg['inc_number']
    end

    it 'can calculate remainder with integers' do
      expect(@parser.parse('(remainder 10 3)')).to eq 1
      expect(@parser.parse('(remainder -10 3)')).to eq '-1'.to_i
      expect(@parser.parse('(remainder 10 -3)')).to eq 1
      expect(@parser.parse('(remainder -10 -3)')).to eq '-1'.to_i
    end

    it 'can calculate remainder with floats' do
      expect(@parser.parse('(remainder 10 3.0)')).to eq 1.0
      expect(@parser.parse('(remainder -10.0 3)')).to eq '-1'.to_f
      expect(@parser.parse('(remainder 10 -3.0)')).to eq 1.0
      expect(@parser.parse('(remainder -10.0 -3.0)')).to eq '-1'.to_f
    end
  end

  describe 'modulo' do
    it 'throws ZeroDivisionError if second argument is 0' do
      expect(@parser.parse('(modulo 1 0)')).to eq @msg['zero_div']
      expect(@parser.parse('(modulo 1 0.0)')).to eq @msg['zero_div']
    end

    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(modulo 10)')).to eq @msg['inc_number']
      expect(@parser.parse('(modulo)')).to eq @msg['inc_number']
      expect(@parser.parse('(modulo 1 3 3)')).to eq @msg['inc_number']
    end

    it 'can calculate modulo with integers' do
      expect(@parser.parse('(modulo 10 3)')).to eq 1
      expect(@parser.parse('(modulo -10 3)')).to eq 2
      expect(@parser.parse('(modulo 10 -3)')).to eq '-2'.to_i
      expect(@parser.parse('(modulo -10 -3)')).to eq '-1'.to_i
    end

    it 'can calculate modulo with floats' do
      expect(@parser.parse('(modulo 10 3.0)')).to eq 1.0
      expect(@parser.parse('(modulo -10.0 3)')).to eq 2.0
      expect(@parser.parse('(modulo 10 -3.0)')).to eq '-2'.to_f
      expect(@parser.parse('(modulo -10.0 -3.0)')).to eq '-1'.to_f
    end
  end

  describe 'numerator' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(numerator)')).to eq @msg['inc_number']
      expect(@parser.parse('(numerator 1 2)')).to eq @msg['inc_number']
    end

    it 'calculates with integer' do
      expect(@parser.parse('(numerator 5)')).to eq 5
      expect(@parser.parse('(numerator 1)')).to eq 1
      expect(@parser.parse('(numerator 0)')).to eq 0
    end

    it 'calculates with float' do
      expect(@parser.parse('(numerator 5.3)')).to eq 5.3
      expect(@parser.parse('(numerator 1.5)')).to eq 1.5
      expect(@parser.parse('(numerator 0.7)')).to eq 0.7
    end

    it 'calculates with rational number' do
      expect(@parser.parse('(numerator 5/6)')).to eq 5
      expect(@parser.parse('(numerator 1/1)')).to eq 1
      expect(@parser.parse('(numerator 1/0)')).to eq 1
    end
  end

  describe 'denominator' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(denominator)')).to eq @msg['inc_number']
      expect(@parser.parse('(denominator 1 2)')).to eq @msg['inc_number']
    end

    it 'calculates with integer' do
      expect(@parser.parse('(denominator 5)')).to eq 1
      expect(@parser.parse('(denominator 1)')).to eq 1
      expect(@parser.parse('(denominator 0)')).to eq 1
    end

    it 'calculates with float' do
      expect(@parser.parse('(denominator 5.3)')).to eq 1
      expect(@parser.parse('(denominator 1.5)')).to eq 1
      expect(@parser.parse('(denominator 0.7)')).to eq 1
    end

    it 'calculates with rational number' do
      expect(@parser.parse('(denominator 5/6)')).to eq 6
      expect(@parser.parse('(denominator 1/1.5)')).to eq 1.5
      expect(@parser.parse('(denominator 1/0)')).to eq 0
    end
  end

  describe 'abs' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(abs)')).to eq @msg['inc_number']
      expect(@parser.parse('(abs 1 2)')).to eq @msg['inc_number']
    end

    it 'can find the absolute value of integer' do
      expect(@parser.parse('(abs 1)')).to eq 1
      expect(@parser.parse('(abs -10)')).to eq 10
      expect(@parser.parse('(abs 0)')).to eq 0
    end

    it 'can find the absolute value of float' do
      expect(@parser.parse('(abs 1.0)')).to eq 1.0
      expect(@parser.parse('(abs -10.7)')).to eq 10.7
      expect(@parser.parse('(abs 0.0)')).to eq 0.0
    end
  end

  describe 'add1' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(add1)')).to eq @msg['inc_number']
      expect(@parser.parse('(add1 1 2)')).to eq @msg['inc_number']
    end

    it 'can add 1 to integers' do
      expect(@parser.parse('(add1 1)')).to eq 2
      expect(@parser.parse('(add1 -1)')).to eq 0
      expect(@parser.parse('(add1 -2)')).to eq '-1'.to_i
    end

    it 'can add 1 to floats' do
      expect(@parser.parse('(add1 1.0)')).to eq 2.0
      expect(@parser.parse('(add1 -1.0)')).to eq 0.0
      expect(@parser.parse('(add1 -2.5)')).to eq '-1.5'.to_f
    end
  end

  describe 'sub1' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(sub1)')).to eq @msg['inc_number']
      expect(@parser.parse('(sub1 1 2)')).to eq @msg['inc_number']
    end

    it 'can subtract 1 with integers' do
      expect(@parser.parse('(sub1 1)')).to eq 0
      expect(@parser.parse('(sub1 -1)')).to eq '-2'.to_i
      expect(@parser.parse('(sub1 -2)')).to eq '-3'.to_i
    end

    it 'can subtract 1 with floats' do
      expect(@parser.parse('(sub1 1.0)')).to eq 0.0
      expect(@parser.parse('(sub1 -1.0)')).to eq '-2'.to_f
      expect(@parser.parse('(sub1 -2.5)')).to eq '-3.5'.to_f
    end
  end

  describe 'min' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(min)')).to eq @msg['inc_number']
    end

    it 'can find the minumum value of single argument' do
      expect(@parser.parse('(min -5)')).to eq '-5'.to_i
      expect(@parser.parse('(min 1.5)')).to eq 1.5
      expect(@parser.parse('(min 1)')).to eq 1
    end

    it 'can find the minumum value of multiple arguments' do
      expect(@parser.parse('(min 0 0)')).to eq 0
      expect(@parser.parse('(min 4 2.1 9.5)')).to eq 2.1
      expect(@parser.parse('(min 5 3 1 2 4)')).to eq 1
      expect(@parser.parse('(min 1.99 1.98002 1.98001 2)')).to eq 1.98001
    end
  end

  describe 'max' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(max)')).to eq @msg['inc_number']
    end

    it 'can find the maximum value of single argument' do
      expect(@parser.parse('(max -5)')).to eq '-5'.to_i
      expect(@parser.parse('(max 1.5)')).to eq 1.5
      expect(@parser.parse('(max 1)')).to eq 1
    end

    it 'can find the maximum value of multiple arguments' do
      expect(@parser.parse('(max 0 0)')).to eq 0
      expect(@parser.parse('(max 4 2.1 9.5)')).to eq 9.5
      expect(@parser.parse('(max 5 3 1 2 4)')).to eq 5
      expect(@parser.parse('(max 1.9999999 2.000001 2)')).to eq 2.000001
    end
  end

  describe '#<' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(<)')).to eq @msg['inc_number']
      expect(@parser.parse('(< 1)')).to eq @msg['inc_number']
    end

    it 'returns true when called with <smaller> and <bigger> arguments' do
      expect(@parser.parse('(< 1 2)')).to eq '#t'
      expect(@parser.parse('(< 1.7 2.8 3)')).to eq '#t'
    end

    it 'returns false when called with <bigger> and <smaller> arguments' do
      expect(@parser.parse('(< 3 2)')).to eq '#f'
      expect(@parser.parse('(< 3.1 2.5 1.2)')).to eq '#f'
    end

    it 'returns false when called with equal arguments' do
      expect(@parser.parse('(< 2 2.0)')).to eq '#f'
      expect(@parser.parse('(< 2 2 2 2 2)')).to eq '#f'
    end
  end

  describe '#>' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(>)')).to eq @msg['inc_number']
      expect(@parser.parse('(> 1)')).to eq @msg['inc_number']
    end

    it 'returns true when called with <smaller> and <bigger> arguments' do
      expect(@parser.parse('(> 3 2)')).to eq '#t'
      expect(@parser.parse('(> 3.2 2.99 1.1)')).to eq '#t'
    end

    it 'returns false when called with <bigger> and <smaller> arguments' do
      expect(@parser.parse('(> 1 2)')).to eq '#f'
      expect(@parser.parse('(> 1.5 2.1 3.7)')).to eq '#f'
    end

    it 'returns false when called with equal arguments' do
      expect(@parser.parse('(> 2 2.0)')).to eq '#f'
      expect(@parser.parse('(> 2 2 2 2 2)')).to eq '#f'
    end
  end

  describe '#<=' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(<=)')).to eq @msg['inc_number']
      expect(@parser.parse('(<= 1)')).to eq @msg['inc_number']
    end

    it 'returns true when called with <smaller> and <bigger> arguments' do
      expect(@parser.parse('(<= 1 2)')).to eq '#t'
      expect(@parser.parse('(<= 1.5 2.1 3.6)')).to eq '#t'
    end

    it 'returns false when called with <bigger> and <smaller> arguments' do
      expect(@parser.parse('(<= 3.1 2.1)')).to eq '#f'
      expect(@parser.parse('(<= 3.2 2.2 1.2)')).to eq '#f'
    end

    it 'returns true when called with equal arguments' do
      expect(@parser.parse('(<= 2 2.0)')).to eq '#t'
      expect(@parser.parse('(<= 2 2 2 2 2)')).to eq '#t'
    end
  end

  describe '#>=' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(>=)')).to eq @msg['inc_number']
      expect(@parser.parse('(>= 1)')).to eq @msg['inc_number']
    end

    it 'returns true when called with <smaller> and <bigger> arguments' do
      expect(@parser.parse('(>= 3 2)')).to eq '#t'
      expect(@parser.parse('(>= 3.5 2.5 1.5)')).to eq '#t'
    end

    it 'returns false when called with <bigger> and <smaller> arguments' do
      expect(@parser.parse('(>= 1 2)')).to eq '#f'
      expect(@parser.parse('(>= 1.5 2.5 3.5)')).to eq '#f'
    end

    it 'returns true when called with equal arguments' do
      expect(@parser.parse('(>= 2 2.0)')).to eq '#t'
      expect(@parser.parse('(>= 2 2 2 2 2)')).to eq '#t'
    end
  end

  describe 'string-length' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(string-length)')).to eq @msg['inc_number']
      expect(@parser.parse('(string-length "a" "b")')).to eq @msg['inc_number']
    end

    it 'can find the length of an empty string' do
      expect(@parser.parse('(string-length "")')).to eq 0
    end

    it 'can find the length of non empty string' do
      expect(@parser.parse('(string-length "Hello world")')).to eq 11
      expect(@parser.parse('(string-length "Sample")')).to eq 6
      expect(@parser.parse('(string-length "   ")')).to eq 3
    end
  end

  describe 'substring' do
    it 'throws argument error when wrong number of arguments are provided' do
      expect(@parser.parse('(substring)')).to eq @msg['inc_number']
      expect(@parser.parse('(substring "a" 1 2 3)')).to eq @msg['inc_number']
    end

    it 'can find the substring with 2 arguments' do
      expect(@parser.parse('(substring "Apple" 1)')).to eq '"pple"'
      expect(@parser.parse('(substring "Hello world" 4)')).to eq '"o world"'
      expect(@parser.parse('(substring "" 4)')).to eq '""'
      expect(@parser.parse('(substring "Sample" 15)')).to eq '""'
      expect(@parser.parse('(substring "Sample" 0)')).to eq '"Sample"'
    end

    it 'can find the substring with 3 arguments' do
      expect(@parser.parse('(substring "Apple" 1 4)')).to eq '"ppl"'
      expect(@parser.parse('(substring "Hello world" 4 7)')).to eq '"o w"'
      expect(@parser.parse('(substring "Apple" 4 2)')).to eq '""'
      expect(@parser.parse('(substring "Sample" 15 16)')).to eq '""'
      expect(@parser.parse('(substring "Sample" 0 0)')).to eq '"Sample"'
    end
  end
end
