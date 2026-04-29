import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { year: Number, month: Number }
  static targets = ["yearBtn", "monthBtn", "dayPanel", "dayContent"]

  connect() {
    this._syncYearButtons()
    this._syncMonthButtons()
  }

  selectYear(event) {
    const year = parseInt(event.currentTarget.dataset.year)
    this.yearValue = year
    this._navigate()
  }

  selectMonth(event) {
    const month = parseInt(event.currentTarget.dataset.month)
    this.monthValue = month
    this._navigate()
  }

  toggleDay(event) {
    const trigger = event.currentTarget
    const date = trigger.dataset.date
    const panel = this.element.querySelector(`[data-day-content="${date}"]`)

    if (!panel) return

    const isOpen = !panel.hidden

    // Close all open panels
    this.element.querySelectorAll("[data-day-content]").forEach(p => {
      p.hidden = true
      const t = this.element.querySelector(`[data-date="${p.dataset.dayContent}"]`)
      if (t) t.setAttribute("aria-expanded", "false")
    })

    // Open clicked panel if it was closed
    if (!isOpen) {
      panel.hidden = false
      trigger.setAttribute("aria-expanded", "true")
      // Focus first input
      const firstInput = panel.querySelector("input, textarea")
      if (firstInput) firstInput.focus()
    }
  }

  // Called after Turbo Stream updates a day's record list
  refreshDay(event) {
    const date = event.detail?.date
    if (!date) return
    const panel = this.element.querySelector(`[data-day-content="${date}"]`)
    if (panel) {
      panel.hidden = false
      const trigger = this.element.querySelector(`[data-date="${date}"]`)
      if (trigger) trigger.setAttribute("aria-expanded", "true")
    }
  }

  _navigate() {
    const url = new URL(window.location.href)
    url.searchParams.set("year", this.yearValue)
    url.searchParams.set("month", this.monthValue)
    window.Turbo.visit(url.toString())
  }

  _syncYearButtons() {
    this.yearBtnTargets.forEach(btn => {
      const active = parseInt(btn.dataset.year) === this.yearValue
      btn.classList.toggle("mp-year-btn--active", active)
      btn.setAttribute("aria-pressed", active.toString())
    })
  }

  _syncMonthButtons() {
    this.monthBtnTargets.forEach(btn => {
      const active = parseInt(btn.dataset.month) === this.monthValue
      btn.classList.toggle("mp-month-btn--active", active)
      btn.setAttribute("aria-pressed", active.toString())
    })
  }

  yearValueChanged() { this._syncYearButtons() }
  monthValueChanged() { this._syncMonthButtons() }
}
