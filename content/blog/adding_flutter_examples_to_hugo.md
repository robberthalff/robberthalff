+++
author = "Robbert Halff"
categories = ["Flutter", "Hugo"]
date = "2019-08-22"
description = "Flutter examples in Hugo"
linktitle = ""
title = "Flutter Examples in Hugo"
type = "post"
codeTabs = true
+++

This article explains how to show [flutter](https://flutter.dev) examples on your [hugo][] powered site using a simple iframe [shortcode][].

### Step 1: Install the flutter_web build tools

First install the [webdev package](https://pub.dartlang.org/packages/webdev) which provides the build tools for Flutter for web:

```console
$ flutter pub global activate webdev
```

Ensure that the `$HOME/.pub-cache/bin` directory
[is in your path](https://www.dartlang.org/tools/pub/cmd/pub-global#running-a-script-from-your-path),
and then you may use the `webdev` command directly from your terminal.

### Step 2: Adding the flutter web repository as submodule

Add the [Flutter Web Repository](https://github.com/flutter/flutter_web) as a submodule to your site's git repository:
```bash
git submodule add git@github.com:flutter/flutter_web.git
```

The examples for flutter web reside in `flutter_web/examples`.

Although we could go hacking up some examples directly within the directory of this submodule it's better to keep that source tree clean and create a new directory for our examples to live in.

e.g.
```
mkdir -p examples/flutter
```

Now let's take one of the examples from the flutter web repository and put them
into our example dir:

```
cp -r flutter_web/examples/spinning_square examples/flutter/
```

The main thing we have to change is the path to flutter web.

> **NOTE**:
>
>  Ensure the path to the packages match your directory structure:

**examples/flutter/spinning_square/pubspec.yaml**:
```diff
dependency_overrides:
  flutter_web:
-    path: ../../packages/flutter_web
+    path: ../../../flutter_web/packages/flutter_web
  flutter_web_ui:
-    path: ../../packages/flutter_web_ui
+    path: ../../../flutter_web/packages/flutter_web_ui
```

Run `pub get` to install the dependencies.

If all goes well you can run `webdev serve` within the example directory and see a spinning square if you
navigate to `https://127.0.0.1:8080`.

Instead of serving this example we will want to build it instead so we can integrate it into our [hugo][] site.

In order to do so run `webdev build`.

This will create a build directory with an `index.html` file and a `main.dart.js`.

Next just move both of these files to the static directory of your [hugo][] installation:

e.g.
```bash
mkdir -p static/examples/flutter/spinning_square
cp examples/flutter/spinning_square/build/index.html static/examples/flutter/spinning_square
cp examples/flutter/spinning_square/build/main.dart.js static/examples/flutter/spinning_square
```

If all went well the example should now be available at the path `/examples/flutter/spinning_square`
of your [hugo][] site.

> Note:
>
> Although it's fine to add the examples directory to git it's probably not a smart idea
> to also commit the build/ directory.
> 
> So make sure to add the `build/` directory to your `.gitignore` file. 

### Step 3: Creating a shortcode to serve the examples

In order to integrate this example into the site we can make a simple iframe [shortcode][].

To do so paste the following code into a file named *iframe.html* in the *shortcodes* directory:

**themes/[your-theme]/layouts/shortcodes/iframe.html**:
```html
<div class="iframe-container">
  <iframe src="{{.Get 0}}" allowfullscreen="allowfullscreen"></iframe>
</div>
```

In addition we'll add some css to make the iframe responsively scale well:

**themes/[your-theme]/static/css/iframe.css**:
```css
.iframe-container {
    overflow: hidden;
    padding-top: 56.25%;
    position: relative;
}

.iframe-container iframe {
    border: 0;
    height: 100%;
    left: 0;
    position: absolute;
    top: 0;
    width: 100%;
}
```
This css will have to be loaded in the header of your site.
For the theme I'm currently using this can be found in `header.html`.

Add something like the following to load the css:

```html
<link rel="stylesheet" type="text/css" href="{{ .Site.BaseURL }}css/iframe.css" />
```
Then from within any post we can now show our flutter example using the iframe [shortcode][]:

```html
{{</* iframe "/examples/flutter/spinning_square" */>}}
```

Which should result in:

{{< iframe "/examples/flutter/spinning_square" >}}

### Step 4: Missing FontManifest.json 

When you serve the example you might notice that `main.dart.js` will try to load a `FontManifest.json` even though the example itself is not using any fonts or icons.
In order to make this file available you must create it manually.
It's contents will depend on which fonts your flutter example is using.

A good default would be:
```json
[
  {
    "family": "MaterialIcons",
    "fonts": [
      {
        "asset": "https://fonts.gstatic.com/s/materialicons/v42/flUhRq6tzZclQEJ-Vdg-IuiaDsNcIhQ8tQ.woff2"
      }
    ]
  }
]
```

For the example used within this article you would create this file at the following path:

`static/examples/flutter/spinning_square/assets/FontManifest.json`

### Summary

In order to create new flutter examples using the above setup all we have to do is.

* Create a flutter web example in `examples/flutter`
* Run `webdev build` to build the example.
* Copy the files `index.html` and `main.dart.js` somewhere within the static directory of your site.
* Create a FontManifest.json file within the example's assets directory.
* Reference the example anywhere in your posts using:

```html
  {{</* iframe "/examples/flutter/[your-example-location]" */>}}
```

[shortcode]: https://gohugo.io/content-management/shortcodes
[hugo]: https://gohugo.io

