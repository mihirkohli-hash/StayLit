# SLTSleepWakeTimer

The `SLTSleepWakeTimer` controls the `caffeinate` process and allows preventing your Mac from going to sleep.

When the lid-closed setting is on, the timer also passes `-s` to `caffeinate`, which keeps a MacBook awake with the lid closed while it runs on AC power.
