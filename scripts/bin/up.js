#!/usr/bin/env node

const { runShellCmd } = require("../helpers");

if (process.cwd().includes("chargebee-ui")) {
  runShellCmd("git pull origin master");
} else {
  runShellCmd("git pull origin main");
}
