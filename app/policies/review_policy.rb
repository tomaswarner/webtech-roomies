# frozen_string_literal: true

class ReviewPolicy < ApplicationPolicy
  # Reviews are public.
  def index?
    true
  end

  def show?
    true
  end

  # Only after their own completed visit.
  def create?
    signed_in? && record.visit.present? && record.visit.completed? && record.visit.application.seeker_id == user.id
  end

  def update?
    author?
  end

  # Their own, or any review for a moderator.
  def destroy?
    author? || moderator?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def author?
    signed_in? && record.seeker_id == user.id
  end
end
