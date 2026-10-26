import { Controller } from "@hotwired/stimulus"

// Submits the form as soon as one of its fields changes (used by the "acting as" select in the navbar).
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
