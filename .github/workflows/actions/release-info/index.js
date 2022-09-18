const core = require("@actions/core");
const github = require("@actions/github");
const fetch = require("node-fetch");
const hasha = require("hasha");
const fs = require("fs");
const path = require("path");

async function run() {
  // Repo information
  const owner = core.getInput("owner");
  const repo = core.getInput("repo");

  // Path info
  const pathToWrite = path.join(core.getInput("out-path"), "_download.json");
  const prePathToWrite = path.join(core.getInput("out-path"), "_prerelease.json");
  const template = core.getInput("out-template");
  

  // GH Api
  const myToken = core.getInput("github-token");
  const octokit = github.getOctokit(myToken);
  
  // Redirect info
  const redirectPath = core.getInput("redirects-path");
  const redirectTemplate = core.getInput("redirects-template");
  const preRedirectTemplate = core.getInput("pre-redirects-template")

  // Function to process a release into a set of 
  // download urls / info and a list of redirects
  const processRelease = async (releaseRaw) => {
    const releaseInfo = {};

    // Release metadata
    releaseInfo.version = releaseRaw.tag_name.slice(1);
    releaseInfo.name = releaseRaw.name;
    releaseInfo.created = releaseRaw.created_at;
    releaseInfo.updated = releaseRaw.updated_at;
    releaseInfo.published = releaseRaw.published_at;

    // Release assets
    releaseInfo.assets = [];
    const redirects = [];
    for (asset of releaseRaw.assets) {
      const algorithm = "sha256";
      const assetFile = await fetch(asset.browser_download_url);
      const buffer = await assetFile.buffer();
      const checksum = hasha(buffer, { algorithm });
      
      if (asset.name === 'changelog.md') {
        var decoder = new TextDecoder("utf-8");
        
        releaseInfo.description = decoder.decode(buffer);
      }

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
    
    return {
      redirects,
      releaseInfo
    }
  }
  
  // Function to get latest prerelease
  const getPrerelease = async () => {
    // List the releases
    var pagenumber = 1;
    var matchedRelease = undefined;
    while(true) {
      console.log("page " + pagenumber + " of prereleases");
      var releases = await octokit.rest.repos.listReleases({
        owner,
        repo,
        per_page: 25,
        page: pagenumber
      });  

      for (const release of releases.data) {
        if (release.prerelease) {
          matchedRelease = release;
          break;
        }
      }

      if (matchedRelease) {
        break;
      } else {
        pagenumber = pagenumber + 1;
      }
    }
    return matchedRelease;    
  }

  const generateRedirects = (redirects, redirTemplate) => {
    let redirOutput = [];
    for (const redirect of redirects) {
      const redir = redirTemplate.replace("$$prefix$$", redirect.name.prefix || "")
                                          .replace("$$version$$", redirect.name.version || "")
                                          .replace("$$suffix$$", redirect.name.suffix || "")
                                          .replace("$$extension$$", redirect.name.extension || "");
      const redirLine = `${redir} ${redirect.url}`;
      redirOutput.push(redirLine);
    }
    return redirOutput;
  }

  const writeReleaseFile = (path, releaseInfo, template) => {
    // Write the download json file
    const strJson = JSON.stringify(releaseInfo, undefined, 2);
    const output = template
      ? template.replace("$$DOWNLOAD_JSON$$", strJson)
      : strJson;
    console.log(`Writing to ${path}`);
    console.log(`${output}]\n\n`);
    fs.writeFileSync(path, output);

  }
  
  // Process the latest release
  const latestRelease = await octokit.rest.repos.getLatestRelease({
    owner,
    repo,
  });
  const releaseProcessed = await processRelease(latestRelease.data);
  const redirects = releaseProcessed.redirects;
  const releaseInfo = releaseProcessed.releaseInfo;
  if (releaseInfo.assets === undefined || releaseInfo.assets.length === 0) {
    throw new Error("Error generating downloads - an empty release was detected.");
  }
  

  // Process the latest pre-release
  console.log("Starting prelease");
  const prerelease = await getPrerelease();
  const prereleaseProcessed = await processRelease(prerelease);
  const prereleaseInfo = prereleaseProcessed.releaseInfo;
  if (prereleaseInfo.assets === undefined || prereleaseInfo.assets.length === 0) {
    throw new Error("Error generating downloads - an empty pre-release was detected.");
  }


  // Note the prerelease data as a test
  console.log(prereleaseProcessed);
  
  // Write the redirects
  if (redirectPath && redirectTemplate) {
    const redirOutput = [];
    // Stable / latest release
    redirOutput.push(...generateRedirects(redirects, redirectTemplate));

    // Unstable / latest prerelease
    redirOutput.push(...generateRedirects(prereleaseProcessed.redirects, preRedirectTemplate));
    
    const redirOut = redirOutput.join("\n");
    console.log(`Writing redirects file to ${redirectPath}`);
    console.log(`${redirOut}\n\n`);
    fs.writeFileSync(redirectPath, redirOut);
  }

  // Write the download json file
  writeReleaseFile(pathToWrite, releaseInfo, template);

  // Write the prerelease file
  writeReleaseFile(prePathToWrite, prereleaseInfo, template);
}

try {
  run().catch((error) => {
    core.setFailed(error.message);
  });
} catch (error) {
  core.setFailed(error.message);
}
