# novamate

Convert TextMate-style language grammar to a basic syntax for Panic's Nova editor.

## Usage

> swift run novamate textmate convert-language <path/to/somelanguage.tmLanguage>
> swift run novamate textmate convert-bundle <path/to/somebundle.tmbundle> --language-name <some language>
> swift run novamate vscode convert-extension <path/to/someextension>
> swift run novamate vscode convert-extension <path/to/someextension> --language-name

## TODO

- make the replacement rules configurable
- flesh out the default replacement rules
- test on many more input files
