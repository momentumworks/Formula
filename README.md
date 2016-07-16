# Code Generation #

This is a command line tool (disguised as an app) for generating code for a project. The use is as follows:

`CodeGen.app/Contents/MacOS/CodeGen -target <source-root> -templates <template-dir> [-clean]`

The code will scan the given `source-root` directory for any `.swift` files using [SourceKitten](https://github.com/jpsim/SourceKitten), and generate code based on templates written using the [Stencil](https://github.com/kylef/Stencil) syntax. Generated code is then written to `Autogen/Autogen.swift`.

Examples of valid templates can be found [in the test fixtures directory](https://bitbucket.org/theconcreteutopia/code-gen/src/HEAD/CodeGenTests/Fixtures/)

# Integrating into the Build Process #

To add a code generation step into your project, you will need to hit `Product -> Archive` in Xcode, and then export it as a Mac App.

Once done, copy the `.app` file into your project, and follow the steps in [this article](https://developer.apple.com/library/ios/recipes/xcode_help-project_editor/Articles/AddingaRunScriptBuildPhase.html).

The first build will fail, as the file `Autogen.swift` won't have been added to your target yet, as it didn't exist - just add that file to your target, and you should be good to go.

Also note that GenKit generates the file in a diff-friendly way, so you can check in the `Autogen.swift` file if you wish, to help smooth over this step.
