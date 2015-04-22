require "rack"
require "rack/rewrite"
require "pry"

d = Rack::Directory.new Dir.new 'build/'


wrapped = Rack::Builder.new do
  map "/cider-ci/documentation" do
    run d
  end
end

#use Rack::Rewrite do
#  rewrite %r{.*}, '/cider-ci/documentation/$1'
#end


Rack::Handler::WEBrick.run wrapped, Port: 8887
