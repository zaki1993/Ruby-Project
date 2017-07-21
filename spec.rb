load 'parser.rb'
RSpec.describe 'Parser' do
  before do
    @parser = Parser.new
  end

  describe '#numbers' do
    context 'sum' do
      it 'sums with one number' do
        expect(@parser.read('(+ 1)')).to eq 1
        expect(@parser.read('(+ 0)')).to eq 0
        expect(@parser.read('(+ 1.0)')).to eq 1
        expect(@parser.read('(+ 0.0)')).to eq 0
        expect(@parser.read('(+ 0.99)')).to eq 0.99
      end

      it 'sums with two numbers' do
        expect(@parser.read('(+ 1 2)')).to eq 3
        expect(@parser.read('(+ 1 0)')).to eq 1
        expect(@parser.read('(+ 1 1.5)')).to eq 2.5
        expect(@parser.read('(+ 1.5 1)')).to eq 2.5
        expect(@parser.read('(+ 1.5 1.5)')).to eq 3
      end

      it 'sums with more than two numbers' do
        expect(@parser.read('(+ 1 2 3)')).to eq 6
        expect(@parser.read('(+ 1 2 3 4 5)')).to eq 15
        expect(@parser.read('(+ 1 2 3 4.5 4.5)')).to eq 15
      end

      it 'can sum with other functions' do
        expect(@parser.read('(+ 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 15
        expect(@parser.read('(+ (+ (+ 1 0) 1) (+ 1 0))')).to eq 3
        expect(@parser.read('(+ (+ (+ 1 0.0) 1) (+ 1.0 0))')).to eq 3
      end
    end

    context 'subtract' do
      it 'subtracts with one number' do
        expect(@parser.read('(- 1)')).to eq 1
        expect(@parser.read('(- 0)')).to eq 0
        expect(@parser.read('(- 1.0)')).to eq 1
        expect(@parser.read('(- 0.0)')).to eq 0
        expect(@parser.read('(- 0.99)')).to eq 0.99
      end

      it 'subtacts with two numbers' do
        expect(@parser.read('(- 1 2)')).to eq -1
        expect(@parser.read('(- 1 0)')).to eq 1
        expect(@parser.read('(- 1 1.5)')).to eq -0.5
        expect(@parser.read('(- 1.5 1)')).to eq 0.5
        expect(@parser.read('(- 1.5 1.5)')).to eq 0
      end

      it 'subtracts with more than two numbers' do
        expect(@parser.read('(- 1 2 3)')).to eq -4
        expect(@parser.read('(- 1 2 3 4 5)')).to eq -13
        expect(@parser.read('(- 1 2 3 4.5 4.5)')).to eq -13
      end

      it 'can subtract with other functions' do
        expect(@parser.read('(- 1 (- 2 0) (- 2 1) (- 2 2) 5)')).to eq -7
        expect(@parser.read('(- (- (- 1 0) 1) (- 1 0))')).to eq -1
        expect(@parser.read('(- (- (- 1 0.0) 1) (- 1.0 0))')).to eq -1
      end
    end

    context 'multiply' do
      it 'multiplies with one number' do
        expect(@parser.read('(* 1)')).to eq 1
        expect(@parser.read('(* 0)')).to eq 0
        expect(@parser.read('(* 1.0)')).to eq 1
        expect(@parser.read('(* 0.0)')).to eq 0
        expect(@parser.read('(* 0.99)')).to eq 0.99
      end

      it 'multiplies with two numbers' do
        expect(@parser.read('(* 1 2)')).to eq 2
        expect(@parser.read('(* 1 0)')).to eq 0
        expect(@parser.read('(* 1 1.5)')).to eq 1.5
        expect(@parser.read('(* 1.5 1)')).to eq 1.5
        expect(@parser.read('(* 1.5 1.5)')).to eq 2.25
      end

      it 'multiplies with more than two numbers' do
        expect(@parser.read('(* 1 2 3)')).to eq 6
        expect(@parser.read('(* 1 2 3 4 5)')).to eq 120
        expect(@parser.read('(* 1 2 3 4.5 4.5)')).to eq 121.5
        expect(@parser.read('(* 1.0 1 3.1)')).to eq 3.1
      end

      it 'can multiply with other functions' do
        expect(@parser.read('(* 1 (* 2 1) (* 2 1) (* 2 2) 5)')).to eq 80
        expect(@parser.read('(* (* (* 1 0) 1) (* 1 0))')).to eq 0
        expect(@parser.read('(* (* (* 1 2) 1) (* 1 2.1))')).to eq 4.2
      end
    end

    context 'devide' do
      it 'devides with one number' do
        expect(@parser.read('(/ 1)')).to eq 1
        expect(@parser.read('(/ 0)')).to eq 0
        expect(@parser.read('(/ 0.99)')).to eq 0.99
        expect(@parser.read('(/ 1.99)')).to eq 1.99
      end

      it 'devides with two numbers' do
        expect(@parser.read('(/ 1 2)')).to eq 0.5
        expect(@parser.read('(/ 1 0)')).to eq '+inf.0'
        expect(@parser.read('(/ 1 1.5)')).to eq 0.6666666666666666
        expect(@parser.read('(/ 1.5 1)')).to eq 1.5
        expect(@parser.read('(/ 1.5 1.5)')).to eq 1
      end

      it 'devides with more than two numbers' do
        expect(@parser.read('(/ 1 2 3)')).to eq 0.16666666666666666
        expect(@parser.read('(/ 1 2 3 4 5)')).to eq 0.008333333333333333
        expect(@parser.read('(/ 1 2 3 4.0 5.0)')).to eq 0.008333333333333333
        expect(@parser.read('(/ 1 2 3.0)')).to eq 0.16666666666666666
        expect(@parser.read('(/ 1.0 1 3.1)')).to eq 0.3225806451612903
      end

      it 'can devide with other functions' do
        expect(@parser.read('(/ 1 (/ 2 1) (/ 2 1) (/ 2 2) 5)')).to eq 0.05
        expect(@parser.read('(/ (/ (/ 1 2) 1) (/ 1 2.1))')).to eq 1.05
      end
    end
  end

  describe '#strings' do
    context 'can find the length of the string' do
      it 'can find the length of the string' do
        expect(@parser.read('(string-length "sample-string")')).to eq 13
        expect(@parser.read('(string-length "ruby rlz")')).to eq 8
      end
    end

    context 'can get substring' do
      it 'can get substring' do
        expect(@parser.read('(substring "sample" 1 5)')).to eq 'ampl'
        expect(@parser.read('(substring "sample" 0)')).to eq 'sample'
        expect(@parser.read('(substring "sample" 0 4)')).to eq 'samp'
        expect(@parser.read('(substring "sample" 0 0)')).to eq ''
      end
    end

    context 'can convert string to upcase' do
      it 'can convert string to upcase' do
        expect(@parser.read('(string-upcase "sample")')).to eq 'SAMPLE'
        expect(@parser.read('(string-upcase "SaMpLe")')).to eq 'SAMPLE'
      end
    end

    context 'can convert string to downcase' do
      it 'can convert string to downcase' do
        expect(@parser.read('(string-downcase "SAMPLE")')).to eq 'sample'
        expect(@parser.read('(string-downcase "SaMpLe")')).to eq 'sample'
      end
    end

    context 'can convert string to list' do
      it 'can convert string to list' do
        result = '\'(#\S #\A #\M #\P #\L #\E) '
        expect(@parser.read('(string->list "SAMPLE")')).to eq result
      end
    end

    context 'can split string' do
      it 'can split string' do
        result = '\'("Hello" "world")'
        expect(@parser.read('(string-split "Hello world")')).to eq result
      end
    end

    context 'checks if string contains substring' do
      it 'checks if string contains substring' do
        expect(@parser.read('(string-contains? "Sample" "amp")')).to eq '#t'
        expect(@parser.read('(string-contains? "Sample" "lee")')).to eq '#f'
        expect(@parser.read('(string-contains? "Sam" "Sam")')).to eq '#t'
        expect(@parser.read('(string-contains? "Sam" "sam")')).to eq '#f'
      end
    end

    context 'checks if literal is string' do
      it 'checks with string' do
        expect(@parser.read('(string? "Sample")')).to eq '#t'
        expect(@parser.read('(string? "123")')).to eq '#t'
      end

      it 'checks with number' do
        expect(@parser.read('(string? 123)')).to eq '#f'
      end

      it 'checks with symbol' do
        expect(@parser.read('(string? \'Sample)')).to eq '#f'
      end

      it 'checks with list' do
        expect(@parser.read('(string? \'(1 2))')).to eq '#f'
      end

      it 'checks with boolean' do
        expect(@parser.read('(string? #t)')).to eq '#f'
      end
    end

    context 'can compare strings' do
      it 'can compare with =' do
        expect(@parser.read('(string=? "asd" "asd")')).to eq '#t'
        expect(@parser.read('(string=? "asd" "asdd")')).to eq '#f'
      end

      it 'can compare with <' do
        expect(@parser.read('(string<? "asd" "bsd")')).to eq '#t'
        expect(@parser.read('(string<? "asd" "asd")')).to eq '#f'
      end

      it 'can compare with >' do
        expect(@parser.read('(string>? "bsd" "asd")')).to eq '#t'
        expect(@parser.read('(string>? "asd" "asd")')).to eq '#f'
      end

      it 'can compare with >=' do
        expect(@parser.read('(string>=? "asd" "asd")')).to eq '#t'
        expect(@parser.read('(string>=? "asd" "bsd")')).to eq '#f'
      end

      it 'can compare with <=' do
        expect(@parser.read('(string<=? "asd" "asd")')).to eq '#t'
        expect(@parser.read('(string<=? "asd" "bsd")')).to eq '#t'
      end
    end
  end

  describe '#if_operator' do
    it 'can use if with single value' do
      expect(@parser.read('(if #t #t #f)')).to eq '#t'
      expect(@parser.read('(if #f #t #f)')).to eq '#f'
      expect(@parser.read('(if #t "Pesho" "Gosho")')).to eq 'Pesho'
      expect(@parser.read('(if #f "Pesho" "Gosho")')).to eq 'Gosho'
      expect(@parser.read('(if #t 1 2)')).to eq 1
      expect(@parser.read('(if #f 1 2)')).to eq 2
    end

    it 'can use if with functions statement' do
      expect(@parser.read('(if (< 2 3) #t #f)')).to eq '#t'
      expect(@parser.read('(if (not #t) #t #f)')).to eq '#f'
      expect(@parser.read('(if (not (not #t)) "Pesho" "Gosho")')).to eq 'Pesho'
      expect(@parser.read('(if (not (< 2 3)) "Pesho" "Gosho")')).to eq 'Gosho'
      expect(@parser.read('(if (not #f) 1 2)')).to eq 1
      expect(@parser.read('(if (= 5 5) 1 2)')).to eq 1
    end

    it 'can use if with functions results' do
      expect(@parser.read('(if (< 2 3) (not #f) #f)')).to eq '#t'
      expect(@parser.read('(if (not #t) #t (not #t))')).to eq '#f'
      expect(@parser.read('(if #t (substring "Pesho" 0) 1)')).to eq 'Pesho'
      expect(@parser.read('(if #f 1 (substring "Gosho" 0))')).to eq 'Gosho'
      expect(@parser.read('(if (not #f) (+ 1 0) 2)')).to eq 1
      expect(@parser.read('(if (= 5 5) (+ 0.5 0.5) 2)')).to eq 1
    end
  end

  describe '#display_values' do
    it 'can display numbers' do
      expect(@parser.read('1')).to eq 1
      expect(@parser.read('1.5')).to eq 1.5
    end

    it 'can display booleans' do
      expect(@parser.read('#t')).to eq '#t'
      expect(@parser.read('#f')).to eq '#f'
    end

    it 'can display strings' do
      expect(@parser.read('"Sample"')).to eq 'Sample'
      expect(@parser.read('"Gosho"')).to eq 'Gosho'
    end

    it 'can display lists' do
      expect(@parser.read('(list 1 2)')).to eq '\'(1 2)'
      expect(@parser.read('\'()')).to eq '\'()'
      expect(@parser.read('\'(1 2)')).to eq '\'(1 2)'
    end

    it 'can display cons' do
      expect(@parser.read('(cons 1 2)')).to eq '(1 . 2)'
      expect(@parser.read('(cons 1 2 3)')).to eq '(1  2 . 3)'
      expect(@parser.read('(cons 1 \'())')).to eq '\'(1)'
    end
  end

  describe '#variables' do
    it 'can define variable' do
      @parser.read('(define x 5)')
      @parser.read('(define y x)')
      expect(@parser.read('x')).to eq '5'
      expect(@parser.read('y')).to eq '5'
    end

    it 'can use variables in functions' do
      @parser.read('(define x 5)')
      @parser.read('(define y x)')
      expect(@parser.read('(+ x y)')).to eq 10
      expect(@parser.read('(- x y)')).to eq 0
      expect(@parser.read('(* x y)')).to eq 25
      expect(@parser.read('(/ x y)')).to eq 1
    end
  end
end
