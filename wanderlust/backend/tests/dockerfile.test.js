const assert = require('assert');
const fs = require('fs');

// Helper function to read Dockerfile contents
function readDockerfile(path) {
  try {
    return fs.readFileSync(path, 'utf8');
  } catch (err) {
    console.error(`Error reading file ${path}:`, err);
    return '';
  }
}

// Test for base image
function testBaseImage(dockerfilePath) {
  const dockerfile = readDockerfile(dockerfilePath);
  const baseImageLine = dockerfile.split('\n')[0];
  const baseImage = baseImageLine.split(' ')[1];
  assert.strictEqual(baseImage, 'node:21-alpine', `Base image should be node:21-alpine, but found ${baseImage}`);
}

// Test for optimized COPY command
function testOptimizedCopy(dockerfilePath) {
  const dockerfile = readDockerfile(dockerfilePath);
  const copyLine = dockerfile.split('\n').find(line => line.startsWith('COPY'));
  assert.ok(copyLine.includes('. .'), 'COPY command should be optimized for caching and layer reuse');
}

// Test for optimized installation
function testOptimizedInstallation(dockerfilePath) {
  const dockerfile = readDockerfile(dockerfilePath);
  const installLine = dockerfile.split('\n').find(line => line.startsWith('RUN'));
  assert.ok(installLine.includes('npm ci'), 'Installation should use npm ci for better performance and consistency');
}

// Test for exposed port
function testExposePort(dockerfilePath, expectedPort) {
  const dockerfile = readDockerfile(dockerfilePath);
  const exposeLine = dockerfile.split('\n').find(line => line.startsWith('EXPOSE'));
  const exposedPort = exposeLine.split(' ')[1];
  assert.strictEqual(exposedPort, expectedPort.toString(), `Expected port ${expectedPort}, but found ${exposedPort}`);
}

// Test for start command
function testStartCommand(dockerfilePath, expectedCommand) {
  const dockerfile = readDockerfile(dockerfilePath);
  const cmdLine = dockerfile.split('\n').find(line => line.startsWith('CMD'));
  const startCommand = cmdLine.split(' ').slice(1);
  assert.deepStrictEqual(startCommand, expectedCommand, `Expected start command ${expectedCommand}, but found ${startCommand}`);
}

// Run tests for frontend Dockerfile
testBaseImage('/frontend/Dockerfile');
testOptimizedCopy('/frontend/Dockerfile');
testOptimizedInstallation('/frontend/Dockerfile');
testExposePort('/frontend/Dockerfile', 5173);
testStartCommand('/frontend/Dockerfile', ['npm', 'run', 'dev', '--', '--host']);

// Run tests for backend Dockerfile
testBaseImage('/backend/Dockerfile');
testOptimizedCopy('/backend/Dockerfile');
testOptimizedInstallation('/backend/Dockerfile');
testExposePort('/backend/Dockerfile', 5000);
testStartCommand('/backend/Dockerfile', ['npm', 'start']);

console.log('All tests passed!');
