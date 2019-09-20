class HtsResultsGiven < ApplicationRecord
	self.table_name = 'hts_results_givens'
	belongs_to :encounters
end