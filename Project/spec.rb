load 'parser.rb'

RSpec.describe 'LispInterpreter' do
  before do
    @parser = Parser.new
  end

  describe 'Literals' do
    it 'can parse integers' do
      expect(@parser.parse('1')).to eq '1'
      expect(@parser.parse('5')).to eq '5'
    end

    it 'can parse floats' do
      expect(@parser.parse('1.5')).to eq '1.5'
      expect(@parser.parse('0.99')).to eq '0.99'
    end

    it 'can parse strings' do
      expect(@parser.parse('"Sample"')).to eq '"Sample"'
      expect(@parser.parse('"Hello world"')).to eq '"Hello world"'
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

    it 'sums with variables' do
      @parser.parse('(define x 5)')
      @parser.parse('(define y 0.999)')
      expect(@parser.parse('(+ 1 x)')).to eq 6
      expect(@parser.parse('(+ 1 y)')).to eq 1.999
      expect(@parser.parse('(+ x y)')).to eq 5.999
    end
  end

  describe '-' do
    it 'subtracts with no arguments' do
      # TODO expect(@parser.parse('(-)')).to eq 0
    end

    it 'subtracts with single argument' do
      expect(@parser.parse('(- 1)')).to be '-1'.to_i
      expect(@parser.parse('(- 5.0)')).to eq '-5.0'.to_f
    end

    it 'subtracts with multiple arguments' do
      expect(@parser.parse('(- 1 2)')).to eq '-1'.to_i
      expect(@parser.parse('(- 1 2 0.0)')).to eq '-1.0'.to_f
      expect(@parser.parse('(- 1 2 3 4 5)')).to eq '-13'.to_i
      expect(@parser.parse('(- -1 2 3 4 5)')).to eq '-15'.to_i
    end

    it 'subtracts with functions as argument' do
      expect(@parser.parse('(- 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq '-13'.to_i
      expect(@parser.parse('(- 1.2 (*) (+))')).to eq 0.19999999999999996
      expect(@parser.parse('(- (length (list 1 2)))')).to eq '-2'.to_i
    end

    it 'subtracts with variables' do
      @parser.parse('(define x 5)')
      @parser.parse('(define y 0.999)')
      expect(@parser.parse('(- 1 x)')).to eq '-4'.to_i
      expect(@parser.parse('(- 1 y)')).to eq 0.0010000000000000009
      expect(@parser.parse('(- x y)')).to eq 4.001
    end
  end

  describe '*' do
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

    it 'can multiply with variables' do
      @parser.parse('(define x 5)')
      @parser.parse('(define y 0.999)')
      expect(@parser.parse('(* 1 x)')).to eq 5
      expect(@parser.parse('(* 1 y)')).to eq 0.999
      expect(@parser.parse('(* x y)')).to eq 4.995
    end
  end

  describe '/' do
    it 'throws ZeroDivisionError' do
      # expect(@parser.parse('(/ 0)')).to eq 0
      # expect(@parser.parse('(/ 1 0)')).to eq 0
    end

    it 'divides with no arguments' do
      # expect(@parser.parse('(/)')).to eq 0
    end

    it 'divides with single argument' do
      expect(@parser.parse('(/ 1)')).to eq 1
      expect(@parser.parse('(/ 10.0)')).to eq 0.1
    end

    it 'divides with multiple arguments' do
      expect(@parser.parse('(/ 81 3.0)')).to eq 27.0
      expect(@parser.parse('(/ 81 3 3 3)')).to eq 3
      expect(@parser.parse('(/ 1 2 3 4 5)')).to eq 0.008333333333333333
    end

    it 'divides with functions as argument' do
      expect(@parser.parse('(/ 1 (+ 2) (+ 2 1))')).to eq 0.16666666666666666
      expect(@parser.parse('(/ (* 0.33 6) (/ 22 7))')).to eq 0.63
      expect(@parser.parse('(/ (length (list 1 2)))')).to eq 0.5
    end

    it 'can divide with variables' do
      @parser.parse('(define x 5)')
      @parser.parse('(define y 0.999)')
      expect(@parser.parse('(/ 1 x)')).to eq 0.2
      expect(@parser.parse('(/ 1 y)')).to eq 1.001001001001001
      expect(@parser.parse('(/ x y)')).to eq 5.005005005005005
    end
  end
end
