# About our workflows

This repository uses different workflows to automatically updates the published websites

- <https://quarto.org/> - The documentation for Quarto, published from the `main` branch
- <https://prerelease.quarto.org/> - The documentation for Quarto prerelease, published from the `prerelease` branch

It also configures some website preview for pull requests, which are published to Netlify as deploy previews. The use non-production deploy and can be consulted to `deploy-preview-<PR number>.quarto.org`. 

Note that technically, <prerelease.quarto.org> is also a deploy preview on Netlify (non-production website) but with a fixed URL.

## Workflow files: What they do

- `publish.yml` - The workflow that publishes the documentation from `main` and `prerelease` branches to netlify. 
  - For stable release version, the doc is deployed from `main`, and published using `quarto publish netlify` command to production website on Netlify.
  - For prerelease version, the doc is deployed from `prerelease`, and published using Github Action `nwtgck/actions-netlify` which use Netlify API to deploy to a non-production website on Netlify.
    The prerelease website is build using a specific profile at render time, set in action using `QUARTO_PROFILE` environment variable.

- `preview.yml` - The workflow that creates a deploy preview for pull requests. It uses the same action `nwtgck/actions-netlify` to deploy to a non-production website on Netlify. The URL is `deploy-preview-<PR number>.quarto.org`.
  - PR previews are configured for any PR to `main` or`prerelease` branches.
  - They are automically created and updated when the PR is created and updated by a user with Contributor role. 
  - For external PR, the preview can be triggered by adding a comment `/deploy-preview` on the PR.
  - Any rendering to prerelease also uses a specific profile at render time, set in action using `QUARTO_PROFILE` environment variable.
  - Deploy previews use the `pr-preview` profile (`_quarto-pr-preview.yml`) which sets `draft-mode: visible` so that draft blog posts and pages are rendered and visible in PR previews. This is needed because `quarto render` (used in CI) hides drafts by default, unlike `quarto preview` (used locally) which always shows them.

- `update-downloads.yml` - This workflow is triggered by a cron schedule. It retrieves information about latest release and prerelease on `quarto-dev/quarto-cli` repository and updates the download links on the website.
  - If there is a new version detected, it will commit the modified files and trigger a deploy of the website calling `publish.yml` workflow with `workflow_call` event trigger.
  - This applies to both `main` and `prerelease` branches
    - For `main` branch, we use `stefanzweifel/git-auto-commit-action` to detect changes and commit them to the `main` branch
    - For `prerelease` branch, we use `git cherry-pick` the commit from main following previous above step. 
    - Then we trigger the `publish.yml` workflow with `workflow_call` event trigger for each of the branch.

- `upload-index.yml` - This workflow is triggered by a cron schedule. It updates the indexes for Algolia search engine, which powers the sites search. 
  - `search.json` is built when the website is rendered and then it is deployed to the website.
  - This index file is retrieved on deployed website to be updated on Algolia.
  - Both `quarto.org` and `prerelease.quarto.org` indexes are updated in the same run - they each use one specific algolia index

- `draft-check.yml` - A lightweight workflow that detects `draft: true` pages among changed `.qmd` files. Runs on all PRs to `main` and `prerelease` with no `paths-ignore`, so it always creates a status check. 
  - Uses the reusable composite action at `.github/workflows/actions/detect-drafts/`.
  - Configured as a required status check on `main` (`check-drafts` job), blocking merge until `draft: true` is removed.
  - Admin override is available for intentional draft merges.

- `port-to-prerelease.yml` - This workflow is used to sync changes made to main for quarto.org to prerelease branch for prerelease.quarto.org. 
  - It is triggered when a PR is merged in to `main`. It can also be triggered manually by adding a comment `/sync-prerelease` on a merged PR.
  - This workflow uses [`korthout/backport-action`](https://github.com/korthout/backport-action) to create a PR with the changes merged into `main` branch to be synced to `prerelease` branch.
  - It will also write a new `/deploy-preview` comment in the new PR to trigger the preview deployment from `preview.yml`.
  - This is possible because it uses a fine-grained PAT token which allows a workflow to trigger another using usual event (GITHUB_TOKEN does not allow that usually). This is configured in repo secrets.

## Reusable Composite Actions

Local composite actions live in `.github/workflows/actions/`:

- `detect-drafts/` - Scans changed `.qmd` files for `draft: true` in YAML frontmatter. Outputs `found` (true/false) and `files` (newline-separated paths). Used by both `preview.yml` (to tag drafts in the PR comment) and `draft-check.yml` (to fail the required check).
- `release-info/` - Retrieves release information from the quarto-cli repository.

## Netlify Configurations

- This repo has a `_redirects` file in the root directory. Otherwise, configuration are made in NETLIFY UI. Quarto website is inside Posit Netlify account. 
- Automatic builds are turned off for this repo on Netlify because we currently need to render with Quarto CLI in Gihub Action CI before publishing the results. 
  - API deploy is used currently, using npm netlify package through `nwtgck/actions-netlify` github actions. One think to know: Netlify has removed `deploy()` function from its npm package in version 7 and recommends now to use Netlify CLI instead. But we are still using the package for now in CI, but also for `quarto publish netlify`.
  - Deploy previews are possible with manual deploy using an alias configuration for the deploy command; This allows us to `deploy-preview-<PR number>` and `prerelease` alias to be used for the deploy previews. 
  - This means our netlify website don't use automatic builds and automatic Branch deploy - Only deploy previews. 
  - The website uses [Automatic Deploy Subdomains](https://docs.netlify.com/domains-https/custom-domains/automatic-deploy-subdomains/#use-a-new-custom-domain-for-your-automatic-deploy-subdomain) to have `prerelease.quarto.org` or `deploy-preview-<PR number>.quarto.org` working.

## Custom Domain

- `quarto.org` is registered in external registrar, but associated with Netlify DNS allowing use to use [custom domains](https://docs.netlify.com/domains-https/custom-domains/multiple-domains/).