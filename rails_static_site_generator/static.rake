require_relative '../../config/environment.rb' # init rails app

# --- conf ---------------------------------------------------------------------
PATHS = {
  'root'  => false,
  'pages' => false,
  'new_page' => false,
  'page'  => Proc.new { Page.all.map { |page| {id: page.id} } }, # record ids to fetch for this path
}
OUT_PATH = Rails.root.join( 'out' ).to_s
# ------------------------------------------------------------------------------

def staticize( path_rel, body )
  path = OUT_PATH + path_rel
  FileUtils.mkdir_p path
  pathname = Pathname.new( path ).join( 'index.html' )
  File.open( pathname, 'w' ) do |file|
    file.puts body
  end
end

namespace :static do
  task :generate_all, [:only] => :environment do |t, args|
    only = args[:only] ? args[:only] : false
    ignore = %w(rails_info_properties rails_info_routes rails_info rails_mailers)
    app = ActionDispatch::Integration::Session.new Rails.application
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
            path = eval( "Rails.application.routes.url_helpers.#{route.name}_path( #{params} )" )
            # make_request path
            staticize path, app.body if app.get( path ) == 200
          end
        else
          path = eval( "Rails.application.routes.url_helpers.#{route.name}_path" )
          # make_request path
          staticize path, app.body if app.get( path ) == 200
        end
      elsif !ignore.include?( route.name ) && !route.path.spec.to_s.starts_with?( '/rails/' ) # ignore rails dev routes
        puts '- Skip ' + ( route.name ? route.name : '' ) + ' => ' + route.path.spec.to_s
      end
    end
  end

  task :generate, [:route, :key, :id] => :environment do |t, args|
    if args[:route] && args[:key] && args[:id]
      app = ActionDispatch::Integration::Session.new Rails.application
      route = args[:route]
      key = args[:key]
      id = args[:id]
      if PATHS[route]
        path = eval( "Rails.application.routes.url_helpers.#{route}_path( #{key}: #{id} )" )
        staticize path, app.body if app.get( path ) == 200
      end
    end
  end
end
