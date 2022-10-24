![License](https://img.shields.io/badge/license-MIT-orange.svg)
![Godot Version](https://img.shields.io/badge/godot-3.5-blue.svg)
![Version](https://img.shields.io/badge/version-v0.2.0-green.svg)

# Storyboard Mapper v0.2.0

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

## 3. Now use it!

OK, super straightforward:
1. Drag and drop your drawings on the board.
2. Use your mouse **middle button** to scroll the board, and your **scrollwheel** to zoom in/out.
3. Move, duplicate, reconnect the frames as suits you. To disconnect a frame, drag its **input end** and drop it on empty space.
4. Double-click on the first frame of the sequence and watch the sequence playing in a popup window. The popup window can be resized and moved on the board. Change whatever has to be changed at the bottom of this window (subtitles, duration, image, sound). Click outside the popup window to hide it.
5. OK back to work. Try connecting your frames differently. Select, duplicate, copy and paste, change subs, make as many sequences as you like. Experiment. You're in charge.
6. You've... saved your work, right? You know, <kbd>Ctrl</kbd>+<kbd>S</kbd>.

And that's it!

Happy storyboard mapping!

## Quick start

* Hit <kbd>F1</kbd> or go to Help > Help to display a short documentation.
* Add as many images as your RAM can handle. Drag and drop image files from your file explorer, or click on <kbd>+</kbd>, or double-click on empty space.
* Drag from the **ouput** pin of a frame to the **input** pin of another frame to connect them. Hey, you're building a sequence already!
* Drag from the input or output pin of a frame and drop on empty space to create a new node.
* Drag from the **input** pin of a frame to disconnect it from the previous frame.
* The **output pin** of a frame can only be connected to one frame (otherwise the player wouldn't know which frame to play next)!
* But... you can connect as many frames as you want to the **input** pin of a frame (that's "many to one"). This lets you experiment with different starting points.
* Click on a frame to select it. Drag a marquee around several frames to select them.
* <kbd>ctrl</kbd> click frames to add or subtract them from the selection.
* Drag a frame or a selection of frames to move them.
* Double-click on a frame to play the sequence starting from that frame.
* Add subtitles to a frame or change their duration right below the image, or even better, in the player.
* Use the buttons at the bottom of the frame to load or reload an image and/or a sound.
* Resize the frame to your liking by dragging the lower-right corner of the frame.
* Click on <kbd>X</kbd> at the upper-right corner of the frame to discard it. Or select it and press <kbd>Del</kbd>.
* The size of a frame can be stored by clicking <kbd>Edit > Store Size</kbd>. Then select a bunch of frames and click on <kbd>Edit > Apply Stored Size</kbd> to set their size to the stored size.
* Select a bunch of frames and click on <kbd>Edit > Align Horizontally</kbd> to ...well, align them horizontally. Same for vertically.
* Btw, if you're picky on alignment, click on the <kbd>grid with magnet</kbd> button at the top-left of the window to display and snap frames to a grid, which can be configured with the spinbox on its right.
* Select just one frame and click on <kbd>Edit > Distribute Horizontally</kbd> to align horizontally all of its followers. Same for vertically and diagonally.
* Set the number of columns in the distribute grid before clicking on <kbd>Edit > Distribute Grid</kbd>.
* Clicking on the menu <kbd>Select > Select Before</kbd> selects all frames upstream to the selected frame. For <kbd>Select After</kbd>, <kbd>Select Connected</kbd> and <kbd>Select Graph</kbd>, well you get the idea.
* If needed, you can change the background color of all frames' images by clicking on the <kbd>colorpicker</kbd> button (black by default) at the top of the window.
* To add a comment box, click on the <kbd>#</kbd> button at the top of the window. Resize it by dragging its bottom-right corner. Click in its empy space, then type a text. That's a comment box.
* Change the color of a comment box by clicking on its <kbd>colorpicker</kbd> button.
* Comment boxes can also host (or "parent") frames! Select a bunch of frames, then click on the <kbd>+</kbd> button at the upper-right of the comment box. Or merely select frames **before** you click on the <kbd>+</kbd> button.
* Select hosted frames, them click on the </kbd>trash can</kbd> button to unhost (or "unparent) them.
* Moving a comment box moves its hosted frames. Moving or resizing one or more hosted frames deforms their hosting comment box automatically.
* When hosting frames, comment boxes cannot be resized manually, they always conform to their content. And only 3 lines of text are displayed, use the scrollbar to read on.

* ***KNOWN BUG***: Sometimes, frames inside a comment box won't let you connect or disconnect them. Just **zoom out** a bit to get things back to normal.

## My... That's an UGLY peace of code!

Yes it is. But hey, it works! The project started as a proof of concept and somehow made its way to this page. I'll do something about it. I promise. When I have time...

## Thanks

Big shoutout to:
* Emilio Coppola for his [tutorials on GraphEdit](https://www.youtube.com/c/EmilioTube/videos).
* Andrew Wilkes for his [tutorial on GraphEdit](https://gdscript.com/solutions/godot-graphnode-and-graphedit-tutorial/).
