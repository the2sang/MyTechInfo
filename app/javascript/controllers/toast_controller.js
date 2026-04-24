import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    requestAnimationFrame(() => {
      this.element.dataset.state = "show"
    })
    this.timer = setTimeout(() => this.dismiss(), 3500)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    clearTimeout(this.timer)
    this.element.dataset.state = "hide"
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
  }
}
