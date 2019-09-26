class UserPolicy < ApplicationPolicy
	def show?
		return true		
	end

	def create?
		user.user_role == 'admin'
	end

	def update?
		user.user_role == 'admin' || record.user == user		
	end

	def destroy?
		user.user_role == 'admin'
	end

	class Scope < ApplicationPolicy::Scope
		def resolve
			scope.all
		end
	end
end