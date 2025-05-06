
import { BedrockRuntimeClient, InvokeModelCommand } from "@aws-sdk/client-bedrock-runtime";
import { Octokit } from "@octokit/rest";
import fetch from "node-fetch";
import fs from "fs";

const github = new Octokit({ auth: process.env.GITHUB_TOKEN });
const commitSha = process.env.CODEBUILD_RESOLVED_SOURCE_VERSION;
const owner = process.env.GITHUB_REPOSITORY_OWNER;
const repo  = process.env.GITHUB_REPOSITORY_NAME;

// 1. PR 番号解決
const { data: prs } = await github.repos.listPullRequestsAssociatedWithCommit({
  owner, repo, commit_sha: commitSha, mediaType: { previews: ["groot"] }
});
if (!prs.length) { console.error("PR not found"); process.exit(1); }
const prNumber = prs[0].number;
fs.writeFileSync("pr_number.txt", String(prNumber));

// 2. diff 取得
const diffRes = await fetch(`https://api.github.com/repos/${owner}/${repo}/pulls/${prNumber}`, {
  headers: { Authorization: `token ${process.env.GITHUB_TOKEN}`, Accept: "application/vnd.github.v3.diff" }
});
if (!diffRes.ok) { console.error("diff fetch failed", diffRes.status); process.exit(1); }
const diff = await diffRes.text();

// 3. Claude 呼び出し
const prompt = `# Context\n以下はプルリクエストのdiffです。\n# Task\nこのdiffをレビューし、日本語で要約してください。\n- 変更概要\n- 懸念点\n- 改善点\n- 良い点\n- その他注意点\n\n# Diff\n\`\`\`diff\n${diff}\n\`\`\``;

const bedrock = new BedrockRuntimeClient({ region: "ap-northeast-1" });
const cmd = new InvokeModelCommand({
  modelId: "anthropic.claude-3-5-sonnet-20240620-v1:0",
  contentType: "application/json",
  accept: "application/json",
  body: JSON.stringify({
    anthropic_version: "bedrock-2023-05-31",
    max_tokens: 2000,
    messages: [{ role: "user", content: [{ type: "text", text: prompt }] }]
  })
});

const claudeRaw  = await bedrock.send(cmd);
const claudeText = JSON.parse(await claudeRaw.body.transformToString()).content?.[0]?.text || "レビュー取得失敗";
fs.writeFileSync("review.txt", claudeText);
console.log("Claude review saved → review.txt");