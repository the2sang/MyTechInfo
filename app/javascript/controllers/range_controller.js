import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values  = { suffix: { type: String, default: "" } }

  connect() {
    const input = this.element.querySelector("input[type=range]")
    if (input && this.hasDisplayTarget) {
      this.displayTarget.textContent = input.value + this.suffixValue
    }
  }

  update(event) {
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = event.target.value + this.suffixValue
    }
  }
}
