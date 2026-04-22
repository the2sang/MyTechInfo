import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._handler = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault()
        this.element.focus()
        this.element.select()
      }
    }
    document.addEventListener("keydown", this._handler)
  }

  disconnect() {
    document.removeEventListener("keydown", this._handler)
  }
}
