#!/usr/bin/env node
import fs from "fs";
import { exec } from "child_process";
import semver from "semver";
import { readPackageUp } from 'read-pkg-up';

// Build array of available versions from input file
const versions = fs.readFileSync(process.argv.pop(), { encoding: "utf8" }).split("\n");

// Read closest package.json file
readPackageUp().then(({ packageJson }) => {
    console.log({ packageJson });
    try {
        // Determine highest version satisfying its version constraint
        const target = semver.maxSatisfying(versions, packageJson.engines.node);

        console.log({ target });

        // Check current node version and switch if necessary
        exec("node -v", (error, stdout) => {
            if (semver.clean(stdout) !== target) {
                console.log(`Switching to node v${target}`);
                exec(`n -p ${target}`);
            }
        });
    } catch (e) {
        console.log(e);
        // fail silently
    }
});
