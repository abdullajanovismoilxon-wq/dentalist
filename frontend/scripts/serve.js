const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const root = process.cwd();
const standaloneDir = path.join(root, ".next", "standalone");
const staticSrc = path.join(root, ".next", "static");
const staticDest = path.join(standaloneDir, ".next", "static");

// 1. Copy static files to standalone dir
if (!fs.existsSync(standaloneDir)) {
  console.error("Build not found. Run 'npm run build' first.");
  process.exit(1);
}
if (fs.existsSync(staticSrc) && !fs.existsSync(staticDest)) {
  fs.cpSync(staticSrc, staticDest, { recursive: true });
  console.log("✓ Static files copied to standalone");
}

// 2. Start the standalone server
console.log("Starting production server on http://localhost:3000");
const server = require(path.join(standaloneDir, "server.js"));
