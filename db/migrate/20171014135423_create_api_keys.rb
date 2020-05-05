class CreateApiKeys < ActiveRecord::Migration[5.1]
  def change
    create_table :api_keys do |t|
      t.references :user, null: false
      t.string :access_token, null: false

      t.timestamps
    end
  end
end
