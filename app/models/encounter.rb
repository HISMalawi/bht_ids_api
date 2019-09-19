class Encounter < ApplicationRecord
	self.table_name = 'encounters'
	has_many :lab_orders
	has_many :hts_results_givens
end
