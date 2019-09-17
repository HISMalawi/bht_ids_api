class Role < ApplicationRecord
	# has_many :user_role_assignments
	# has_many :users, through: :user_role_assignments
	
	validates :name, presence: true, uniqueness: true
end
