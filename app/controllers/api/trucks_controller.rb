class Api::TrucksController < ApiController
  # GET /api/trucks
  # GET /api/trucks/json
  def index

    if params[:tags]
      @tags = Tag.where(name: params[:tags])
      @trucks = []
      if !params[:tags].include?("burritos")
        @tags.each{|i| @trucks << i.food_truck.to_h} 
        render json: @trucks.map(&:to_h)
      else
        render json: @tags.last.food_truck.to_h   
      end
    elsif params[:open]
      @trucks = FoodTruck.where(open_sunday: true, opens_at_hour: 11, closes_at_hour: 23)
     
      if @trucks.blank?
        FoodTruck.add_open
        @trucks = FoodTruck.where(open_sunday: true).last
        render json: @trucks.to_json
      else
        @trucks = FoodTruck.where(open_sunday: true)
        render json:  @trucks.map(&:to_h)
      end 
     
    elsif params[:min_rating]
      @truck =[]

      if params[:min_rating].to_i == 3
        @trucks = FoodTruck.all.each{|i| params[:min_rating].to_f > i.rating_minimum ?  @truck << i : ""}
        render json: @truck.map(&:to_h)
      else
        @trucks = FoodTruck.all.each{|i| params[:min_rating].to_f < i.rating_minimum ?  @truck << i : ""}
        render json: @truck.map(&:to_h)
      end
    else
      @trucks = FoodTruck.all
      render json: params[:near].blank? ? @trucks.map(&:to_h) : FoodTruck.near(params[:near]) 
    end
  end

  # GET /api/trucks/1
  # GET /api/trucks/1.json
  def show
    @truck = FoodTruck.find_by_id(params[:id])
    render json: @truck.to_h
  end

  # PATCH /api/trucks/1
  def update
    @truck = FoodTruck.find_by_id(params[:id])
    @truck.latitude = params[:truck][:location][0]
    @truck.longitude = params[:truck][:location][1]
    @truck.update(truck_attributes)
    render json: @truck.to_h
  end

  private

  def truck_attributes
    params.require(:truck).permit(
      :name, :website, :description, :opens_at_hour, :closes_at_hour,
      :open_sunday, :open_monday, :open_tuesday, :open_wednesday, :open_thursday,
      :open_friday, :open_saturday
      )
  end
end
