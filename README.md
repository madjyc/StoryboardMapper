![License](https://img.shields.io/badge/license-MIT-orange.svg)
![Godot Version](https://img.shields.io/badge/godot-3.5-blue.svg)
![Version](https://img.shields.io/badge/version-v0.2.2-green.svg)

# Storyboard Mapper v0.2.2

**Mind-mapping for storyboarders**, made in **Godot Engine 3.5**.

**Storyboard Mapper** helps to organize your images in sequences, like connected **Post-It**s, and play them in realtime in a slideshow. Give each image a duration, add subtitles or even a sound file if you want to. You're done.

![screenshot](../Images/Screencopies/StoryboardMapper.jpg)

**As simple as 1-2-3:**

## 1. Download Godot Engine 3.5

### [Click here to download Godot Engine 3.5 (Standard version)](https://godotengine.org/download)
You don't need to install **Godot Engine**, it's an executable file. Just unzip it and you're done.

## 2. Download Storyboard Mapper

If for some reason you're not keen on cloning the repository, you can simply download the project in a ZIP file:
1. Click on the green <kbd>Code</kbd> button at the top of this page, then on <kbd>Download ZIP</kbd>.
2. Unzip it wherever you fancy.
3. Run **Godot Engine**. The first time you run it, you'll need to tell **Godot Engine** where you unzipped **Storyboard Mapper**. Click on <kbd>Import</kbd> and find **Storyboard Mapper** wherever you unzipped it, select the project file "**project.godot**", and click on <kbd>Open</kbd>.
4. Select **Storyboard Mapper** in the list, then click on <kbd>Run</kbd>. And there you go. Easy peasy.

## 3. Install FFMpeg (optional)

**Storyboard Mapper** will work fine as is, but if you want to be able to export image sequences as MP4 videos, you'll need to "install" FFMpeg properly.
1. Download **FFMpeg** from the [official FFMpeg website](https://ffmpeg.org/download.html). For example, Windows users will click on the Windows logo, then on one of the two available depositaries (e.g. "Windows builds from gyan.dev"). Download the smallest version (e.g. "ffmpeg-release-essentials.7z" from gyan.dev, in the "release builds" section).
2. Unzip it wherever you like. You will delete this folder anyways, you just need one of its files.
3. Copy the file named **ffmpeg** from the <kbd>bin</kbd> folder to your project folder (i.e. where you unzipped **Storyboard Mapper**, next to the "**project.godot**" file). Done. You can now safely delete both the FFMpeg zip file you have downloaded and its unzipped folder.

## Now use it!

OK, super straightforward:
1. Drag and drop your drawings on the board.
2. Use your **middle mouse button** to scroll the board, and your **scrollwheel** to zoom in/out.
3. Move, duplicate, reconnect the frames as suits you. To disconnect a frame, drag its **input end** and drop it on empty space.
4. Double-click on the first frame of the sequence and watch the sequence playing in a popup window. The popup window can be resized and moved on the board. Change whatever has to be changed at the bottom of this window (subtitles, duration, image, sound). Click outside the popup window to hide it.
5. OK back to work. Try connecting your frames differently. Select, duplicate, copy and paste, change subs, make as many sequences as you like. Experiment. You're in charge.
6. You've... saved your work, right? You know, <kbd>Ctrl</kbd>+<kbd>S</kbd>.

And that's it!

Happy storyboard mapping!

## Features

* ***KNOWN BUG***: Sometimes, frames inside a comment box won't let you connect or disconnect them. Just **zoom out** a bit to get things back to normal.

* Hit <kbd>F1</kbd> or go to <kbd>Help > Help</kbd> to display a short documentation.
* Use your **middle mouse button** to scroll the board, and your **scrollwheel** to zoom in/out.
* Import as many images as your RAM can handle. Drag and drop image files from your file explorer, or click on <kbd>+</kbd>, or double-click on empty space.
* Drag from the **ouput** pin of a frame to the **input** pin of another frame to connect them. Hey, you're building a sequence already!
* Drag from the **input or output** pin of a frame and drop on empty space to create a new node.
* Drag from the **input** pin of a frame (i.e. its right end) to disconnect it from the previous frame.
* The **output pin** of a frame can only be connected to one frame (otherwise the player wouldn't know which frame to play next).
* But... you can connect as many frames as you want to the **input** pin of a frame (that's "many to one"). This lets you experiment with different starting points.
* Click on a frame to select it. Drag a marquee around several frames to select them.
* <kbd>ctrl</kbd> + click frames to add them to or subtract them from the selection.
* <kbd>shift</kbd> + click a frame to add all connected frames between this frame and selected frames frames to the selection ("path" selection).
* Drag a frame or a selection of frames to move them (stating the obvious, I know).
* Double-click on a frame to play the sequence from that frame. Or click on the <kbd>movie slate</kbd> button at the top of the window.
* Add subtitles to a frame or change their duration right below the image, or even better, in the player.
* Use the buttons at the bottom of the frame to load or reload an image and/or a sound.
* Resize the frame to your liking by dragging the lower-right corner of the frame.
* Click on <kbd>X</kbd> at the upper-right corner of the frame to delete it. Or select a bunch of frames and press <kbd>Del</kbd>.
* The size of a frame can be stored by clicking <kbd>Edit > Store Size</kbd>. Then select a bunch of frames and click on <kbd>Edit > Apply Stored Size</kbd> to set their size to the stored size.
* Select a bunch of frames and click on <kbd>Edit > Align Horizontally</kbd> to ...well, align them horizontally. Same for vertically.
* Btw, if you're picky on alignment, click on the <kbd>grid with magnet</kbd> button at the top-left of the window to display and snap frames to a grid, which can be configured with the spinbox on its right.
* Select just one frame and click on <kbd>Edit > Distribute Horizontally</kbd> to align all its followers horizontally. Same for vertically and diagonally.
* Set the number of columns in the distribute grid before clicking on <kbd>Edit > Distribute Grid</kbd>!
* Clicking on the menu <kbd>Select > Select Before</kbd> selects all frames upstream to the selected frame. For <kbd>Select After</kbd>, <kbd>Select Connected</kbd> and <kbd>Select Graph</kbd>, well you get the idea.
* If needed, you can change the background color of all frames' images by clicking on the <kbd>colorpicker</kbd> button (black by default) at the top of the window.
* Select a frame, then <kbd>File > Export to Video</kbd> to export the sequence as an MP4 video from that frame. You need to install FFMpeg properly to get access to this operation (see above).
* To add a comment box, click on the <kbd>#</kbd> button at the top of the window. Resize the comment box by dragging its bottom-right corner. Click on empy space inside the comment box, then type some text. You've made yourself a comment box.
* Change the color of a comment box by clicking on its <kbd>colorpicker</kbd> button.
* Add up to 6 icons to the comment box by clicking on its top-left <kbd>light bulb</kbd> button. Remove them by clicking on its top-left <kbd>trash can</kbd> button.
* But wait! Comment boxes can also host (or "parent") frames. Select a bunch of frames, then click on the <kbd>+</kbd> button at the top right of the comment box. Even better, select frames **before** you click on the <kbd>#</kbd> button to let the new comment box host them right off the bat.
* To unhost (or "unparent") hosted frames, select them, then click on the <kbd>trash can</kbd> button at the top-righ of the comment box.
* Moving a comment box moves its hosted frames. A comment box also automatically deforms to fit the frames that host it, even when you move or resize them.
* As a result, comment boxes hosting frames cannot be resized manually, they automatically conform to their content. And only 3 lines of text are displayed, use the scrollbar to read the rest.

## Thanks

Big shoutout to:
* Emilio Coppola for his [tutorials on GraphEdit](https://www.youtube.com/c/EmilioTube/videos).
* Andrew Wilkes for his [tutorial on GraphEdit](https://gdscript.com/solutions/godot-graphnode-and-graphedit-tutorial/).
