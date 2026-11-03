import { _electron } from 'playwright';
import fs from 'node:fs';
import assert from 'node:assert/strict';
const config = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const apps = [];
try {
  for (const executablePath of [config.executableA, config.executableB]) {
    const app = await _electron.launch({ executablePath, timeout: 30000 });
    apps.push(app);
    const page = await app.firstWindow();
    await page.waitForSelector('#start');
    assert.equal(await page.evaluate(() => typeof require), 'undefined');
    const details = await app.evaluate(({ app, BrowserWindow }) => ({
      name: app.name, profile: app.getPath('userData'), pid: process.pid,
      sandbox: BrowserWindow.getAllWindows()[0].webContents.getLastWebPreferences().sandbox,
      isolation: BrowserWindow.getAllWindows()[0].webContents.getLastWebPreferences().contextIsolation,
      noSandbox: app.commandLine.hasSwitch('no-sandbox'),
    }));
    assert.equal(details.sandbox, true);
    assert.equal(details.isolation, true);
    assert.equal(details.noSandbox, false);
    assert.ok(details.profile.startsWith(config.root + '/profiles/'));
    console.log(JSON.stringify(details));
    await page.screenshot({ path: config.root + '/' + details.name + '.png' });
  }
  assert.notEqual(apps[0].process().pid, apps[1].process().pid);
  await apps[0].close();
  assert.equal(await (await apps[1].firstWindow()).title(), 'AYM DevKit');
  console.log('Independent processes, isolated profiles, sandboxed renderers and quit isolation: PASS');
} finally {
  for (const app of apps) { try { await app.close(); } catch {} }
}
