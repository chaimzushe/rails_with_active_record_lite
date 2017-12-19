require 'rack'
require_relative 'router/lib/router.rb'
require_relative 'router/lib/controller_base.rb'
require_relative 'router/lib/show_exceptions.rb'
require_relative '99Cats/controllers/cat_controller.rb'




router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  get Regexp.new("^/cats/new$"), CatsController, :new
  post Regexp.new("^/cats/create$"), CatsController, :create
end


app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use ShowExceptions
  run app
end.to_app

  Rack::Server.start(
      app: app,
      Port: 3000
  )
