class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.references :food_truck, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
