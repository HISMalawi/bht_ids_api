class LabTestResult < ApplicationRecord
	belongs_to :lab_order
	has_many :master_definition
end
