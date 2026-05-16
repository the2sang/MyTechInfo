import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    name: String,
    sportLevel: String,
    gender: String,
    ageGroup: String,
    region: String,
  }

  connect() {
    this._popover = null
    this._boundClose = this._closeOnOutside.bind(this)
  }

  disconnect() {
    this._remove()
  }

  show() {
    if (this._popover) { this._remove(); return }

    const popover = document.createElement("div")
    popover.className = "participant-popover"

    const nameEl = document.createElement("div")
    nameEl.className = "participant-popover__name"
    nameEl.textContent = this.nameValue
    popover.appendChild(nameEl)

    const rows = document.createElement("div")
    rows.className = "participant-popover__rows"
    ;[
      ["운동 레벨", this.sportLevelValue],
      ["성별",     this.genderValue],
      ["연령대",   this.ageGroupValue],
      ["거주지역", this.regionValue || "—"],
    ].forEach(([label, value]) => {
      const row = document.createElement("div")
      row.className = "participant-popover__row"

      const lbl = document.createElement("span")
      lbl.className = "participant-popover__label"
      lbl.textContent = label

      const val = document.createElement("span")
      val.className = "participant-popover__value"
      val.textContent = value

      row.appendChild(lbl)
      row.appendChild(val)
      rows.appendChild(row)
    })
    popover.appendChild(rows)

    document.body.appendChild(popover)
    this._popover = popover
    this._position(popover)

    requestAnimationFrame(() => {
      document.addEventListener("click", this._boundClose)
    })
  }

  _position(popover) {
    const rect  = this.element.getBoundingClientRect()
    const scrollY = window.scrollY
    const popW  = 200

    let left = rect.left + rect.width / 2 - popW / 2
    left = Math.max(8, Math.min(left, window.innerWidth - popW - 8))

    popover.style.position = "absolute"
    popover.style.width    = `${popW}px`
    popover.style.left     = `${left}px`
    popover.style.top      = `${rect.bottom + scrollY + 6}px`
    popover.style.zIndex   = "9999"
  }

  _closeOnOutside(event) {
    if (!this.element.contains(event.target)) this._remove()
  }

  _remove() {
    if (this._popover) {
      this._popover.remove()
      this._popover = null
    }
    document.removeEventListener("click", this._boundClose)
  }
}
