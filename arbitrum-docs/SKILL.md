---
name: arbitrum-docs
description: Look up the official Arbitrum documentation before answering questions about Arbitrum, Arbitrum One, Arbitrum Nova, Arbitrum Orbit chains, Nitro, Stylus, ArbOS, BoLD, the Arbitrum bridge, retryable tickets, L1-to-L2 or L2-to-L1 messaging, Arbitrum precompiles (ArbSys, ArbGasInfo, ArbRetryableTx, ...), the Arbitrum SDK, sequencer, batch poster, validators, or running an Arbitrum node. Use whenever the user mentions "Arbitrum", "Arb", "Arb1", "Nitro", "Stylus", "Orbit chain", or asks how something differs between Arbitrum and Ethereum.
compatibility: Requires network access and curl.
allowed-tools: Bash(curl:*) Bash(grep:*) Bash(rg:*) Bash(wc:*) Bash(find:*) Bash(stat:*) Read
---

# Arbitrum docs

Answer Arbitrum questions from the official documentation, not from memory. The full docs are published as a single plain-text file at https://docs.arbitrum.io/llms-full.txt (about 4 MB, ~490 sections, each starting with a `# Title` line).

## Workflow

1. **Ensure a fresh local copy.** Cache the file at `~/.cache/arbitrum-docs/llms-full.txt`. Re-download if the file is missing or older than one day:

   ```bash
   mkdir -p ~/.cache/arbitrum-docs
   f=~/.cache/arbitrum-docs/llms-full.txt
   if [ ! -f "$f" ] || [ -n "$(find "$f" -mtime +1)" ]; then
     curl -sSL https://docs.arbitrum.io/llms-full.txt -o "$f"
   fi
   wc -c "$f"
   ```

2. **Never read the whole file.** It does not fit in context. Locate relevant sections first:

   ```bash
   # list headings (any level) matching a topic
   grep -n '^#\{1,3\} ' "$f" | grep -i 'retryable'
   # search body text with context
   grep -n -i -C 3 'ArbSys' "$f" | head -100
   ```

3. **Read only the relevant sections** with the `Read` tool using `offset` and `limit` based on the line numbers found above. A page runs from its `# Title` line to the next `# ` line, with `##` and `###` subsections inside.

4. **Answer from the docs.** Quote or paraphrase the documentation, and name the section title you used so the user can find it at https://docs.arbitrum.io. If the docs do not cover the question, say so explicitly rather than guessing.

## Notes

- Prefer the docs over prior knowledge when they disagree. Arbitrum changes frequently (ArbOS upgrades, BoLD, Stylus) and memory is likely stale.
- For questions that are about code in the user's repository (for example the nitro or nitro-contracts repos), still consult the docs for protocol behavior, then check the code for implementation details.
- If the download fails, tell the user and fall back to `WebFetch` on the specific page under https://docs.arbitrum.io/ if the tool is available.
