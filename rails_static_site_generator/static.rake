require_relative '../../config/environment.rb' # init rails app

# --- conf ---------------------------------------------------------------------
PATHS = {
  'root'  => false,
  'pages' => false,
  'page'  => Proc.new { Page.all.map { |page| {id: page.id} } }, # record ids to fetch for this path
}
OUT_PATH = Rails.root.join( 'public' ).to_s
# ------------------------------------------------------------------------------

app = ActionDispatch::Integration::Session.new Rails.application
app.get '/' # necessary for init

include Rails.application.routes.url_helpers # route helpers

ApplicationController.class_eval do
  after_action :staticize

  def staticize # write rails output to file
    path = OUT_PATH + request.env['PATH_INFO']
    FileUtils.mkdir_p path
    pathname = Pathname.new( path )
    File.open( pathname.join( 'index.html' ), 'w' ) do |file|
      file.puts response.body
    end
  end
end

## Another way: making requests
# HOST = 'localhost'
# PORT = 3000
# def make_request( path )
#   req = Net::HTTP::Get.new( path )
#   res = Net::HTTP.start( HOST, PORT ) do |http|
#     http.request( req )
#   end
# end

namespace :static do
  task :generate_all, [:only] => :environment do |t, args|
    only = args[:only] ? args[:only] : false
    ignore = %w(rails_info_properties rails_info_routes rails_info rails_mailers)
    Rails.application.routes.routes.each do |route|
      next if route.verb != 'GET' || route.name.nil? # consider GET routes
      paths = only ? {"#{only}" => PATHS[only]} : PATHS # filter paths if required
      if paths.include? route.name
        puts '+ Gen ' + ( route.name ? route.name : '' ) + ' => ' + route.path.spec.to_s
        parts = route.parts.dup
        parts.delete :format
        # paths could be used also to generate a sitemap
        if paths[route.name]
          paths[route.name].call.each do |params|
            path = eval( route.name + "_path( #{params} )" )
            # make_request path
            app.get path
          end
        else
          path = eval( route.name + '_path' )
          # make_request path
          app.get path
        end
      elsif !ignore.include?( route.name ) && !route.path.spec.to_s.starts_with?( '/rails/' ) # ignore rails dev routes
        puts '- Skip ' + ( route.name ? route.name : '' ) + ' => ' + route.path.spec.to_s
      end
    end
  end

  task :generate, [:route, :key, :id] => :environment do |t, args|
    if args[:route] && args[:key] && args[:id]
      route = args[:route]
      key = args[:key]
      id = args[:id]
      # p route, key, id
      if PATHS[route]
        path = eval( route + "_path( #{key}: #{id} )" )
        app.get path
        puts path
      end
    end
  end
end
