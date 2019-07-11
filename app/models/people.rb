class People < ApplicationRecord
  has_many :relationships
  has_many :encounters

  self.table_name = "people"
end
