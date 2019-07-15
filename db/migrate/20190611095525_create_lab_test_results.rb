class CreateLabTestResults < ActiveRecord::Migration[5.2]
  def change
    create_table :lab_test_results do |t|

      t.timestamps
    end
  end
end
