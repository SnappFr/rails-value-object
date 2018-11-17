class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.datetime :birthdate
      t.string :paypal_id
      t.string :email

      t.timestamps null: false
    end
  end
end
