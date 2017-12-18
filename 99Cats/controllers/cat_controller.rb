require 'require_all'

require_all './././router'

class CatsController < ControllerBase
  def index
    render :index
  end

  def show
    render :show
  end
end
