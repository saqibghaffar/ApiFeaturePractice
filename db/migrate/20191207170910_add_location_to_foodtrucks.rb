class AddLocationToFoodtrucks < ActiveRecord::Migration[5.1]
  def change
  	  add_column :food_trucks, :latitude, :float
  	  add_column :food_trucks, :longitude, :float
  end
end
