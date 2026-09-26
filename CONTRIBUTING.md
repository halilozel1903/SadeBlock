# Contributing to SadeBlock

Thank you for helping improve native Safari ad blocking. Keep changes focused, easy to review, and supported by a reproducible example.

## Report a filtering problem

Open an issue with:

- Your macOS and Safari versions.
- The public page URL and steps to reproduce the issue.
- Whether an ad remains visible or legitimate content stops working.
- The result with SadeBlock enabled and disabled after reloading.
- A redacted screenshot or the relevant public ad domain, when useful.

Do not include cookies, access tokens, account details, or private browsing logs. A full network capture is not necessary.

## Submit a change

1. Fork the repository and create a focused branch.
2. Make the change. Keep domain patterns anchored and avoid generic selectors that could hide real content.
3. For filter changes, add representative positive and negative URL cases in `Tests/ValidateRules.swift` when relevant.
4. Run the Release build and rule validation commands in the README.
5. For UI or filter changes, manually verify behavior in Safari and describe what you checked.
6. Open a pull request explaining the problem, expected behavior, and test results.

Avoid unrelated formatting changes or generated Xcode user settings. Do not commit signing identities, provisioning profiles, binaries, or personal configuration.

## Design priorities

- Keep the content blocker independent of browsing-history access.
- Avoid telemetry and external runtime dependencies.
- Prefer targeted rules over broad patterns that cause site breakage.
- Document limits honestly; do not claim universal ad blocking or performance gains without evidence.

Contributions are provided under the repository’s MIT license.
