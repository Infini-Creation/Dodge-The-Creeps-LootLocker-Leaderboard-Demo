This is the official _Godot_ 2D tutorial "**Dodge The Creeps**" game with _LootLocker_ _guest login_ feature and leaderboard integration.

It is not, by far, a comprenhensive tutorial on how to add _LootLocker_ features to your game, but more like the official demo, a working sample to take inspiration from.
It is neither the best way to use [_LootLocker_ SDK](https://github.com/ARez2/LootLocker-Godot-SDK) as it is still under heavy developpement and many things will change sooner or later.

The main screen, with the new 'reset' button (to delete saved data, so create a _new guest_ on _LootLocker_ system):
![DTC-main](https://github.com/Infini-Creation/Dodge-The-Creeps-LootLocker-Leaderboard-Demo/assets/136735040/3f920f18-38c9-490c-8cb1-3af76378d0d3)

The submit score page with a text input to also change the player name if wanted:
![DTC-submitscore](https://github.com/Infini-Creation/Dodge-The-Creeps-LootLocker-Leaderboard-Demo/assets/136735040/893b9eb1-f744-436d-bc63-6898a8e677f1)

And finally the leaderboard page (early version):

![DTC-highscores](https://github.com/Infini-Creation/Dodge-The-Creeps-LootLocker-Leaderboard-Demo/assets/136735040/3c04e179-59bf-48dc-8c7e-d8bb61caba1d)

Improved version:

![dtc-leaaderboard-1](https://github.com/Infini-Creation/Dodge-The-Creeps-LootLocker-Leaderboard-Demo/assets/136735040/1e9b6557-9d5c-4573-8e2f-f67e02f4e814)

it shows here a lot of _player_uid_, used because no names has been set for these players (many test runs done while working on it)
This version is still WIP as it will be replaced by this view IF there are no more than ten scores already registered, or a view of the first three and the player rank as well as the two above and below the score.

The definitive version of the leaderboard shows the first ten scores IF there are no more than ten already AND player's rank is less than seven. If there are more scores than ten and player's rank is lower, it shows only the first thress high-scores AND the three before and after the player's rank if there are enough around like on the picture above.

## playable demo

### itch.io

You can play the ame in your browser there -> URL WILL BE SET SOON

### computer version

Windows & Linux version are available ready-to-play on itch.io page

## setup
### LootLocker SDK
### leaderboard (to have you own)
