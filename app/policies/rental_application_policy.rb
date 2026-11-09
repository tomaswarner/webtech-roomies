# frozen_string_literal: true

# The policy of the Application model. It cannot be called ApplicationPolicy, which is the base class of every
# policy, so Application.policy_class points here.
class RentalApplicationPolicy < ApplicationPolicy
  # The applications page needs an account; what it lists comes from the scope.
  def index?
    signed_in?
  end

  # The seeker who wrote it and the host of the listing it was sent to. Moderators see every application.
  def show?
    seeker? || host? || moderator?
  end

  # Any signed-in user, except on their own listing.
  def create?
    signed_in? && !host?
  end

  # Shortlist, reject or accept: only the host of the listing. Moderators get no extra power here.
  def decide?
    host?
  end

  # Withdraw: only the seeker who wrote it.
  def withdraw?
    seeker?
  end

  class Scope < Scope
    # The query itself only returns the applications the user may see: the ones they wrote and the ones
    # received on their listings. Moderators see all of them. Visitors see none.
    def resolve
      if moderator?
        scope.all
      elsif user
        scope.where(seeker_id: user.id)
             .or(scope.where(listing_id: Listing.joins(:property).where(properties: { host_id: user.id }).select(:id)))
      else
        scope.none
      end
    end
  end

  private

  def seeker?
    signed_in? && record.seeker_id == user.id
  end

  def host?
    signed_in? && record.listing.property.host_id == user.id
  end
end
