require 'erb'
require 'rack'
class ShowExceptions
  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    res = Rack::Response.new
    res.status = 500
    res['Content-type'] = "text/html"
    line_number = /\:\d+/.match(e.backtrace.to_s)
    file_name = /[\w|\/|\-|\_]+\/\w+\.rb/.match(e.backtrace.to_s)
    name = File.expand_path("views/exception_helper.html.erb")
    output = ERB.new(File.read(name)).result(binding)
    res.write(output)
    res.finish
  end

end
