import { Controller } from "@hotwired/stimulus"

// 날짜 + 시작시간 + 종료시간을 work_at / work_end_at hidden field에 합산
export default class extends Controller {
  static targets = ["dateInput", "startTimeInput", "endTimeInput", "hiddenWorkAt", "hiddenWorkEndAt"]

  connect() {
    this.syncDatetime()
  }

  syncDatetime() {
    const date      = this.dateInputTarget.value
    const startTime = this.startTimeInputTarget.value || "00:00"
    const endTime   = this.endTimeInputTarget.value   || ""

    if (date) {
      this.hiddenWorkAtTarget.value    = `${date}T${startTime}`
      this.hiddenWorkEndAtTarget.value = endTime ? `${date}T${endTime}` : ""
    } else {
      this.hiddenWorkAtTarget.value    = ""
      this.hiddenWorkEndAtTarget.value = ""
    }
  }
}
