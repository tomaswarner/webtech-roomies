class PagesController < ApplicationController
  allow_unauthenticated_access
  # The landing page has no record to authorize; its listings come from the policy scope.
  skip_after_action :verify_pundit_authorization

  def home
    @featured_listings = policy_scope(Listing).published.with_attached_photos.includes(property: :neighborhood).newest_first.limit(3)
    @neighborhoods = Neighborhood.by_name
  end
end
