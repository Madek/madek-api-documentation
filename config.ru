require "rubygems"
require "middleman-core/load_paths"
require "rack/rewrite"
require "pry"

Middleman.setup_load_paths

require "middleman-core"
require "middleman-core/preview_server"

module Middleman::PreviewServer
  def self.preview_in_rack
    @options = {port: 8887}
    @app = new_app
    start_file_watcher
  end
end

Middleman::PreviewServer.preview_in_rack
app= Middleman::PreviewServer.app.class.to_rack_app path_prefix: "/blah"


wrapped = Rack::Builder.new do
  map "/blah" do
    run app
  end
end

use Rack::Rewrite do
  rewrite %r{.*}, '/blah/$1'
end

Rack::Handler::WEBrick.run app, Port: 8887
