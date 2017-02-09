## gear-launcher
## G.E.A.R - generic electronics augmentation rig

### Features
  - Search / Launch apps
  - Hide apps from the launch screen
  - Kill apps (requires root)
  - Launch scripts and toggles from **/data/local/gear/scripts** (requires root)
  - Icon/Title or Mixed View

### Installation
  Download APK [here](https://github.com/hakt0r/gear-launcher/releases/), or rebuild with Android Studio (or gradle)

  ![screenshot](https://raw.githubusercontent.com/hakt0r/gear-launcher/master/img/screenshot.png)

### Adding scripts
  Any located files in **/data/local/gear/scripts** will be made available
  as a button in the launcher. It's possible to rename the script with the
  rename function, which also works for normal apps.

  Files ending in **.toggle** will get special treatment. It is assumed that
  your script support the **start**, **stop** and **status** arguments.

#### Example **.toggle**

    #!/system/bin/sh
    case "$1"
    in
    start)  start_action;;
    stop)   stop_action;;
    status) status_action;;
    esac


### Icons
  The **/data/local/gear/icons** directory can contain custom icons to replace
  the default ones. Use **PACKAGENAME.png** where PACKAGENAME could be
  something like *com.android.browser* or *script.debian.toggle*.

### Building
  Make sure to run npm init (requires nodejs/npm) before building.
  This downloads jQuery and FontAwesome to assets.

### Copyrights
  * gear-launcher  c) 2017  Sebastian Glaser <anx@ulzq.de>

### Licensed under GNU GPLv3

gear-launcher is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

gear-launcher is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this software; see the file COPYING.  If not, write to
the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
Boston, MA 02111-1307 USA

http://www.gnu.org/licenses/gpl.html
