class CreateMachines < ActiveRecord::Migration[6.0]
  def change
    create_table :machines do |t|
      t.string :ip
      t.string :external_ip
      t.integer :cpu
      t.integer :ram
      t.integer :disk
      t.text :username
      t.text :password
      t.string :machine_type
      t.references :pool, foreign_key: true
      t.timestamps
    end
  end
end