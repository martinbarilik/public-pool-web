import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="home"
export default class extends Controller {
  static targets = [
    "anchor",
    "bestDifficulty",
    "workersCount",
    "networkDifficulty",
    "networkHashrate",
  ];
  static values = { host: String };

  connect() {
    this.interval = setInterval(this.refreshGraph.bind(this), 65000);
    this.pullPoolData();
    this.pullNetworkData();
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval);
  }

  refreshGraph() {
    this.#activeTarget?.click();
  }

  get #activeTarget() {
    return this.anchorTargets.find((t) => t.classList.contains("active"));
  }

  async pullPoolData() {
    try {
      const response = await fetch(`http://${this.hostValue}:2019/api/info`);

      if (!response.status) return;

      const data = await response.json();

      this.bestDifficultyTarget.innerHTML = this.parseBestDifficulty(data);
      this.workersCountTarget.innerHTML = this.parseWorkersCount(data);
    } catch (err) {
      console.log("ERROR: ", err.message);
    }
  }

  parseBestDifficulty(data) {
    return this.humanizeDifficulty(
      Math.max(data.highScores.map((score) => score.bestDifficulty))
    );
  }

  parseWorkersCount(data) {
    return data.userAgents
      .map((agent) => agent.count)
      .reduce((a, b) => a + b, 0);
  }

  async pullNetworkData() {
    try {
      const response = await fetch(`http://${this.hostValue}:2019/api/network`);

      if (!response.status) return;

      const data = await response.json();

      this.networkDifficultyTarget.innerHTML = this.humanizeDifficulty(
        data.difficulty
      );
      this.networkHashrateTarget.innerHTML = this.humanizeHashRate(
        data.networkhashps
      );
    } catch (err) {
      console.log("ERROR: ", err.message);
    }
  }

  humanizeHashRate(hashRate) {
    const units = ["H/s", "KH/s", "MH/s", "GH/s", "TH/s", "PH/s", "EH/s"];
    let index = 0;
    let value = hashRate;

    while (value > 1000 && index < units.length - 1) {
      value /= 1000;
      index++;
    }

    return `${value.toFixed(2)} ${units[index]}`;
  }

  humanizeDifficulty(difficulty) {
    const units = ["", "K", "M", "G", "T", "P", "E"];
    let unitIndex = 0;

    while (difficulty >= 1024 && unitIndex < units.length - 1) {
      difficulty /= 1000;
      unitIndex++;
    }

    return `${difficulty.toFixed(2)}${units[unitIndex]}`;
  }
}
