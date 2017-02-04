RSpec.describe 'Parser' do
  before do
    @parser = Parser.new
  end

  describe '#numbers' do
# todo for variables
    context 'sum' do
      it 'sums with one number' do
        expect(@parser.read('(+ 1)')).to eq 1
        expect(@parser.read('(+ 0)')).to eq 0
      end

      it 'sums with two numbers' do
        expect(@parser.read('(+ 1 2)')).to eq 3
        expect(@parser.read('(+ 1 0)')).to eq 1
      end

      it 'sums with more than two numbers' do
        expect(@parser.read('(+ 1 2 3)')).to eq 6
        expect(@parser.read('(+ 1 2 3 4 5)')).to eq 15
      end

      it 'can sum with other functions' do
        expect(@parser.read('(+ 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 15
        expect(@parser.read('(+ (+ (+ 1 0) 1) (+ 1 0))')).to eq 3
      end
    end

    context 'subtract' do
      it 'subtracts with one number' do
        expect(@parser.read('(- 1)')).to eq 1
      end

      it 'subtacts with two numbers' do
        expect(@parser.read('(- 1 2)')).to eq -1
        expect(@parser.read('(- 1 0)')).to eq 1
      end

      it 'subtracts with more than two numbers' do
        expect(@parser.read('(- 1 2 3)')).to eq -4
        expect(@parser.read('(- 1 2 3 4 5)')).to eq -13
      end

      it 'can subtract with other functions' do
        expect(@parser.read('(- 1 (- 2 0) (- 2 1) (- 2 2) 5)')).to eq -7
        expect(@parser.read('(- (- (- 1 0) 1) (- 1 0))')).to eq -1
      end
    end

    context 'multiply' do
      it 'multiplies with one number' do
        expect(@parser.read('(* 1)')).to eq 0
      end

      it 'multiplies with two numbers' do
        expect(@parser.read('(* 1 2)')).to eq 2
        expect(@parser.read('(* 1 0)')).to eq 0
      end

      it 'multiplies with more than two numbers' do
        expect(@parser.read('(* 1 2 3)')).to eq 6
        expect(@parser.read('(* 1 2 3 4 5)')).to eq 120
      end

      it 'can multiply with other functions' do
        expect(@parser.read('(* 1 (* 2 1) (* 2 1) (* 2 2) 5)')).to eq 80
        expect(@parser.read('(* (* (* 1 0) 1) (* 1 0))')).to eq 0
      end
    end

    context 'devide' do
      it 'devides with one number' do
        expect(@parser.read('(/ 1)')).to eq '+inf.0'
      end

      it 'devides with two numbers' do
        expect(@parser.read('(/ 1 2)')).to eq 0.5
        expect(@parser.read('(/ 1 0)')).to eq '+inf.0'
      end

      it 'devides with more than two numbers' do
        expect(@parser.read('(/ 1 2 3)')).to eq 0.16666666666666666
      expect(@parser.read('(/ 1 2 3 4 5)')).to eq 0.008333333333333333
      end

      it 'can devide with other functions' do
        expect(@parser.read('(/ 1 (/ 2 1) (/ 2 1) (/ 2 2) 5)')).to eq 0.05
      end
    end

    it 'divide numbers' do
      expect(@parser.read('(/ 1 2)')).to eq 0.5
      expect(@parser.read('(/ 1 0)')).to eq '+inf.0'
      expect(@parser.read('(/ 1 2 3)')).to eq 0.16666666666666666
      expect(@parser.read('(/ 1 2 3 4 5)')).to eq 0.008333333333333333
      expect(@parser.read('(/ 1 (/ 2 1) (/ 2 1) (/ 2 2) 5)')).to eq 0.05
      #expect(@parser.read('(/ (/ (/ 1 2) 1) (/ 1 2))')).to eq 1
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
end
