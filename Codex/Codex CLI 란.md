# Codex CLI 란

Codex CLI is OpenAI’s coding agent that you can run locally from your terminal. It can read, change, and run code on your machine in the selected directory. It’s open source and built in Rust for speed and efficiency.

https://developers.openai.com/codex/cli

# CLI setup

### install

Install the Codex CLI with npm.

```bash
npm i -g @openai/codex
```

### run

Run Codex in a terminal. It can inspect your repository, edit files, and run commands.

```bash
codex
```

The first time you run Codex, you'll be prompted to sign in. Authenticate with your ChatGPT account or an API key.

See the [pricing page](https://developers.openai.com/codex/pricing) if you're not sure which plans include Codex access.

### upgrade

New versions of the Codex CLI are released regularly. See the changelog for release notes. To upgrade with npm, run:

```bash
npm i -g @openai/codex@latest
```
