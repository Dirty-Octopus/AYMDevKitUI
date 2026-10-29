import { test, expect } from "@playwright/test";
async function clickVisible(page, selector) {
  await page.evaluate(() => document.fonts.ready);
  const point = await page.locator(selector).evaluate(async (el) => {
    const { lensDisplayPoint } = await import("/src/vendor/crt.js");
    const r = el.getBoundingClientRect();
    return lensDisplayPoint(
      r.x + r.width / 2,
      r.y + r.height / 2,
      innerWidth,
      innerHeight,
    );
  });
  await page.mouse.click(point.x, point.y);
}
test("real pointer reaches curved buttons, embedded settings, input and slider", async ({
  page,
}) => {
  const errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  await page.goto("/");
  await expect(page.locator("#start")).toBeVisible();
  await page.waitForTimeout(400);
  await page.screenshot({ path: "test-results/welcome.png" });
  await clickVisible(page, "#start");
  await expect(page.locator("#welcome")).toBeHidden();
  await expect(page.locator("#site")).not.toHaveAttribute(
    "data-assembling",
    "true",
  );
  await clickVisible(page, "[data-page=components]");
  await expect(page.locator("section[data-view=components]")).toBeVisible();
  await expect(page.locator("#main")).toHaveAttribute("aria-busy", "false");
  await clickVisible(page, "#count-button");
  await expect(page.locator("#count")).toHaveText("1");
  await clickVisible(page, "#project-name");
  await page.keyboard.type("Hitbox verified");
  await expect(page.locator("#project-name")).toHaveValue("Hitbox verified");
  const points = await page.locator("#level").evaluate(async (el) => {
    const { lensDisplayPoint: l } = await import("/src/vendor/crt.js");
    const r = el.getBoundingClientRect();
    return [
      l(
        r.x + 12 + (r.width - 24) * 0.5,
        r.y + r.height / 2,
        innerWidth,
        innerHeight,
      ),
      l(
        r.x + 12 + (r.width - 24) * 0.8,
        r.y + r.height / 2,
        innerWidth,
        innerHeight,
      ),
    ];
  });
  await page.mouse.move(points[0].x, points[0].y);
  await page.mouse.down();
  await page.mouse.move(points[1].x, points[1].y, { steps: 12 });
  await page.mouse.up();
  await expect(page.locator("#level")).toHaveValue("80");
  await clickVisible(page, "#system-open");
  await expect(page.locator("#system-dialog")).toBeVisible();
  await page.waitForTimeout(800);
  await clickVisible(page, "[data-treatment=mono]");
  await expect(page.locator("body")).toHaveAttribute("data-treatment", "mono");
  await page.waitForTimeout(200);
  await page.screenshot({ path: "test-results/settings.png" });
  await page.keyboard.press("Escape");
  await expect(page.locator("#system-dialog")).not.toBeVisible();
  await page.waitForTimeout(400);
  await clickVisible(page, "#count-button");
  await expect(page.locator("#count")).toHaveText("2");
  await page.screenshot({ path: "test-results/components.png" });
  expect(errors).toEqual([]);
});

