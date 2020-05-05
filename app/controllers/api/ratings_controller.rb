class Api::RatingsController < ApiController
  # POST /api/trucks/1/ratings


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

  def create
      if request.headers.include?('HTTP_AUTHORIZATION')
        @foodtruck = FoodTruck.find_by_id(params[:truck_id])
        @rating = Rating.new()
        @rating.rating = params[:rating]
        @rating.comment = params[:comment]
        @rating.food_truck_id = params[:truck_id]
        if @rating.save
         
        else
        
        end
      else
        head :unauthorized
      end
  end

  def update
    
  end

 end
