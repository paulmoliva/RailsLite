require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
Dir["/ActiveRecordLite/*.rb"].each {|file| require file }
require 'byebug'
class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = params
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'double render' if already_built_response?
    @res['location']=(url)
    @res.status = 302
    @already_built_response = true
    session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'double render' if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    @already_built_response = true
    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    loc = File.dirname(__FILE__)
    loc = loc.split('/')[0..-2].join('/')
    loc += "/views/"
    loc += self.class.name.match(/^[A-Z][a-z]+/).to_s.downcase
    loc += '_controller/'
    template_content = File.read(loc + template_name.to_s + '.html.erb')
    template_content = ERB.new(template_content)
    render_content(template_content.result(binding), 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    check_authenticity_token if req.request_method != 'GET' && @@authenticate
    render(name) unless already_built_response?
  end

  def form_authenticity_token
    cookie = req.cookies["authenticity_token"]
    if cookie
      @token = JSON.parse(cookie)
    else
      @token ||= {token: SecureRandom.urlsafe_base64(8)}
      res.set_cookie("authenticity_token", JSON.generate(@token))
    end
    JSON.generate(@token)
  end

  def check_authenticity_token
    raise 'Invalid authenticity token' unless self.params["authenticity_token"]
    cookie = req.env['HTTP_COOKIE'].split('=').last
    raise 'Invalid authenticity token' unless self.params["authenticity_token"] == cookie
  end

  def self.protect_from_forgery
    @@authenticate = true
  end
end
