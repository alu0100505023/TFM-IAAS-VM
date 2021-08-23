class AddNameToMachines < ActiveRecord::Migration[6.0]
  def change
    add_column :machines, :name, :string
  end
end
