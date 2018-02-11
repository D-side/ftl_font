# FTL 1.6 Font manipulation tools

This is a toolset for adding and replacing characters in fonts from [FTL: Faster Than Light](https://subsetgames.com/ftl.html) version 1.6.

The initial intended goal for this project is to add cyrillic symbols to these fonts, but if you find other uses for these tools, go ahead!

Also, source code doubles as documentation for the format, since it uses `bit-struct` that allows for pretty readable descriptions of binary structures. See `lib/ftl_font/binary/*.rb` for details and `lib/ftl_font/binary_wrapper.rb` to see how they come together. Or file an issue for me to document the format in a more human-digestible way.

## Usage

This toolset is intended for use primarily on Windows machines, thus the step-by-step guides will assume Windows.

It will work on Linux and OS X as well with no changes, but the guides might not reflect the exact steps you might need to do there. If there's any demand for instructions for Linux, I'll be happy to add them in! OS X is too much of a hassle for me to test on, sorry, but steps should be almost the same.

### Setting up the toolset

1. Install Ruby, **preferably 2.4**
  * Use [RubyInstaller](https://rubyinstaller.org/). No DevKit necessary.
2. Download & unpack or `git clone` this repository.
  * See <kbd>Clone or download</kbd> > `Download ZIP` above if you're not sure what this means; then unpack the resulting file somewhere
3. Use [Slipstream Mod Manager](https://github.com/Vhati/Slipstream-Mod-Manager) to unpack FTL's resource file, `ftl.dat`, located inside the game folder. You'll see a folder called `fonts` in there: copy it into the downloaded repository, you should be prompted if folders should be merged, say "yes".
4. Install Bundler (`gem install bundler`) and use it to install dependencies (`bundle install`).
  * `setup-ruby.bat` for Windows does just that in a double-click, run it, wait until it finishes and you're set!

### Using the toolset

#### Patching

Just so you know what's what, the build process goes like this:

* It scans `font_templates` folder for any `*.json` files; for each `<name>.json` file found:
  * It opens the font specified in the `source` option
  * It merges in every set of additions in the `additions` option (an "addition" is a folder of characters to add or replace)
  * It saves the resulting font into the `assembled` folder under the name of `<name>.font` (after the `*.json` file from `font_templates`)

So to alter a font you'll need to create:

* A set of additions in `additions` folder: there are a few examples there, but in general every set comprises of:
  * PNG files of individual characters.
    * **White on black**.
    * Grays allowed as well, they'll be translucent.
  * `index.json` with a JSON array of parameters; one set for every character to add or replace.
* A `FontNameHere.json` file in `font_templates` with the instructions.
  * There already is an example, you can copy it, rename appropriately, change the source font (just the file name inside the `fonts` folder) and adjust the list of additions (folder names inside the `additions` folder).
  * Note: additions specified further take precedence, you can define an addition that replaces a character in the source font or another addition, as long as that addition goes **before** the one you need.

If you've done that, or you want to build an example font, execute the `reassemble.rb` script. Once it finishes, you should have the corresponding patched `*.font` files in the `assembled` folder.

**Note:** in case such a font already exists there, it _silently overwrites_ it! This is just to make adjustments quicker.

#### Dismantling

Useful if you want original characters from a font with the intent to edit them or just change their parameters.

The process is easy: run `dismantle.rb` and wait until it completes. You should then have a bunch of `*.original` folders inside the `additions` folder, ready to modify as you see fit. Yes, they are ready-to-use additions too.

## Limitations

* Some characters, namely ` ` (space) have **zero width** in the original fonts and thus cannot be exported as PNGs (ChunkyPNG, that I'm using, can do it, but it will choke when trying to open the result). Such characters are not currently supported in additions. Zero width can be emulated by using a 1-pixel wide black "character" with one of the spacings (`before` or `after`) set 1 pixel smaller (negatives are valid in spacings too!). You can also let me know you need proper support for these by filing an issue.
* Characters do not support colors. Internally every pixel is represented in the font as a single byte, specifying a value of opaqueness, e. g. `0x00` for fully transparent and `0xFF` for fully opaque. It makes sense to only use white, black and grays. Others won't cause crashes, but will be converted to grays anyway with an algorithm I don't know (or want to know, really).
* Removing existing characters from fonts is not supported at this time. It's not hard to add, but there has been no demand for this.

## Contributing

I'm estimating the number of potential contributors to this project as 1 (one), that's including myself. So I may have skipped some steps that could facilitate contributions for others.

I do appreciate any help with this though! If you wish to contribute, but something about this repository is stopping you from doing so, [file an issue](https://github.com/D-side/ftl_font/issues/new), we'll figure it out.

## Why not a gem?

Packaging it up as a gem with a few executables that perform transformations of fonts looks highly appealing! But requires some work I just haven't done yet.
