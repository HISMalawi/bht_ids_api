class User < ApplicationRecord
    has_secure_password

    # has_many :user_role_assignments
    # has_many :roles, through: :user_role_assignments

    def role?(role)
    	roles.any? { |r| r.name.underscore.to_sym == role }  
    end  
end
