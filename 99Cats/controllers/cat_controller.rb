require 'require_all'

require_all './././router'
require_relative './cat.rb'



class CatsController < ControllerBase
  def index
    $cats = Cat.all
    render :index
  end

  def show
     $show_cat = Cat.find(params["id"])
    render :show
  end

  def new

  end

  def create
    new_cat = Cat.new(params["cat"])

    if !new_cat.invalid_name?
      new_cat.save
      redirect_to "/cats"
    else
      flash[:errors] = new_cat.errors
      render :new
    end
  end

  def edit
    $edit_cat = Cat.find(params["id"])
    render :edit
  end

  def update
    $edit_cat.name = params['cat']['name']

    if !$edit_cat.invalid_name?
      $edit_cat.save
      redirect_to "/cats/#{$edit_cat.id}"
    else
      flash[:errors] = new_cat.errors
      render :edit
    end
  end

  def destroy
    cat = Cat.find(params["id"])
    flash[:errors] = ["Sorry delete not yet implemented"]
    render :show
  end


end
