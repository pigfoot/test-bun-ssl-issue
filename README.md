# Test Case: Bun + Podman SSL Issue on GitHub Actions ubuntu-24.04

**Purpose**: Verify GitHub Actions ubuntu-24.04 runner image 20251208.163.1 container networking issue that breaks `bun install` inside Podman containers.

## Issue Summary

- **Symptom**: `bun install` fails with `UNKNOWN_CERTIFICATE_VERIFICATION_ERROR` when running inside Podman containers on GitHub Actions ubuntu-24.04 runners (version 20251208.163.1+)
- **Root Cause**: Runner image networking configuration change affecting container network access
- **Workaround**: Use `--network=host` flag in `podman build`

## Test Setup

This minimal test case reproduces the issue with:
- Minimal `package.json` (single dependency: `zod`)
- Minimal `Containerfile` (Node.js + Bun + `bun install`)
- Two GitHub Actions workflows for comparison

## Expected Results

### Workflow 1: WITHOUT `--network=host` ❌
**File**: `.github/workflows/test-without-network-host.yml`

**Expected outcome**: FAIL with error similar to:
```
error: GET https://registry.npmjs.org/zod
error: UNKNOWN_CERTIFICATE_VERIFICATION_ERROR
```

### Workflow 2: WITH `--network=host` ✅
**File**: `.github/workflows/test-with-network-host.yml`

**Expected outcome**: SUCCESS - build completes without errors

## Running the Test

1. **Create a new public GitHub repository**
   ```bash
   gh repo create test-bun-ssl-issue --public --source=/tmp/test_bun_ssl_issue --push
   ```

2. **Or manually**:
   - Create new public repo on GitHub
   - Push contents of `/tmp/test_bun_ssl_issue`

3. **Trigger workflows**:
   - Go to Actions tab
   - Manually trigger both workflows via "Run workflow" button
   - Or push a commit to `main` branch

4. **Observe results**:
   - First workflow should FAIL on ubuntu-24.04
   - Second workflow should SUCCEED with `--network=host`

## Test Files

```
test_bun_ssl_issue/
├── package.json                     # Minimal dependencies
├── Containerfile                    # Bun install test
├── README.md                        # This file
└── .github/
    └── workflows/
        ├── test-without-network-host.yml  # Expected to FAIL
        └── test-with-network-host.yml     # Expected to SUCCEED
```

## Related Information

- **Original Issue Report**: `/tmp/github-actions-bun-ssl-issue-report.md`
- **Runner Image**: ubuntu-24.04 version 20251208.163.1
- **Release Date**: 2025-12-08
- **Affected Component**: Container networking (DNS/iptables/systemd-resolved)

## Next Steps After Verification

If this test confirms the issue:

1. ✅ File issue on https://github.com/actions/runner-images
2. ✅ Update documentation to recommend `--network=host` for Podman builds
3. ✅ Monitor runner-images releases for fixes

## Notes

- This test uses **podman-static** for heredoc syntax support (buildah >= 1.35.0)
- The issue is **runner-specific**, not code-specific
- Same Containerfile works perfectly on:
  - Local Podman environments
  - GitHub Actions runners prior to 20251208
  - GitHub Actions host (outside container)
