
import { Octokit } from "@octokit/rest";
import fs from "fs";

const review = fs.readFileSync("review.txt", "utf8");
const prNum  = Number(fs.readFileSync("pr_number.txt", "utf8"));

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
const body = [
  "🧠 Claude 自動レビュー結果:\n",
  review
].join("\n");

const { data } = await octokit.issues.createComment({
  owner: process.env.GITHUB_REPOSITORY_OWNER,
  repo:  process.env.GITHUB_REPOSITORY_NAME,
  issue_number: prNum,
  body,
});
console.log("Comment URL:", data.html_url);
