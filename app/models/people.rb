class People < ApplicationRecord
  has_many :relationships
  has_many :encounters
  has_many :person_has_types, class_name: 'PersonHasTypes', foreign_key: 'person_id'
  

  self.table_name = "people"
end
