# Code Generation #

This is a command line tool for generating code for a project. The use is as follows:

`CodeGenCLI -target <target-dir> [-clean true]`

The code will scan the given `target-dir` for any `.swift` files, and generate code based on the currently enabled [`Generator`](https://bitbucket.org/theconcreteutopia/code-gen/src/e7ab297d195d27591cc11be55dd1c6c6539f5cc0/CodeGen/CodeGen/Generators/Generator.swift)s.

Each Generator will filter the parsed objects, and then generate its specific functions for those remaining. There is currently only one Generator - the [`ImmutableSettersGenerator`](https://bitbucket.org/theconcreteutopia/code-gen/src/e7ab297d195d27591cc11be55dd1c6c6539f5cc0/CodeGen/CodeGen/Generators/ImmutableSettersGenerator.swift), so look at that for an example of how to write more Generators.

As this is a Swift project, and Swift command line apps aren't really a thing yet, the setup here is rather... unorthodox. There is a Swift package containing the parsing and generation logic, and then a separate Objective-C project which provides a CLI to that. Then, to bridge the two, the Objective-C project exposes 2 targets - one of which is a bundle for essentially attaching the above Swift package. It sucks, and I'm sorry, but my hands were tied there. You can read more about that setup [here](https://colemancda.github.io/programming/2015/02/12/embedded-swift-frameworks-osx-command-line-tools/) and [here](http://jaanus.com/how-to-correcty-configure-building-private-slash-embeddable-os-x-frameworks/) (though in that second link ignore the section "Fixing the last warning", as we want it to be installable, though that error shouldn't be present anyway)

Because of that confusion, there are 3 schemes defined in this project. To run this project locally, edit the "CodeGenCLIBundle" scheme and update the "-target" argument that is passed on launch during the run step (this repo contains an Example directory, so point it at that), and then run that scheme.

To add a code generation step into your project, follow [this](https://developer.apple.com/library/ios/recipes/xcode_help-project_editor/Articles/AddingaRunScriptBuildPhase.html) (there is also some extra info [here](http://stackoverflow.com/questions/1371351/add-files-to-an-xcode-project-from-a-script), but we didn't follow that in the Momentum project).

Then, all that remains is to make your target code trigger those filters - e.g. for the `ImmutableSettersGenerator` you need to extend the `Immutable` protocol (a made-up protocol), and make sure that the target class/struct contains a constructor which sets all of the values (or at least takes as parameters all of the values in the order that they're defined).