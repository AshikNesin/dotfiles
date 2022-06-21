#!/usr/bin/env node

const simpleGit = require("simple-git");
const git = simpleGit().clean(simpleGit.CleanOptions.FORCE);

const pullOrigin = (branchName) => {
  return git
    .exec(() => console.log("Starting pull..."))
    .pull("origin", branchName)
    .exec(() => console.log("pull done."));
};

(async () => {
  if (process.cwd().includes("chargebee-ui")) {
    await pullOrigin("master");
    let currentGitStatus = await git.status();
    if (
      !currentGitStatus.isClean() &&
      currentGitStatus.modified.includes("cb-open-api-specs")
    ) {
      git.submoduleUpdate("cb-open-api-specs", "master");
    }
  } else {
    pullOrigin("main");
  }
})();
