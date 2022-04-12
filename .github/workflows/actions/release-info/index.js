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
  
  // Redirect info
  const redirectPath = core.getInput("redirects-path");
  const redirectTemplate = core.getInput("redirects-template");

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
  const redirects = [];
  for (asset of releaseRaw.assets) {
    const algorithm = "sha256";
    const assetFile = await fetch(asset.browser_download_url);
    const buffer = await assetFile.buffer();
    const checksum = hasha(buffer, { algorithm });

    console.log(asset.name);
    const parts = asset.name.split("-");
    const prefix = parts[0];
    const version = parts[1];
    
    const suffixParts = parts.slice(2).join("-").split(".");
    console.log(" -" + suffixParts);
    const suffix = suffixParts[0];
    const extension = suffixParts.slice(1).join('.');
    redirects.push({
      url: asset.browser_download_url,
      name: {
         prefix,
         version,
         suffix,
         extension
      }
    });
   
    releaseInfo.assets.push({
      name: asset.name,
      download_url: asset.browser_download_url,
      checksum,
      size: asset.size,
    });
  }
  
  if (redirectPath && redirectTemplate) {
     let redirOutput = [];
     for (const redirect of redirects) {
       const redir = redirectTemplate.replace("$$prefix$$", redirect.name.prefix || "")
                                           .replace("$$version$$", redirect.name.version || "")
                                           .replace("$$suffix$$", redirect.name.suffix || "")
                                           .replace("$$extension$$", redirect.name.extension || "");
       const redirLine = `${redir} ${redirect.url}`;
       redirOutput.push(redirLine);
     }
    
    const redirOut = redirOutput.join("\n");
    console.log(`Writing redirects file to ${redirectPath}`);
    console.log(`${redirOut}\n\n`);
    fs.writeFileSync(redirectPath, redirOut);
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
