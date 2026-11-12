#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');

function grokHome() {
  return process.env.GROK_HOME || path.join(process.env.HOME || process.cwd(), '.grok');
}

function projectId(projectRoot) {
  const absolute = path.resolve(projectRoot);
  const base = path.basename(absolute).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'project';
  const suffix = crypto.createHash('sha256').update(absolute).digest('hex').slice(0, 8);
  return `${base}-${suffix}`;
}

function paths(projectRoot) {
  const id = projectId(projectRoot);
  const dir = path.join(grokHome(), 'artifacts', 'auto-build-engine', id);
  return { id, dir, state: path.join(dir, 'state.json'), activity: path.join(dir, 'activity.jsonl') };
}

function appendActivity(file, record) {
  fs.appendFileSync(file, `${JSON.stringify({ at: new Date().toISOString(), ...record })}\n`, { mode: 0o600 });
}

function init(projectRoot) {
  const root = path.resolve(projectRoot);
  if (!fs.existsSync(root) || !fs.statSync(root).isDirectory()) throw new Error(`Project directory not found: ${root}`);
  const p = paths(root);
  fs.mkdirSync(p.dir, { recursive: true, mode: 0o700 });
  if (!fs.existsSync(p.state)) {
    const now = new Date().toISOString();
    const initial = {
      schema_version: 1,
      project_id: p.id,
      project_root: root,
      status: 'ready',
      phase: 'discovery',
      completed_phases: [],
      pending_items: [],
      runs_used: 0,
      max_runs_requested: 5,
      created_at: now,
      updated_at: now
    };
    fs.writeFileSync(p.state, `${JSON.stringify(initial, null, 2)}\n`, { mode: 0o600, flag: 'wx' });
    appendActivity(p.activity, { event: 'initialized', project_id: p.id, project_root: root });
  }
  process.stdout.write(`${JSON.stringify({ project_id: p.id, project_root: root, state_file: p.state, activity_file: p.activity }, null, 2)}\n`);
}

function readState(projectRoot) {
  const p = paths(projectRoot);
  if (!fs.existsSync(p.state)) throw new Error(`No saved state for ${path.resolve(projectRoot)}. Run /build first.`);
  return { p, state: JSON.parse(fs.readFileSync(p.state, 'utf8')) };
}

function begin(projectRoot) {
  const { p, state } = readState(projectRoot);
  if (state.status === 'complete') {
    process.stdout.write(`${JSON.stringify({ ...state, message: 'Objective is already marked complete.' }, null, 2)}\n`);
    return;
  }
  const limit = Number.isInteger(state.max_runs_requested) ? state.max_runs_requested : 5;
  if (state.runs_used >= limit) throw new Error(`Requested run budget exhausted (${state.runs_used}/${limit}). Resume only after the operator authorizes additional runs.`);
  state.runs_used += 1;
  state.status = 'running';
  state.updated_at = new Date().toISOString();
  state.last_run_started_at = state.updated_at;
  fs.writeFileSync(p.state, `${JSON.stringify(state, null, 2)}\n`, { mode: 0o600 });
  appendActivity(p.activity, { event: 'run_started', run: state.runs_used, run_budget: limit, phase: state.phase });
  process.stdout.write(`${JSON.stringify(state, null, 2)}\n`);
}

function checkpoint(projectRoot, phase, status, message) {
  const { p, state } = readState(projectRoot);
  state.phase = phase;
  state.status = status;
  state.updated_at = new Date().toISOString();
  state.last_message = message || '';
  if (status === 'complete' && !state.completed_phases.includes(phase)) state.completed_phases.push(phase);
  fs.writeFileSync(p.state, `${JSON.stringify(state, null, 2)}\n`, { mode: 0o600 });
  appendActivity(p.activity, { event: 'checkpoint', phase, status, message: message || '' });
  process.stdout.write(`${JSON.stringify(state, null, 2)}\n`);
}

function selfTest() {
  const manifestPath = path.join(__dirname, '..', 'plugin.json');
  const skillPath = path.join(__dirname, '..', 'skills', 'build', 'SKILL.md');
  JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  const skill = fs.readFileSync(skillPath, 'utf8');
  if (!skill.startsWith('---\n') || !skill.includes('name: build')) throw new Error('Build skill frontmatter is missing or malformed.');
  process.stdout.write('Auto-Build Engine self-test passed.\n');
}

function main(argv) {
  const [command, ...args] = argv;
  if (command === 'self-test') return selfTest();
  if (command === 'init') return init(args[0] || process.cwd());
  if (command === 'begin') return begin(args[0] || process.cwd());
  if (command === 'status') {
    const { state } = readState(args[0] || process.cwd());
    process.stdout.write(`${JSON.stringify(state, null, 2)}\n`);
    return;
  }
  if (command === 'checkpoint') {
    if (args.length < 3) throw new Error('Usage: core-engine.js checkpoint <project-dir> <phase> <status> [message]');
    return checkpoint(args[0], args[1], args[2], args.slice(3).join(' '));
  }
  throw new Error('Usage: core-engine.js <self-test|init|begin|status|checkpoint> [args]');
}

try {
  main(process.argv.slice(2));
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
