# StayLit

StayLit is a small menu bar utility for macOS 12 and newer. It keeps your Mac from going to sleep for a set time, or until you turn it off. On a MacBook that is plugged in, it can also keep the Mac awake with the lid closed.

## Installation

There are no prebuilt releases yet. Build the app from source with Xcode.

## How does it work?

The app is a small wrapper around Apple's `caffeinate` command line utility. All current versions of macOS ship with this tool by default. You can read the manual page [here](https://web.archive.org/web/20140604153141/https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man8/caffeinate.8.html).

### Does it work on a MacBook with a closed lid?

Yes, if you turn on **Stay awake when the lid is closed (requires power adapter)** in the Advanced settings, and the Mac is connected to power. This runs `caffeinate -s`, and macOS ignores that assertion on battery, so the Mac still sleeps when you close the lid unplugged. Keeping a closed MacBook running in a bag or other enclosed space can overheat it.

## Is this dangerous?

This utility will not harm your Mac because it is based on an official command line tool by Apple. **BUT** there is no guarantee of any kind, so use this tool **AT YOUR OWN RISK**.

## Contribution Guidelines

If you plan to contribute to the project, please read the [Contribution Guidelines](./CONTRIBUTING.md) first.

## License

Everything in this project is licensed under the [MIT license](http://opensource.org/licenses/MIT). See [LICENSE](./LICENSE) for the copyright notices, including those of the open source project StayLit is based on.
