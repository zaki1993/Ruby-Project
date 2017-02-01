RSpec.describe 'Parser' do
  before do
    @parser = Parser.new
  end

  it 'sum numbers' do
    expect(@parser.read('(+ 1 2)')).to eq 3
    expect(@parser.read('(+ 1 0)')).to eq 1
    expect(@parser.read('(+ 1 2 3)')).to eq 6
    expect(@parser.read('(+ 1 2 3 4 5)')).to eq 15
    expect(@parser.read('(+ 1 (+ 2 0) (+ 2 1) (+ 2 2) 5)')).to eq 15
    expect(@parser.read('(+ (+ (+ 1 0) 1) (+ 1 0))')).to eq 3
  end

  it 'subtract numbers' do
    expect(@parser.read('(- 1 2)')).to eq '-1'
    expect(@parser.read('(- 1 0)')).to eq 1
    expect(@parser.read('(- 1 2 3)')).to eq '-4'
    expect(@parser.read('(- 1 2 3 4 5)')).to eq '-13'
    expect(@parser.read('(- 1 (- 2 0) (- 2 1) (- 2 2) 5)')).to eq '-7'
    expect(@parser.read('(- (- (- 1 0) 1) (- 1 0))')).to eq '-1'
  end

  it 'multiply numbers' do

  end

  it 'divide numbers' do

  end
end
