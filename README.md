# chihuahua-reporters
Reporters for the Chihuahua test runner. The library supports XUnit so test
results can be consumed by build servers.

### Installation

You'll need `chihuahua-tester` in order to use this module.

```
npm install chihuahua-tester --save-dev
npm install chihuahua-reporters --save-dev
```

### Configuration

Set your test command in package.json to something like the following:

```
$(npm bin)/chi-run spec *.test.js .testresults default coverage xunit
```

The parameters to `chi-run` are:

 1. Directory containing test files (treated recursively).
 2. File matching pattern.
 3. Directory for report files.
 4. Reporters. All reporters currently supported are shown. The `xunit`
 reporter will only display to the terminal if you supply the parameter
 as `+xunit`. All supplied reporters will deposit a file in the report
 files filder.
 
### NYC

The library uses NYC for coverage. If you want to exclude your test files
from coverage checks, you will need to edit your package.json. Adding something
like the following will exclude your test files:

```
  "nyc": {
    "include": [
      "src/**/*"
    ]
  }
```

The module can use NYC if you install it to your project or globally. If you
install it globally, this helps keep your project dependency tree smaller. It
presents a problem if you need to consume coverage in your build process. The
simple way to address this is to add the following line to a script task near
the start of your build process:

```
npm install nyc
```
