import path from 'path'
import simpleGit from 'simple-git'
import { statSync, rmSync } from 'fs'
import { copyFile } from 'fs/promises'

import projectsList from '../../projects.list.mjs'
import preSeedsList from '../../pre-seeds.list.mjs'

export const data = {
  run_date: (d => `${d.getFullYear()}${d.getMonth()<9?'0':''}${d.getMonth()+1}${d.getDate()<10?'0':''}${d.getDate()}`)(new Date()),
}

export const paths = {
  project_root: projectsList.config.project_root,
  working_root: process.env?.WORKING_ROOT ?? path.join(projectsList.config.project_root, '_working_'),
}

export const projects = projectsList.projects

export const preseeds = preSeedsList

/**
 * If the `working_root` folder exists, remove it.
 */
export function clearWorkingRoot () {
  if (fileExists(paths.working_root)) {
    console.info('removing the working_root:', paths.working_root)
    rmSync(paths.working_root, { force: true, recursive: true })
  }
}

/**
 * At the target directory, create a git repo fetch only the given ref from the given
 * repo and check it out as branch `target`.
 *
 * @param {string} dir Target working directory
 * @param {string} repoUrl Git URL for the remote repository to fetch from
 * @param {string} repoRef Remote ref to fetch, defaults to `master`
 * @param {string} localBranch Name of the local branch for the `remoteRef`, defaults to `target`
 *
 * @returns {string} Full hash code of the HEAD commit
 */
export async function checkoutRepo (dir, repoUrl, repoRef = 'master', localBranch = 'target') {
  const git = simpleGit(dir)
  const res =
    await git
      .init()
      .addRemote('origin', repoUrl)
      .fetch([
        '--no-tags',
        '--prune',
        '--depth=1',
        'origin',
        `${repoRef}:${localBranch}`,
      ])
      .checkout(localBranch)
      .log()

  return res.latest.hash
}

/**
 * Check if a file exists at the given path.
 */
export function fileExists (path) {
  const stat = statSync(path, { throwIfNoEntry: false })
  if (stat) {
    return true
  } else {
    return false
  }
}

/**
 * Checkout a remote ref and verify repo contents.
 *
 * @param {string} targetDir Target working directory
 * @param {string} name Working name of the repo
 * @param {Object} info Info about the repository
 * @param {string} info.git_url git clone URL
 * @param {string} info.branch remote branch to fetch and verify
 * @param {string} info.folder where to look for necessary files, defaults to `/`
 *
 * @returns {Object} result Verification result
 * @returns {string} result.commitId The head commit id for the remote branch
 * @returns {string[]} result.importantFiles Set of important file verified to exist in the repo
 */
export async function checkoutAndVerifyRepo(targetDir, name, { git_url, branch, folder = '/' }) {
  let commitId
  try {
    commitId = await checkoutRepo(targetDir, git_url, branch)
  } catch (cause) {
    throw new Error(`Problem checking out the repo (${git_url})`, {cause})
  }

  const importantFiles = [
    path.join(folder, 'package.json'),
    path.join(folder, 'yarn.lock'),
  ]

  if (!importantFiles.every(file => fileExists(path.join(targetDir, file)))) {
    throw new Error(`Not all of the important files exist in the repo: ${JSON.stringify(importantFiles)}`)
  }

  return { commitId, importantFiles }
}

/**
 * Copy the list of important files from the source directory to the root of the target
 * directory.
 *
 * @param {string} sourceDir Source path
 * @param {string} targetDir Destination path
 * @param {string[]} importantFiles Set of files to copy
 */
export async function copyImportantFiles(sourceDir, targetDir, importantFiles) {
  for (const importantFile of importantFiles) {
    await copyFile(
      path.join(sourceDir, importantFile),
      path.join(targetDir, path.basename(importantFile))
    )
  }
}

/**
 * Retrieve the `clone_url` for a github project via the github rest api.  Throws an
 * `Error` if there is a problem accessing the API or if the repository isn't available.
 *
 * @param {*} octokit Configured octokit instance
 * @param {Object} api github rest api info
 * @param {string} api.owner Repository owner
 * @param {string} api.repo Repository name
 *
 * @returns {string} The git `clone_url` for the project
 */
export async function getCloneUrl (octokit, { owner, repo }) {
  let clone_url

  let res
  try {
    res = await octokit.rest.repos.get({ owner, repo })
  } catch (cause) {
    throw new Error(`Problem accessing the github repo via api`, {cause})
  }

  if (res.status === 200) {
    clone_url = res.data.clone_url
  } else {
    throw new Error(`Problem accessing the github repo, response status: ${res.status}`)
  }

  return clone_url
}

/**
 * Verify that a pull request meets the criteria to be included as a pre-seed source.
 * Throws an `Error` if there is a problem accessing the API, if the pull request isn't
 * available, or if the pull request doesn't meet the criteria.
 *
 * @param {*} octokit Configured octokit instance
 * @param {Object} api github rest api info
 * @param {string} api.owner Repository owner
 * @param {string} api.repo Repository name
 * @param {number} api.pull_number PUll request ID
 *
 * @returns {boolean} Only returns if the PR passes verification
 */
export async function verifyPullRequestStatus (octokit, { owner, repo, pull_number }) {
  let res
  try {
    res = await octokit.rest.pulls.get({
      owner,
      repo,
      pull_number,
    })
  } catch (cause) {
    throw new Error(`Problem accessing the github pull request via api`, {cause})
  }

  if (res.status !== 200) {
    throw new Error(`Problem accessing the github pull request via api, response status: ${res.status}`)
  }

  if (res.data.state !== 'open' || res.data.merged) {
    throw new Error('PR is closed or merged, cannot use as a pre-seed')
  }

  return true
}
