import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="home"
export default class extends Controller {
  static targets = [
    'anchor',
    'bestDifficulty',
    'networkDifficulty',
    'networkHashrate'
  ];

  connect() {
    this.interval = setInterval(this.refreshGraph.bind(this), 65000);
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval);
  }

  refreshGraph() {
    this.#activeTarget?.click();
  }

  get #activeTarget() {
    return this.anchorTargets.find(t => t.classList.contains('active'));
  }
}
