import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input", "toggle"]

  connect() {
    this._keyHandler = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault()
        this.open()
      }
      if (e.key === "Escape" && this.formTarget.classList.contains("nav-search--open")) {
        this.close()
      }
    }
    this._outsideHandler = (e) => {
      if (!this.element.contains(e.target)) this.close()
    }
    document.addEventListener("keydown", this._keyHandler)

    // Keep open if there's an active search query
    if (this.inputTarget.value) {
      this._showForm()
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this._keyHandler)
    document.removeEventListener("click", this._outsideHandler)
  }

  open() {
    this._showForm()
    // Focus after transition starts
    setTimeout(() => {
      this.inputTarget.focus()
      this.inputTarget.select()
    }, 50)
    setTimeout(() => document.addEventListener("click", this._outsideHandler), 0)
  }

  close() {
    this._hideForm()
    document.removeEventListener("click", this._outsideHandler)
  }

  _showForm() {
    this.formTarget.classList.add("nav-search--open")
    this.toggleTarget.classList.add("nav-search__toggle--hidden")
  }

  _hideForm() {
    this.formTarget.classList.remove("nav-search--open")
    this.toggleTarget.classList.remove("nav-search__toggle--hidden")
  }
}
