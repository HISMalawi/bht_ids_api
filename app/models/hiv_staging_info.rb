class HivStagingInfo < ApplicationRecord
	belongs_to :person
	has_many :person_has_types, class_name: 'PersonHasTypes', foreign_key: 'person_id'
end
