# StayLit Automation

## URL Scheme

StayLit supports the `staylit:///` URL scheme to activate and deactive the app externally.

### activate

```
staylit:///activate
```

Activates and prevents sleep for the configured default duration.

#### activate?seconds=X

```
staylit:///activate?seconds=30
```

Activates and prevents sleep for exactly 30 seconds.

#### activate?minutes=X

```
staylit:///activate?minutes=5
```

Activates and prevents sleep for exactly 5 minutes.

#### activate?hours=X

```
staylit:///activate?hours=2
```

Activates and prevents sleep for exactly 2 hours.

_Please note: the seconds, minutes and hours parameters cannot be combined at the moment._

### deactivate

```
staylit:///deactivate
```

Deactivates and allows the system to go to sleep.

### toggle

```
staylit:///toggle
```

Toggles the activation state between activated and deactivated.

## Command Line Usage

The URL scheme can be used together with the `open` command to control StayLit from the command line.

```
open -g "staylit:///activate"
open -g "staylit:///activate?seconds=30"
open -g "staylit:///deactivate"
open -g "staylit:///toggle"
```
