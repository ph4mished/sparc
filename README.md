# SPARC - Schema Parser for Arguments and Commands
SPARC is a declarative command-line argument parser for Nim that uses schema-based definitions for type-safe self-documenting CLI tools:

# Features
1. **Schema-First Design**: Define your CLI interface in a clean, declarative schema
2. **Type Safety**: Automatic type validation
3. **Self-Documenting**: Auto generated help from schema definitons.
4. **Modular Architecture**: Clean separation between interface definition and execution logic.

# Installation
``` bash
nimble install sparc
```

# Usage Examples
``` nim
import sparc

#CLI definition here
let schema = parseSchema("""
[cli app="FconvT" version="2.3.0" description="File format converter"]
[flag name="input" short="i" type="string" help="Input file"]
[flag name="output" short="o" type="string" help="Output file"]
[flag name="verbose" short="v" type="bool" help="Enable verbose mode"]
[flag name="help"  short="h" type="bool" help="display this help"]
""")


#execution logic here
proc main() = 
  #parse command line arguments
  let args = schema.parseCommandLine()

  #Access values with type safe conversions
  let inputFile = args.asString("input")
  let outputFile = args.asString("output")

  #For bools, use flag presence chech
  let verbose = args.flagExists("verbose")

  #flag presence check (it checks if user provided such flag)
  if args.flagExists("help"):
    #outputs schema generated help
    echo schema.generateHelp()
  
  if args.flagExists(inputFile) and args.flagExists(outputFile):
    if verbose:
      echo "Starting conversion in verbose mode ..."
      #verbose mode logic here
    else:
      echo "Converting ", inputFile, " to ", outputFile

when isMainModule:
  main()
```

# SPARC is not stable yet, not even near stable (still expect breaking changes)
## The current syntax or form is more likely to change from stringy form to sectional/ DSL form
As in 
``` nim
#this is just an idea
import sparc

program:
  name "myTool"
  flags:
    "verbose", "v", "Enable debugging mode"
    "help, "h", "Show this help and exit"

  options:
    "input", string, "i", "Accept input", required=true
    "output", string, "o", "Write results to file"
    "timeout", int, "Timeout in secconds", default=10

let args = parseCommandLine()
echo args.input  #Expecting value when user uses input flag
echo args.output
```

