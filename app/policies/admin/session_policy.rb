module Admin
  class SessionPolicy < ApplicationPolicy
    def index? = user&.admin?

    class Scope < ApplicationPolicy::Scope
      def resolve
        user&.admin? ? scope.all : scope.none
      end
    end
  end
end
