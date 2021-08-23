class AddPoolTypeToPools < ActiveRecord::Migration[6.0]
  def change
    add_column :pools, :pool_type, :string
  end
end
