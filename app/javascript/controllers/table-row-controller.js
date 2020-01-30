import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["tr"]

  toggleExpansion(e) {
    if (e.target.dataset.behavior == 'no-expand') { return }

    let expandedRow = this.trTarget.nextElementSibling
    expandedRow.classList.toggle('d-none')
  }
}
