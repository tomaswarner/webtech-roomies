# frozen_string_literal: true

# Base policy: every question answers false unless a subclass says otherwise.
#
# `user` is the signed-in user, or nil for a visitor: the visitor is not a value of the role enum,
# it is simply not being signed in. Every helper below is nil-safe.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # Deny by default: a scope that is not written returns no rows.
    def resolve
      scope.none
    end

    private

    attr_reader :user, :scope

    def moderator?
      user&.moderator? || false
    end
  end

  private

  def signed_in?
    user.present?
  end

  def moderator?
    user&.moderator? || false
  end
end
