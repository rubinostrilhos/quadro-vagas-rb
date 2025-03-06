import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="welcome"
export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.textContent = "Hello, World!"
    }, 2000) // 2000ms = 2 seconds
  }
}
