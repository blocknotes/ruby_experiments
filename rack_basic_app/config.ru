#\ -p 3000
use Rack::Reloader, 0

Dir.glob('./app/**/*.rb').each { |f| require f }

# require './app/test.rb'

run Test.new
