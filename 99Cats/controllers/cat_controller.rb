require 'require_all'

require_all './././router'
require_relative './cat.rb'



class CatsController < ControllerBase
  def index
    $cats = Cat.all
    render :index
  end

  def show
    render :show
  end
end
