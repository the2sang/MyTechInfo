import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values  = { active: { type: String, default: "result" } }

  connect() {
    this.#activate(this.activeValue)
  }

  switch(event) {
    this.#activate(event.currentTarget.dataset.tab)
  }

  #activate(selected) {
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tab === selected
      tab.classList.toggle("wj-tab--active", isActive)
      tab.setAttribute("aria-selected", isActive)
    })
    this.panelTargets.forEach(panel => {
      panel.hidden = panel.dataset.panel !== selected
    })
  }
}
