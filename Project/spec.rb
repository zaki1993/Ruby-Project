load 'parser.rb'

RSpec.describe 'Parser' do
  before do
    @parser = Parser.new
  end

  describe '#scheme_numbers' do
    context 'arithmetic_function' do
      it 'calculates with no arguments' do
        expect(@parser.parse_token('(+)')).to eq 1
        expect(@parser.parse_token('(-)')).to eq 1
        expect(@parser.parse_token('(*)')).to eq 1
        expect(@parser.parse_token('(/)')).to eq 1
      end

      it 'sums with one number' do
        expect(@parser.parse_token('(+ 1)')).to eq 1
        expect(@parser.parse_token('(+ 0)')).to eq 0
        expect(@parser.parse_token('(+ 1.0)')).to eq 1
        expect(@parser.parse_token('(+ 0.0)')).to eq 0
        expect(@parser.parse_token('(+ 0.99)')).to eq 0.99
      end

      it 'sums with two numbers' do
        expect(@parser.parse_token('(+ 1 2)')).to eq 3
        expect(@parser.parse_token('(+ 1 0)')).to eq 1
        expect(@parser.parse_token('(+ 1 1.5)')).to eq 2.5
        expect(@parser.parse_token('(+ 1.5 1)')).to eq 2.5
        expect(@parser.parse_token('(+ 1.5 1.5)')).to eq 3
      end

      it 'sums with more than two numbers' do
        expect(@parser.parse_token('(+ 1 2 3)')).to eq 6
        expect(@parser.parse_token('(+ 1 2 3 4 5)')).to eq 15
        expect(@parser.parse_token('(+ 1 2 3 4.5 4.5)')).to eq 15
      end

      it 'can sum with other functions' do
        expect(@parser.parse_token('(+ 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 15
        expect(@parser.parse_token('(+ (+ (+ 1 0) 1) (+ 1 0))')).to eq 3
        expect(@parser.parse_token('(+ (+ (+ 1 0.0) 1) (+ 1.0 0))')).to eq 3
      end
    end

    context 'subtract' do
      it 'subtracts with one number' do
        expect(@parser.parse_token('(- 1)')).to eq 1
        expect(@parser.parse_token('(- 0)')).to eq 0
        expect(@parser.parse_token('(- 1.0)')).to eq 1
        expect(@parser.parse_token('(- 0.0)')).to eq 0
        expect(@parser.parse_token('(- 0.99)')).to eq 0.99
      end

      it 'subtacts with two numbers' do
        expect(@parser.parse_token('(- 1 2)')).to eq -1
        expect(@parser.parse_token('(- 1 0)')).to eq 1
        expect(@parser.parse_token('(- 1 1.5)')).to eq -0.5
        expect(@parser.parse_token('(- 1.5 1)')).to eq 0.5
        expect(@parser.parse_token('(- 1.5 1.5)')).to eq 0
      end

      it 'subtracts with more than two numbers' do
        expect(@parser.parse_token('(- 1 2 3)')).to eq -4
        expect(@parser.parse_token('(- 1 2 3 4 5)')).to eq -13
        expect(@parser.parse_token('(- 1 2 3 4.5 4.5)')).to eq -13
      end

      it 'can subtract with other functions' do
        expect(@parser.parse_token('(- 1 (- 2 0) (- 2 1) (- 2 2) 5)')).to eq -7
        expect(@parser.parse_token('(- (- (- 1 0) 1) (- 1 0))')).to eq -1
        expect(@parser.parse_token('(- (- (- 1 0.0) 1) (- 1.0 0))')).to eq -1
      end
    end

    context 'multiply' do
      it 'multiplies with one number' do
        expect(@parser.parse_token('(* 1)')).to eq 1
        expect(@parser.parse_token('(* 0)')).to eq 0
        expect(@parser.parse_token('(* 1.0)')).to eq 1
        expect(@parser.parse_token('(* 0.0)')).to eq 0
        expect(@parser.parse_token('(* 0.99)')).to eq 0.99
      end

      it 'multiplies with two numbers' do
        expect(@parser.parse_token('(* 1 2)')).to eq 2
        expect(@parser.parse_token('(* 1 0)')).to eq 0
        expect(@parser.parse_token('(* 1 1.5)')).to eq 1.5
        expect(@parser.parse_token('(* 1.5 1)')).to eq 1.5
        expect(@parser.parse_token('(* 1.5 1.5)')).to eq 2.25
      end

      it 'multiplies with more than two numbers' do
        expect(@parser.parse_token('(* 1 2 3)')).to eq 6
        expect(@parser.parse_token('(* 1 2 3 4 5)')).to eq 120
        expect(@parser.parse_token('(* 1 2 3 4.5 4.5)')).to eq 121.5
        expect(@parser.parse_token('(* 1.0 1 3.1)')).to eq 3.1
      end

      it 'can multiply with other functions' do
        expect(@parser.parse_token('(* 1 (* 2 1) (* 2 1) (* 2 2) 5)')).to eq 80
        expect(@parser.parse_token('(* (* (* 1 0) 1) (* 1 0))')).to eq 0
        expect(@parser.parse_token('(* (* (* 1 2) 1) (* 1 2.1))')).to eq 4.2
      end
    end

    context 'devide' do
      it 'devides with one number' do
        expect(@parser.parse_token('(/ 1)')).to eq 1
        expect(@parser.parse_token('(/ 0)')).to eq 0
        expect(@parser.parse_token('(/ 0.99)')).to eq 0.99
        expect(@parser.parse_token('(/ 1.99)')).to eq 1.99
      end

      it 'devides with two numbers' do
        expect(@parser.parse_token('(/ 1 2)')).to eq 0.5
        expect(@parser.parse_token('(/ 1 0)')).to eq '+inf.0'
        expect(@parser.parse_token('(/ 1 1.5)')).to eq 0.6666666666666666
        expect(@parser.parse_token('(/ 1.5 1)')).to eq 1.5
        expect(@parser.parse_token('(/ 1.5 1.5)')).to eq 1
      end

      it 'devides with more than two numbers' do
        expect(@parser.parse_token('(/ 1 2 3)')).to eq 0.16666666666666666
        expect(@parser.parse_token('(/ 1 2 3 4 5)')).to eq 0.008333333333333333
        expect(@parser.parse_token('(/ 1 2 3 4.0 5.0)')).to eq 0.008333333333333333
        expect(@parser.parse_token('(/ 1 2 3.0)')).to eq 0.16666666666666666
        expect(@parser.parse_token('(/ 1.0 1 3.1)')).to eq 0.3225806451612903
      end

      it 'can devide with other functions' do
        expect(@parser.parse_token('(/ 1 (/ 2 1) (/ 2 1) (/ 2 2) 5)')).to eq 0.05
        expect(@parser.parse_token('(/ (/ (/ 1 2) 1) (/ 1 2.1))')).to eq 1.05
      end
    end
  end

  describe '#strings' do
    context 'can find the length of the string' do
      it 'can find the length of the string' do
        expect(@parser.parse_token('(string-length "sample-string")')).to eq 13
        expect(@parser.parse_token('(string-length "ruby rlz")')).to eq 8
      end
    end

    context 'can get substring' do
      it 'can get substring' do
        expect(@parser.parse_token('(substring "sample" 1 5)')).to eq 'ampl'
        expect(@parser.parse_token('(substring "sample" 0)')).to eq 'sample'
        expect(@parser.parse_token('(substring "sample" 0 4)')).to eq 'samp'
        expect(@parser.parse_token('(substring "sample" 0 0)')).to eq ''
      end
    end

    context 'can convert string to upcase' do
      it 'can convert string to upcase' do
        expect(@parser.parse_token('(string-upcase "sample")')).to eq 'SAMPLE'
        expect(@parser.parse_token('(string-upcase "SaMpLe")')).to eq 'SAMPLE'
      end
    end

    context 'can convert string to downcase' do
      it 'can convert string to downcase' do
        expect(@parser.parse_token('(string-downcase "SAMPLE")')).to eq 'sample'
        expect(@parser.parse_token('(string-downcase "SaMpLe")')).to eq 'sample'
      end
    end

    context 'can convert string to list' do
      it 'can convert string to list' do
        result = '\'(#\S #\A #\M #\P #\L #\E) '
        expect(@parser.parse_token('(string->list "SAMPLE")')).to eq result
      end
    end

    context 'can split string' do
      it 'can split string' do
        result = '\'("Hello" "world")'
        expect(@parser.parse_token('(string-split "Hello world")')).to eq result
      end
    end

    context 'checks if string contains substring' do
      it 'checks if string contains substring' do
        expect(@parser.parse_token('(string-contains? "Sample" "amp")')).to eq '#t'
        expect(@parser.parse_token('(string-contains? "Sample" "lee")')).to eq '#f'
        expect(@parser.parse_token('(string-contains? "Sam" "Sam")')).to eq '#t'
        expect(@parser.parse_token('(string-contains? "Sam" "sam")')).to eq '#f'
      end
    end

    context 'checks if literal is string' do
      it 'checks with string' do
        expect(@parser.parse_token('(string? "Sample")')).to eq '#t'
        expect(@parser.parse_token('(string? "123")')).to eq '#t'
      end

      it 'checks with number' do
        expect(@parser.parse_token('(string? 123)')).to eq '#f'
      end

      it 'checks with symbol' do
        expect(@parser.parse_token('(string? \'Sample)')).to eq '#f'
      end

      it 'checks with list' do
        expect(@parser.parse_token('(string? \'(1 2))')).to eq '#f'
      end

      it 'checks with boolean' do
        expect(@parser.parse_token('(string? #t)')).to eq '#f'
      end
    end

    context 'can compare strings' do
      it 'can compare with =' do
        expect(@parser.parse_token('(string=? "asd" "asd")')).to eq '#t'
        expect(@parser.parse_token('(string=? "asd" "asdd")')).to eq '#f'
      end

      it 'can compare with <' do
        expect(@parser.parse_token('(string<? "asd" "bsd")')).to eq '#t'
        expect(@parser.parse_token('(string<? "asd" "asd")')).to eq '#f'
      end

      it 'can compare with >' do
        expect(@parser.parse_token('(string>? "bsd" "asd")')).to eq '#t'
        expect(@parser.parse_token('(string>? "asd" "asd")')).to eq '#f'
      end

      it 'can compare with >=' do
        expect(@parser.parse_token('(string>=? "asd" "asd")')).to eq '#t'
        expect(@parser.parse_token('(string>=? "asd" "bsd")')).to eq '#f'
      end

      it 'can compare with <=' do
        expect(@parser.parse_token('(string<=? "asd" "asd")')).to eq '#t'
        expect(@parser.parse_token('(string<=? "asd" "bsd")')).to eq '#t'
      end
    end
  end

  describe '#if_operator' do
    it 'can use if with single value' do
      expect(@parser.parse_token('(if #t #t #f)')).to eq '#t'
      expect(@parser.parse_token('(if #f #t #f)')).to eq '#f'
      expect(@parser.parse_token('(if #t "Pesho" "Gosho")')).to eq 'Pesho'
      expect(@parser.parse_token('(if #f "Pesho" "Gosho")')).to eq 'Gosho'
      expect(@parser.parse_token('(if #t 1 2)')).to eq 1
      expect(@parser.parse_token('(if #f 1 2)')).to eq 2
    end

    it 'can use if with functions statement' do
      expect(@parser.parse_token('(if (< 2 3) #t #f)')).to eq '#t'
      expect(@parser.parse_token('(if (not #t) #t #f)')).to eq '#f'
      expect(@parser.parse_token('(if (not (not #t)) "Pesho" "Gosho")')).to eq 'Pesho'
      expect(@parser.parse_token('(if (not (< 2 3)) "Pesho" "Gosho")')).to eq 'Gosho'
      expect(@parser.parse_token('(if (not #f) 1 2)')).to eq 1
      expect(@parser.parse_token('(if (= 5 5) 1 2)')).to eq 1
    end

    it 'can use if with functions results' do
      expect(@parser.parse_token('(if (< 2 3) (not #f) #f)')).to eq '#t'
      expect(@parser.parse_token('(if (not #t) #t (not #t))')).to eq '#f'
      expect(@parser.parse_token('(if #t (substring "Pesho" 0) 1)')).to eq 'Pesho'
      expect(@parser.parse_token('(if #f 1 (substring "Gosho" 0))')).to eq 'Gosho'
      expect(@parser.parse_token('(if (not #f) (+ 1 0) 2)')).to eq 1
      expect(@parser.parse_token('(if (= 5 5) (+ 0.5 0.5) 2)')).to eq 1
    end
  end

  describe '#display_values' do
    it 'can display numbers' do
      expect(@parser.parse_token('1')).to eq 1
      expect(@parser.parse_token('1.5')).to eq 1.5
    end

    it 'can display booleans' do
      expect(@parser.parse_token('#t')).to eq '#t'
      expect(@parser.parse_token('#f')).to eq '#f'
    end

    it 'can display strings' do
      expect(@parser.parse_token('"Sample"')).to eq 'Sample'
      expect(@parser.parse_token('"Gosho"')).to eq 'Gosho'
    end

    it 'can display lists' do
      expect(@parser.parse_token('(list 1 2)')).to eq '\'(1 2)'
      expect(@parser.parse_token('\'()')).to eq '\'()'
      expect(@parser.parse_token('\'(1 2)')).to eq '\'(1 2)'
    end

    it 'can display cons' do
      expect(@parser.parse_token('(cons 1 2)')).to eq '(1 . 2)'
      expect(@parser.parse_token('(cons 1 2 3)')).to eq '(1  2 . 3)'
      expect(@parser.parse_token('(cons 1 \'())')).to eq '\'(1)'
    end
  end

  describe '#variables' do
    it 'can define variable' do
      @parser.parse_token('(define x 5)')
      @parser.parse_token('(define y x)')
      expect(@parser.parse_token('x')).to eq '5'
      expect(@parser.parse_token('y')).to eq '5'
    end

    it 'can use variables in functions' do
      @parser.parse_token('(define x 5)')
      @parser.parse_token('(define y x)')
      expect(@parser.parse_token('(+ x y)')).to eq 10
      expect(@parser.parse_token('(- x y)')).to eq 0
      expect(@parser.parse_token('(* x y)')).to eq 25
      expect(@parser.parse_token('(/ x y)')).to eq 1
    end
  end
end
