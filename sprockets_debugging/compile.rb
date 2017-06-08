require Dir.pwd + '/config/environment' # exec from a Rails root

puts "env: #{Rails.env}"

Rails.application.assets.each_file do |f|
  if f.end_with?( '.js' )
    puts " -> #{f}"
    begin
      Uglifier.compile( File.read( f ), mangle_properties: { debug: true } )
    rescue Exception => e
      puts e.message
    end
  end
end
