const core = require('@actions/core');
const github = require('@actions/github');


async function run() {
  // Repo information
  const owner = core.getInput('owner');
  const repo = core.getInput("name");


  const pathToWrite = core.getInput('out-path');


  const octokit = new github.GitHub(
    core.getInput('github_token', { required: true })
  )

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

