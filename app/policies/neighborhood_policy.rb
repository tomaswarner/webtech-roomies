# frozen_string_literal: true

class NeighborhoodPolicy < ApplicationPolicy
  def index?
    signed_in?
  end

  def show?
    signed_in?
  end

  # Managing the catalog: only moderators.
  def create?
    moderator?
  end

  def update?
    moderator?
  end

  def destroy?
    moderator?
  end

  class Scope < Scope
    def resolve
      user ? scope.all : scope.none
    end
  end
end
