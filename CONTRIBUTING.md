# Contribution Guidelines

Thank you for considering a contribution to StayLit. These guidelines help keep contributions easy to review.

## Localizations

Update or add a localization with a pull request that **only** contains the changed `*.xliff` files inside a `*.xcloc` localization catalog. Export the translations from _Xcode_ as an `*.xcloc` catalog. Keep them in `Localizations/StayLit/<language>.xcloc/Localized Contents/<language>.xliff`.

The maintainer imports localizations back into the app after the pull request is merged, and adds a new language to the project configuration at that time. Keep a localization pull request to a single language with no unrelated code changes.

Changes to `*.xcstrings` files directly are possible but not preferred.

### Credits (Optional)

Anyone who adds a language or makes major translation updates can be credited in `Credits.rtf`, which shows in the "About" tab of the app settings. To be credited, add a line in this format to the pull request or its description:

```
[language] Translation
[existing name or username] <email or URL as clickable link>
[your name or username] <email or URL as clickable link>
```

Follow the pattern of the other translation credits.

## Code Style and Programming Language

Follow the style of the existing code, especially for brackets (`{}`, `()`), spaces and line breaks. Use the `Auto` helper macro for type inference of local variables, which is non-standard in Objective-C.

Objective-C, C and C++ are the preferred languages. Code in other languages is not accepted at this time.

## Features, Structural Changes and UI Modifications

For a new feature, a structural change to the project setup or a UI change, open a GitHub issue first as a proposal. This avoids rework and long feedback cycles.

## Tests

Run the tests for the code you change. `make test` runs the full suite.
