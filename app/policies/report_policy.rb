# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  # Only moderators review the reports.
  def index?
    moderator?
  end

  # Report a listing: any signed-in user.
  def create?
    signed_in?
  end

  # Resolve or dismiss a report: only moderators.
  def update?
    moderator?
  end

  class Scope < Scope
    def resolve
      moderator? ? scope.all : scope.none
    end
  end
end
