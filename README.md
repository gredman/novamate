# novamate

Convert TextMate-style language grammar to a basic syntax for Panic's Nova editor.

## Usage

> swift run novamate textmate convert-language [--debug] --language-file <path/to/somelanguage.tmLanguage>
> swift run novamate textmate convert-bundle --bundle <path/to/somebundle.tmbundle> --language-name <some language>

## TODO

- make the "front matter" (metadata, detectors, indentation etc.) configurable somehow
- make the replacement rules configurable
- flesh out the default replacement rules
- test on many more input files
