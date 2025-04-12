import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["period"];
  static values = { url: String };

  connect() {
    const activePeriod = this.periodTargets.find((target) =>
      target.classList.contains("active")
    );

    if (this.urlValue) return;

    this.urlValue = activePeriod.url;

    activePeriod.click();
  }

  activate(e) {
    this.periodTargets.forEach((target) => {
      target.classList.remove("active");
    });

    e.target.classList.add("active");
  }
}
