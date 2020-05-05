class TagsController < ApplicationController
  def index
    @tags = Tag.all
  end

  def show
    @tag = Tag.find_by_id(params[:id])
    @trucks = FoodTruck.tagged_with(@tag)
  end
end
