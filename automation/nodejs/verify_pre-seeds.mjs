#!/usr/bin/env node

import process from 'process'
import path from 'path'
import chalk from 'chalk'
import { mkdir } from 'fs/promises'
import { Octokit } from '@octokit/rest'

import * as lib from './library.mjs'

console.log(`Verifying pre-seeds: [ ${Object.keys(lib.preseeds).map(n=>chalk.yellow(n)).join(', ')} ]`)
console.log(`working root: ${chalk.green(lib.paths.working_root)}`)

const results = {
  success: {},
  fail: {},
}

/*
 * Configure Octokit and use an authentication token from the env var `GITHUB_TOKEN`
 * if it is available.  See https://octokit.github.io/rest.js/v18#authentication
 */
const octokit = new Octokit({
  userAgent: 'ovirt-engine-nodejs-modules',
  auth: process.env?.GITHUB_TOKEN ?? '',
})

for await (const [name, info] of Object.entries(lib.preseeds)) {
  console.log()
  console.group(`pre-seeds for: ${chalk.yellow(name)}`)

  // verify the github project by looking up the clone_url
  let git_url
  try {
    git_url = await lib.getCloneUrl(octokit, {
      owner: info.github.owner,
      repo: info.github.repo,
    })
    console.log('github project ok, git_url:', chalk.cyan(git_url))
  } catch (e) {
    console.error(chalk.red('could not access git clone url from github'))
    console.error(e)
    console.groupEnd()
    results.fail[name] = e
    continue
  }

  // verify each preseed PR listed for the project
  console.log(`pull requests to process: [ ${info.pr.map(p=>chalk.yellow(p)).join(', ')} ]`)
  for await (const pr of info.pr) {
    const prName = `${name}_pull${pr}`
    console.log()
    console.group(`${chalk.yellow(`PR #${pr}`)} (${prName})`)
    console.log('starting PR verification')

    // verify the PRs is open/unmerged
    try {
      await lib.verifyPullRequestStatus(octokit, {
        owner: info.github.owner,
        repo: info.github.repo,
        pull_number: pr,
      })
      console.log(`PR is ${chalk.green('good')} to use as a pre-seed`)
    } catch (e) {
      console.error(`PR ${chalk.red('verification fail')}`)
      console.error(e)
      console.groupEnd()
      results.fail[prName] = e
      continue
    }

    // IF the git_url is good and the PR is acceptable, then test the repo...
    const gitRepoDir = path.join(lib.paths.working_root, prName)
    await mkdir(gitRepoDir, { recursive: true })

    try {
      console.log('checkout and verify the PR\'s branch in the repo')
      const { commitId, importantFiles } = await lib.checkoutAndVerifyRepo(gitRepoDir, prName, {
        git_url,
        branch: `refs/pull/${pr}/head`,
        folder: info.folder,
      })

      const installFromDir = `${gitRepoDir}_${lib.data.run_date}.git.${commitId.slice(0, 7)}`
      await mkdir(installFromDir, { recursive: true })
      await lib.copyImportantFiles(gitRepoDir, installFromDir, importantFiles)

      const success = {
        installFromDir,
        commitId,
        importantFiles,
      }
      results.success[prName] = success

      console.group(chalk.green('SUCCESS'))
      console.log('head commit:', chalk.cyan(commitId))
      console.log('install from directory:', chalk.cyan(path.basename(installFromDir)))
      console.log('important files:', importantFiles)
      console.groupEnd()
    } catch (e) {
      console.group(chalk.red('FAIL'))
      console.log('reason:', chalk.white(e.message))
      console.groupEnd()
      results.fail[prName] = e

    }

    console.groupEnd()
  }

  console.groupEnd()
}

console.log(`
results:
  - success: ${chalk.green(Object.keys(results.success).length)}
  - fail: ${chalk.red(Object.keys(results.fail).length)}
`)
process.exitCode = Object.keys(results.fail).length === 0 ? 0 : 1
