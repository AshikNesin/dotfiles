#!/usr/bin/env node
const path = require("path");

const {
  readJsonFromCsvFile,
  writeJsonToCsvFile,
  runShellCmd,
} = require("../helpers");

const type = process.argv[2];
const args = process.argv.slice(3);

const typeMapper = {
  "--brew": {
    fileName: "brew.csv",
    installCmd: "brew install",
  },
  "--cask": {
    fileName: "cask.csv",
    installCmd: "brew install --cask",
  },
  "--npm": {
    fileName: "npm.csv",
    installCmd: "npm install -g",
  },
};

if (typeMapper[type] === undefined) {
  console.log(`Make sure to pass install type properly. --brew, --cask, --npm`);
  process.exit(1);
}

const fileName = typeMapper[type].fileName;
const installCmd = typeMapper[type].installCmd;

const csvPath = path.join(
  __dirname.split("/scripts")[0],
  "config",
  "apps",
  fileName
);
console.log(csvPath);
const date = new Date().toISOString().split("T")[0];

(async () => {
  try {
    const appsInJson = await readJsonFromCsvFile(csvPath);
    const appsInMap = new Map([
      ...appsInJson.map((item) => [item.appName, { ...(item || {}) }]),
    ]);

    for (const app of args) {
      let item = {
        appName: app,
        lastInstalledOn: date,
        description: "",
      };

      if (appsInMap.has(app)) {
        item = {
          ...appsInMap.get(app),
          lastInstalledOn: date,
        };
      }
      appsInMap.set(app, item);
    }

    const resultJson = Array.from(appsInMap, ([appName, value]) => ({
      appName,
      ...(value || {}),
    }));

    await writeJsonToCsvFile(resultJson, csvPath);

    await runShellCmd(`${installCmd} "${args.join(" ")}"`);
  } catch (error) {
    console.log(error);
  }
})();
