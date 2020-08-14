class AddEmailToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :email, :string
  end
end
