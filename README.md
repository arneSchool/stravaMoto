# stravaMoto

This repository contains a Flutter application. Firebase configuration files originally included
sensitive API keys which have been replaced with environment variable lookups.

## Firebase configuration

Create a `.env` file based on `.env.example` and provide your own API keys. During development
use `--dart-define` options or environment specific generation to supply these values.
The files `firebase_options.dart`, `google-services.json` and `GoogleService-Info.plist` should be
generated locally and are ignored from version control.
