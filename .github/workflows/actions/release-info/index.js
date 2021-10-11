const core = require('@actions/core');
const github = require('@actions/github');


async function run() {
  // Repo information
  const owner = core.getInput('owner');
  const repo = core.getInput('repo');

  // Path info
  const pathToWrite = core.getInput('out-path');

  // GH Api
  const myToken = core.getInput('github-token');
  const octokit = github.getOctokit(myToken)

  const latestRelease = await octokit.rest.repos.getLatestRelease({
    owner,
    repo
  });
  
  const releaseRaw = latestRelease.data;
  
  const releaseInfo = {};
  
  // Release metadata
  releaseInfo.version = releaseRaw.tag_name.slice(1);
  releaseInfo.name = releaseRaw.name;
  
  // Release assets
  releaseInfo.assets = [];
  for (asset of releaseRaw.assets) {
    const assetFile = await octokit.rest.repos.getReleaseAsset({
      accept: "application/octet-stream",
      owner,
      repo,
      asset_id: asset.id
    });
    console.log(assetFile);
    
    
    releaseInfo.assets.push({
      name: asset.name,
      download_url: asset.browser_download_url,
      checksum: "",
      size: asset.size
    });
  }
  
  console.log(releaseInfo);
}

try {
  run().catch((error) => {
    core.setFailed(error.message);
  }); 
} catch (error) {
  core.setFailed(error.message);
}

