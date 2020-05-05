class TrucksController < ApplicationController
  def index
    @trucks = FoodTruck.all
  end
end
