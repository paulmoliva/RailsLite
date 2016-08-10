require 'byebug'
require 'rack'
class Static
  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    path = env["PATH_INFO"]
    serve_asset(path) || app.call(env)
  end

  private
  def serve_asset(path)
    return nil unless path =~ /^\/public/
    res = Rack::Response.new
    dir = File.expand_path(__FILE__)
    project_root = /([\/|\w|\-\_]+)\/lib/.match(dir)[1].to_s
    name = File.expand_path(path)
    begin
      file = File.read(project_root + name)
      res.status = 200
      res["Content-Type"] = "text/plain"
      res.write(file)
    rescue
      res.status = 404
    ensure
      res.finish
    end
    res.finish
  end
end
