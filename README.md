# **YT-DLP Visualizer**

A minimalist macOS GUI companion for [yt-dlp](https://github.com/yt-dlp/yt-dlp). Easily download YouTube videos as MP4 or extract audio to MP3.

## **Prerequisites**

You need [yt-dlp](https://github.com/yt-dlp/yt-dlp) and [ffmpeg](https://ffmpeg.org) installed on your Mac. The easiest way to install them is via [Homebrew](https://brew.sh):

brew install yt-dlp ffmpeg

## **Installation & Security**

Since this app is open-source and not signed with a paid Apple Developer Account, macOS will show a security warning on the first launch.

**To bypass this:**

1. Drag **YT-DLP Visualizer.app** to your **Applications** folder.  
2. **Right-click (Control-click)** the app icon and select **Open**.  
3. Click **Open** on the confirmation dialog.

*You only need to do this once. Subsequent launches will work by simply double-clicking.*

## **Build from Source**

1. Clone the repository:  
   git clone \[https://github.com/samimkel/YT-DLP-Visualizer.git\](https://github.com/samimkel/YT-DLP-Visualizer.git)

2. Open the project in **Xcode**.  
3. **Important:** Go to **Target Settings \-\> Signing & Capabilities** and delete/disable **App Sandbox** (required to run yt-dlp).  
4. Press Cmd \+ R to build and run.

## **License**

This project is open-source and available under the [MIT License](http://docs.google.com/LICENSE).