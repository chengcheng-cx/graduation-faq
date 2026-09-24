
function setExternalLinks() {
  document.querySelectorAll("a[href]").forEach(link => {
    const url = new URL(link.href, window.location.href);

    if (
      (url.protocol === "https:" || url.protocol === "http:") &&
      url.origin !== window.location.origin
    ) {
      link.target = "_blank";
      link.rel = "noopener noreferrer";
    }
  });
}

if (typeof document$ !== "undefined") {
  document$.subscribe(setExternalLinks);
} else {
  document.addEventListener("DOMContentLoaded", setExternalLinks);
}
