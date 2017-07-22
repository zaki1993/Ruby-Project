load 'parser.rb'

RSpec.describe 'Parser' do
  before do
    @parser = Parser.new
    @PI = 3.142857142857143
  end

  describe '#scheme_numbers' do
    context '#+' do
      it 'can sum with no arguments' do
        expect(@parser.parse('(+)')).to eq 0
      end

      it 'can sum without arguments' do
        expect(@parser.parse('(+ 1)')).to eq 1
        expect(@parser.parse('(+ 0)')).to eq 0
        expect(@parser.parse('(+ 1.0)')).to eq 1.0
        expect(@parser.parse('(+ 0.9999)')).to eq 0.9999
        expect(@parser.parse('(+ 0.0001)')).to eq 0.0001
        expect(@parser.parse('(+ 0.5)')).to eq 0.5
        expect(@parser.parse('(+ 0.0)')).to eq 0.0
        expect(@parser.parse('(+ 1234567)')).to eq 1234567
      end

      it 'can sum with two arguments' do
        expect(@parser.parse('(+ 1 2)')).to eq 3
        expect(@parser.parse('(+ 1 0)')).to eq 1
        expect(@parser.parse('(+ 1 1.5)')).to eq 2.5
        expect(@parser.parse('(+ 1.5 1)')).to eq 2.5
        expect(@parser.parse('(+ 0.9999 0.0001)')).to eq 1.0
        expect(@parser.parse('(+ 1.5 1.99)')).to eq 3.49
        expect(@parser.parse('(+ 1.5 0.0)')).to eq 1.5
        expect(@parser.parse('(+ 1.349 1.651)')).to eq 3
      end

      it 'can sum with more than two arguments' do
        expect(@parser.parse('(+ 1 2 0)')).to eq 3
        expect(@parser.parse('(+ 1 2 3 4 5)')).to eq 15
        expect(@parser.parse('(+ 0.2 0.2 0.2 0.2 0.2)')).to eq 1.0
        expect(@parser.parse('(+ 1 2 0.5 1)')).to eq 4.5
        expect(@parser.parse('(+ 0 0 0 0 0.0)')).to eq 0.0
        expect(@parser.parse('(+ 0.33 0.33 0.33 0.01)')).to eq 1.0
        expect(@parser.parse('(+ 1 2 0.0001 0.0009)')).to eq 3.0010000000000003
        expect(@parser.parse('(+ 1 0.0001 0.0009)')).to eq 1.001
      end

      it 'can sum with other functions' do
        expect(@parser.parse('(+ 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 15
        expect(@parser.parse('(+ (+ (+ 1 0) 1) (+ 1 0))')).to eq 3
        expect(@parser.parse('(+ (+ (+ 1 0.0) 1) (+ 1.0 0))')).to eq 3.0
        expect(@parser.parse('(+ 1 (* 2 3) (* 0.2 5) (/ 81 3))')).to eq 35.0
        expect(@parser.parse('(+ 1.0 (+ (- 1)))')).to eq 0.0
        expect(@parser.parse('(+ -1 2 (/ 5 2))')).to eq 3.5
        expect(@parser.parse('(+ (* 0.33 6) (/ 22 7))')).to eq @PI + 1.98
        expect(@parser.parse('(+ 1.2 (*) (- 0) (+))')).to eq 2.2
        expect(@parser.parse('(+ (string-length "Sample"))')).to eq 6
        expect(@parser.parse('(+ (length (list 1 2)))')).to eq 2
      end

      it 'can sum with variables' do
        @parser.parse('(define x 5)')
        @parser.parse('(define y 0.999)')
        expect(@parser.parse('(+ 1 x)')).to eq 6
        expect(@parser.parse('(+ x y)')).to eq 5.999
        expect(@parser.parse('(+ 0.5 (+ 0 0.5) y)')).to eq 1.999
        expect(@parser.parse('(+ 0.001 x)')).to eq 5.001
        expect(@parser.parse('(+ x x x)')).to eq 15
        expect(@parser.parse('(+ y x y x)')).to eq 11.998
      end
    end

    context '#-' do
      it 'can subtract without arguments' do
        # TODO expect(@parser.parse('(-)')).to eq 0
      end

      it 'can subtract with one arguments' do
        expect(@parser.parse('(- 1)')).to eq -1
        expect(@parser.parse('(- 0)')).to eq 0
        expect(@parser.parse('(- 1.0)')).to eq -1.0
        expect(@parser.parse('(- 0.9999)')).to eq -0.9999
        expect(@parser.parse('(- 0.0001)')).to eq -0.0001
        expect(@parser.parse('(- 0.5)')).to eq -0.5
        expect(@parser.parse('(- 0.0)')).to eq 0.0
        expect(@parser.parse('(- 1234567)')).to eq -1234567
        expect(@parser.parse('(- (- 5.0))')).to eq 5.0
        expect(@parser.parse('(- -5)')).to eq 5
      end

      it 'can subtract with two arguments' do
        expect(@parser.parse('(- 1 2)')).to eq -1
        expect(@parser.parse('(- -1 2)')).to eq -3
        expect(@parser.parse('(- 1 0)')).to eq 1
        expect(@parser.parse('(- 1 1.5)')).to eq -0.5
        expect(@parser.parse('(- 1.5 1)')).to eq 0.5
        expect(@parser.parse('(- 0.9999 0.0001)')).to eq 0.9998
        expect(@parser.parse('(- 1.5 1.99)')).to eq -0.49
        expect(@parser.parse('(- 1.5 0.0)')).to eq 1.5
      end

      it 'can subtract with more than two arguments' do
        expect(@parser.parse('(- 1 2 0)')).to eq -1
        expect(@parser.parse('(- 1 2 0.0)')).to eq -1.0
        expect(@parser.parse('(- 1 2 3 4 5)')).to eq -13
        expect(@parser.parse('(- -1 2 3 4 5)')).to eq -15
        expect(@parser.parse('(- -0.2 0.2 0.2 0.2 0.2)')).to eq -1.0
        expect(@parser.parse('(- 1 2 0.5 1)')).to eq -2.5
        expect(@parser.parse('(- 0 0 0 0 0.0)')).to eq 0.0
        expect(@parser.parse('(- 0.33 0.33 0.33 0.01)')).to eq -0.34
        expect(@parser.parse('(- -0.33 0.33 0.33 0.01)')).to eq -1.0
        expect(@parser.parse('(- 1 2 0.001 0.009)')).to eq -1.0099999999999998
        expect(@parser.parse('(- 1 0.0001 0.0009)')).to eq 0.999
      end

      it 'can subtract with other functions' do
        expect(@parser.parse('(- 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq -13
        expect(@parser.parse('(- (+ (+ 1 0) 1) (+ 1 0))')).to eq 1
        expect(@parser.parse('(- (+ (+ 1 0.0) 1) (+ 1.0 0))')).to eq 1.0
        expect(@parser.parse('(- 1 (* 2 3) (* 0.2 5) (/ 81 3))')).to eq -33.0
        expect(@parser.parse('(- 1.0 (+ (- 1)))')).to eq 2.0
        expect(@parser.parse('(- -1 2 (/ 5 2))')).to eq -5.5
        expect(@parser.parse('(- (* 0.33 6) (/ 22 7))')).to eq 1.98 - @PI
        expect(@parser.parse('(- 1.2 (*) (+))')).to eq 0.19999999999999996
        expect(@parser.parse('(- (string-length "Sample"))')).to eq -6
        expect(@parser.parse('(- (- (string-length "Sample")))')).to eq 6
        expect(@parser.parse('(- (length (list 1 2)))')).to eq -2
      end

      it 'can subtract with variables' do
        @parser.parse('(define x 5)')
        @parser.parse('(define y 0.999)')
        expect(@parser.parse('(- 1 x)')).to eq -4
        expect(@parser.parse('(- x y)')).to eq 4.001
        expect(@parser.parse('(- 5 (+ 0 0.5) y)')).to eq 3.501
        expect(@parser.parse('(- 0.001 x)')).to eq -4.999
        expect(@parser.parse('(- x x x)')).to eq -5
        expect(@parser.parse('(- y x y x)')).to eq -9.999999999999998
      end
    end

    context '#*' do
      it 'can multiply without arguments' do
        expect(@parser.parse('(*)')).to eq 1
      end

      it 'can multiply with one arguments' do
        expect(@parser.parse('(* 1)')).to eq 1
        expect(@parser.parse('(* 0)')).to eq 0
        expect(@parser.parse('(* 1.0)')).to eq 1.0
        expect(@parser.parse('(* 0.9999)')).to eq 0.9999
        expect(@parser.parse('(* 0.0001)')).to eq 0.0001
        expect(@parser.parse('(* 0.5)')).to eq 0.5
        expect(@parser.parse('(* 0.0)')).to eq 0.0
        expect(@parser.parse('(* 1234567)')).to eq 1234567
      end

      it 'can multiply with two arguments' do
        expect(@parser.parse('(* 1 2)')).to eq 2
        expect(@parser.parse('(* -1 2)')).to eq -2
        expect(@parser.parse('(* 1 0)')).to eq 0
        expect(@parser.parse('(* 1 1.5)')).to eq 1.5
        expect(@parser.parse('(* 1.5 1)')).to eq 1.5
        expect(@parser.parse('(* 1.0 0.0001)')).to eq 0.0001
        expect(@parser.parse('(* 1.5 1.99)')).to eq 2.985
        expect(@parser.parse('(* 1.5 0.0)')).to eq 0.0
      end

      it 'can multiply with more than two arguments' do
        expect(@parser.parse('(* 1 2 0)')).to eq 0
        expect(@parser.parse('(* 1 2 0.0)')).to eq 0.0
        expect(@parser.parse('(* 1 2 3 4 5)')).to eq 120
        expect(@parser.parse('(* -1 2 3 4 5)')).to eq -120
        expect(@parser.parse('(* -0.2 5)')).to eq -1.0
        expect(@parser.parse('(* 1 2 0.5 1)')).to eq 1.0
        expect(@parser.parse('(* 0 0 0 0 0.0)')).to eq 0.0
        expect(@parser.parse('(* 0.33 0.33 0.33 0.01)')).to eq 0.00035937
        expect(@parser.parse('(* -0.33 0.33 0.33 0.01)')).to eq -0.00035937
        expect(@parser.parse('(* 1 2 0.001 0.009)')).to eq 0.000018
        expect(@parser.parse('(* 1 0.0001 0.0009)')).to eq 9e-8
      end

      it 'can multiply with other functions' do
        expect(@parser.parse('(* 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 120
        expect(@parser.parse('(* (+ (+ 1 0) 1) (+ 1 0))')).to eq 2
        expect(@parser.parse('(* (+ (+ 1 0.0) 1) (+ 1.0 0))')).to eq 2.0
        expect(@parser.parse('(* 1 (* 2 3) (* 0.2 5) (/ 81 3))')).to eq 162.0
        expect(@parser.parse('(* 1.0 (+ (- 1)))')).to eq -1.0
        expect(@parser.parse('(* -1 2 (/ 5 2))')).to eq -5.0
        expect(@parser.parse('(* (* 0.33 6) (/ 22 7))')).to eq 3.08 + @PI
        expect(@parser.parse('(* 1.2 (*) (+))')).to eq 0.0
        expect(@parser.parse('(* (string-length "Sample"))')).to eq 6
        expect(@parser.parse('(* (- (string-length "Sample")))')).to eq -6
        expect(@parser.parse('(* (length (list 1 2)))')).to eq 2
      end

      it 'can multiply with variables' do
        @parser.parse('(define x 5)')
        @parser.parse('(define y 0.999)')
        expect(@parser.parse('(* 1 x)')).to eq 5
        expect(@parser.parse('(* x y)')).to eq 4.995
        expect(@parser.parse('(* 5 (+ 0 0.5) y)')).to eq 2.4975
        expect(@parser.parse('(* 0.001 x)')).to eq 0.005
        expect(@parser.parse('(* x x x)')).to eq 125
        expect(@parser.parse('(* y x y x)')).to eq 24.950025
      end
    end

    context '#/' do
      it 'throws ZeroDivisionError' do
        #expect(@parser.parse('(/ 0)')).to eq 0
        #expect(@parser.parse('(/ 1 0)')).to eq 0
        #expect(@parser.parse('(/ 0 0)')).to eq 0
        #expect(@parser.parse('(/ 1.5 0.0)')).to eq 0.0
        #expect(@parser.parse('(/ 0.0)')).to eq 0.0
        #expect(@parser.parse('(/ 0 0 0 0 0.0)')).to eq 0.0
        #expect(@parser.parse('(/ 1.2 (*) (+))')).to eq 0.0
      end

      it 'can divide with one arguments' do
        expect(@parser.parse('(/ 1)')).to eq 1
        expect(@parser.parse('(/ 1.0)')).to eq 1.0
        expect(@parser.parse('(/ 0.9999)')).to eq 1.000100010001
        expect(@parser.parse('(/ 0.0001)')).to eq 10000
        expect(@parser.parse('(/ 0.5)')).to eq 2
        expect(@parser.parse('(/ 1234567)')).to eq 8.100005913004317e-7
      end

      it 'can divide with two arguments' do
        expect(@parser.parse('(/ 1 2)')).to eq 0.5
        expect(@parser.parse('(/ -1 2)')).to eq -0.5
        expect(@parser.parse('(/ 0 1)')).to eq 0
        expect(@parser.parse('(/ 81 3)')).to eq 27
        expect(@parser.parse('(/ 81 3.0)')).to eq 27.0
        expect(@parser.parse('(/ 1 1.5)')).to eq 0.6666666666666666
        expect(@parser.parse('(/ 1.5 1)')).to eq 1.5
        expect(@parser.parse('(/ 1.0 0.0001)')).to eq 10000.0
        expect(@parser.parse('(/ 1.5 1.99)')).to eq 0.7537688442211056
      end

      it 'can divide with more than two arguments' do
        expect(@parser.parse('(/ 0.0 1 2)')).to eq 0.0
        expect(@parser.parse('(/ 0 1 2)')).to eq 0
        expect(@parser.parse('(/ 1 2 3 4 5)')).to eq 0.008333333333333333
        expect(@parser.parse('(/ -1 2 3 4 5)')).to eq -0.008333333333333333
        expect(@parser.parse('(/ -0.2 5)')).to eq -0.04
        expect(@parser.parse('(/ 1 2 0.5 1)')).to eq 1.0
        expect(@parser.parse('(/ 0.33 0.33 0.33 0.01)')).to eq 303.030303030303
        expect(@parser.parse('(/ 1 2 0.001 0.009)')).to eq 55555.55555555556
        expect(@parser.parse('(/ 1 0.0001 0.0009)')).to eq 11111111.111111112
      end

      it 'can divide with other functions' do
        expect(@parser.parse('(/ 1 (+ 2) (+ 2 1))')).to eq 0.16666666666666666
        expect(@parser.parse('(/ (+ (+ 1 0) 1) (+ 1 0))')).to eq 2
        expect(@parser.parse('(/ (+ (+ 1 0.0) 1) (+ 1.0 0))')).to eq 2.0
        expect(@parser.parse('(/ (* 2 3) (/ 81 3))')).to eq 0.2222222222222222
        expect(@parser.parse('(/ 1.0 (+ (- 1)))')).to eq -1.0
        expect(@parser.parse('(/ -1 2 (/ 5 2))')).to eq -0.2
        expect(@parser.parse('(/ (* 0.33 6) (/ 22 7))')).to eq 0.63
        expect(@parser.parse('(/ (string-length "John"))')).to eq 0.25
        expect(@parser.parse('(/ (length (list 1 2)))')).to eq 0.5
      end

      it 'can divide with variables' do
        @parser.parse('(define x 5)')
        @parser.parse('(define y 0.999)')
        expect(@parser.parse('(/ 1 x)')).to eq 0.2
        expect(@parser.parse('(/ x y)')).to eq 5.005005005005005
        expect(@parser.parse('(/ 5 (+ 0 0.5) y)')).to eq 10.01001001001001
        expect(@parser.parse('(/ 0.001 x)')).to eq 0.0002
        expect(@parser.parse('(/ x x x)')).to eq 0.2
        expect(@parser.parse('(/ y x y x)')).to eq 0.04
      end
    end
  end

  describe '#strings' do
    context 'can find the length of the string' do
      it 'can find the length of the string' do
        expect(@parser.parse('(string-length "sample-string")')).to eq 13
        expect(@parser.parse('(string-length "ruby rlz")')).to eq 8
      end
    end

    context 'can get substring' do
      it 'can get substring' do
        expect(@parser.parse('(substring "sample" 1 5)')).to eq 'ampl'
        expect(@parser.parse('(substring "sample" 0)')).to eq 'sample'
        expect(@parser.parse('(substring "sample" 0 4)')).to eq 'samp'
        expect(@parser.parse('(substring "sample" 0 0)')).to eq ''
      end
    end

    context 'can convert string to upcase' do
      it 'can convert string to upcase' do
        expect(@parser.parse('(string-upcase "sample")')).to eq 'SAMPLE'
        expect(@parser.parse('(string-upcase "SaMpLe")')).to eq 'SAMPLE'
      end
    end

    context 'can convert string to downcase' do
      it 'can convert string to downcase' do
        expect(@parser.parse('(string-downcase "SAMPLE")')).to eq 'sample'
        expect(@parser.parse('(string-downcase "SaMpLe")')).to eq 'sample'
      end
    end

    context 'can convert string to list' do
      it 'can convert string to list' do
        result = '\'(#\S #\A #\M #\P #\L #\E) '
        expect(@parser.parse('(string->list "SAMPLE")')).to eq result
      end
    end

    context 'can split string' do
      it 'can split string' do
        result = '\'("Hello" "world")'
        expect(@parser.parse('(string-split "Hello world")')).to eq result
      end
    end

    context 'checks if string contains substring' do
      it 'checks if string contains substring' do
        expect(@parser.parse('(string-contains? "Sample" "amp")')).to eq '#t'
        expect(@parser.parse('(string-contains? "Sample" "lee")')).to eq '#f'
        expect(@parser.parse('(string-contains? "Sam" "Sam")')).to eq '#t'
        expect(@parser.parse('(string-contains? "Sam" "sam")')).to eq '#f'
      end
    end

    context 'checks if literal is string' do
      it 'checks with string' do
        expect(@parser.parse('(string? "Sample")')).to eq '#t'
        expect(@parser.parse('(string? "123")')).to eq '#t'
      end

      it 'checks with number' do
        expect(@parser.parse('(string? 123)')).to eq '#f'
      end

      it 'checks with symbol' do
        expect(@parser.parse('(string? \'Sample)')).to eq '#f'
      end

      it 'checks with list' do
        expect(@parser.parse('(string? \'(1 2))')).to eq '#f'
      end

      it 'checks with boolean' do
        expect(@parser.parse('(string? #t)')).to eq '#f'
      end
    end

    context 'can compare strings' do
      it 'can compare with =' do
        expect(@parser.parse('(string=? "asd" "asd")')).to eq '#t'
        expect(@parser.parse('(string=? "asd" "asdd")')).to eq '#f'
      end

      it 'can compare with <' do
        expect(@parser.parse('(string<? "asd" "bsd")')).to eq '#t'
        expect(@parser.parse('(string<? "asd" "asd")')).to eq '#f'
      end

      it 'can compare with >' do
        expect(@parser.parse('(string>? "bsd" "asd")')).to eq '#t'
        expect(@parser.parse('(string>? "asd" "asd")')).to eq '#f'
      end

      it 'can compare with >=' do
        expect(@parser.parse('(string>=? "asd" "asd")')).to eq '#t'
        expect(@parser.parse('(string>=? "asd" "bsd")')).to eq '#f'
      end

      it 'can compare with <=' do
        expect(@parser.parse('(string<=? "asd" "asd")')).to eq '#t'
        expect(@parser.parse('(string<=? "asd" "bsd")')).to eq '#t'
      end
    end
  end

  describe '#if_operator' do
    it 'can use if with single value' do
      expect(@parser.parse('(if #t #t #f)')).to eq '#t'
      expect(@parser.parse('(if #f #t #f)')).to eq '#f'
      expect(@parser.parse('(if #t "Pesho" "Gosho")')).to eq 'Pesho'
      expect(@parser.parse('(if #f "Pesho" "Gosho")')).to eq 'Gosho'
      expect(@parser.parse('(if #t 1 2)')).to eq 1
      expect(@parser.parse('(if #f 1 2)')).to eq 2
    end

    it 'can use if with functions statement' do
      expect(@parser.parse('(if (< 2 3) #t #f)')).to eq '#t'
      expect(@parser.parse('(if (not #t) #t #f)')).to eq '#f'
      expect(@parser.parse('(if (not (not #t)) "Pesho" "Gosho")')).to eq 'Pesho'
      expect(@parser.parse('(if (not (< 2 3)) "Pesho" "Gosho")')).to eq 'Gosho'
      expect(@parser.parse('(if (not #f) 1 2)')).to eq 1
      expect(@parser.parse('(if (= 5 5) 1 2)')).to eq 1
    end

    it 'can use if with functions results' do
      expect(@parser.parse('(if (< 2 3) (not #f) #f)')).to eq '#t'
      expect(@parser.parse('(if (not #t) #t (not #t))')).to eq '#f'
      expect(@parser.parse('(if #t (substring "Pesho" 0) 1)')).to eq 'Pesho'
      expect(@parser.parse('(if #f 1 (substring "Gosho" 0))')).to eq 'Gosho'
      expect(@parser.parse('(if (not #f) (+ 1 0) 2)')).to eq 1
      expect(@parser.parse('(if (= 5 5) (+ 0.5 0.5) 2)')).to eq 1
    end
  end

  describe '#display_values' do
    it 'can display numbers' do
      expect(@parser.parse('1')).to eq 1
      expect(@parser.parse('1.5')).to eq 1.5
    end

    it 'can display booleans' do
      expect(@parser.parse('#t')).to eq '#t'
      expect(@parser.parse('#f')).to eq '#f'
    end

    it 'can display strings' do
      expect(@parser.parse('"Sample"')).to eq 'Sample'
      expect(@parser.parse('"Gosho"')).to eq 'Gosho'
    end

    it 'can display lists' do
      expect(@parser.parse('(list 1 2)')).to eq '\'(1 2)'
      expect(@parser.parse('\'()')).to eq '\'()'
      expect(@parser.parse('\'(1 2)')).to eq '\'(1 2)'
    end

    it 'can display cons' do
      expect(@parser.parse('(cons 1 2)')).to eq '(1 . 2)'
      expect(@parser.parse('(cons 1 2 3)')).to eq '(1  2 . 3)'
      expect(@parser.parse('(cons 1 \'())')).to eq '\'(1)'
    end
  end

  describe '#variables' do
    it 'can define variable' do
      @parser.parse('(define x 5)')
      @parser.parse('(define y x)')
      expect(@parser.parse('x')).to eq '5'
      expect(@parser.parse('y')).to eq '5'
    end

    it 'can use variables in functions' do
      @parser.parse('(define x 5)')
      @parser.parse('(define y x)')
      expect(@parser.parse('(+ x y)')).to eq 10
      expect(@parser.parse('(- x y)')).to eq 0
      expect(@parser.parse('(* x y)')).to eq 25
      expect(@parser.parse('(/ x y)')).to eq 1
    end
  end
end
