require 'rack'
require_relative 'router/lib/router.rb'
require_relative 'router/lib/controller_base.rb'
require_relative 'router/lib/show_exceptions.rb'
require_relative '99Cats/controllers/cat_controller.rb'




router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/(?<cat_id>\\d+)$"), CatsController, :show
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
