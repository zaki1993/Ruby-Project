load 'parser.rb'

RSpec.describe 'LispInterpreter' do
  before do
    @p = Parser.new
    @p.parse('(define x 5)')
    @p.parse('(define y 0.999)')
    @msg =
      {
        'inc_number' => 'Incorrect number of arguments',
        'zero_div' => 'divided by 0',
        'inv_type' => 'Invalid data type'
      }
    def car_cdr_err(got, fn)
      'Cannot apply ' + fn + ' on ' + got
    end
    @p.parse('(define xl (lambda (x) (* 2 x)))')
    @p.parse('(define yl (lambda () 5))')
    @p.parse('(define zl (lambda ()))')
  end

  describe 'exceptions' do
    context 'wrong number of arguments' do
      it 'throws error when less arguments are provided' do
        expect(@p.parse('(cons 1)')).to eq @msg['inc_number']
        expect(@p.parse('(xl)')).to eq @msg['inc_number']
      end

      it 'throws error when more arguments are provided' do
        expect(@p.parse('(cons 6 6 6)')).to eq @msg['inc_number']
        expect(@p.parse('(xl 6 6)')).to eq @msg['inc_number']
        expect(@p.parse('(equal? 1 3 3)')).to eq @msg['inc_number']
      end

      it 'throws error when no arguments are expected' do
        expect(@p.parse('(yl 5)')).to eq @msg['inc_number']
        expect(@p.parse('(zl 5)')).to eq @msg['inc_number']
      end
    end

    context 'incorrect argument type' do
      it 'throws error when <number> is expected' do
        expect(@p.parse('(+ #t)')).to eq @msg['inv_type']
      end

      it 'throws error when <string> is expected' do
        expect(@p.parse('(string-length 1)')).to eq @msg['inv_type']
      end

      it 'throws error when <boolean> is expected' do
        expect(@p.parse('(not \'apple)')).to eq @msg['inv_type']
      end

      it 'throws error when <list> is expected' do
        expect(@p.parse('(length "not list")')).to eq @msg['inv_type']
      end
    end
  end

  describe 'Literals' do
    it 'throws invalid variable error when the data is invalid' do
      expect(@p.parse('#\invalid')).to eq @msg['inv_type']
    end

    it 'can parse integers' do
      expect(@p.parse('1')).to eq '1'
    end

    it 'can parse floats' do
      expect(@p.parse('1.5')).to eq '1.5'
    end

    it 'can parse strings' do
      expect(@p.parse('"Sample"')).to eq '"Sample"'
    end

    it 'can parse booleans' do
      expect(@p.parse('#t')).to eq '#t'
      expect(@p.parse('#f')).to eq '#f'
    end

    it 'can parse characters' do
      expect(@p.parse('#\t')).to eq '#\t'
      expect(@p.parse('#\space')).to eq '#\space'
    end

    it 'can parse quotes' do
      expect(@p.parse('\'(1 2)')).to eq '\'(1 2)'
      expect(@p.parse('\'QUOTE')).to eq '\'QUOTE'
    end
  end

  describe '+' do
    it 'sums with no arguments' do
      expect(@p.parse('(+)')).to eq 0
    end

    it 'sums with single argument' do
      expect(@p.parse('(+ 1)')).to eq 1
      expect(@p.parse('(+ 5.0)')).to eq 5.0
    end

    it 'sums with multiple arguments' do
      expect(@p.parse('(+ 1 2)')).to eq 3
      expect(@p.parse('(+ 1 2.0 3)')).to eq 6.0
      expect(@p.parse('(+ 1 0 3 4.4)')).to eq 8.4
      expect(@p.parse('(+ 1 2 3 4 5)')).to eq 15
    end

    it 'sums with functions as argument' do
      expect(@p.parse('(+ 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 15
      expect(@p.parse('(+ 1.2 (*) (- 0) (+))')).to eq 2.2
      expect(@p.parse('(+ (length (list 1 2)))')).to eq 2
    end
  end

  describe '-' do
    it 'subtracts with no arguments' do
      expect(@p.parse('(-)')).to eq 0
    end

    it 'subtracts with single argument' do
      expect(@p.parse('(- 1)')).to be '-1'.to_i
      expect(@p.parse('(- 5.0)')).to eq '-5'.to_f
    end

    it 'subtracts with multiple arguments' do
      expect(@p.parse('(- 1 2)')).to eq '-1'.to_i
      expect(@p.parse('(- 1 2 0.0)')).to eq '-1'.to_f
      expect(@p.parse('(- 1 2 3 4 5)')).to eq '-13'.to_i
      expect(@p.parse('(- -1 2 3 4 5)')).to eq '-15'.to_i
    end

    it 'subtracts with functions as argument' do
      expect(@p.parse('(- 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq '-13'.to_i
      expect(@p.parse('(- 1.2 (*) (+))')).to eq 0.19999999999999996
      expect(@p.parse('(- (length (list 1 2)))')).to eq '-2'.to_i
    end
  end

  describe '*' do
    it 'multiplies with no arguments' do
      expect(@p.parse('(*)')).to eq 1
    end

    it 'multiplies with single argument' do
      expect(@p.parse('(* 1)')).to eq 1
      expect(@p.parse('(* 0.0)')).to eq 0.0
    end

    it 'multiplies with multiple arguments' do
      expect(@p.parse('(* 8.0 9)')).to eq 72.0
      expect(@p.parse('(* 1 2 0.0)')).to eq 0.0
      expect(@p.parse('(* 1 2 3 4)')).to eq 24
      expect(@p.parse('(* 1 2 3 4.0 5)')).to eq 120.0
    end

    it 'multiplies with functions as argument' do
      expect(@p.parse('(* 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 120
      expect(@p.parse('(* 1.2 (*) (+))')).to eq 0.0
      expect(@p.parse('(* (length (list 1 2)))')).to eq 2
    end
  end

  describe '/' do
    it 'throws ZeroDivisionError' do
      expect(@p.parse('(/ 0)')).to eq @msg['zero_div']
      expect(@p.parse('(/ 0.0)')).to eq @msg['zero_div']
    end

    it 'divides with single argument' do
      expect(@p.parse('(/ 1)')).to eq 1
      expect(@p.parse('(/ 10.0)')).to eq 0.1
    end

    it 'divides with multiple arguments' do
      expect(@p.parse('(/ 81 3.0)')).to eq 27.0
      expect(@p.parse('(/ 1 2 3 4 5)')).to eq 0.008333333333333333
    end

    it 'divides with functions as argument' do
      expect(@p.parse('(/ 1 (+ 2) (+ 2 1))')).to eq 0.16666666666666666
      expect(@p.parse('(/ (* 0.33 6) (/ 22 7))')).to eq 0.63
      expect(@p.parse('(/ (length (list 1 2)))')).to eq 0.5
    end
  end

  describe 'not' do
    it 'can negate with literals' do
      expect(@p.parse('(not #t)')).to eq '#f'
      expect(@p.parse('(not #f)')).to eq '#t'
    end

    it 'can negate with functions' do
      expect(@p.parse('(not (not #t))')).to eq '#t'
      expect(@p.parse('(not (not #f))')).to eq '#f'
    end
  end

  describe 'equal?' do
    it 'can compare with literals' do
      expect(@p.parse('(equal? 1 1.0)')).to eq '#f'
      expect(@p.parse('(equal? 1 1)')).to eq '#t'
      expect(@p.parse('(equal? "Sample" "Sample")')).to eq '#t'
      expect(@p.parse('(equal? #t #f)')).to eq '#f'
      expect(@p.parse('(equal? \'yes \'yes)')).to eq '#t'
      expect(@p.parse('(equal? #\a #\b)')).to eq '#f'
    end

    it 'can compare with functions' do
      expect(@p.parse('(equal? (cons 1 2) (cons 1 2))')).to eq '#t'
      expect(@p.parse('(equal? (cons 1 2) \'(1 . 2))')).to eq '#t'
      expect(@p.parse('(equal? (not #t) (not #f))')).to eq '#f'
    end
  end

  describe 'quotient' do
    it 'throws ZeroDivisionError if second argument is 0' do
      expect(@p.parse('(quotient 1 0)')).to eq @msg['zero_div']
    end

    it 'can calculate quotient with integers' do
      expect(@p.parse('(quotient 10 3)')).to eq 3
      expect(@p.parse('(quotient -10 3)')).to eq '-3'.to_i
      expect(@p.parse('(quotient 10 -3)')).to eq '-3'.to_i
      expect(@p.parse('(quotient -10 -3)')).to eq 3
    end

    it 'can calculate quotient with floats' do
      expect(@p.parse('(quotient 10 3.0)')).to eq 3.0
      expect(@p.parse('(quotient -10.0 3)')).to eq '-3'.to_f
      expect(@p.parse('(quotient -10 3.0)')).to eq '-3'.to_f
      expect(@p.parse('(quotient -10.0 -3.0)')).to eq 3.0
    end
  end

  describe 'remainder' do
    it 'throws ZeroDivisionError if second argument is 0' do
      expect(@p.parse('(remainder 1 0)')).to eq @msg['zero_div']
      expect(@p.parse('(remainder 1 0.0)')).to eq @msg['zero_div']
    end

    it 'can calculate remainder with integers' do
      expect(@p.parse('(remainder 10 3)')).to eq 1
      expect(@p.parse('(remainder -10 3)')).to eq '-1'.to_i
      expect(@p.parse('(remainder 10 -3)')).to eq 1
      expect(@p.parse('(remainder -10 -3)')).to eq '-1'.to_i
    end

    it 'can calculate remainder with floats' do
      expect(@p.parse('(remainder 10 3.0)')).to eq 1.0
      expect(@p.parse('(remainder -10.0 3)')).to eq '-1'.to_f
      expect(@p.parse('(remainder 10 -3.0)')).to eq 1.0
      expect(@p.parse('(remainder -10.0 -3.0)')).to eq '-1'.to_f
    end
  end

  describe 'modulo' do
    it 'throws ZeroDivisionError if second argument is 0' do
      expect(@p.parse('(modulo 1 0)')).to eq @msg['zero_div']
      expect(@p.parse('(modulo 1 0.0)')).to eq @msg['zero_div']
    end

    it 'can calculate modulo with integers' do
      expect(@p.parse('(modulo 10 3)')).to eq 1
      expect(@p.parse('(modulo -10 3)')).to eq 2
      expect(@p.parse('(modulo 10 -3)')).to eq '-2'.to_i
      expect(@p.parse('(modulo -10 -3)')).to eq '-1'.to_i
    end

    it 'can calculate modulo with floats' do
      expect(@p.parse('(modulo 10 3.0)')).to eq 1.0
      expect(@p.parse('(modulo -10.0 3)')).to eq 2.0
      expect(@p.parse('(modulo 10 -3.0)')).to eq '-2'.to_f
      expect(@p.parse('(modulo -10.0 -3.0)')).to eq '-1'.to_f
    end
  end

  describe 'numerator' do
    it 'calculates with integer' do
      expect(@p.parse('(numerator 5)')).to eq 5
      expect(@p.parse('(numerator 1)')).to eq 1
      expect(@p.parse('(numerator 0)')).to eq 0
    end

    it 'calculates with float' do
      expect(@p.parse('(numerator 5.3)')).to eq 5.3
      expect(@p.parse('(numerator 1.5)')).to eq 1.5
      expect(@p.parse('(numerator 0.7)')).to eq 0.7
    end

    it 'calculates with rational number' do
      expect(@p.parse('(numerator 5/6)')).to eq 5
      expect(@p.parse('(numerator 1/1)')).to eq 1
      expect(@p.parse('(numerator 1/0)')).to eq 1
    end
  end

  describe 'denominator' do
    it 'calculates with integer' do
      expect(@p.parse('(denominator 5)')).to eq 1
      expect(@p.parse('(denominator 1)')).to eq 1
      expect(@p.parse('(denominator 0)')).to eq 1
    end

    it 'calculates with float' do
      expect(@p.parse('(denominator 5.3)')).to eq 1
      expect(@p.parse('(denominator 1.5)')).to eq 1
      expect(@p.parse('(denominator 0.7)')).to eq 1
    end

    it 'calculates with rational number' do
      expect(@p.parse('(denominator 5/6)')).to eq 6
      expect(@p.parse('(denominator 1/1.5)')).to eq 1.5
      expect(@p.parse('(denominator 1/0)')).to eq 0
    end
  end

  describe 'abs' do
    it 'can find the absolute value of integer' do
      expect(@p.parse('(abs 1)')).to eq 1
      expect(@p.parse('(abs -10)')).to eq 10
      expect(@p.parse('(abs 0)')).to eq 0
    end

    it 'can find the absolute value of float' do
      expect(@p.parse('(abs 1.0)')).to eq 1.0
      expect(@p.parse('(abs -10.7)')).to eq 10.7
      expect(@p.parse('(abs 0.0)')).to eq 0.0
    end
  end

  describe 'add1' do
    it 'can add 1 to integers' do
      expect(@p.parse('(add1 1)')).to eq 2
      expect(@p.parse('(add1 -1)')).to eq 0
      expect(@p.parse('(add1 -2)')).to eq '-1'.to_i
    end

    it 'can add 1 to floats' do
      expect(@p.parse('(add1 1.0)')).to eq 2.0
      expect(@p.parse('(add1 -1.0)')).to eq 0.0
      expect(@p.parse('(add1 -2.5)')).to eq '-1.5'.to_f
    end
  end

  describe 'sub1' do
    it 'can subtract 1 with integers' do
      expect(@p.parse('(sub1 1)')).to eq 0
      expect(@p.parse('(sub1 -1)')).to eq '-2'.to_i
      expect(@p.parse('(sub1 -2)')).to eq '-3'.to_i
    end

    it 'can subtract 1 with floats' do
      expect(@p.parse('(sub1 1.0)')).to eq 0.0
      expect(@p.parse('(sub1 -1.0)')).to eq '-2'.to_f
      expect(@p.parse('(sub1 -2.5)')).to eq '-3.5'.to_f
    end
  end

  describe 'min' do
    it 'can find the minumum value of single argument' do
      expect(@p.parse('(min -5)')).to eq '-5'.to_i
      expect(@p.parse('(min 1.5)')).to eq 1.5
      expect(@p.parse('(min 1)')).to eq 1
    end

    it 'can find the minumum value of multiple arguments' do
      expect(@p.parse('(min 0 0)')).to eq 0
      expect(@p.parse('(min 4 2.1 9.5)')).to eq 2.1
      expect(@p.parse('(min 5 3 1 2 4)')).to eq 1
      expect(@p.parse('(min 1.99 1.98002 1.98001 2)')).to eq 1.98001
    end
  end

  describe 'max' do
    it 'can find the maximum value of single argument' do
      expect(@p.parse('(max -5)')).to eq '-5'.to_i
      expect(@p.parse('(max 1.5)')).to eq 1.5
      expect(@p.parse('(max 1)')).to eq 1
    end

    it 'can find the maximum value of multiple arguments' do
      expect(@p.parse('(max 0 0)')).to eq 0
      expect(@p.parse('(max 4 2.1 9.5)')).to eq 9.5
      expect(@p.parse('(max 5 3 1 2 4)')).to eq 5
      expect(@p.parse('(max 1.9999999 2.000001 2)')).to eq 2.000001
    end
  end

  describe '#<' do
    it 'returns true when called with <smaller> and <bigger> arguments' do
      expect(@p.parse('(< 1 2)')).to eq '#t'
      expect(@p.parse('(< 1.7 2.8 3)')).to eq '#t'
    end

    it 'returns false when called with <bigger> and <smaller> arguments' do
      expect(@p.parse('(< 3 2)')).to eq '#f'
      expect(@p.parse('(< 3.1 2.5 1.2)')).to eq '#f'
    end

    it 'returns false when called with equal arguments' do
      expect(@p.parse('(< 2 2.0)')).to eq '#f'
      expect(@p.parse('(< 2 2 2 2 2)')).to eq '#f'
    end
  end

  describe '#>' do
    it 'returns true when called with <smaller> and <bigger> arguments' do
      expect(@p.parse('(> 3 2)')).to eq '#t'
      expect(@p.parse('(> 3.2 2.99 1.1)')).to eq '#t'
    end

    it 'returns false when called with <bigger> and <smaller> arguments' do
      expect(@p.parse('(> 1 2)')).to eq '#f'
      expect(@p.parse('(> 1.5 2.1 3.7)')).to eq '#f'
    end

    it 'returns false when called with equal arguments' do
      expect(@p.parse('(> 2 2.0)')).to eq '#f'
      expect(@p.parse('(> 2 2 2 2 2)')).to eq '#f'
    end
  end

  describe '#<=' do
    it 'returns true when called with <smaller> and <bigger> arguments' do
      expect(@p.parse('(<= 1 2)')).to eq '#t'
      expect(@p.parse('(<= 1.5 2.1 3.6)')).to eq '#t'
    end

    it 'returns false when called with <bigger> and <smaller> arguments' do
      expect(@p.parse('(<= 3.1 2.1)')).to eq '#f'
      expect(@p.parse('(<= 3.2 2.2 1.2)')).to eq '#f'
    end

    it 'returns true when called with equal arguments' do
      expect(@p.parse('(<= 2 2.0)')).to eq '#t'
      expect(@p.parse('(<= 2 2 2 2 2)')).to eq '#t'
    end
  end

  describe '#>=' do
    it 'returns true when called with <smaller> and <bigger> arguments' do
      expect(@p.parse('(>= 3 2)')).to eq '#t'
      expect(@p.parse('(>= 3.5 2.5 1.5)')).to eq '#t'
    end

    it 'returns false when called with <bigger> and <smaller> arguments' do
      expect(@p.parse('(>= 1 2)')).to eq '#f'
      expect(@p.parse('(>= 1.5 2.5 3.5)')).to eq '#f'
    end

    it 'returns true when called with equal arguments' do
      expect(@p.parse('(>= 2 2.0)')).to eq '#t'
      expect(@p.parse('(>= 2 2 2 2 2)')).to eq '#t'
    end
  end

  describe 'string-length' do
    it 'can find the length of an empty string' do
      expect(@p.parse('(string-length "")')).to eq 0
    end

    it 'can find the length of non empty string' do
      expect(@p.parse('(string-length "Hello world")')).to eq 11
      expect(@p.parse('(string-length "Sample")')).to eq 6
      expect(@p.parse('(string-length "   ")')).to eq 3
    end
  end

  describe 'substring' do
    it 'can find the substring with 2 arguments' do
      expect(@p.parse('(substring "Apple" 1)')).to eq '"pple"'
      expect(@p.parse('(substring "Hello world" 4)')).to eq '"o world"'
      expect(@p.parse('(substring "" 4)')).to eq '""'
      expect(@p.parse('(substring "Sample" 15)')).to eq '""'
      expect(@p.parse('(substring "Sample" 0)')).to eq '"Sample"'
    end

    it 'can find the substring with 3 arguments' do
      expect(@p.parse('(substring "Apple" 1 4)')).to eq '"ppl"'
      expect(@p.parse('(substring "Hello world" 4 7)')).to eq '"o w"'
      expect(@p.parse('(substring "Apple" 4 2)')).to eq '""'
      expect(@p.parse('(substring "Sample" 15 16)')).to eq '""'
      expect(@p.parse('(substring "Sample" 0 0)')).to eq '"Sample"'
    end
  end

  describe 'string-upcase' do
    it 'returns empty string if empty string as argument' do
      expect(@p.parse('(string-upcase "")')).to eq '""'
    end

    it 'can convert to upcase with words with small letters' do
      expect(@p.parse('(string-upcase "Apple")')).to eq '"APPLE"'
      expect(@p.parse('(string-upcase "sample")')).to eq '"SAMPLE"'
    end

    it 'can convert to upcase with words with capital letters' do
      expect(@p.parse('(string-upcase "APPLE")')).to eq '"APPLE"'
      expect(@p.parse('(string-upcase "SaMpLe")')).to eq '"SAMPLE"'
    end
  end

  describe 'string-downcase' do
    it 'returns empty string if empty string as argument' do
      expect(@p.parse('(string-downcase "")')).to eq '""'
    end

    it 'can convert to upcase with words with small letters' do
      expect(@p.parse('(string-downcase "Apple")')).to eq '"apple"'
      expect(@p.parse('(string-downcase "Sample")')).to eq '"sample"'
    end

    it 'can convert to upcase with words with capital letters' do
      expect(@p.parse('(string-downcase "APPLE")')).to eq '"apple"'
      expect(@p.parse('(string-downcase "SaMpLe")')).to eq '"sample"'
    end
  end

  describe 'string-contains?' do
    it 'returns true if the second word is prefix of the first' do
      expect(@p.parse('(string-contains? "Racket" "Rac")')).to eq '#t'
      expect(@p.parse('(string-contains? "racket" "rac")')).to eq '#t'
    end

    it 'returns true if the second word is sufix of the first' do
      expect(@p.parse('(string-contains? "Racket" "ket")')).to eq '#t'
      expect(@p.parse('(string-contains? "racket" "ket")')).to eq '#t'
    end

    it 'returns true if the second word is infix of the first' do
      expect(@p.parse('(string-contains? "Racket" "acke")')).to eq '#t'
      expect(@p.parse('(string-contains? "racket" "acke")')).to eq '#t'
      expect(@p.parse('(string-contains? "Racket" "Racket")')).to eq '#t'
    end

    it 'returns false in other cases' do
      expect(@p.parse('(string-contains? "Racket" "Rackett")')).to eq '#f'
      expect(@p.parse('(string-contains? "racket" "sample")')).to eq '#f'
    end
  end

  describe 'string->list' do
    it 'converts empty string to <null>' do
      expect(@p.parse('(string->list "")')).to eq '\'()'
    end

    it 'converts non empty string to <list>' do
      result = '\'(#\S #\a #\m #\p #\l #\e)'
      expect(@p.parse('(string->list "Sample")')).to eq result
    end
  end

  describe 'string-split' do
    it 'can split empty string' do
      expect(@p.parse('(string-split "")')).to eq '\'()'
    end

    it 'can split string only with spaces' do
      expect(@p.parse('(string-split "  ")')).to eq '\'()'
    end

    it 'can remove carriage when splitting' do
      result = '\'("foo" "bar" "baz")'
      expect(@p.parse('(string-split "  foo bar  baz \r\n\t")')).to eq result
    end

    it 'can split non empty string' do
      expect(@p.parse('(string-split "p e n")')).to eq '\'("p" "e" "n")'
    end
  end

  describe 'string?' do
    it 'returns false if the aregument is not <string>' do
      expect(@p.parse('(string? 1)')).to eq '#f'
      expect(@p.parse('(string? 1.5)')).to eq '#f'
      expect(@p.parse('(string? \'apple)')).to eq '#f'
      expect(@p.parse('(string? \'(1 . 2))')).to eq '#f'
      expect(@p.parse('(string? #\a)')).to eq '#f'
      expect(@p.parse('(string? #t)')).to eq '#f'
    end
  end

  describe 'string-replace' do
    it 'can replace the empty string' do
      expect(@p.parse('(string-replace "pen" "" " ")')).to eq '" p e n "'
    end

    it 'can replace non empty strings' do
      res = '"foo blah baz"'
      expect(@p.parse('(string-replace "foo bar baz" "bar" "blah")')).to eq res
    end
  end

  describe 'string-prefix?' do
    it 'returns true if the second word is prefix of the first' do
      expect(@p.parse('(string-prefix? "Racket" "Rac")')).to eq '#t'
      expect(@p.parse('(string-prefix? "racket" "rac")')).to eq '#t'
    end

    it 'returns true if the first word is equal to the second' do
      expect(@p.parse('(string-prefix? "Racket" "Racket")')).to eq '#t'
    end

    it 'returns false in other cases' do
      expect(@p.parse('(string-prefix? "Racket" "Rackett")')).to eq '#f'
      expect(@p.parse('(string-prefix? "racket" "sample")')).to eq '#f'
      expect(@p.parse('(string-prefix? "racket" "ket")')).to eq '#f'
    end
  end

  describe 'string-sufix?' do
    it 'returns true if the second word is sufix of the first' do
      expect(@p.parse('(string-sufix? "Racket" "cket")')).to eq '#t'
      expect(@p.parse('(string-sufix? "racket" "cket")')).to eq '#t'
    end

    it 'returns true if the first word is equal to the second' do
      expect(@p.parse('(string-sufix? "Racket" "Racket")')).to eq '#t'
    end

    it 'returns false in other cases' do
      expect(@p.parse('(string-sufix? "Racket" "Rackett")')).to eq '#f'
      expect(@p.parse('(string-sufix? "racket" "sample")')).to eq '#f'
      expect(@p.parse('(string-sufix? "racket" "rack")')).to eq '#f'
    end
  end

  describe 'string-join' do
    it 'joins the list when no delimeter is provided' do
      expect(@p.parse('(string-join \'(1 2))')).to eq '"1 2"'
      expect(@p.parse('(string-join \'())')).to eq '""'
      expect(@p.parse('(string-join (list 1 2))')).to eq '"1 2"'
    end

    it 'joins the list when delimeter is provided' do
      expect(@p.parse('(string-join \'(1 2) "potato")')).to eq '"1potato2"'
      expect(@p.parse('(string-join \'() "potato")')).to eq '""'
      expect(@p.parse('(string-join (list 1 2) "potato")')).to eq '"1potato2"'
    end
  end

  describe 'null?' do
    it 'returns true when empty <list> is provided' do
      expect(@p.parse('(null? \'())')).to eq '#t'
      expect(@p.parse('(null? null)')).to eq '#t'
      expect(@p.parse('(null? (list))')).to eq '#t'
    end

    it 'returns false when non empty list is provided' do
      expect(@p.parse('(null? \'(1 2))')).to eq '#f'
      expect(@p.parse('(null? (cons 1 \'()))')).to eq '#f'
      expect(@p.parse('(null? (list 1 2))')).to eq '#f'
    end

    it 'returns false when literals are provided as argument' do
      expect(@p.parse('(null? 1)')).to eq '#f'
      expect(@p.parse('(null? 1.5)')).to eq '#f'
      expect(@p.parse('(null? "string")')).to eq '#f'
      expect(@p.parse('(null? #t)')).to eq '#f'
      expect(@p.parse('(null? \'quote)')).to eq '#f'
    end
  end

  describe 'cons' do
    it 'returns <pair> when the second argument is not <list>' do
      expect(@p.parse('(cons 1 2)')).to eq '(1 . 2)'
      expect(@p.parse('(cons 1 (cons 2 3))')).to eq '(1 2 . 3)'
    end

    it 'returns <list> when the second argument is <list>' do
      expect(@p.parse('(cons 1 \'())')).to eq '(1)'
      expect(@p.parse('(cons 1 null)')).to eq '(1)'
      expect(@p.parse('(cons 1 (list))')).to eq '(1)'
      expect(@p.parse('(cons 1 (cons 2 \'()))')).to eq '(1 2)'
      expect(@p.parse('(cons 1 (list 2 3))')).to eq '(1 2 3)'
    end
  end

  describe '#reserverd_keywords' do
    context '#null' do
      it 'returns empty list' do
        expect(@p.parse('null')).to eq '()'
      end
    end
  end

  describe 'list' do
    it 'returns empty list when no arguments are provided' do
      expect(@p.parse('(list)')).to eq '()'
    end

    it 'returns non empty list when 1 or more arguments are provided' do
      expect(@p.parse('(list 1)')).to eq '(1)'
      expect(@p.parse('(list 1 "s")')).to eq '(1 "s")'
      result = '\'(1 \'(#t . #f) \'quote)'
      expect(@p.parse('(list 1 (cons #t #f) \'quote)')).to eq result
    end
  end

  describe 'car' do
    it 'throws error when <null> provided' do
      expect(@p.parse('(car null)')).to eq car_cdr_err '\'()', 'car'
      expect(@p.parse('(car (list))')).to eq car_cdr_err '\'()', 'car'
      expect(@p.parse('(car \'())')).to eq car_cdr_err '\'()', 'car'
    end

    it 'returns the first element of <pair>' do
      expect(@p.parse('(car (cons 1 2))')).to eq '1'
      expect(@p.parse('(car \'( #t . 2))')).to eq '#t'
    end

    it 'returns the first element of <list>' do
      expect(@p.parse('(car (list #f 2 3 4))')).to eq '#f'
      expect(@p.parse('(car \'(1 2 3 4))')).to eq '1'
    end
  end

  describe 'cdr' do
    it 'throws error when <null> provided' do
      expect(@p.parse('(cdr null)')).to eq car_cdr_err '\'()', 'cdr'
      expect(@p.parse('(cdr (list))')).to eq car_cdr_err '\'()', 'cdr'
      expect(@p.parse('(cdr \'())')).to eq car_cdr_err '\'()', 'cdr'
    end

    it 'returns list of rest of the <pair>' do
      expect(@p.parse('(cdr (cons 1 2))')).to eq '\'(2)'
      expect(@p.parse('(cdr \'( "sample" . #t))')).to eq '(#t)'
      expect(@p.parse('(cdr (cons 1 (cons 2 3)))')).to eq '(2 . 3)'
    end

    it 'returns the first element of <list>' do
      expect(@p.parse('(cdr (list #f 2 3 4))')).to eq '(2 3 4)'
      expect(@p.parse('(cdr \'(1 2 3 4))')).to eq '(2 3 4)'
    end
  end
end
