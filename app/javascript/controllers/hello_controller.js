import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["result"]
  connect() {
    console.log("Conectado via Stimulus");
    setInterval( () => {this.resultTarget.textContent = "Hello World"}, 1000);
  }
}
