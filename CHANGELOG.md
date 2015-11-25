# 0.2.0 (11-25-15)

## Build changes

`make run` replaced with `make compile`. This will generate the built applications. Windows x64 build was added.

## Bug Fixes

- Fixed bug with saving user settings
- Updated README

## Features

- Added a setting to disable notifications
- Large refactor of codebase - created a number of models that are used within the watchdog app


# 0.1.5 (08-06-15)

## Build Changes

There is a new build process for developing in Watchdog. You can now simply run `make run` in the root directory of Watchdog. This will run a bunch of grunt tasks that will do all the work required to build a Watchdog.app file in the dist/ directory. With this release, the new build process will only work for the OS X build. This will be updated in the future to automatically build the Windows and Linux apps as well.

Along with this new build process, the overall architecture of the Watchdog has changed. All of the major app code is now contained in the `watchdog\app` directory.

# 0.1.4 (07-17-15)

## Bug Fixes

- Only display one icon in notifications
- Error checking for when a user entered on startup or in settings doesn't exist
- Loading screen when launching a stream is now more closely tied to what Livestreamer is doing
- Fix parsing bug when fetching followed streams
- Fixed input color on setup screen

## Features

- Added a menu option that checks to see if there is an update that can be downloaded.


# 0.1.3 (07-10-15)

## Bug Fixes

- Fixed error message being displayed everytime a stream was closed
- Tries to launch livestreamer in a Mac and Windows friendly way now

## Features

- Added build information on the settings page. Will display last updated date and current version for easier debugging
- Added a simple loading screen for launching a stream

# 0.1.2 (07-09-15)

## Bug Fixes

- Previous streamers were not being stored properly. This caused issues where notifications after initial launch would not be displayed.
- Updated README to include updated running instructions

# 0.1.1 (07-08-15)

## Bug Fixes

- If an error occurs when launching Livestreamer, a message is now displayed. No more guessing what happened!
- Fixed some ordering issues that caused streamers names to change order in the drop down menu ecerytime streamers were re-fetched
- Fixed some other small bugs

## Features

- Group streamers within the menu by the game they are playing
- NEW ICONS!!! We actually have our own awesome icons now, no more using copyrighted place holders.

# 0.1.0

- It lives!


