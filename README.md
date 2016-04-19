# Code Generation #

This is a command line tool (disguised as an app) for generating code for a project. The use is as follows:

`CodeGen.app/Contents/MacOS/CodeGen -target <source-root> -templates <template-dir> [-clean]`

The code will scan the given `source-root` directory for any `.swift` files using [SourceKitten](https://github.com/jpsim/SourceKitten), and generate code based on templates written using the [Stencil](https://github.com/kylef/Stencil) syntax. Generated code is then written to Autogen/Autogen.swift.

Examples of valid templates can be found [in the test fixtures directory](https://bitbucket.org/theconcreteutopia/code-gen/src/HEAD/CodeGenTests/Fixtures/)

# Integrating into the Build Process #

To add a code generation step into your project, you will need to hit Product -> Archive in Xcode, and then export it as a Mac App. Once done, copy the .app file into your project, and follow [this](https://developer.apple.com/library/ios/recipes/xcode_help-project_editor/Articles/AddingaRunScriptBuildPhase.html) (there is also some extra info [here](http://stackoverflow.com/questions/1371351/add-files-to-an-xcode-project-from-a-script), but we didn't follow that in our project). You should end up with an extra step before the compile step, that looks something like this:
![Screen Shot 2016-04-19 at 10.22.02.png](https://bitbucket.org/repo/78nRAa/images/3624840485-Screen%20Shot%202016-04-19%20at%2010.22.02.png)

The first build will fail, as the file Autogen.swift won't have been added to your target yet, as it didn't exist - just add that file to your target, and you should be good to go. Also note that this project generates that file in a deterministic manner, so you can check in the Autogen.swift file if you wish, to help smooth over this step.
