require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params, :already_built_response

  # Setup the controller
  def initialize(req, res, route_params = {})
    @params = route_params.merge(req.params)
    @req = req
    @res = res
    @@protect_from_forgery ||= false
  end

  # Helper method to alias
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Already responded" if @already_built_response
    @res.status = 302
    @res['Location'] = url
    @already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
    nil
  end


  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Already rendered" if @already_built_response
    @res['Content-Type'] = content_type
    @res.write(content)
    @res.finish
    @already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
    nil
  end


  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore

    view = File.read("././99Cats/views/#{controller_name}/#{template_name}.html.erb")

    erb_view = ERB.new(view).result(binding)
    render_content(erb_view, 'text/html')
  end


  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # method exposing a `Flash` object
  def flash
    @flash ||= Flash.new(req)
  end



  def invoke_action(name)
    if protect_from_forgery? && req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end
    self.send(name)
    render(name) unless already_built_response?
    nil
  end

  def form_authenticity_token
    @token ||= generate_authenticity_token
    res.set_cookie('authenticity_token', value: @token, path: '/')
    @token
  end

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  def protect_from_forgery?
    @@protect_from_forgery
  end

  def check_authenticity_token
    cookie = @req.cookies["authenticity_token"]
    unless cookie && cookie == params["authenticity_token"]
      raise "Invalid authenticity token"
    end
  end

  def generate_authenticity_token
    SecureRandom.urlsafe_base64(16)
  end

end
