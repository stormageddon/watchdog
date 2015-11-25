# Watchdog

![Watchdog, Media](/app/img/watchdog-icon.png)

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
The build process for Watchdog is currently only streamlined for building Watchdog for use on a Mac. For alternate OS builds, follow Electrons suggested build process.

1. Ensure the dependencies listed above are installed
2. Clone the repository with `git clone git@github.com:stormageddon/watchdog.git`
3. navigate into the watchdog project
4. Run `npm install` to install the dependencies.
5. Run `make compile` to build the Watchdog project into the `watchdog\dist` directory
6. Run Watchdog.app from the dist folder

## Current status
Watchdog is in the very early stages of development.

## License
Copyright (c) 2015

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
