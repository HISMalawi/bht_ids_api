class Encounter < ApplicationRecord
	self.table_name = "encounters"
	has_many :lab_orders
end
