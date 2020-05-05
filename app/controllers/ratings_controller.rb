class RatingsController < ApplicationController
  
  def index
    @rating = Rating.all
  end

  def show
    @rating = Rating.find_by_id(params[:id])
  end
  #GET /ratings/new
  def new
    # require 'pry'
    # binding.pry
    @rating = Rating.new
  end

  #GET /ratings/1/edit
  def edit
  end

  def create

    @rating = Rating.new(rating_params)

    @rating.save
        redirect_to @rating
  end

  def update
  end

  private
    # def set_rating
    #   @rating = Rating.find(params[:id])
    # end
    #
    # def set_truck
    #   @truck = Truck.find(params[:truck_id])
    # end


    def rating_params
      params.require(:rating).permit(:rating, :comment)
    end

end
