import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"

export default class extends Controller {
  static targets = ["textarea", "editPane", "previewPane", "editTab", "previewTab", "formatMarkdown", "formatHtml", "previewPanel"]

  connect() {
    this.showEdit()
  }

  showEdit() {
    this.editPaneTarget.hidden = false
    this.previewPaneTarget.hidden = true
    this.editTabTarget.classList.add("content-editor__tab--active")
    this.previewTabTarget.classList.remove("content-editor__tab--active")
  }

  showPreview() {
    this.renderPreview()
    this.editPaneTarget.hidden = true
    this.previewPaneTarget.hidden = false
    this.editTabTarget.classList.remove("content-editor__tab--active")
    this.previewTabTarget.classList.add("content-editor__tab--active")
  }

  renderPreview() {
    const content = this.textareaTarget.value
    const isMarkdown = this.formatMarkdownTarget.checked

    if (content.trim() === "") {
      this.previewPanelTarget.innerHTML = '<span class="content-preview__empty">미리 보기할 내용을 입력하세요</span>'
      return
    }

    if (isMarkdown) {
      this.previewPanelTarget.innerHTML = marked.parse(content)
    } else {
      this.previewPanelTarget.innerHTML = content
    }
  }

  onFormatChange() {
    if (!this.previewPaneTarget.hidden) {
      this.renderPreview()
    }
  }
}
