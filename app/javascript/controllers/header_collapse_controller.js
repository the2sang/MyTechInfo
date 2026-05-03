import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // 기존 버튼 제거 (Turbo 재연결 시 중복 방지)
    this.element.querySelectorAll(".header-collapse-btn").forEach(b => b.remove())

    this.header = this.element.querySelector(".page__header")
    if (!this.header) return

    this._injectToggle()

    const userExpanded = localStorage.getItem(this._storageKey()) === "0"
    if (!userExpanded) {
      this.header.classList.add("page__header--collapsed")
      this._updateIcon(true)
    }
  }

  disconnect() {
    if (this.toggleBtn) this.toggleBtn.remove()
  }

  toggle() {
    if (!this.header) return
    const collapsed = this.header.classList.toggle("page__header--collapsed")
    localStorage.setItem(this._storageKey(), collapsed ? "1" : "0")
    this._updateIcon(collapsed)
  }

  _injectToggle() {
    const btn = document.createElement("button")
    btn.className = "header-collapse-btn"
    btn.setAttribute("aria-label", "헤더 접기/펼치기")
    btn.setAttribute("data-action", "click->header-collapse#toggle")

    const icon = document.createElement("iconify-icon")
    icon.setAttribute("icon", "lucide:chevron-up")
    btn.appendChild(icon)

    this.toggleBtn = btn
    this.header.after(btn)
  }

  _updateIcon(collapsed) {
    if (!this.toggleBtn) return
    const icon = this.toggleBtn.querySelector("iconify-icon")
    if (icon) icon.setAttribute("icon", collapsed ? "lucide:chevron-down" : "lucide:chevron-up")
  }

  _storageKey() {
    const seg = window.location.pathname.split("/").filter(Boolean)[0] || "root"
    return `header-collapse:${seg}`
  }
}
