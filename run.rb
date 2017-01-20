load 'parser.rb'
parser = Parser.new
loop do
  token = gets.chomp
  parser.read token
end
