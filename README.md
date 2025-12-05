# SPARC - Simple Parser for Arguments and Commands
SPARC is a simple command-line argument parser for building CLI tools in nim:


# Installation
``` bash
nimble install sparc
```

# Usage Examples
``` nim
import sparc

var brute = newCmd()
#app name is automatically inferred from program name, but can be overriden
brute.app = "nimbuster"
brute.version =  "0.1.0"
brute.description = "A simple directory bruteforcing tool."

brute.opt("url", @["-u", "--url"], "Target URL(eg., http://example.com)", required=true)
brute.opt("wordlist", @["-w", "--wordlist", "--word"], "Path to wordlist file", default="wordlist.txt")
brute.opt("extension", @["-e", "--extensions"], "File extensions to try(comma-separated)", default="php,html,txt")
brute.opt("threads", @["-t", "--threads"], "Number of concurrent threads", default="10")
brute.opt("delay", @["-d", "--delay"], "Delay between request (ms)", default="100")
brute.opt("timeout", @["-T", "--timeout"], "Request timeout (seconds)", default="5")
brute.flag("recursive", @["-r", "--recursive"], "Recursive bruteforce found directories")
brute.flag("redirect", @["-L", "--follow-redirect"], "Follow HTTP redirects")
brute.flag("verbose", @["-V", "--verbose"], "Show detailed output")
brute.flag("help", @["--help", "-h", "-?"], "Show this help message")
brute.opt("output", @["-o", "--output"], "Output file for results" )


#execution logic here
proc main() = 
  
  let args = parseCommandLine(brute)

  #help and version is already handled by SPARC and can't be overriden, except for custom variants


  let url = args.asString("url")
  let wordlist = args.asString("wordlist")
  let verbose = args.asBool("verbose")
  let timeout = args.asInt("timeout")
  let threads = args.asInt("threads")
  #......


  if verbose:
    echo "VERBOSE MODE ON"

  echo "SCANNING URL: ", url
  echo "READING WORDLIST: ", wordlist
  echo "TIMEOUT SET TO: ", timeout
  echo "THREADS SET TO: ", threads


when isMainModule:
  main()

```

# Help Output
``` bash
$./nimbuster -h

                        ================================
                                NIMBUSTER v0.1.0
                        ================================

A simple directory bruteforcing tool.

USAGE:
    nimbuster [FLAGS] [OPTIONS]

FLAGS:
    -r, --recursive                         Recursive bruteforce found directories
    -L, --follow-redirect                   Follow HTTP redirects
    -V, --verbose                           Show detailed output
    --help, -h, -?                          Show this help message


OPTIONS:
    -u, --url VALUE                         Target URL(eg., http://example.com) (required)
    -w, --wordlist, --word VALUE            Path to wordlist file [default: wordlist.txt]
    -e, --extensions VALUE                  File extensions to try(comma-separated) [default: php,html,txt]
    -t, --threads VALUE                     Number of concurrent threads [default: 10]
    -d, --delay VALUE                       Delay between request (ms) [default: 100]
    -T, --timeout VALUE                     Request timeout (seconds) [default: 5]
    -o, --output VALUE                      Output file for results
```
