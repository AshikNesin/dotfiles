const shell = require("shelljs");

async function runShellCmd(cmd) {
  return new Promise((resolve, reject) => {
    shell.exec(cmd, async (code, stdout, stderr) => {
      if (!code) {
        return resolve(stdout);
      }
      return reject(stderr);
    });
  });
}

module.exports = runShellCmd;