test("reference typography, logo contrast, control sounds, queued transitions and scroll detents", async ({
  page,
}) => {
  await page.addInitScript(() => {
    window.__played = [];
    HTMLMediaElement.prototype.play = function () {
      window.__played.push(this.src);
      return Promise.resolve();
    };
  });
  await page.goto("/");
  await expect(page.locator("#music-toggle")).toHaveCount(0);
  expect(
    await page
      .locator(".color-card.yellow canvas")
      .evaluate((c) =>
        Array.from(c.getContext("2d").getImageData(1, 4, 1, 1).data),
      ),
  ).toEqual([0, 0, 0, 255]);
  expect(
    await page
      .locator("h1")
      .first()
      .evaluate((el) => getComputedStyle(el).fontFamily),
  ).toContain("Barlow Condensed");
  await clickVisible(page, "#start");
  await expect(page.locator("#site")).toHaveAttribute(
    "data-assembling",
    "true",
  );
  await expect(page.locator("#site")).not.toHaveAttribute(
    "data-assembling",
    "true",
  );
  await page.evaluate(() => (window.__played = []));
  await clickVisible(page, "#system-open");
  await page.waitForTimeout(800);
  const cues = await page.evaluate(() => window.__played);
  expect(cues.some((s) => s.includes("preselect"))).toBe(true);
  expect(cues.some((s) => s.includes("clickevent"))).toBe(true);
  expect(cues.some((s) => s.includes("scanner"))).toBe(false);
  await page.keyboard.press("Escape");
  await expect(page.locator("#system-dialog")).not.toBeVisible();
  await clickVisible(page, "[data-page=foundations]");
  await clickVisible(page, "[data-page=panels]");
  await expect(page.locator("#site")).toHaveAttribute("data-view", "panels");
  await expect(page.locator("#main")).toHaveAttribute("aria-busy", "false");
  await clickVisible(page, "[data-page=components]");
  await expect(page.locator("#main")).toHaveAttribute("aria-busy", "false");
  await page.mouse.move(800, 600);
  await page.mouse.wheel(0, 240);
  await page.waitForTimeout(700);
  const scroll = await page.locator("#main").evaluate((el) => ({
    y: el.scrollTop,
    max: el.scrollHeight - el.clientHeight,
  }));
  expect(scroll.y).toBeGreaterThan(0);
  expect(
    Math.min(
      Math.abs(scroll.y - Math.round(scroll.y / 56) * 56),
      Math.abs(scroll.y - scroll.max),
    ),
  ).toBeLessThan(2);
  expect(
    await page.evaluate(() =>
      window.__played.some((s) => s.includes("lowerclack")),
    ),
  ).toBe(true);
  await page.screenshot({ path: "test-results/reference-components.png" });
});

test("entry uses source assembly without a second ASCII pass; real audio plays on input controls", async ({
  page,
}) => {
  await page.addInitScript(() => {
    window.__audio = [];
    window.__scrambles = 0;
    const play = HTMLMediaElement.prototype.play;
    HTMLMediaElement.prototype.play = function () {
      const record = { src: this.src, result: "pending" };
      window.__audio.push(record);
      return play.call(this).then(
        () => (record.result = "playing"),
        (e) => {
          record.result = e.name;
          throw e;
        },
      );
    };
    new MutationObserver((records) => {
      window.__scrambles += records.filter(
        (r) => r.attributeName === "data-ascii",
      ).length;
    }).observe(document, {
      subtree: true,
      attributes: true,
      attributeFilter: ["data-ascii"],
    });
  });
  await page.goto("/");
  await clickVisible(page, "#start");
  await expect(page.locator("#site")).toHaveAttribute(
    "data-assembling",
    "true",
  );
  await expect(page.locator("#welcome")).toBeHidden();
  await page.waitForTimeout(450);
  expect(await page.evaluate(() => window.__scrambles)).toBe(0);
  await page.screenshot({ path: "test-results/entry-overview.png" });
  await clickVisible(page, "[data-page=components]");
  await expect(page.locator("#main")).toHaveAttribute("aria-busy", "false");
  await page.evaluate(() => (window.__audio = []));
  await clickVisible(page, "#project-name");
  await page.waitForTimeout(250);
  const audio = await page.evaluate(() => window.__audio);
  expect(
    audio.some((a) => a.src.includes("preselect") && a.result === "playing"),
  ).toBe(true);
  expect(
    audio.some((a) => a.src.includes("clickevent") && a.result === "playing"),
  ).toBe(true);
  expect(audio.filter((a) => a.result !== "playing")).toEqual([]);
  expect(await page.evaluate(() => window.__scrambles)).toBe(0);
});

