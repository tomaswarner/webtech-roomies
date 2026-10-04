module ApplicationHelper
  STATUS_COLORS = {
    "draft" => "secondary", "published" => "success", "reserved" => "warning", "rented" => "dark",
    "withdrawn" => "danger", "pending" => "secondary", "shortlisted" => "info", "accepted" => "success",
    "rejected" => "danger", "proposed" => "secondary", "confirmed" => "primary", "cancelled" => "danger",
    "completed" => "success", "resolved" => "success", "dismissed" => "secondary"
  }.freeze

  def money(amount)
    number_to_currency(amount, unit: "$", delimiter: ".", separator: ",", precision: 0)
  end

  def status_badge(status)
    tag.span(status.to_s.humanize, class: "badge text-bg-#{STATUS_COLORS.fetch(status.to_s, 'secondary')}")
  end

  def rating_stars(rating)
    return tag.span("No ratings yet", class: "text-muted small") if rating.blank?

    full = rating.round
    tag.span(class: "text-warning", title: "#{rating} out of 5", "aria-label": "#{rating} out of 5") do
      safe_join(Array.new(5) { |i| tag.i(class: i < full ? "bi bi-star-fill" : "bi bi-star") })
    end
  end

  def nav_link_to(name, path)
    active = current_page?(path) || (path != root_path && request.path.start_with?(path))
    link_to name, path, class: [ "nav-link", ("active" if active) ], "aria-current": ("page" if active)
  end
end
