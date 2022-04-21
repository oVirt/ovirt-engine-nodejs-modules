#!/usr/bin/env node

import process from 'process'
import path from 'path'
import chalk from 'chalk'
import { mkdir } from 'fs/promises'

import * as lib from './library.mjs'

console.log(`Verifying projects: [ ${Object.keys(lib.projects).map(n=>chalk.yellow(n)).join(', ')} ]`)
console.log(`working root: ${chalk.green(lib.paths.working_root)}`)

const results = {
  success: {},
  fail: {},
}

for await (const [name, info] of Object.entries(lib.projects)) {
  console.log()
  console.group('project: ' + chalk.yellow(name))
  console.log('starting verification')

  const gitRepoDir = path.join(lib.paths.working_root, name)
  await mkdir(gitRepoDir, { recursive: true })

  try {
    console.log('git url:', chalk.cyan(info.git_url))
    console.log('checkout and verify repo')
    const { commitId, importantFiles } = await lib.checkoutAndVerifyRepo(gitRepoDir, name, info)

    const installFromDir = `${gitRepoDir}_${info.branch}_${lib.data.run_date}.git.${commitId.slice(0, 7)}`
    await mkdir(installFromDir, { recursive: true })
    await lib.copyImportantFiles(gitRepoDir, installFromDir, importantFiles)

    const success = {
      installFromDir,
      commitId,
      importantFiles,
    }
    results.success[`${name}_${info.branch}`] = success

    console.group(chalk.green('SUCCESS'))
    console.log('head commit:', chalk.cyan(commitId))
    console.log('install from directory:', chalk.cyan(path.basename(installFromDir)))
    console.log('important files:', importantFiles)
    console.groupEnd()
  } catch (e) {
    console.group(chalk.red('FAIL'))
    console.log('reason:', chalk.white(e.message))
    console.groupEnd()
    results.fail[`${name}_${info.branch}`] = e
  }

  console.groupEnd()
}

console.log(`
results:
  - success: ${chalk.green(Object.keys(results.success).length)}
  - fail: ${chalk.red(Object.keys(results.fail).length)}
`)
process.exitCode = Object.keys(results.fail).length === 0 ? 0 : 1
