class CreateRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :ratings do |t|
      t.float :rating
      t.text :comment

      t.timestamps
    end
  end
end
