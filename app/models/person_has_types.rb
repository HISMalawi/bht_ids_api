class PersonHasTypes < ApplicationRecord
	self.table_name = "person_has_types"
	has_many :hiv_staging_info, primary_key: 'person_id', class_name: 'HivStagingInfo', foreign_key: 'person_id'
	belongs_to :people, class_name: 'People', foreign_key: 'person_id'
	has_many :de_identified_identifier, primary_key: 'person_id', class_name: 'DeIdentifiedIdentifier', foreign_key: 'person_id'
end
