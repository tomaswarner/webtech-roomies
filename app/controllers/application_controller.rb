class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Every action must ask a policy: index through policy_scope, every other action through authorize.
  after_action :verify_pundit_authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_user

  private

  # The signed-in user. On public pages require_authentication is skipped, so the session is resumed here:
  # a signed-in host on a listing page still sees the buttons the policy allows them.
  def current_user
    resume_session
    Current.user
  end

  def pundit_user
    current_user
  end

  def verify_pundit_authorization
    if action_name == "index"
      verify_policy_scoped
    else
      verify_authorized
    end
  end

  # An unauthorized attempt is a 403 with a page that explains what happened, never a raw error.
  # authorize runs before any write, so a refused update or destroy changes nothing.
  def user_not_authorized(exception)
    @reason =
      if exception.policy
        I18n.t("pundit.#{exception.policy.class.to_s.underscore}.#{exception.query}",
               default: I18n.t("pundit.default"))
      else
        exception.message
      end
    if turbo_frame_request?
      render "shared/forbidden_frame", layout: false, formats: :html, status: :forbidden
    else
      render "shared/forbidden", formats: :html, status: :forbidden
    end
  end
end
