# frozen_string_literal: true

class VisitPolicy < ApplicationPolicy
  # Propose a visit: the host of the listing, or the applicant.
  def create?
    participant?
  end

  # Confirm, cancel, reschedule or complete: the host of the listing, or the applicant.
  def update?
    participant?
  end

  class Scope < Scope
    def resolve
      if user
        scope.where(application_id: RentalApplicationPolicy::Scope.new(user, Application).resolve.select(:id))
      else
        scope.none
      end
    end
  end

  private

  def participant?
    return false unless signed_in?

    application = record.application
    application.seeker_id == user.id || application.listing.property.host_id == user.id
  end
end
