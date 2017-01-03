load 'parser.rb'
parser = Parser.new
while true
token = gets.chomp
parser.read token
end
