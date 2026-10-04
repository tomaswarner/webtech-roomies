module ListingsHelper
  def availability_text(listing)
    listing.available_now? ? "Available now" : "Available from #{l(listing.available_on, format: :long)}"
  end

  def stay_text(months)
    pluralize(months, "month")
  end

  def room_features(listing)
    [
      (listing.furnished? ? "Furnished" : "Unfurnished"),
      (listing.private_bathroom? ? "Private bathroom" : "Shared bathroom"),
      "Minimum stay: #{stay_text(listing.minimum_stay_months)}"
    ]
  end
end
