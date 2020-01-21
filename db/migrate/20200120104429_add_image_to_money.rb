class AddImageToMoney < ActiveRecord::Migration[5.2]
  def change
    add_column :money, :image, :string
  end
end
