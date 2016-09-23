# SubtitleHelper
Making Subtitle Adjusting Easier

## What?

A basic Mac application that allows for GUI editing of SupRipText (.srt) subtitle files.

## Features

- Adjust all time ranges. Offset all entries by a certain amount
- Undo/Redo support

## Goals

1. Make it easy to identify overlaping subtitles, so you can trim to just the important text!
2. Make validation easier, especially on long movies, etc.
3. Help me learn macOS programming and Swift.

## FAQ

1. Why is the main srt parser in Perl?
    Because text parsing is easier there.
2. What version of Swift?
    Swift 3 right now, it's a small project and we'll try to keep it up to date.
3. Why SubRipText?
    Because it's what I needed
4. What about other subtitle formats?
    Open an issue with a format definition, and we can add it.
5. What about writing subtitles to mp4's?
    That'd be cool, but that's easily a v2 or v3 feature.
6. What about automatically determining the correct offset for subtitle display?
    You mean detecting speech, and seeing if the subtitles line up? That'd be really cool, but based on the papers I've read, require some fun machine learning, and that means data to train on...
