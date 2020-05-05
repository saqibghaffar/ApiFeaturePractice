class CreateFoodTrucks < ActiveRecord::Migration[5.1]
  def change
    create_table :food_trucks do |t|
      t.string :name, null: false
      t.string :website
      t.text :description
      t.integer :opens_at_hour, limit: 1
      t.integer :closes_at_hour, limit: 1

      Date::DAYNAMES.each do |day_of_week|
        t.boolean "open_#{day_of_week.downcase}", default: false
      end

      t.timestamps
    end
  end
end
