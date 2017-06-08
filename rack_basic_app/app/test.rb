class Test
  def call( env )
    req = Rack::Request.new( env )
    case env['REQUEST_PATH']
    when '/'
      [ 200, { 'Content-Type' => 'text/html' }, [ 'Home!' ] ]
    else
      [ 404, { 'Content-Type' => 'text/html' }, [ 'This is not the page you are looking for...' ] ]
    end
  end
end
