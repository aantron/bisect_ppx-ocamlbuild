# Bisect_ppx Ocamlbuild plugin

<br/>

<a id="Ocamlbuild"></a>
## Using with Ocamlbuild

This plugin gives you a new tag, `coverage`, which you can use to mark your
source files for coverage analysis by Bisect_ppx. The plugin is in the [public
domain][unlicense], so you can freely link with it, customize and incorporate
it, and/or include it in releases.

It is used like this:

1. Install the plugin:

        opam install bisect_ppx-ocamlbuild

1. Create a `myocamlbuild.ml` file in your project root, with the following
   contents:

        open Ocamlbuild_plugin
        let () = dispatch Bisect_ppx_plugin.dispatch

   If you already have `myocamlbuild.ml`, you just need to call
   `Bisect_ppx_plugin.handle_coverage ()` somewhere in it.
2. Add `-use-ocamlfind -plugin-tag 'package(bisect_ppx-ocamlbuild)'` to your
   Ocamlbuild invocation.
3. <a id="Tagging"></a> Now, you have a new tag available, called `coverage`.
   Make your `_tags` file look something like this:

        <src/*>: coverage                           # For instrumentation
        <tests/test.{byte,native}>: coverage        # For linking

4. Now, if you build while the environment variable `BISECT_COVERAGE` is set to
   `YES`, the files in `src` will be instrumented for coverage analysis.
   Otherwise, the tag does nothing, so you can build the files for release. So,
   to build, you will have two targets with commands like these:

        # For tests
        BISECT_COVERAGE=YES ocamlbuild -use-ocamlfind \
            -plugin-tag 'package(bisect_ppx-ocamlbuild)' tests/test.native --

        # For release
        ocamlbuild -use-ocamlfind \
            -plugin-tag 'package(bisect_ppx-ocamlbuild)' src/my_project.native

If you don't want to make Bisect_ppx a hard build dependency just for the
`coverage` tag, you can work the [contents][plugin-code] of `Bisect_ppx_plugin`
directly into your `myocamlbuild.ml`. Use them to replace the call to
`Bisect_ppx_plugin.dispatch`. In that case, you should omit the second step.

<br/>

<a id="OASIS"></a>
## Using with OASIS

Since OASIS uses Ocamlbuild, the instructions are similar:

1. Install the plugin:

        opam install bisect_ppx-ocamlbuild

1. At the top of your `_oasis` file are the *package fields*, such as the name
   and version. Add these:

        OCamlVersion:           >= 4.01
        AlphaFeatures:          ocamlbuild_more_args
        XOCamlbuildPluginTags:  package(bisect_ppx-ocamlbuild)

   Then, run `oasis setup`.
2. You should have a `myocamlbuild.ml` file in your project root. Near the
   bottom, after `(* OASIS_STOP *)`, you will have a line like this one, if you
   have not yet modified it:

        Ocamlbuild_plugin.dispatch dispatch_default;;

   replace it with

        let () =
          dispatch
            (MyOCamlbuildBase.dispatch_combine
               [MyOCamlbuildBase.dispatch_default conf package_default;
                Bisect_ppx_plugin.dispatch])

3. This enables the `coverage` tag. Tag your source files as
   [described in the Ocamlbuild instructions](#Ocamlbuild). Insert the tags after
   the line `# OASIS STOP`.
4. Use the `BISECT_COVERAGE` environment variable to enable coverage analysis:

        # For tests
        BISECT_COVERAGE=YES ocaml setup.ml -build && test.native

        # For release
        ocaml setup.ml -build

As in the Ocamlbuild instructions, if you don't want to make Bisect_ppx a build
dependency, you can work the [contents][plugin-code] of `Bisect_ppx_plugin`
directly into `myocamlbuild.ml`. Use them to replace the call to
`Bisect_ppx_plugin.dispatch`. In that case, you don't want to put the package
fields in the first step into your `_oasis` file.

[unlicense]: https://github.com/aantron/bisect_ppx-ocamlbuild/blob/master/LICENSE.md
[plugin-code]: https://github.com/aantron/bisect_ppx-ocamlbuild/blob/master/src/bisect_ppx_plugin.ml
