require 'spec_helper'

RSpec.describe Lisp::Interpreter do
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

    def build_lst(arr)
      '(' + arr.join(' ') + ')'
    end

    @p.parse('(define xl (lambda (x) (* 2 x)))')
    @p.parse('(define yl (lambda () 5))')
    @p.parse('(define zl (lambda ()))')
  end

  describe 'exceptions' do
    context 'wrong number of arguments' do
      it 'throws error when less arguments are provided' do
        expect(@p.parse('(cons 1)')).to eq @msg['inc_number']
      end

      it 'throws error when more arguments are provided' do
        expect(@p.parse('(xl 6 6)')).to eq @msg['inc_number']
      end

      it 'throws error when no arguments are expected' do
        expect(@p.parse('(yl 5)')).to eq @msg['inc_number']
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

  describe 'literals' do
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
      expect(@p.parse('\'(1 2)')).to eq '(1 2)'
      expect(@p.parse('\'QUOTE')).to eq 'QUOTE'
    end
  end

  describe '(+ z ...)' do
    it 'returns 0 when <z> is not provided' do
      expect(@p.parse('(+)')).to eq 0
    end

    it 'returns <z> when <z> is single argument' do
      expect(@p.parse('(+ 1)')).to eq 1
      expect(@p.parse('(+ 5.0)')).to eq 5.0
    end

    it 'returns the sum of <z>s when <z> are multiple arguments' do
      expect(@p.parse('(+ 1 2)')).to eq 3
      expect(@p.parse('(+ 1 2.0 3)')).to eq 6.0
      expect(@p.parse('(+ 1 0 3 4.4)')).to eq 8.4
      expect(@p.parse('(+ 1 2 3 4 5)')).to eq 15
      expect(@p.parse('(+ 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 15
      expect(@p.parse('(+ 1.2 (*) (- 0) (+))')).to eq 2.2
    end
  end

  describe '(- z w ...+)' do
    it 'returns 0 if no <z> and <w>s are provided' do
      expect(@p.parse('(-)')).to eq 0
    end

    it 'returns <-z> if no <w>s are provided' do
      expect(@p.parse('(- 1)')).to be '-1'.to_i
      expect(@p.parse('(- 5.0)')).to eq '-5'.to_f
    end

    it 'returns the subtractions of <w>s from <z>' do
      expect(@p.parse('(- 1 2)')).to eq '-1'.to_i
      expect(@p.parse('(- 1 2 0.0)')).to eq '-1'.to_f
      expect(@p.parse('(- 1 2 3 4 5)')).to eq '-13'.to_i
      expect(@p.parse('(- -1 2 3 4 5)')).to eq '-15'.to_i
      expect(@p.parse('(- 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq '-13'.to_i
      expect(@p.parse('(- 1.2 (*) (+))')).to eq 0.19999999999999996
    end
  end

  describe '(* z ...)' do
    it 'returns 1 if <z> is not provided' do
      expect(@p.parse('(*)')).to eq 1
    end

    it 'return <z> if <z> is single argument' do
      expect(@p.parse('(* 1)')).to eq 1
      expect(@p.parse('(* 0.0)')).to eq 0.0
    end

    it 'returns the product of <z> if <z> is not single argument' do
      expect(@p.parse('(* 8.0 9)')).to eq 72.0
      expect(@p.parse('(* 1 2 0.0)')).to eq 0.0
      expect(@p.parse('(* 1 2 3 4)')).to eq 24
      expect(@p.parse('(* 1 2 3 4.0 5)')).to eq 120.0
      expect(@p.parse('(* 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 120
    end
  end

  describe '(/ z w ...+)' do
    it 'throws ZeroDivisionError when <z> is 0 and no <w>s are provided' do
      expect(@p.parse('(/ 0)')).to eq @msg['zero_div']
      expect(@p.parse('(/ 0.0)')).to eq @msg['zero_div']
    end

    it 'returns <z> when no <w>s are provided' do
      expect(@p.parse('(/ 1)')).to eq 1
      expect(@p.parse('(/ 10.0)')).to eq 0.1
    end

    it 'returns (/ <z> <w>s) when <w>s are provided' do
      expect(@p.parse('(/ 81 3.0)')).to eq 27.0
      expect(@p.parse('(/ 1 2 3 4 5)')).to eq 0.008333333333333333
      expect(@p.parse('(/ 1 (+ 2) (+ 2 1))')).to eq 0.16666666666666666
      expect(@p.parse('(/ (* 0.33 6) (/ 22 7))')).to eq 0.63
    end
  end

  describe '(not v)' do
    it 'returns #t when <v> is #f' do
      expect(@p.parse('(not #f)')).to eq '#t'
      expect(@p.parse('(not (not #t))')).to eq '#t'
    end

    it 'returns #f when <v> is #t' do
      expect(@p.parse('(not #t)')).to eq '#f'
      expect(@p.parse('(not (not #f))')).to eq '#f'
    end
  end

  describe '(equal? v1 v2)' do
    it 'returns #t when <v1> = <v2>' do
      expect(@p.parse('(equal? 1 1)')).to eq '#t'
      expect(@p.parse('(equal? "Sample" "Sample")')).to eq '#t'
      expect(@p.parse('(equal? \'yes \'yes)')).to eq '#t'
      expect(@p.parse('(equal? (cons 1 2) (cons 1 2))')).to eq '#t'
      expect(@p.parse('(equal? (cons 1 2) \'(1 . 2))')).to eq '#t'
    end

    it 'returns #f when <v1> != <v2>' do
      expect(@p.parse('(equal? 1 1.0)')).to eq '#f'
      expect(@p.parse('(equal? #t #f)')).to eq '#f'
      expect(@p.parse('(equal? #\a #\b)')).to eq '#f'
      expect(@p.parse('(equal? (not #t) (not #f))')).to eq '#f'
    end
  end

  describe '(quotient n m)' do
    it 'throws ZeroDivisionError if second argument is 0' do
      expect(@p.parse('(quotient 1 0)')).to eq @msg['zero_div']
    end

    it 'finds the quotient of <n> and <m> when they are integers' do
      expect(@p.parse('(quotient 10 3)')).to eq 3
      expect(@p.parse('(quotient -10 3)')).to eq '-3'.to_i
      expect(@p.parse('(quotient 10 -3)')).to eq '-3'.to_i
      expect(@p.parse('(quotient -10 -3)')).to eq 3
    end

    it 'finds the quotient of <n> and <m> when they are floats' do
      expect(@p.parse('(quotient 10 3.0)')).to eq 3.0
      expect(@p.parse('(quotient -10.0 3)')).to eq '-3'.to_f
      expect(@p.parse('(quotient -10 3.0)')).to eq '-3'.to_f
      expect(@p.parse('(quotient -10.0 -3.0)')).to eq 3.0
    end
  end

  describe '(remainder n m)' do
    it 'throws ZeroDivisionError if <m> is 0' do
      expect(@p.parse('(remainder 1 0)')).to eq @msg['zero_div']
      expect(@p.parse('(remainder 1 0.0)')).to eq @msg['zero_div']
    end

    it 'finds the remainder of <n> and <m> when they are integers' do
      expect(@p.parse('(remainder 10 3)')).to eq 1
      expect(@p.parse('(remainder -10 3)')).to eq '-1'.to_i
      expect(@p.parse('(remainder 10 -3)')).to eq 1
      expect(@p.parse('(remainder -10 -3)')).to eq '-1'.to_i
    end

    it 'finds the remainder of <n> and <m> when they are floats' do
      expect(@p.parse('(remainder 10 3.0)')).to eq 1.0
      expect(@p.parse('(remainder -10.0 3)')).to eq '-1'.to_f
      expect(@p.parse('(remainder 10 -3.0)')).to eq 1.0
      expect(@p.parse('(remainder -10.0 -3.0)')).to eq '-1'.to_f
    end
  end

  describe '(modulo n m)' do
    it 'throws ZeroDivisionError if <m> is 0' do
      expect(@p.parse('(modulo 1 0)')).to eq @msg['zero_div']
      expect(@p.parse('(modulo 1 0.0)')).to eq @msg['zero_div']
    end

    it 'finds the modulo of <n> and <m> when they are integers' do
      expect(@p.parse('(modulo 10 3)')).to eq 1
      expect(@p.parse('(modulo -10 3)')).to eq 2
      expect(@p.parse('(modulo 10 -3)')).to eq '-2'.to_i
      expect(@p.parse('(modulo -10 -3)')).to eq '-1'.to_i
    end

    it 'finds the modulo of <n> and <m> when they are floats' do
      expect(@p.parse('(modulo 10 3.0)')).to eq 1.0
      expect(@p.parse('(modulo -10.0 3)')).to eq 2.0
      expect(@p.parse('(modulo 10 -3.0)')).to eq '-2'.to_f
      expect(@p.parse('(modulo -10.0 -3.0)')).to eq '-1'.to_f
    end
  end

  describe '(numerator q)' do
    it 'returns the numerator of <q> when <q> is integer' do
      expect(@p.parse('(numerator 5)')).to eq 5
      expect(@p.parse('(numerator 1)')).to eq 1
      expect(@p.parse('(numerator 0)')).to eq 0
    end

    it 'returns the numerator of <q> when <q> is float' do
      expect(@p.parse('(numerator 5.3)')).to eq 5.3
      expect(@p.parse('(numerator 1.5)')).to eq 1.5
      expect(@p.parse('(numerator 0.7)')).to eq 0.7
    end

    it 'returns the numerator of <q> when <q> is rational' do
      expect(@p.parse('(numerator 5/6)')).to eq 5
      expect(@p.parse('(numerator 1/1)')).to eq 1
      expect(@p.parse('(numerator 1/0)')).to eq 1
    end
  end

  describe '(denominator q)' do
    it 'returns the denominator of <q> when <q> is integer' do
      expect(@p.parse('(denominator 5)')).to eq 1
      expect(@p.parse('(denominator 1)')).to eq 1
      expect(@p.parse('(denominator 0)')).to eq 1
    end

    it 'returns the denominator of <q> when <q> is float' do
      expect(@p.parse('(denominator 5.3)')).to eq 1
      expect(@p.parse('(denominator 1.5)')).to eq 1
      expect(@p.parse('(denominator 0.7)')).to eq 1
    end

    it 'returns the denominator of <q> when <q> is rational' do
      expect(@p.parse('(denominator 5/6)')).to eq 6
      expect(@p.parse('(denominator 1/1.5)')).to eq 1.5
      expect(@p.parse('(denominator 1/0)')).to eq 0
    end
  end

  describe '(abs z)' do
    it 'returns the absolute value of <z> when <z> is integer' do
      expect(@p.parse('(abs 1)')).to eq 1
      expect(@p.parse('(abs -10)')).to eq 10
      expect(@p.parse('(abs 0)')).to eq 0
    end

    it 'returns the absolute value of <z> when <z> is float' do
      expect(@p.parse('(abs 1.0)')).to eq 1.0
      expect(@p.parse('(abs -10.7)')).to eq 10.7
      expect(@p.parse('(abs 0.0)')).to eq 0.0
    end
  end

  describe '(add1 z)' do
    it 'returns <z> + 1 when <z> is integer' do
      expect(@p.parse('(add1 1)')).to eq 2
      expect(@p.parse('(add1 -1)')).to eq 0
      expect(@p.parse('(add1 -2)')).to eq '-1'.to_i
    end

    it 'returns <z> + 1 when <z> is float' do
      expect(@p.parse('(add1 1.0)')).to eq 2.0
      expect(@p.parse('(add1 -1.0)')).to eq 0.0
      expect(@p.parse('(add1 -2.5)')).to eq '-1.5'.to_f
    end
  end

  describe '(sub1 z)' do
    it 'returns <z> - 1 when <z> is integer' do
      expect(@p.parse('(sub1 1)')).to eq 0
      expect(@p.parse('(sub1 -1)')).to eq '-2'.to_i
      expect(@p.parse('(sub1 -2)')).to eq '-3'.to_i
    end

    it 'returns <z> - 1 when <z> is float' do
      expect(@p.parse('(sub1 1.0)')).to eq 0.0
      expect(@p.parse('(sub1 -1.0)')).to eq '-2'.to_f
      expect(@p.parse('(sub1 -2.5)')).to eq '-3.5'.to_f
    end
  end

  describe '(min x ...+)' do
    it 'returns <x> if <x> is single argument' do
      expect(@p.parse('(min -5)')).to eq '-5'.to_i
      expect(@p.parse('(min 1.5)')).to eq 1.5
      expect(@p.parse('(min 1)')).to eq 1
    end

    it 'returns the smallest of <x>s' do
      expect(@p.parse('(min 0 0)')).to eq 0
      expect(@p.parse('(min 4 2.1 9.5)')).to eq 2.1
      expect(@p.parse('(min 5 3 1 2 4)')).to eq 1
      expect(@p.parse('(min 1.99 1.98002 1.98001 2)')).to eq 1.98001
    end
  end

  describe '(max x ...+)' do
    it 'returns <x> if <x>s is single argument' do
      expect(@p.parse('(max -5)')).to eq '-5'.to_i
      expect(@p.parse('(max 1.5)')).to eq 1.5
      expect(@p.parse('(max 1)')).to eq 1
    end

    it 'returns the largest of <x>' do
      expect(@p.parse('(max 0 0)')).to eq 0
      expect(@p.parse('(max 4 2.1 9.5)')).to eq 9.5
      expect(@p.parse('(max 5 3 1 2 4)')).to eq 5
      expect(@p.parse('(max 1.9999999 2.000001 2)')).to eq 2.000001
    end
  end

  describe '(< x y ...+)' do
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

  describe '(> x y ...+)' do
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

  describe '(<= x y ...+)' do
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

  describe '(>= x y ...+)' do
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

  describe '(string-length str)' do
    it 'returns 0 whem <str> is the empty string' do
      expect(@p.parse('(string-length "")')).to eq 0
    end

    it 'returns the length of <str> when <str> is not the empty string' do
      expect(@p.parse('(string-length "Hello world")')).to eq 11
      expect(@p.parse('(string-length "Sample")')).to eq 6
      expect(@p.parse('(string-length "   ")')).to eq 3
    end
  end

  describe '(substring str from [to])' do
    it 'finds the substring of <str> when only <from> is provided' do
      expect(@p.parse('(substring "Apple" 1)')).to eq '"pple"'
      expect(@p.parse('(substring "Hello world" 4)')).to eq '"o world"'
      expect(@p.parse('(substring "" 4)')).to eq '""'
      expect(@p.parse('(substring "Sample" 15)')).to eq '""'
      expect(@p.parse('(substring "Sample" 0)')).to eq '"Sample"'
    end

    it 'finds the substring of <str> when <from> and <to> are provided' do
      expect(@p.parse('(substring "Apple" 1 4)')).to eq '"ppl"'
      expect(@p.parse('(substring "Hello world" 4 7)')).to eq '"o w"'
      expect(@p.parse('(substring "Apple" 4 2)')).to eq '""'
      expect(@p.parse('(substring "Sample" 15 16)')).to eq '""'
      expect(@p.parse('(substring "Sample" 0 0)')).to eq '"Sample"'
    end
  end

  describe '(string-upcase str)' do
    it 'returns <str> if <str> is the empty string' do
      expect(@p.parse('(string-upcase "")')).to eq '""'
    end

    it 'converts <str> to upcase if <str> is not the empty string' do
      expect(@p.parse('(string-upcase "Apple")')).to eq '"APPLE"'
      expect(@p.parse('(string-upcase "sample")')).to eq '"SAMPLE"'
      expect(@p.parse('(string-upcase "APPLE")')).to eq '"APPLE"'
      expect(@p.parse('(string-upcase "SaMpLe")')).to eq '"SAMPLE"'
    end
  end

  describe '(string-downcase str)' do
    it 'returns <str> if <str> is the empty string' do
      expect(@p.parse('(string-downcase "")')).to eq '""'
    end

    it 'converts <str> to downcase if <str> is not the empty string' do
      expect(@p.parse('(string-downcase "Apple")')).to eq '"apple"'
      expect(@p.parse('(string-downcase "Sample")')).to eq '"sample"'
      expect(@p.parse('(string-downcase "APPLE")')).to eq '"apple"'
      expect(@p.parse('(string-downcase "SaMpLe")')).to eq '"sample"'
    end
  end

  describe '(string-contains? s contained)' do
    it 'returns true if <contained> is prefix of <s>' do
      expect(@p.parse('(string-contains? "Racket" "Rac")')).to eq '#t'
      expect(@p.parse('(string-contains? "racket" "rac")')).to eq '#t'
    end

    it 'returns true if <contained> is sufix of <s>' do
      expect(@p.parse('(string-contains? "Racket" "ket")')).to eq '#t'
      expect(@p.parse('(string-contains? "racket" "ket")')).to eq '#t'
    end

    it 'returns true if <contained> is infix of <s>' do
      expect(@p.parse('(string-contains? "Racket" "acke")')).to eq '#t'
      expect(@p.parse('(string-contains? "racket" "acke")')).to eq '#t'
      expect(@p.parse('(string-contains? "Racket" "Racket")')).to eq '#t'
    end

    it 'returns false if <s> does not contain <contained>' do
      expect(@p.parse('(string-contains? "Racket" "Rackett")')).to eq '#f'
      expect(@p.parse('(string-contains? "racket" "sample")')).to eq '#f'
    end
  end

  describe '(string->list str)' do
    it 'return the empty list if <str> is the empty string' do
      expect(@p.parse('(string->list "")')).to eq '()'
    end

    it 'returns a list of <str> characters when <str> is not the empty list' do
      result = '(#\S #\a #\m #\p #\l #\e)'
      expect(@p.parse('(string->list "Sample")')).to eq result
    end
  end

  describe '(string-split str [sep])' do
    it 'splits the empty string' do
      expect(@p.parse('(string-split "")')).to eq '()'
    end

    it 'splits string only with spaces' do
      expect(@p.parse('(string-split "  ")')).to eq '()'
    end

    it 'removes the carriage when splitting' do
      result = '("foo" "bar" "baz")'
      expect(@p.parse('(string-split "  foo bar  baz \r\n\t")')).to eq result
    end

    it 'can split non empty string' do
      expect(@p.parse('(string-split "p e n")')).to eq '("p" "e" "n")'
    end
  end

  describe '(string? v)' do
    it 'returns true if <v> is string' do
      expect(@p.parse('(string? "str")')).to eq '#t'
      expect(@p.parse('(string? "")')).to eq '#t'
    end

    it 'returns false if <v> is not string' do
      expect(@p.parse('(string? 1)')).to eq '#f'
      expect(@p.parse('(string? 1.5)')).to eq '#f'
      expect(@p.parse('(string? \'apple)')).to eq '#f'
      expect(@p.parse('(string? \'(1 . 2))')).to eq '#f'
      expect(@p.parse('(string? #\a)')).to eq '#f'
      expect(@p.parse('(string? #t)')).to eq '#f'
    end
  end

  describe '(string-replace str from to)' do
    it 'can replace the empty string' do
      expect(@p.parse('(string-replace "pen" "" " ")')).to eq '" p e n "'
    end

    it 'can replace non empty strings' do
      res = '"foo blah baz"'
      expect(@p.parse('(string-replace "foo bar baz" "bar" "blah")')).to eq res
    end
  end

  describe '(string-prefix? s prefix)' do
    it 'returns true if <s> starts with <prefix>' do
      expect(@p.parse('(string-prefix? "Racket" "Rac")')).to eq '#t'
      expect(@p.parse('(string-prefix? "racket" "rac")')).to eq '#t'
    end

    it 'returns true if <prefix> is equal to <s>' do
      expect(@p.parse('(string-prefix? "Racket" "Racket")')).to eq '#t'
    end

    it 'returns false if <s> does not start with <prefix>' do
      expect(@p.parse('(string-prefix? "Racket" "Rackett")')).to eq '#f'
      expect(@p.parse('(string-prefix? "racket" "sample")')).to eq '#f'
      expect(@p.parse('(string-prefix? "racket" "ket")')).to eq '#f'
    end
  end

  describe '(string-sufix? s suffix)' do
    it 'returns true if <s> ends with <suffix>' do
      expect(@p.parse('(string-sufix? "Racket" "cket")')).to eq '#t'
      expect(@p.parse('(string-sufix? "racket" "cket")')).to eq '#t'
    end

    it 'returns true if <suffix> is equal to <s>' do
      expect(@p.parse('(string-sufix? "Racket" "Racket")')).to eq '#t'
    end

    it 'returns false if <s> does not end with <suffix>' do
      expect(@p.parse('(string-sufix? "Racket" "Rackett")')).to eq '#f'
      expect(@p.parse('(string-sufix? "racket" "sample")')).to eq '#f'
      expect(@p.parse('(string-sufix? "racket" "rack")')).to eq '#f'
    end
  end

  describe '(string-join strs [sep])' do
    it 'appends the strings in <strs> when <sep> is not provided' do
      expect(@p.parse('(string-join \'(1 2))')).to eq '"1 2"'
      expect(@p.parse('(string-join \'())')).to eq '""'
      expect(@p.parse('(string-join (list 1 2))')).to eq '"1 2"'
    end

    it 'appends the strings in <strs> when <sep> is provided' do
      expect(@p.parse('(string-join \'(1 2) "potato")')).to eq '"1potato2"'
      expect(@p.parse('(string-join \'() "potato")')).to eq '""'
      expect(@p.parse('(string-join (list 1 2) "potato")')).to eq '"1potato2"'
    end
  end

  describe '(null? v)' do
    it 'returns true when <v> is the empty list' do
      expect(@p.parse('(null? \'())')).to eq '#t'
      expect(@p.parse('(null? null)')).to eq '#t'
      expect(@p.parse('(null? (list))')).to eq '#t'
    end

    it 'returns false when <v> is not the empty list' do
      expect(@p.parse('(null? \'(1 2))')).to eq '#f'
      expect(@p.parse('(null? (cons 1 \'()))')).to eq '#f'
      expect(@p.parse('(null? (list 1 2))')).to eq '#f'
      expect(@p.parse('(null? 1)')).to eq '#f'
      expect(@p.parse('(null? 1.5)')).to eq '#f'
      expect(@p.parse('(null? "string")')).to eq '#f'
      expect(@p.parse('(null? #t)')).to eq '#f'
      expect(@p.parse('(null? \'quote)')).to eq '#f'
    end
  end

  describe '(cons a d)' do
    it 'returns pair of <a> and <d> when <d> is not list' do
      expect(@p.parse('(cons 1 2)')).to eq '(1 . 2)'
      expect(@p.parse('(cons 1 (cons 2 3))')).to eq '(1 2 . 3)'
    end

    it 'returns pair when <d> is list' do
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

  describe '(list v ...)' do
    it 'returns empty list when <v> is not provided' do
      expect(@p.parse('(list)')).to eq '()'
    end

    it 'returns non empty list when <v> has 1 or more elements' do
      expect(@p.parse('(list 1)')).to eq '(1)'
      expect(@p.parse('(list 1 "s")')).to eq '(1 "s")'
      result = '(1 (#t . #f) quote)'
      expect(@p.parse('(list 1 (cons #t #f) \'quote)')).to eq result
    end
  end

  describe '(car p)' do
    it 'throws error when <p> is the empty list' do
      expect(@p.parse('(car null)')).to eq car_cdr_err '\'()', 'car'
      expect(@p.parse('(car (list))')).to eq car_cdr_err '\'()', 'car'
      expect(@p.parse('(car \'())')).to eq car_cdr_err '\'()', 'car'
    end

    it 'returns the first element of <p>' do
      expect(@p.parse('(car (cons 1 2))')).to eq '1'
      expect(@p.parse('(car \'( #t . 2))')).to eq '#t'
      expect(@p.parse('(car (list #f 2 3 4))')).to eq '#f'
      expect(@p.parse('(car \'(1 2 3 4))')).to eq '1'
      expect(@p.parse('(car \'(1))')).to eq '1'
    end
  end

  describe '(cdr p)' do
    it 'throws error when <p> is the empty list' do
      expect(@p.parse('(cdr null)')).to eq car_cdr_err '\'()', 'cdr'
      expect(@p.parse('(cdr (list))')).to eq car_cdr_err '\'()', 'cdr'
      expect(@p.parse('(cdr \'())')).to eq car_cdr_err '\'()', 'cdr'
    end

    it 'returns the second element of <p>' do
      expect(@p.parse('(cdr (cons 1 2))')).to eq '(2)'
      expect(@p.parse('(cdr \'( "sample" . #t))')).to eq '(#t)'
      expect(@p.parse('(cdr (cons 1 (cons 2 3)))')).to eq '(2 . 3)'
      expect(@p.parse('(cdr (list #f 2 3 4))')).to eq '(2 3 4)'
      expect(@p.parse('(cdr \'(1 2 3 4))')).to eq '(2 3 4)'
      expect(@p.parse('(cdr \'(1))')).to eq '()'
    end
  end

  describe '(list? v)' do
    it 'returns true if <v> is empty list' do
      expect(@p.parse('(list? null)')).to eq '#t'
      expect(@p.parse('(list? (list))')).to eq '#t'
      expect(@p.parse('(list? \'())')).to eq '#t'
    end

    it 'returns true if <v> is not empty list' do
      expect(@p.parse('(list? \'(1 2))')).to eq '#t'
      expect(@p.parse('(list? (list 1 2))')).to eq '#t'
      expect(@p.parse('(list? \'(1 #t "str"))')).to eq '#t'
    end

    it 'returns false if <v> is not list' do
      expect(@p.parse('(list? #t)')).to eq '#f'
      expect(@p.parse('(list? 1)')).to eq '#f'
      expect(@p.parse('(list? \'quote)')).to eq '#f'
      expect(@p.parse('(list? "string")')).to eq '#f'
      expect(@p.parse('(list? \'(1 . 2))')).to eq '#f'
    end
  end

  describe '(pair? v)' do
    it 'returns true if <v> is not empty list' do
      expect(@p.parse('(pair? \'(1 2))')).to eq '#t'
      expect(@p.parse('(pair? \'(1))')).to eq '#t'
      expect(@p.parse('(pair? (list 1 2))')).to eq '#t'
      expect(@p.parse('(pair? \'(1 #t "str"))')).to eq '#t'
    end

    it 'returns false if <v> is empty list' do
      expect(@p.parse('(pair? null)')).to eq '#f'
      expect(@p.parse('(pair? (list))')).to eq '#f'
      expect(@p.parse('(pair? \'())')).to eq '#f'
    end

    it 'returns false if <v> is not pair' do
      expect(@p.parse('(pair? #t)')).to eq '#f'
      expect(@p.parse('(pair? 1)')).to eq '#f'
      expect(@p.parse('(pair? \'quote)')).to eq '#f'
      expect(@p.parse('(pair? "string")')).to eq '#f'
    end
  end

  describe '(length lst)' do
    it 'returns 0 if <lst> is the empty list' do
      expect(@p.parse('(length null)')).to eq 0
      expect(@p.parse('(length (list))')).to eq 0
      expect(@p.parse('(length \'())')).to eq 0
    end

    it 'returns the number of elements in <lst> if <lst> is not empty list' do
      expect(@p.parse('(length \'(1 2))')).to eq 2
      expect(@p.parse('(length (list 1 2 3))')).to eq 3
      expect(@p.parse('(length (cons 1 \'(2 3 4)))')).to eq 4
    end
  end

  describe '(reverse lst)' do
    it 'returns <lst> if <lst> is the empty list' do
      expect(@p.parse('(reverse null)')).to eq '()'
      expect(@p.parse('(reverse (list))')).to eq '()'
      expect(@p.parse('(reverse \'())')).to eq '()'
    end

    it 'returns <lst> backwards if <lst> is not the empty list' do
      expect(@p.parse('(reverse \'(1 2))')).to eq '(2 1)'
      expect(@p.parse('(reverse (list 1 2 3))')).to eq '(3 2 1)'
      expect(@p.parse('(reverse (cons 1 \'(2 3 4)))')).to eq '(4 3 2 1)'
      expect(@p.parse('(reverse \'(1 \'(2 3 4) 5))')).to eq '(5 (2 3 4) 1)'
    end
  end

  describe '(remove v lst)' do
    it 'returns <lst> if the <v> is not found in <lst>' do
      expect(@p.parse('(remove 9 (list 1 2 3))')).to eq '(1 2 3)'
      expect(@p.parse('(remove (list 1 2 3) (cons 1 \'(2 3)))')).to eq '(1 2 3)'
      expect(@p.parse('(remove #t \'(1 2 3))')).to eq '(1 2 3)'
    end

    it 'returns <lst> ommiting the first element that is equal to <v>' do
      expect(@p.parse('(remove 1 (list 1 2 3))')).to eq '(2 3)'
      expect(@p.parse('(remove \'(1) (list \'(1) 2 3))')).to eq '(2 3)'
      expect(@p.parse('(remove #t \'(1 2 #t 3))')).to eq '(1 2 3)'
      expect(@p.parse('(remove 1 (list 1 2 1 3))')).to eq '(2 1 3)'
      expect(@p.parse('(remove #t \'(#t #t #t))')).to eq '(#t #t)'
      expect(@p.parse('(remove "str" \'("str"))')).to eq '()'
    end
  end

  describe '(shuffle lst)' do
    it 'returns <lst> if <lst> is the empty list' do
      expect(@p.parse('(shuffle \'())')).to eq '()'
      expect(@p.parse('(shuffle (list))')).to eq '()'
      expect(@p.parse('(shuffle null)')).to eq '()'
    end

    it 'returns <lst> with randomly shuffled elements' do
      permuts = [1, 2, 3].permutation(3).to_a
      permuts = permuts.map { |p| build_lst p }
      expect(permuts).to include(@p.parse('(shuffle (list 1 2 3))'))
      expect(@p.parse('(shuffle (list 1 1 1))')).to eq '(1 1 1)'
    end
  end

  describe '(map proc lst ...+)' do
    it 'returns <lst> if <lst> is the empty list' do
      expect(@p.parse('(map + \'())')).to eq '()'
      expect(@p.parse('(map (lambda ()) null)')).to eq '()'
    end

    it 'Applies <proc> to the elements of the <lst> when <proc> is lambda' do
      expr1 = '(map (lambda (n)(+ 1 n))\'(1 2 3 4))'
      expr2 = '(map (lambda (x y)(+ x y))\'(1 2 3 4)\'(10 100 1000 10000))'
      expr3 = '(map xl \'(1 2 3 4))'
      expect(@p.parse(expr1)).to eq '(2 3 4 5)'
      expect(@p.parse(expr2)).to eq '(11 102 1003 10004)'
      expect(@p.parse(expr3)).to eq '(2 4 6 8)'
    end

    it 'Applies <proc> to the elements of the <lst> when <proc> is function' do
      expr1 = '(map list \'(1 2 3 4))'
      expr2 = '(map cons \'(1 2 3 4)\'(1 10 100 1000))'
      expect(@p.parse(expr1)).to eq '((1) (2) (3) (4))'
      expect(@p.parse(expr2)).to eq '((1 . 1) (2 . 10) (3 . 100) (4 . 1000))'
    end
  end
  
  describe '(member v lst)' do
    it 'returns false if <v> is not found in <lst>' do
      expect(@p.parse('(member 9 (list 1 2 3 4))')).to eq '#f'
      expect(@p.parse('(member 2 (list))')).to eq '#f'
      expect(@p.parse('(member 2.0 (list 1 2 3 4))')).to eq '#f'
    end
    
    it 'returns <lst> with elements after the first occurance of <v> in <lst>' do
      expect(@p.parse('(member 2 (list 1 2 3 4))')).to eq '(2 3 4)'
      expect(@p.parse('(member \'(1) (list 3 (list 1) 2))')).to eq '((1) 2)'
      expect(@p.parse('(member 1 (list 1 1 1))')).to eq '(1 1 1)'
    end
  end
  
  describe '(lambda params body ...+)' do
    it 'returns procedure when there are no <params>' do
      expect(@p.parse('(lambda ())')).to be_an_instance_of(Proc)
      expect(@p.parse('(lambda () 5)')).to be_an_instance_of(Proc)
    end
    
    it 'returns procedure when there are <params>' do
      expect(@p.parse('(lambda (x))')).to be_an_instance_of(Proc)
      expect(@p.parse('(lambda (x) x)')).to be_an_instance_of(Proc)
    end
    
    it 'calls the procedure by given values for the <params>' do
      expect(@p.parse('((lambda (x) x) 10)')).to eq '10'
      expect(@p.parse('((lambda (x y) (* x y)) 10 10)')).to '100'
    end
  end
  
  describe '(apply proc v ... lst)' do
    it 'applies <proc> to <lst> when no <v>s are supplied' do
      expect(@p.parse('(apply + \'(1 2 3))')).to eq 6
      expect(@p.parse('(apply + \'())')).to eq 0
    end
    
    it 'applies <proc> to <lst> when <v>s are supplied' do
      expect(@p.parse('(apply + 1 2 \'(3))')).to eq 6
      expr2 = '(apply map list \'((a b c) (1 2 3)))'
      expect(@p.parse(expr2)).to eq '((a 1) (b 2) (c 3))'
    end
    
    it 'applies <proc> to <lst> when <proc> is lambda expression' do
      expr1 = '(apply (lambda (x) (* x x x)) (list 2))'
      expr2 = '(apply xl) (list 5))'
      expect(@p.parse(expr1)).to eq 8
      expect(@p.parse(expr2)).to eq 10
    end
  end
  
  describe '(compose proc ...)' do
    # TODO to fix compose !
  end
  
  describe 'define' do
    it 'can define variable' do
      expect(@p.parse('(define x 5)')).to eq 5
      expect(@p.parse('(x)')).to eq 5
    end
    
    it 'can define function' do
      expr1 = '(define (prod x y)(* x y))'
      expect(@p.parse(expr1)).to eq be_an_instance_of(Proc)
      expect(@p.parse('(prod 2 3)')).to eq 6
    end
    
    it 'can define lambda' do
      expr1 = '(define x (lambda (x) (* 2 x)))'
      expect(@p.parse(expr1)).to eq be_an_instance_of(Proc)
      expect(@p.parse('(x 5)')).to eq 10
    end
  end
  
  describe 'scopes' do
    it 'uses inner scope variables with the same name as in outer scope' do
      expr1 = '(define (prod x y) ((lambda (x y) (* x y)) x y))'
      expect(@p.parse(epxr1)).to be_an_instance_of(Proc)
      expect(@p.parse(prod 2 3)).to eq 6
    end
    
    it 'defines variables visible only in the scope of deffinition or lower' do
      expr1 = '(define prodfive (lambda (x)(define y 5)(* x y)))'
      expect(@p.parse(epxr1)).to be_an_instance_of(Proc)
      expect(@p.parse(prodfive 6)).to eq 30
    end
  end
end
