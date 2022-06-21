#!/usr/bin/env node

// Create new branch from master / main
const simpleGit = require("simple-git");
const git = simpleGit().clean(simpleGit.CleanOptions.FORCE);
const args = process.argv.slice(2);

const isCbUI = process.cwd().includes("chargebee-ui");

const branchName = args[0];
const startPoint = args[1] || isCbUI ? "origin/master" : "origin/main";

const createNewBranch = (branchName, startPoint = "origin/main") => {
  return git
    .exec(() => console.log("Creating new branch branch..."))
    .checkoutBranch(branchName, startPoint)
    .exec(() => console.log("done."));
};

createNewBranch(branchName, startPoint);
