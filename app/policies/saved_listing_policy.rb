# frozen_string_literal: true

# Saved listings belong to the seeker who saved them.
class SavedListingPolicy < ApplicationPolicy
  def index?
    signed_in?
  end

  def create?
    signed_in?
  end

  def destroy?
    signed_in? && record.seeker_id == user.id
  end

  class Scope < Scope
    def resolve
      user ? scope.where(seeker_id: user.id) : scope.none
    end
  end
end
