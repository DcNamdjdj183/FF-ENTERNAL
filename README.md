# FFKernelCheat

Unsigned iOS IPA. Kernel R/W chain for Free Fire entity walk, aim, ESP.

## Structure
- `exploit/` and `kexploit/` — paste your C sources and headers here before build.
- Bridging header already imports the expected headers.
- GitHub Actions builds unsigned archive + IPA on push.

## Build
1. Push this repo to GitHub.
2. Actions runs `build_ipa.yml` on macos-latest.
3. Download artifact `FFKernelCheat-IPA`.
4. Sideload the unsigned IPA with your preferred tool.

## Boot Sequence
`KernelAutoLoader.boot()` → `kexploit_opa334()` → `offsets_init()` → `sandbox_escape()` → resolve Free Fire pid + libil2cpp.so base.

Singleton + `os_unfair_lock` around all kernel ops. 3 retries at 500 ms. Falls back to userland if kernel fails. Threads pause on background, killed on terminate. Re-resolves base if process restarts.

## Credit
Developer: Dinh Duc Nam  
Contact: 0395109314 - 0332011756

## Notes
- Paste complete C implementations into `exploit/` and `kexploit/` before the Actions run.
- App is dark theme, glass cards, splash with credit.
- Features toggles write through `KernelRW` once the exploit is live.
