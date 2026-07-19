# GitHub Main-Branch Delivery Record

## Verified state

- Repository: `aafham/Sunnah-Everyday`
- Main branch: `main`
- Retained feature branch: `codex/sunnah-everyday-build`
- Pushed governance commit: `c1b089bf197431638d06edf3c7693f357b32da31`
- Pushed application-shell commit: `ae1cde4201686db56f072df4fd31aead04389a17`
- Pushed schema-baseline commit: `3680dc15f325ccb4f98c0f51997ae1c5d93e2ee5`
- Pushed content-contract commit: `64ea49206bdbc87ebe3cdc796ca354872735de0f`
- Pushed content-validation commit: `e0aeb6f4a3836492e18217fb35a9e6e3487bb4b7`
- Pushed Flutter-test-harness commit: `458232b992e5bae7db3806723b0c45c355d0419e`
- Pushed local-onboarding commit: `4913b548d7afccd25b4bf364b60d47ec77df1ad1`
- Pushed fail-closed-daily commit: `c8ddbebd1831ffb847ffee876006529574f68b0b`
- Pushed responsive-UX commit: `56daf54e3f7bd9c98ed92a5f0c778eba75479e7d`
- Pushed generic-RTL commit: `3031af27220f4897abfe305b63a40e2ebd8ed62b`
- Pushed private-reflection commit: `86f80bafb97348e91417a675c1550fdf89023874`
- Pushed display-settings accessibility commit: `0f4e79bec87f4c0ed9fd62f3562d3e64d7d1e362`
- Pushed safe-deep-link commit: `0437704676d4f471cf3e6aa7f27f5f598436a8ff`
- Pushed mobile quality regression commit: `2daac26c30d84db6d3ba177d01c1322fa4a38a4e`
- Pushed source-audit commit: `1aa0c83c7e92743f8b5aa6a0090faae44c5bba0a`
- Pushed CI workflow/hardening commits: `1c2463d`, `4ceff86` and
  `766e1fbb4ccb78ded664216a4819c42c0246bdbc`
- Main promotion: on explicit owner instruction, `main` was fast-forwarded from
  `137521e24133ee93605c9653e8175ea4519530fb` to
  `69273cbb15ef93cb32e803670d0b01716cfa7a44` and pushed successfully on
  2026-07-19. The retained feature branch remains at that promoted commit.
- GitHub CLI authentication: unavailable (`gh auth status` has no logged-in
  account), so protected repository settings cannot be inspected. No browser
  session was available as an authenticated fallback.
- CI: Quality run [29685451382](https://github.com/aafham/Sunnah-Everyday/actions/runs/29685451382)
  passed contracts, Flutter quality and debug/web smoke for `1aa0c83`.
  The contracts job includes current-source mobile-security and QLT-04 source
  audit guards; they are not signed-release, transitive-SDK, runtime,
  performance, device-security or Data Safety audits.
  No pull request was used for the owner-authorised main promotion.

## Remaining GitHub control

After authentication, inspect branch protection and CI on `main`. Do not
force-push or bypass checks for later deliveries.
