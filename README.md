# Aseprite Diagram Generator

![Screen Cap](screenCap.png)

This is a [threshold filter](https://en.wikipedia.org/wiki/Thresholding_(image_processing)) for use with the [Aseprite](https://www.aseprite.org/) [scripting API](https://github.com/aseprite/api). (The screen shot above uses David's [_The Lictors Bring to Brutus the Bodies of His Sons_](https://en.wikipedia.org/wiki/The_Lictors_Bring_to_Brutus_the_Bodies_of_His_Sons) as a test image.)

## Download

To download this script, click on the green Code button above, then select Download Zip. You can also copy and paste the contents of the `threshold.lua` file. Be sure to click on the Raw file button before copying; do not copy the formatted code. Beware that some browsers will append a `.txt` file format extension to script files on download. Aseprite will not recognize the script until this is removed and the original `.lua` extension is used. 

## Usage

To use this script, open Aseprite. In the menu bar, go to `File > Scripts > Open Scripts Folder`. Move the Lua script into the folder that opens. Return to Aseprite; go to `File > Scripts > Rescan Scripts Folder`. The script should now be listed under `File > Scripts`. Select `threshold.lua` to launch the dialog.

If an error message in Aseprite's console appears, check if the script folder is on a file path that includes characters beyond ASCII, such as 'é' (e acute) or 'ö' (o umlaut).

A hot key can be assigned to the script by going to `Edit > Keyboard Shortcuts`. The search input box in the top left of the shortcuts dialog can be used to locate the script by its file name

## Acknowledgments & References

The series of blog posts from Craft of Coding on the [Bernsen](https://craftofcoding.wordpress.com/2021/10/27/thresholding-algorithms-bernsen-local/), [Niblack](https://craftofcoding.wordpress.com/2021/09/30/thresholding-algorithms-niblack-local/), [Sauvola](https://craftofcoding.wordpress.com/2021/10/06/thresholding-algorithms-sauvola-local/) and [Phansalkar](https://craftofcoding.wordpress.com/2021/09/28/thresholding-algorithms-phansalkar-local/) algorithms were of great use in creating the Lua implementation.

## Examples


🇹🇼 🇺🇦