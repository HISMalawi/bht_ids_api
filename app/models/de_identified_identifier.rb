class DeIdentifiedIdentifier < ApplicationRecord
	self.table_name = "de_identified_identifiers"
	belongs_to :people, class_name: 'People', foreign_key: 'person_id'
	has_many :person_has_types, class_name: 'PersonHasTypes', foreign_key: 'person_id'
end