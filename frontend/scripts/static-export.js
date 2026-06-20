const fs = require("fs");
const path = require("path");

const rootDir = process.cwd();
const mainNextDir = path.join(rootDir, ".next");
const buildDir = path.join(mainNextDir, "standalone", ".next");
const publicDir = path.join(rootDir, "public");
const outDir = path.join(rootDir, "out");

if (fs.existsSync(outDir)) fs.rmSync(outDir, { recursive: true });

// Copies directories recursively
function copyDir(src, dest) {
  if (!fs.existsSync(src)) return;
  if (!fs.existsSync(dest)) fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const d = path.join(dest, entry.name);
    if (entry.isDirectory()) copyDir(s, d);
    else fs.copyFileSync(s, d);
  }
}

// Copy _next/static → out/_next/static (main .next/static, not standalone/.next)
const nextStaticSrc = path.join(mainNextDir, "static");
if (fs.existsSync(nextStaticSrc)) {
  copyDir(nextStaticSrc, path.join(outDir, "_next", "static"));
  console.log("Copied _next/static/");
} else {
  console.warn("WARNING: _next/static/ not found at", nextStaticSrc);
}

// Copy public/ → out/
copyDir(publicDir, outDir);

// Scan app HTML files and copy to out/ as directory index.html
const appDir = path.join(buildDir, "server", "app");
if (!fs.existsSync(appDir)) {
  console.error("Build output not found at:", appDir);
  console.error("Run 'npm run build' first.");
  process.exit(1);
}

function buildExport(dir, outPrefix) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory() && !entry.name.startsWith("_") && entry.name !== "page") {
      // Recurse into subdirectories
      buildExport(full, path.join(outPrefix, entry.name));
    } else if (entry.name.endsWith(".html") && entry.name !== "page.html") {
      // E.g. "chat.html" → out/chat/index.html, "index.html" → out/index.html
      let route = entry.name.replace(/\.html$/, "");
      // Special case: index.html stays at root
      let destDir;
      if (route === "index") {
        destDir = path.join(outDir, outPrefix);
      } else {
        destDir = path.join(outDir, outPrefix, route);
      }
      if (!fs.existsSync(destDir)) fs.mkdirSync(destDir, { recursive: true });
      fs.copyFileSync(full, path.join(destDir, "index.html"));
    }
  }
}
buildExport(appDir, "");

// Read root index.html as SPA fallback for dynamic routes
const indexPath = path.join(outDir, "index.html");
const indexHtml = fs.readFileSync(indexPath, "utf-8");

// Generate fallback pages for dynamic SSG routes
const dynamic = ["chat/[id]", "clinics/[id]", "doctors/[id]"];
for (const route of dynamic) {
  const parts = route.split("/");
  const dirPath = path.join(outDir, ...parts);
  if (!fs.existsSync(dirPath)) fs.mkdirSync(dirPath, { recursive: true });
  fs.writeFileSync(path.join(dirPath, "index.html"), indexHtml);
  console.log(`  → ${route}/index.html (fallback)`);
}

// Summary
console.log("\nGenerated files:");
function listFiles(dir, prefix) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) listFiles(p, `${prefix}${e.name}/`);
    else if (e.name === "index.html") console.log(`  ${prefix}${e.name} (${(fs.statSync(p).size / 1024).toFixed(1)} KB)`);
  }
}
listFiles(outDir, "");

console.log(`\nTotal size: ${(fs.readdirSync(outDir, { withFileTypes: true }).filter(f => f.name === "index.html").length)} pages`);
console.log("Done! Static export ready in 'out/'");
