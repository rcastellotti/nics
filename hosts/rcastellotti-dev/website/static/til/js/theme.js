const toggle = document.querySelector("#theme-toggle");
const themes = ["light", "dark"];

function updateToggle() {
  const theme = document.documentElement.dataset.theme;
  const nextTheme = themes[(themes.indexOf(theme) + 1) % themes.length];
  toggle.textContent = theme;
  toggle.setAttribute("aria-label", `Switch to ${nextTheme} mode`);
}

toggle.addEventListener("click", () => {
  const currentTheme = document.documentElement.dataset.theme;
  setTheme(themes[(themes.indexOf(currentTheme) + 1) % themes.length], true);
  updateToggle();
});

systemTheme.addEventListener("change", (event) => {
  if (getStoredTheme()) return;
  setTheme(event.matches ? "dark" : "light");
  updateToggle();
});

updateToggle();
