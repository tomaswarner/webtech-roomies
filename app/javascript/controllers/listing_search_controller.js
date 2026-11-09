import { Controller } from "@hotwired/stimulus"

// The search page: reads the filters of the form, asks the JSON API for the matching published listings
// with fetch, and draws one card per listing without reloading the page.
export default class extends Controller {
  static targets = ["form", "results", "status"]
  static values = { url: String }

  connect() {
    this.search()
  }

  async search(event) {
    if (event) event.preventDefault()

    const params = new URLSearchParams(new FormData(this.formTarget))
    for (const [key, value] of [...params]) {
      if (value === "") params.delete(key)
    }

    this.statusTarget.textContent = "Loading rooms..."
    this.resultsTarget.replaceChildren()

    try {
      const response = await fetch(`${this.urlValue}?${params}`, { headers: { Accept: "application/json" } })
      const body = await response.json()

      if (!response.ok) {
        this.statusTarget.textContent = body.errors.join(". ")
        return
      }

      this.statusTarget.textContent = body.length === 0
        ? "No rooms match your search."
        : `${body.length} ${body.length === 1 ? "room" : "rooms"} found.`
      this.resultsTarget.replaceChildren(...body.map((listing) => this.card(listing)))
    } catch (error) {
      this.statusTarget.textContent = "The rooms could not be loaded. Please try again."
    }
  }

  // Every value from the API is written with textContent, never as HTML.
  card(listing) {
    const column = this.element("div", "col-md-6 col-lg-4")
    const card = this.element("div", "card h-100 shadow-sm listing-card")

    if (listing.photo_url) {
      const image = this.element("img", "card-img-top listing-photo")
      image.src = listing.photo_url
      image.alt = listing.title
      image.loading = "lazy"
      card.append(image)
    } else {
      card.append(this.element("div", "placeholder-photo bg-body-secondary"))
    }

    const body = this.element("div", "card-body d-flex flex-column")
    body.append(this.element("p", "small text-uppercase text-muted mb-1", listing.neighborhood.name))

    const title = this.element("h3", "card-title h5")
    const link = this.element("a", "stretched-link text-reset text-decoration-none", listing.title)
    link.href = listing.url
    title.append(link)
    body.append(title)

    const rent = this.element("p", "card-text fw-semibold mb-1", `${this.money(listing.monthly_rent)} `)
    rent.append(this.element("span", "fw-normal text-muted", "/ month"))
    body.append(rent)
    body.append(this.element("p", "card-text text-muted small mb-2", this.availability(listing.available_on)))

    const amenities = listing.property.amenities.map((amenity) => amenity.name).join(" · ")
    if (amenities) body.append(this.element("p", "card-text small text-muted mt-auto mb-0", amenities))

    card.append(body)
    column.append(card)
    return column
  }

  element(tag, className, text) {
    const node = document.createElement(tag)
    node.className = className
    if (text !== undefined) node.textContent = text
    return node
  }

  money(amount) {
    return `$${Number(amount).toLocaleString("es-CL")}`
  }

  availability(isoDate) {
    const date = new Date(`${isoDate}T00:00:00`)
    if (date <= new Date()) return "Available now"
    return `Available from ${date.toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" })}`
  }
}
