# frozen_string_literal: true

# A user sees and edits only their own profile.
class UserPolicy < ApplicationPolicy
  def show?
    own?
  end

  def update?
    own?
  end

  class Scope < Scope
    def resolve
      user ? scope.where(id: user.id) : scope.none
    end
  end

  private

  def own?
    signed_in? && record.id == user.id
  end
end
