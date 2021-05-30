# novamate

Convert TextMate-style language grammar to a basic syntax for Panic's Nova editor.

## Usage

### Convert VS Code extension

> novamate vscode convert-extension <path/to/someextension>
> novamate vscode convert-extension <path/to/someextension> --language-name <some language>

### Convert TextMate language

> novamate textmate convert-language <path/to/somelanguage.tmLanguage>

### Convert TextMate bundle

> novamate textmate convert-bundle <path/to/somebundle.tmbundle> --language-name <some language>

### Replace scope names

> novamate <some subcommand> --replace <source.scope.name>:<replacement.scope.name>
> novamate <some subcommand> --default-replacements
