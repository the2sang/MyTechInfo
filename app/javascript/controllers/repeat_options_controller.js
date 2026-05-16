import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typeSelect", "specificDays", "endDate", "notice", "dayCheck"]

  connect() {
    this.toggle()
  }

  toggle() {
    const type = this.typeSelectTarget.value
    const isRepeating = type !== "no_repeat"
    const isSpecific = type === "specific_days"

    this.noticeTargets.forEach(el => el.style.display = isRepeating ? "flex" : "none")
    this.endDateTargets.forEach(el => el.style.display = isRepeating ? "block" : "none")
    this.specificDaysTargets.forEach(el => el.style.display = isSpecific ? "block" : "none")
  }
}
