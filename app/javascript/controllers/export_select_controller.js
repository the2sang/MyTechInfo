import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["exportBtn", "count"]

  connect() {
    this.selectedIds = new Set()
  }

  toggle(event) {
    const btn = event.currentTarget
    const card = btn.closest("[data-tech-info-id]")
    const id = card.dataset.techInfoId

    if (this.selectedIds.has(id)) {
      this.selectedIds.delete(id)
      card.classList.remove("tech-info-card--selected")
      btn.querySelector("i").className = "fa-regular fa-square"
    } else {
      this.selectedIds.add(id)
      card.classList.add("tech-info-card--selected")
      btn.querySelector("i").className = "fa-solid fa-square-check"
    }

    this.updateExportBtn()
  }

  updateExportBtn() {
    const count = this.selectedIds.size
    this.exportBtnTarget.hidden = count === 0
    this.countTarget.textContent = count
  }

  exportSelected() {
    const baseUrl = this.exportBtnTarget.dataset.baseUrl
    const url = new URL(baseUrl, window.location.origin)
    this.selectedIds.forEach(id => url.searchParams.append("ids[]", id))
    window.location.href = url.toString()
  }
}
