# FTL 1.6 Font manipulation tools

This is a work-in-progress on dissecting fonts from [FTL: Faster Than Light](https://subsetgames.com/ftl.html) version 1.6.

The initial intended goal for this project is to add cyrillic symbols to these fonts, but if you find other uses for these tools, go ahead!

Also, since it uses `bit-struct` that allows for pretty readable descriptions of binary structures, source code doubles as documentation for the format.

## Requirements

Developed on Ruby 2.4, likely to work on 1.9 and newer as well. Refrain from using unsupported releases whenever possible.

Font files. You can get them by unpacking FTL's resource files with 3rd-party tools.

The tools don't use any gems with native extensions, so they should work even on Windows via [RubyInstaller](https://rubyinstaller.org/) __without__ a development kit (you can remove the check in the final installation step to avoid cluttering your system).

## Usage

### Quick start

1. Install a Ruby interpreter (skip if it's already installed).
2. Open up a command line in this repository and run the following commands to install dependencies:
    ```sh
    gem install bundler
    bundle install
    ```
3. Put `*.font` files from FTL 1.6 into the `fonts` folder.
4. Run the `dismantle` script via Bundler (might work without it too):
    ```sh
    bundle exec ./dismantle.rb
    ```
5. Look into the `dismantled` folder for results.
    - Note that this script intentionally skips all fonts that appear to already have corresponding folders with dismantled results; remove/move/rename that folder out to do another pass.

### The REPL

If you're feeling crafty and happen to know Ruby (or [can spare 20 minutes to learn the basics](https://www.ruby-lang.org/en/documentation/quickstart/)), run the `repl.rb` to find yourself in a Pry (very IRB-like) session with the `FtlFont` class loaded. Right now, unfortunately, you'll have to look at the source code to learn how to use it.

## TODO

* Assemble modified dismantled fonts back into `*.font` files
* Documentation (the API is not stable yet)

## Contributing

I'm estimating the number of potential contributors to this project as 1 (one), that's including myself. So I may have skipped some steps that could facilitate contributions for others.

I do appreciate any help with this though!

If you wish to contribute, but something about this repository is stopping you from doing so, [file an issue](https://github.com/D-side/ftl_font/issues/new), we'll figure it out.

Right now the codebase is horribly unstable, as it's not clear at this point what we'll need in practice to build the fonts we need. But I'm open to any suggestions even about cosmetic improvements to the API.

## Why not a gem?

Hasn't attracted any significant attention yet. Apart from difficulties in testing (the definition of "works" lies within proprietary files) I don't see a problem with it.