test("language scrambles with fitted action backgrounds and stable structural layout; appearance follows system with explicit overrides", async ({
  page,
}) => {
  await page.emulateMedia({ colorScheme: "dark" });
  await page.goto("/");
  await clickVisible(page, "#start");
  await expect(page.locator("#welcome")).toBeHidden();
  await clickVisible(page, "#system-open");
  await page.waitForTimeout(800);
  const geometry = () =>
    page.evaluate(() =>
      [
        ...document.querySelectorAll(
          "#site button,#site p[data-zh],#system-dialog button,#system-dialog label,#system-dialog h3",
        ),
      ]
        .filter(
          (el) =>
            el.getClientRects().length &&
            !el.hasAttribute("data-language-sized"),
        )
        .map((el) => {
          const r = el.getBoundingClientRect();
          return {
            id:
              el.id ||
              el.dataset.page ||
              el.dataset.language ||
              el.dataset.appearanceChoice ||
              el.dataset.treatment ||
              el.dataset.goto ||
              el.dataset.en ||
              el.tagName,
            x: r.x,
            y: r.y,
            w: r.width,
            h: r.height,
          };
        }),
    );
  const action = page.locator('[data-goto="components"]');
  const chineseWidth = await action.evaluate(
    (el) => el.getBoundingClientRect().width,
  );
  await expect(page.locator(".hero > .lead")).toHaveCSS(
    "background-color",
    "rgba(0, 0, 0, 0)",
  );
  await expect(page.locator("#softness")).toHaveCSS("appearance", "none");
  await expect(page.locator("#softness")).toHaveCSS("border-radius", "0px");
  const before = await geometry();
  await clickVisible(page, "[data-language=en]");
  // Capture the whole language transition synchronously: heading-only coverage
  // must not pass when prose, buttons or settings labels are omitted.
  const coverage = await page.evaluate(() =>
    [...document.querySelectorAll("[data-zh][data-en]")]
      .filter(
        (el) =>
          el.getClientRects().length &&
          !el.children.length &&
          el.textContent.trim(),
      )
      .map((el) => ({
        tag: el.tagName,
        text: el.textContent,
        active: el.classList.contains("ascii-scramble"),
        frame: el.dataset.ascii,
      })),
  );
  expect(coverage.some((el) => el.tag === "P" && el.text.length > 48)).toBe(
    true,
  );
  expect(coverage.some((el) => el.tag === "BUTTON")).toBe(true);
  expect(coverage.some((el) => el.tag === "SPAN")).toBe(true);
  expect(coverage.every((el) => el.active && el.frame)).toBe(true);
  await page.screenshot({ path: "test-results/language-content-scramble.png" });
  await page.waitForTimeout(600);
  await expect(page.locator(".ascii-scramble,[data-ascii]")).toHaveCount(0);
  const englishWidth = await action.evaluate(
    (el) => el.getBoundingClientRect().width,
  );
  expect(englishWidth).toBeGreaterThan(chineseWidth + 10);
  const after = await geometry();
  expect(after.length).toBe(before.length);
  for (let i = 0; i < before.length; i++)
    for (const key of ["x", "y", "w", "h"])
      expect(
        Math.abs(after[i][key] - before[i][key]),
        `${before[i].id} ${key} ${JSON.stringify(before[i])} -> ${JSON.stringify(after[i])}`,
      ).toBeLessThan(1.1);
  await expect(page.locator("html")).toHaveAttribute("data-appearance", "dark");
  await clickVisible(page, "[data-appearance-choice=light]");
  await expect(page.locator("html")).toHaveClass(/appearance-transition/);
  await expect(page.locator("html")).toHaveAttribute(
    "data-appearance",
    "light",
  );
  await page.waitForTimeout(600);
  await page.screenshot({ path: "test-results/light-settings.png" });
  await page.emulateMedia({ colorScheme: "dark" });
  await expect(page.locator("html")).toHaveAttribute(
    "data-appearance",
    "light",
  );
  await clickVisible(page, "[data-appearance-choice=system]");
  await expect(page.locator("html")).toHaveAttribute("data-appearance", "dark");
  await page.emulateMedia({ colorScheme: "light" });
  await expect(page.locator("html")).toHaveAttribute(
    "data-appearance",
    "light",
  );
  await page.reload();
  await expect(page.locator("html")).toHaveAttribute(
    "data-appearance",
    "light",
  );
});
