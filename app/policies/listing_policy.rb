# frozen_string_literal: true

class ListingPolicy < ApplicationPolicy
  # Browse and search published listings: everyone, also visitors.
  def index?
    true
  end

  # Drafts: only their host and the moderators. Published, reserved and rented listings: everyone.
  # Withdrawn listings stay visible to their host and the moderators.
  def show?
    record.published? || record.reserved? || record.rented? || host? || moderator?
  end

  # A listing is created inside a property: only the host of that property.
  def create?
    host?
  end

  # Edit (and publish, withdraw, mark as rented) or delete: the host, or any moderator.
  def update?
    host? || moderator?
  end

  def destroy?
    host? || moderator?
  end

  class Scope < Scope
    def resolve
      if moderator?
        scope.all
      elsif user
        scope.visible.or(scope.where(property_id: user.properties.select(:id)))
      else
        scope.visible
      end
    end
  end

  private

  def host?
    signed_in? && record.property.host_id == user.id
  end
end
