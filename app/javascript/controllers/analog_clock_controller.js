import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hour", "minute", "second", "digital"]

  connect() {
    this._tick()
    this.timer = setInterval(() => this._tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  _renderDigital(period, time) {
    const el = this.digitalTarget
    if (!this._ampmSpan) {
      el.textContent = ""
      this._ampmSpan = document.createElement("span")
      this._ampmSpan.className = "analog-clock__ampm"
      this._hhmmSpan = document.createElement("span")
      this._hhmmSpan.className = "analog-clock__hhmm"
      el.appendChild(this._ampmSpan)
      el.appendChild(this._hhmmSpan)
    }
    this._ampmSpan.textContent = period
    this._hhmmSpan.textContent = time
  }

  _tick() {
    const now = new Date()
    const h = now.getHours() % 12
    const m = now.getMinutes()
    const s = now.getSeconds()

    const hourDeg   = h * 30 + m * 0.5
    const minuteDeg = m * 6 + s * 0.1
    const secondDeg = s * 6

    if (this.hasHourTarget)   this.hourTarget.setAttribute("transform",   `rotate(${hourDeg}, 50, 50)`)
    if (this.hasMinuteTarget) this.minuteTarget.setAttribute("transform", `rotate(${minuteDeg}, 50, 50)`)
    if (this.hasSecondTarget) this.secondTarget.setAttribute("transform", `rotate(${secondDeg}, 50, 50)`)

    if (this.hasDigitalTarget) {
      const hours = now.getHours()
      const period = hours >= 12 ? "PM" : "AM"
      const h12 = (hours % 12 || 12).toString().padStart(2, "0")
      const mm = m.toString().padStart(2, "0")
      this._renderDigital(period, `${h12}:${mm}`)
    }
  }
}
