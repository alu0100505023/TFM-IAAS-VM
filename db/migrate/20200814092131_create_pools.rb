class CreatePools < ActiveRecord::Migration[6.0]
  def change
    create_table :pools do |t|
      t.string :cluster
      t.string :storage_domain
      t.string :template
      t.string :instance_type
      t.integer :masters
      t.integer :slaves
      t.references :post, foreign_key: true
      t.timestamps
    end
  end
end