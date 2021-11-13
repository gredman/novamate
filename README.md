# novamate

Convert TextMate-style language grammar to a basic syntax for Panic's Nova editor.

## Usage

### Convert VS Code extension

> `novamate vscode convert-extension <path/to/someextension>`

> `novamate vscode convert-extension <path/to/someextension> --language-name <some language>`

### Convert TextMate language

> `novamate textmate convert-language <path/to/somelanguage.tmLanguage>`

### Convert TextMate bundle

> `novamate textmate convert-bundle <path/to/somebundle.tmbundle> --language-name <some language>`

### Replace scope names

> `novamate <some subcommand> --replace <source.scope.name>:<replacement.scope.name>`

> `novamate <some subcommand> --default-replacements`

Output grammars are printed to `stdout`, so you can either redirect to you syntax XML file, or pipe into `pbcopy`, or whatever. Any errors or debugging information will print to `stderr`.

## Caveats

1. The scope names used in TextMate are very different from Nova's. These can be replaced using the `--replace` option.
2. Many TextMate grammars apply nested rules to the contents of regex captures. I haven't found a way to reproduce this ability in Nova. The best I have come up with is to try to infer a scope name from the nested rules, which can then be applied to the capture group.
3. The regex engines used between the various editors seem to vary. The there are usually a few expressions in the resulting grammar that will need to be tidied up.
