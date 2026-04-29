import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "dropdown"]

  connect() {
    this._onOutsideClick = this._onOutsideClick.bind(this)
    this._onOtherOpen = this._onOtherOpen.bind(this)
    this._onVisit = () => this._close()
    document.addEventListener("turbo:before-visit", this._onVisit)
    document.addEventListener("navgroup:open", this._onOtherOpen)
  }

  disconnect() {
    document.removeEventListener("click", this._onOutsideClick)
    document.removeEventListener("turbo:before-visit", this._onVisit)
    document.removeEventListener("navgroup:open", this._onOtherOpen)
  }

  hover() {
    if (!this._isDesktop) return
    this._open()
  }

  hoverOut() {
    if (!this._isDesktop) return
    this._close()
  }

  tap(event) {
    if (this._isDesktop) return
    event.stopPropagation()
    this.dropdownTarget.classList.contains("nav__dropdown--open")
      ? this._close()
      : this._open()
  }

  _open() {
    if (!this._isDesktop) {
      document.dispatchEvent(new CustomEvent("navgroup:open", { detail: { opener: this.element } }))
    }
    this.dropdownTarget.classList.add("nav__dropdown--open")
    this.triggerTarget.setAttribute("aria-expanded", "true")
    if (!this._isDesktop) {
      document.addEventListener("click", this._onOutsideClick)
    }
  }

  _close() {
    this.dropdownTarget.classList.remove("nav__dropdown--open")
    this.triggerTarget.setAttribute("aria-expanded", "false")
    document.removeEventListener("click", this._onOutsideClick)
  }

  _onOtherOpen(event) {
    if (event.detail.opener !== this.element) {
      this._close()
    }
  }

  _onOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this._close()
    }
  }

  get _isDesktop() {
    return window.matchMedia("(min-width: 769px)").matches
  }
}
