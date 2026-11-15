# StayLit

## Changelog

### Unreleased

- added a "Stay awake when the lid is closed" advanced setting. On power it uses `caffeinate -s`. On battery it turns on `pmset disablesleep` after a one-time administrator permission, and a watchdog turns it off again when the session ends or the app crashes. Battery mode needs the non-sandboxed Direct build
- the menu bar and app icons are now a desktop computer
- added a "Menu Bar Icon Color" drop-down in the General settings with White (default), Dark and Follow System
- the screen of the menu bar icon pulses while StayLit is active, and the monitor body stays steady. A white icon pulses black and a dark icon pulses white. The pulse stops when macOS Reduce Motion is on, and an Advanced setting turns it off. A custom icon fades as a whole instead
- added a "Pulse Duration" drop-down in the General settings with 0.5, 1 (default), 2, 3 and 5 seconds for one pulse cycle
