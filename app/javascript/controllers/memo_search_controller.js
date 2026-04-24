import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["type", "contentField", "dateField",
                    "contentInput", "dateFromInput", "dateToInput"]

  connect() {
    // 서버 렌더링 hidden 상태를 JS가 덮어쓰지 않도록 현재 select 값 기준으로 재적용
    this.switchType()
    // hidden 속성이 style display와 충돌하지 않도록 명시 처리
    this.element.style.visibility = "visible"
  }

  switchType() {
    const isDate = this.typeTarget.value === "date"
    this.contentFieldTarget.hidden = isDate
    this.dateFieldTarget.hidden    = !isDate
    if (isDate) {
      this.contentInputTarget.value = ""
    } else {
      this.dateFromInputTarget.value = ""
      this.dateToInputTarget.value   = ""
    }
  }
}
