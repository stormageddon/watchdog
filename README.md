# Watchdog

## About
Watchdog is a simple application for the Twitch diehard. It removes the pain of opening your browser, loading the streamers you follow, and finally (after YEARS of loading screens) seeing if there's anyone even worth watching currently streaming. Instead, you can run a single command from your terminal and immediately know who is streaming - before you've even opened a browser!

Watchdog uses [Electron](https://github.com/atom/electron) to launch a javascript application on your desktop. This app lives in your menu bar and displays a list of the streamers you follow when you click the icon! Eventually, clicking one of those streamers names will automatically launch that stream in your favorite video software (such as VLC), making the stream viewing experience super easy and, more importantly, super smooth. Currently, a gray icon means that no streamers are currently live, while a colored icon means that one or more streamers are available to watch.

If you decide you would like to watch one of those streamers, you simply click the streamers name and Livestreamer (if installed) will open up the best video player for you to stream in, and stream directly to that player! The biggest benefit of this is that Livestreamer allows you to avoid all of the nasty flash and programs on Twitch that tend to really bog down the quality of the stream.

## Goals
1. Avoid the hassle that is encountered when trying to use twitch. This means finding streamers and launching the stream without ever having to open a browser and navigating to twitch.tv
2. Provide a clean, easy, and seemless process for viewing your favorite streamers.

Note - This app is NOT a replacement for twitch. You'll still need an account and you'll still need to manage your followers and everything through Twitch. This just provides a simpler workflow for receiving notifications of your favorite streamers and then launching that particular stream.

## Installing Watchdog
Watchdog requires that you have the following installed on your system:

1. node
2. npm
3. [Livestreamer](https://github.com/chrippa/livestreamer)

If you do not have the above installed, please install those first.

Watchdog can be downloaded [here](http://stormageddon.github.io). Download the proper binary for your operating system and then run the Watchdog executable/application. That's all there is to it!

## Developing for Watchdog
The process hasn't been streamlined very well yet, but that's on the to-do list. The process below is what is currently necessary to build and run Watchdog yourself.

1. Ensure the dependencies listed above are installed
2. Clone the repository with `git clone git@github.com:stormageddon/watchdog.git`
3. navigate into the watchdog project
4. Run `npm install` to install the dependencies.
5. Download the correct [Electron source code package](https://github.com/atom/electron/releases) for your system.
6. Compile all of the .coffee files in Watchdog to .js files
7. Rename `Watchdog` directory to `app`
8. Copy `app` directory to your Electron installation directory (see Electrons [distribution docs](http://electron.atom.io/docs/v0.28.0/tutorial/application-distribution/) for where you should put the directory for your operating system)
9. Now you should finally be able to run Watchdog

## Current status
Watchdog is in the very early stages of development.
