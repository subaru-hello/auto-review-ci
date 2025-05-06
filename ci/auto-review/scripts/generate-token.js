
import { Octokit } from "@octokit/rest";
import jwt from "jsonwebtoken";

const appId  = process.env.GITHUB_APP_ID;
const pKey   = process.env.GITHUB_APP_PRIVATE_KEY; // PEM
const owner  = process.env.GITHUB_REPOSITORY_OWNER;

function createJWT() {
  const now = Math.floor(Date.now() / 1000);
  return jwt.sign({ iat: now, exp: now + 600, iss: appId }, pKey, { algorithm: "RS256" });
}

const appOctokit = new Octokit({ auth: createJWT() });
const { data: installs } = await appOctokit.apps.listInstallations();
const inst = installs.find(i => i.account?.login === owner);
if (!inst) throw new Error(`Installation not found for ${owner}`);
const { data: token } = await appOctokit.apps.createInstallationAccessToken({ installation_id: inst.id });
console.log(`GITHUB_TOKEN=${token.token}`);