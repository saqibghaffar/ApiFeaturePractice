class AddColumnInRating < ActiveRecord::Migration[5.1]
  def change
  	add_column :ratings, :food_truck_id, :integer
  end
end
