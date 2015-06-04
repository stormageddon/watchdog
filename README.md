# Watchdog

## About
Watchdog is a simple application for the Twitch diehard. It removes the pain of opening your browser, loading the streamers you follow, and finally (after YEARS of loading screens) seeing if there's anyone even worth watching currently streaming. Instead, you can run a single command from your terminal and immediately know who is streaming - before you've even opened a browser!

Watchdog uses [Electron](https://github.com/atom/electron) to launch a javascript application on your desktop. This app lives in your menu bar and displays a list of the streamers you follow when you click the icon! Eventually, clicking one of those streamers names will automatically launch that stream in your favorite video software (such as VLC), making the stream viewing experience super easy and, more importantly, super smooth. Currently, a gray icon means that no streamers are currently live, while a colored icon means that one or more streamers are available to watch.

## Goals
1. Avoid the hassle that is encountered when trying to use twitch. This means finding streamers and launching the stream without ever having to open a browser and navigating to twitch.tv
2. Provide a clean, easy, and seemless process for viewing your favorite streamers.

Note - This app is NOT a replacement for twitch. You'll still need an account and you'll still need to manage everything through Twitch. This just provides a simpler workflow for receiving notifications of your favorite streamers and then launching that particular stream.

## Installing Watchdog
Watchdog requires that you have the following installed on your system:

1. node
2. npm

If you do not have the above installed, please install those first.

1. Clone the repository with `git clone git@github.com:stormageddon/watchdog.git`
2. navigate into the watchdog project
3. Run `npm install` to install the dependencies.

You are now set to begin using Watchdog!

## To run Watchdog
Simply run `npm start <Your Twitch Username>` in the watchdog directory. It's really that easy!

If you want to make it even easier to see who's online, you can create an alias within your .bashrc, .zshrc, or the config of whatever shell you use. The best way to alias watchdog is to begin running it in a separate shell by using the following alias command:

`alias watchdog="(cd <path to watchdog root directory>; npm start <Your Twitch Username>)"`

Then you can just run `watchdog` in your terminal and Watchdog will launch.

## Current status
Watchdog is in the very early stages of development. At this point in time, all it will do is display a list of the channels that you watch that are currently streaming. It also displays a notification if another of your followed streamers begins streaming.
