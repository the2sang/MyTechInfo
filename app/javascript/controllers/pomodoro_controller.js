import { Controller } from "@hotwired/stimulus"

// State machine: idle → running → paused → idle
//                running → finished → (auto-switch mode) → idle
export default class extends Controller {
  static targets = ["display", "startBtn", "resetBtn", "modeLabel", "sessionCount"]
  static values  = { focusMinutes: Number, breakMinutes: Number }

  connect() {
    this.mode = "focus"       // "focus" | "break"
    this.sessions = 0
    this._reset()
  }

  disconnect() {
    this._clearTick()
  }

  toggle() {
    this.running ? this._pause() : this._start()
  }

  reset() {
    this._clearTick()
    this._reset()
  }

  skipMode() {
    this._clearTick()
    this.mode = this.mode === "focus" ? "break" : "focus"
    this._reset()
  }

  // ── private ──────────────────────────────────────────────

  _start() {
    this.running = true
    this.startBtnTarget.textContent = "일시정지"
    this.startBtnTarget.classList.replace("btn--primary", "btn--secondary")
    this._tick()
    this.timer = setInterval(() => this._tick(), 1000)
  }

  _pause() {
    this.running = false
    this.startBtnTarget.textContent = "계속하기"
    this.startBtnTarget.classList.replace("btn--secondary", "btn--primary")
    this._clearTick()
  }

  _tick() {
    if (this.remaining <= 0) {
      this._finish()
      return
    }
    this.remaining -= 1
    this._render()
  }

  _finish() {
    this._clearTick()
    this.running = false

    if (this.mode === "focus") {
      this.sessions += 1
      this._updateSessionCount()
      this._notify("집중 완료! 휴식할 시간입니다 🎉")
      this.mode = "break"
    } else {
      this._notify("휴식 완료! 다시 집중할 시간입니다 💪")
      this.mode = "focus"
    }
    this._reset()
  }

  _reset() {
    this.running  = false
    this.remaining = this._totalSeconds()
    this._render()
    this._renderMode()
    if (this.hasStartBtnTarget) {
      this.startBtnTarget.textContent = "시작"
      this.startBtnTarget.classList.remove("btn--secondary")
      this.startBtnTarget.classList.add("btn--primary")
    }
    document.title = `${this._formatted()} — 집중`
  }

  _totalSeconds() {
    return (this.mode === "focus"
      ? this.focusMinutesValue
      : this.breakMinutesValue) * 60
  }

  _render() {
    const fmt = this._formatted()
    if (this.hasDisplayTarget) this.displayTarget.textContent = fmt
    document.title = `${fmt} — ${this.mode === "focus" ? "집중 중" : "휴식 중"}`
  }

  _renderMode() {
    if (!this.hasModeLabelTarget) return
    if (this.mode === "focus") {
      this.modeLabelTarget.textContent = "집중"
      this.modeLabelTarget.dataset.mode = "focus"
    } else {
      this.modeLabelTarget.textContent = "휴식"
      this.modeLabelTarget.dataset.mode = "break"
    }
  }

  _updateSessionCount() {
    if (this.hasSessionCountTarget) {
      this.sessionCountTarget.textContent = `완료 ${this.sessions}세션`
    }
  }

  _formatted() {
    const m = Math.floor(this.remaining / 60).toString().padStart(2, "0")
    const s = (this.remaining % 60).toString().padStart(2, "0")
    return `${m}:${s}`
  }

  _clearTick() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  _notify(msg) {
    if ("Notification" in window && Notification.permission === "granted") {
      new Notification(msg)
    } else {
      alert(msg)
    }
  }
}
