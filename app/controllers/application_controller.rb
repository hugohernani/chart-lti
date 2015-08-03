# require 'canvas/lib/canvasclient'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    render text: "hello, world"
  end

  def oauthDance(canvas_host, client_id, secret_key)
    @canvas_host = canvas_host
    @canvas_api_access = Canvas::API.new(:host => canvas_host, :client_id => client_id, :secret => secret_key)
    host = request.scheme + "://" + request.host_with_port
    url = host + "/oauth_success"
    puts "url from oauthDance: " + url
    oauth_url = @canvas_api_access.oauth_url(url)
    puts "oauth url: " + oauth_url
    redirect_to(URI.unescape(oauth_url)) and return
  end

  def oauth_success
    canvas = @canvas_api_access
    code = params['code']
    puts "code: " + code.to_s
    host = request.scheme + "://" + request.host_with_port
    url = host + "/oauth_success"
    puts "Url from oauth_success: " + url
    @access_token = canvas.retrieve_access_token(code, url)
    if not @access_token.nil?
      host = request.scheme + "://" + request.host_with_port
      api_root_url = host + "api/v1"
      render text: "Token acquired: " + @access_token
      # @my_canvas = CanvasClient.new(@access_token, api_root_url)
      # @my_canvas.user(1).get_courses()
    else
      render text: "Token not acquired."
    end
  end

  def initialize_api
    canvas_host = params["canvas_host"]
    client_id = params["client_id"]
    secret_key = params["secret_key"]

    oauthDance(canvas_host, client_id, secret_key)
  end
end
