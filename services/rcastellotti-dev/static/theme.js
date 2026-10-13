const systemTheme = window.matchMedia("(prefers-color-scheme: dark)");
const themeColors = { light: "#ffffff", dark: "#000000" };

function getStoredTheme() {
  try {
    const theme = localStorage.getItem("theme");
    if (themeColors[theme]) return theme;
    localStorage.removeItem("theme");
  } catch {}
  return null;
}

function setTheme(theme, persist = false) {
  document.documentElement.dataset.theme = theme;
  document
    .querySelector('meta[name="theme-color"]')
    .setAttribute("content", themeColors[theme]);
  if (persist) {
    try {
      localStorage.setItem("theme", theme);
    } catch {}
  }
}

setTheme(getStoredTheme() ?? (systemTheme.matches ? "dark" : "light"));

document.addEventListener("DOMContentLoaded", () => {
  const toggle = document.querySelector("#theme-toggle");
  const updateToggle = () => {
    const next =
      document.documentElement.dataset.theme === "dark" ? "light" : "dark";
    toggle.textContent = next;
    toggle.setAttribute("aria-label", `Switch to ${next} theme`);
  };

  toggle.addEventListener("click", () => {
    const next =
      document.documentElement.dataset.theme === "dark" ? "light" : "dark";
    setTheme(next, true);
    updateToggle();
  });
  updateToggle();
});
