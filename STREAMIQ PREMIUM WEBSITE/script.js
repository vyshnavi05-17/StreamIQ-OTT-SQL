(() => {
  document.documentElement.classList.add("has-js");
  const header = document.querySelector(".site-header");
  const menuToggle = document.querySelector(".menu-toggle");
  const navLinks = document.querySelector(".nav-links");
  const backToTop = document.querySelector(".back-to-top");
  const videos = [...document.querySelectorAll(".hero-animation, .film-strip-video")];
  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  videos.forEach((video) => {
    video.addEventListener("error", () => {
      console.warn(`StreamIQ video could not be loaded: ${video.currentSrc || video.querySelector("source")?.src}`);
    }, { once: true });
    if (reduceMotion) {
      video.pause();
      return;
    }
    video.play().catch((error) => {
      console.warn(`StreamIQ video autoplay could not start: ${video.currentSrc || video.querySelector("source")?.src}`, error);
    });
  });

  const closeMenu = () => {
    if (!menuToggle || !navLinks) return;
    menuToggle.setAttribute("aria-expanded", "false");
    menuToggle.setAttribute("aria-label", "Open navigation");
    navLinks.classList.remove("is-open");
  };

  menuToggle?.addEventListener("click", () => {
    const isOpen = menuToggle.getAttribute("aria-expanded") === "true";
    menuToggle.setAttribute("aria-expanded", String(!isOpen));
    menuToggle.setAttribute("aria-label", isOpen ? "Open navigation" : "Close navigation");
    navLinks?.classList.toggle("is-open", !isOpen);
  });

  navLinks?.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", closeMenu);
  });

  const updateScrollUI = () => {
    const y = window.scrollY;
    header?.classList.toggle("is-scrolled", y > 15);
    backToTop?.classList.toggle("is-visible", y > 600);
  };

  window.addEventListener("scroll", updateScrollUI, { passive: true });
  window.addEventListener("resize", () => {
    if (window.innerWidth > 700) closeMenu();
  });
  updateScrollUI();

  backToTop?.addEventListener("click", () => {
    window.scrollTo({ top: 0, behavior: reduceMotion ? "auto" : "smooth" });
  });

  const navAnchors = [...(navLinks?.querySelectorAll('a[href^="#"]') ?? [])];
  const navSections = navAnchors
    .map((link) => document.querySelector(link.getAttribute("href")))
    .filter(Boolean);

  if ("IntersectionObserver" in window) {
    const revealObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -35px 0px" });

    document.querySelectorAll(".reveal").forEach((element) => revealObserver.observe(element));

    const counterObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const counter = entry.target;
        const target = Number(counter.dataset.value);
        if (!Number.isFinite(target)) {
          observer.unobserve(counter);
          return;
        }
        const decimals = Number(counter.dataset.decimals ?? 0);
        const prefix = counter.dataset.prefix ?? "";
        const suffix = counter.dataset.suffix ?? "";
        const duration = reduceMotion ? 0 : 1150;
        const start = performance.now();
        const render = (time) => {
          const progress = duration === 0 ? 1 : Math.min((time - start) / duration, 1);
          const eased = 1 - Math.pow(1 - progress, 4);
          const value = target * eased;
          let formattedValue = value.toLocaleString("en-IN", {
            minimumFractionDigits: progress === 1 ? decimals : 0,
            maximumFractionDigits: decimals,
          });
          if (progress === 1 && counter.dataset.pad) {
            formattedValue = formattedValue.padStart(Number(counter.dataset.pad), "0");
          }
          counter.textContent = `${prefix}${formattedValue}${suffix}`;
          if (progress < 1) requestAnimationFrame(render);
        };
        requestAnimationFrame(render);
        observer.unobserve(counter);
      });
    }, { threshold: 0.65 });

    document.querySelectorAll(".metric-value[data-value], .object-number[data-value]").forEach((counter) => counterObserver.observe(counter));

    const sectionObserver = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const active = `#${entry.target.id}`;
        navAnchors.forEach((link) => {
          if (link.getAttribute("href") === active) link.classList.add("is-active");
          else link.classList.remove("is-active");
        });
      });
    }, { rootMargin: "-35% 0px -55% 0px" });
    navSections.forEach((section) => sectionObserver.observe(section));
  } else {
    document.querySelectorAll(".reveal").forEach((element) => element.classList.add("is-visible"));
  }

})();
