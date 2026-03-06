import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    url: String,
    handle: { type: String, default: ".cms-section-item__handle" }
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      handle: this.handleValue,
      animation: 150,
      onEnd: this.persistOrder.bind(this)
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }

  persistOrder() {
    const ids = Array.from(this.element.querySelectorAll("[data-page-section-id]"))
      .map(el => el.dataset.pageSectionId)

    const body = new URLSearchParams()
    ids.forEach(id => body.append("page_section_ids[]", id))

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content,
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: body.toString()
    })
  }
}
