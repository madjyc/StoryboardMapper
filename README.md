![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Godot Version](https://img.shields.io/badge/godot-3.5-blue.svg)
![Version](https://img.shields.io/badge/version-v0.1-alpha-orange.svg)

# Storyboard Mapper v0.1 alpha

**Mind-mapping for storyboarders**, made in **Godot Engine 3.5**.

**Storyboard Mapper** helps to organize your images in sequences, like connected **Post-It**s, and play them in realtime in a slideshow. Give each image a duration, add subtitles or even a sound file if you want to. You're done.

![screenshot](../Images/Screencopies/StoryboardMapper.jpg)

Simple as 1-2-3.

## 1. Download and install Godot Engine 3.5

### [Click here to download Godot Engine 3.5](https://godotengine.org/download)

## 2. Download Storyboard Mapper

If for some reason you're not keen on cloning the repository, you can simply download the project in a ZIP file:
1. Click on the green <kbd>Code</kbd> button at the top of this page, then on <kbd>Download ZIP</kbd>.
2. Unzip it wherever you fancy.
3. Run **Godot Engine**, click on <kbd>Import</kbd> and find **Storyboard Mapper** wherever your fancy unzipped it, select the project file "**project.godot**", click on <kbd>Open</kbd>, then <kbd>Import & Edit</kbd>.
4. Hit <kbd>F5</kbd> and there you go.

## 3. Use it!

Super straightforward.
1. Drag and drop your drawings on the board. When selecting multiple files, the file that your mouse cursor actually drags will be the first frame in the sequence.
2. Use the mouse **middle button** to scroll the board, and the **scrollwheel** to zoom in or out.
3. Move, duplicate, reconnect the frames as suits you. To disconnect a frame, drag its **input end** and drop it on empty space.
4. Double-click on the first frame of the sequence and watch the sequence playing in a popup window. The popup window can be resized and moved on the board. Change whatever has to be changed at the bottom of this window (subtitles, duration, image, sound). Click outside the popup window to hide it.
5. OK back to work. Try connecting your frames differently. Select, duplicate, copy and paste, change subs, make as many sequences as you like. Experiment. You're in charge.
6. You've... saved your work, right? You know, <kbd>Ctrl</kbd>+<kbd>S</kbd>.

And that's it!

Happy storyboard mapping!

## But... that code is UGLY!

Yes it is. But hey, it works! The project started as a proof of concept and somehow made its way to this page. I'll do something about it. I promise. When I have time...

## Thanks

Big shoutout to:
* Emilio Coppola for his [tutorials on GraphEdit](https://www.youtube.com/c/EmilioTube/videos).
* Andrew Wilkes for his [tutorial on GraphEdit](https://gdscript.com/solutions/godot-graphnode-and-graphedit-tutorial/).
