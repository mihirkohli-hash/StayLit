# StayLit

StayLit is a small menu bar utility for macOS 12 and newer. It keeps your Mac from going to sleep for a set time, or until you turn it off. On a MacBook that is plugged in, it can also keep the Mac awake with the lid closed.

## Installation

There are no prebuilt releases yet. Build the app from source with Xcode.

To build the Direct app and install it on your own Mac, run `make install-local`. It copies `StayLit.app` to `/Applications`, signs it ad hoc for local use and starts it. This build turns off library validation so macOS accepts the embedded Sparkle framework. Do not share a build made this way. A shareable build needs signing with an Apple Developer ID.

## How does it work?

The app is a small wrapper around Apple's `caffeinate` command line utility. All current versions of macOS ship with this tool by default. You can read the manual page [here](https://web.archive.org/web/20140604153141/https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man8/caffeinate.8.html).

### Does it work on a MacBook with a closed lid?

Yes, if you turn on **Stay awake when the lid is closed** in the Advanced settings.

* **On power:** StayLit adds `caffeinate -s` to keep the Mac awake.
* **On battery:** macOS has no supported way to do this, so StayLit turns on the hidden `SleepDisabled` power setting with `pmset`. That needs administrator rights. The first time you activate StayLit on battery, it asks for your administrator password once. It then adds a rule in `/etc/sudoers.d/staylit` that lets your user run only `pmset -a disablesleep 0` and `pmset -a disablesleep 1` without a password.
* **Turning it off again:** a small watchdog process turns `SleepDisabled` off when you deactivate StayLit, when the timer ends, when StayLit quits, and when StayLit crashes. If a logout stops the watchdog, StayLit turns the setting off the next time it starts. You can always run `sudo pmset -a disablesleep 0` yourself.
* **Removing the permission:** run `sudo rm /etc/sudoers.d/staylit`.
* **Build limits:** the battery mode only works in the Direct build, which does not use the App Sandbox. A sandboxed build cannot run `sudo`, so it stays on `caffeinate -s` and needs power.
* **Risks:** a closed Mac that stays awake gets hot and drains its battery. Do not leave it in a bag or other enclosed space. The built-in display can stay lit under the lid.

## Releasing

GitHub Actions tests the app on every push to `main` and builds a disk image when the tests pass. Download it from the run's artifacts. A version tag publishes it as a release, with the notes of that version from `CHANGELOG.md`.

1. While you work, add each user-visible change under `### Unreleased` in `CHANGELOG.md`.
2. Run `make prepare-release VERSION=1.7.0`. It turns the unreleased notes into the notes of that version, adds a fresh `### Unreleased` section and sets the version number. It does not run git.
3. Review the changes, commit them and push to `main`.
4. Run `git tag v1.7.0 && git push origin v1.7.0`. The workflow checks that the tag matches the app version, then publishes the release.

The image is signed ad hoc and not notarized, so macOS asks for confirmation the first time the app opens. A shareable release needs signing with an Apple Developer ID.

## Is this dangerous?

This utility will not harm your Mac because it is based on an official command line tool by Apple. **BUT** there is no guarantee of any kind, so use this tool **AT YOUR OWN RISK**.

## Contribution Guidelines

If you plan to contribute to the project, please read the [Contribution Guidelines](./CONTRIBUTING.md) first.

## License

StayLit is licensed under the [MIT license](./LICENSE). Parts of it come from other MIT-licensed software. Their copyright notices are in [NOTICE](./NOTICE).
