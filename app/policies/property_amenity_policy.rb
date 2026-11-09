# frozen_string_literal: true

# The amenities of a property are chosen in the property form: whoever may edit the property may change them.
class PropertyAmenityPolicy < ApplicationPolicy
  def create?
    PropertyPolicy.new(user, record.property).update?
  end

  def destroy?
    create?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
