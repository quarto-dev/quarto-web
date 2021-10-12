const core = require("@actions/core");
const github = require("@actions/github");
const fetch = require("node-fetch");
const hasha = require("hasha");
const fs = require("fs");

async function run() {
  // Repo information
  const owner = core.getInput("owner");
  const repo = core.getInput("repo");

  // Path info
  const pathToWrite = core.getInput("out-path");
  const template = core.getInput("out-template");

  // GH Api
  const myToken = core.getInput("github-token");
  const octokit = github.getOctokit(myToken);

  const latestRelease = await octokit.rest.repos.getLatestRelease({
    owner,
    repo,
  });

  const releaseRaw = latestRelease.data;

  const releaseInfo = {};

  // Release metadata
  releaseInfo.version = releaseRaw.tag_name.slice(1);
  releaseInfo.name = releaseRaw.name;

  // Release assets
  releaseInfo.assets = [];
  for (asset of releaseRaw.assets) {
    const algorithm = "sha256";
    const assetFile = await fetch(asset.browser_download_url);
    const buffer = await assetFile.buffer();
    const checksum = hasha(buffer, { algorithm });

    releaseInfo.assets.push({
      name: asset.name,
      download_url: asset.browser_download_url,
      checksum,
      size: asset.size,
    });
  }

  const strJson = JSON.stringify(releaseInfo, undefined, 2);
  const output = template
    ? template.replace("$$DOWNLOAD_JSON$$", strJson)
    : strJson;
  console.log(`Writing to ${pathToWrite}`);
  console.log(`${output}]\n\n`);
  fs.writeFileSync(pathToWrite, output);
}

try {
  run().catch((error) => {
    core.setFailed(error.message);
  });
} catch (error) {
  core.setFailed(error.message);
}
