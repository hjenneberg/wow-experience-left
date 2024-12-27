<div align="center">

![Screenshot][image-screenshot]

# ExperienceLeft

A World of Warcraft addon that shows an estimate of how much time is needed to reach the next level.

· [Changelog](./CHANGELOG.md) ·

[![Version 0.5.0][github-release-shield]][github-release-link]

</div>

## 👋🏻 Welcome

After a fresh start on a fresh Classic Hardcore server I decided to get into addon development again. This is the first addon I've created in a long time and maybe the last one, too. Have fun :)

## ✨ Features

The addon offers a lot of the features you know from other addons of this type:

-   Displays current XP in relation to current maximum XP and XP left to reach next level
-   Calculates XP per hour rates and estimates time left to reach next level
-   Experience rate is saved and used for calculation in subsequent sessions
-   Level progress is displayed color coded on a scale from red to green

The addon frame will be hidden upon reaching max level, but the addon will still be active. Consider disabling it on characters that have reached max level.

## 📦 Download & Installation

This addon is available on [CurseForge][curseforge-release-link]. You can use the CurseForge app to download and stay up to date with this addon.

If you don't want to use CurseForge you can just [download the current version][github-release-link] from Github and drop the contents of the folder into your WoW addons folder.

## 🔨 Usage

### Context menu

Most of the addon options are available via context menu. Just right click the addon frame to show it.

### How to move the frame

-   Use [Shift] + Left click to move the frame to the desired position

### Slash commands

-   Use `/xpleft hide` to hide the frame
-   Use `/xpleft show` to show the frame after you have hidden it
-   Use `/xpleft center` to move the frame back to its initial position if you have accidentally dragged it out of the screen
-   Use `/xpleft reset` to restart your XP session. All your previous XP rates will be deleted.

## License

MIT

<!-- Links -->

[curseforge-release-link]: https://www.curseforge.com/wow/addons/experience-left
[github-release-shield]: https://img.shields.io/badge/version-0.5.0-blue?color=369eff&labelColor=black&logo=github
[github-release-link]: https://github.com/hjenneberg/wow-experience-left/releases/tag/0.5.0
[image-screenshot]: ./docs/images/screenshot.png
