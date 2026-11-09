# frozen_string_literal: true

class PropertyPolicy < ApplicationPolicy
  # Property pages are part of the public side of Roomies.
  def index?
    true
  end

  def show?
    true
  end

  def create?
    signed_in?
  end

  # Edit or delete: the host, or any moderator.
  def update?
    host? || moderator?
  end

  def destroy?
    host? || moderator?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def host?
    signed_in? && record.host_id == user.id
  end
end
