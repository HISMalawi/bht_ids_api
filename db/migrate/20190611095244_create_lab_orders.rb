class CreateLabOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :lab_orders do |t|

      t.timestamps
    end
  end
end
