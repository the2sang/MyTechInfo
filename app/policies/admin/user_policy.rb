module Admin
  class UserPolicy < ApplicationPolicy
    def index? = user&.admin?
    def show?  = user&.admin?

    class Scope < ApplicationPolicy::Scope
      def resolve
        user&.admin? ? scope.all : scope.none
      end
    end
  end
end
