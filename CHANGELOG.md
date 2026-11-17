# StayLit

## Changelog

### Unreleased

### v1.7.1 (2026-11-17)

- fixed a second activation leaving the earlier `caffeinate` process running after StayLit was turned off
- fixed the timer state changing off the main thread, and a crash when a running timer was released
- fixed the `activate` URL and Shortcuts action leaving the icon inactive while the Mac was kept awake, and made it reject negative or non-numeric durations
- fixed switching back to a user session starting an indefinite session that nobody asked for
- fixed external display detection, which read uninitialized values and ended the session in clamshell mode with an external main display
- fixed the launch at login setting not reporting its change
- the battery-mode permission is now one file per user, `/etc/sudoers.d/staylit-<user name>`, so a second user no longer replaces the first user's rule
- the ad-hoc signed app no longer carries the library validation exception

### v1.7.0 (2026-11-15)

- added a "Stay awake when the lid is closed" advanced setting. On power it uses `caffeinate -s`. On battery it turns on `pmset disablesleep` after a one-time administrator permission, and a watchdog turns it off again when the session ends or the app crashes. Battery mode needs the non-sandboxed Direct build
- the menu bar and app icons are now a desktop computer
- added a "Menu Bar Icon Color" drop-down in the General settings with White (default), Dark and Follow System
- the screen of the menu bar icon pulses while StayLit is active, and the monitor body stays steady. A white icon pulses black and a dark icon pulses white. The fade changes 20 times a second at every speed, so it looks smooth, and it pauses while the displays sleep. The pulse stops when macOS Reduce Motion is on, and an Advanced setting turns it off. A custom icon fades as a whole instead
- added a "Pulse Duration" drop-down in the General settings with 0.5, 1, 2 (default), 3 and 5 seconds for one pulse cycle
