const core = require('@actions/core');
const github = require('@actions/github');


async function run() {
  // Repo information
  const owner = core.getInput('owner');
  const repo = core.getInput("name");


  const pathToWrite = core.getInput('out-path');


  const myToken = core.getInput('github-token');
  const octokit = github.getOctokit(myToken)

  const latestRelease = await octokit.repos.getLatestRelease({
    owner,
    repo
  });
  console.log(latestRelease);
}

try {
  run() 
} catch (error) {
  core.setFailed(error.message);
}

