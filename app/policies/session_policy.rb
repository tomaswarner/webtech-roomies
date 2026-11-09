# frozen_string_literal: true

# Sessions are created and ended by the authentication controllers; a user only ever reaches their own.
class SessionPolicy < ApplicationPolicy
  def destroy?
    signed_in? && record.user_id == user.id
  end

  class Scope < Scope
    def resolve
      user ? scope.where(user_id: user.id) : scope.none
    end
  end
end
