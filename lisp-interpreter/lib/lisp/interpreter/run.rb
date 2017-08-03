require_relative 'parser'

parser = Parser.new Environment::PROD
parser.run
