<div align="center">

![Screenshot][image-screenshot]

# ExperienceLeft

A World of Warcraft addon that shows an estimate of how much time is needed to reach the next level.

· [Changelog](./CHANGELOG.md) ·

[![Version 0.2.1][github-release-shield]][github-release-link]

</div>

## 👋🏻 Welcome

After a fresh start on a fresh Classic Hardcore server I decided to get into addon development again. This is the first addon I've created in a long time and maybe the last one, too. Have fun :)

## ✨ Features

The addon offers a lot of the features you know from other addons of this type:

-   Displays current XP in relation to current maximum XP and XP left to reach next level
-   Calculates XP per hour rates and time left to reach next level
-   Experience rate is saved and used for calculation in subsequent sessions
-   Level progress is displayed color coded on a scale from red to green

## 📦 Download & Installation

~~This addon is available on [CurseForge][curseforge-release-link]. You can use the CurseForge app to download and stay up to date with this addon.~~

If you don't want to use CurseForge you can just [download the current version][github-release-link] from Github and drop the contents of the folder into your WoW addons folder.

## 🔨 Usage

### Slash commands

- Use `/xpleft show` to show the xp frame
- Use `/xpleft hide` to hide the xp frame
- Use `/xpleft center` to move the xp frame back to its initial position
- Use `/xpleft reset` to reset saved xp rates from previous sessions

### How to move the frame

- Use [Shift] + Left click to move the frame to the desired position

## 🏭 Todo

-   Tooltip to show movement options
-   Show help for slash commands
-   Improve number format

## License

MIT

<!-- Links -->

[curseforge-release-link]: https://www.curseforge.com/wow/addons/experience-left
[github-release-shield]: https://img.shields.io/badge/version-0.2.1-blue?color=369eff&labelColor=black&logo=github
[github-release-link]: https://github.com/hjenneberg/wow-experience-left/releases/tag/0.2.1
[image-screenshot]: ./docs/images/screenshot.png
