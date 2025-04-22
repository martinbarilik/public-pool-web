import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["period", "chart"];

  static values = {
    data: String,
    url: String,
    color: String,
    gridColor: String,
    fontColor: String,
    fontSize: Number,
    offset: Number,
    min: Number,
    max: Number,
  };

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

  chartTargetConnected(element) {
    if (!this.dataValue) return;

    new Chartkick.AreaChart(
      element,
      JSON.parse(this.dataValue),
      this.defaultOptions(this.minValue, this.maxValue)
    );
  }

  defaultOptions(min, max) {
    const _this = this;

    return {
      colors: [this.colorValue],
      library: {
        scales: {
          x: {
            grid: {
              display: true,
              drawOnChartArea: true,
              drawTicks: true,
              color: this.gridColorValue,
            },
            ticks: {
              color: this.colorValue,
              font: { size: this.fontSizeValue },
              count: 4, // This will attempt to show ~10 ticks on X axis
            },
          },
          y: {
            grid: {
              display: true,
              drawOnChartArea: true,
              drawTicks: true,
              color: this.gridColorValue,
            },
            ticks: {
              color: this.colorValue,
              font: { size: this.fontSizeValue },
              count: 4, // This will attempt to show ~15 ticks on Y axis
              callback: function (value) {
                return _this.humanizeHashRate(value);
              },
            },
            min: min - this.calculateOffset(min),
            max: max + this.calculateOffset(max),
          },
        },
        plugins: {
          tooltip: {
            callbacks: {
              label: function (context) {
                const value = context.parsed.y;
                return `Hashrate: ${_this.humanizeHashRate(value)}`;
              },
              title: function (context) {
                return `Date: ${new Date(
                  context[0].parsed.x
                ).toLocaleString()}`;
              },
            },
          },
        },
      },
    };
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

  calculateOffset(value) {
    return (value / 100) * this.offsetValue;
  }
}
