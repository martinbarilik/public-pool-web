import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="theme-picker"
export default class extends Controller {
  static targets = ["radioBtn"];

  connect() {
    this.setTheme(this.getPreferredTheme());
  }

  getStoredTheme() {
    return localStorage.getItem("theme");
  }

  setStoredTheme(theme) {
    localStorage.setItem("theme", theme);
  }

  getPreferredTheme() {
    const storedTheme = this.getStoredTheme();
    if (storedTheme) {
      return storedTheme;
    }

    return window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  setTheme(theme) {
    if (theme === "auto") {
      document.documentElement.setAttribute(
        "data-bs-theme",
        window.matchMedia("(prefers-color-scheme: dark)").matches
          ? "dark"
          : "light"
      );
    } else {
      document.documentElement.setAttribute("data-bs-theme", theme);
    }

    this.radioBtnTargets.forEach((radioBtn) => {
      console.log(radioBtn.id);
      console.log(radioBtn.id === theme);

      radioBtn.checked = radioBtn.id === theme;
    });
  }

  change(e) {
    this.setStoredTheme(e.target.id);
    this.setTheme(e.target.id);
  }
}
