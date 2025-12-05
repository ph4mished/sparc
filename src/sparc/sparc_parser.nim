import strutils, tables, os, strformat, terminal, parseOpt

type
  Schema* = ref object
    app*: string
    version*: string
    description*: string
    flags*: seq[Flag]
    options*: seq[Option]
    commands*: seq[Command]
    #examples*: seq[Example]
  

  #support commands, subcommands and args
  Arg* = object
    name*: string
    help*: string
  
  Flag* = object
    name*: string
    aliases*: seq[string]
    #[long*:string
    short*:string]#
    help*: string
    #group*: string
    #required*: bool

  Option* = object
    name*: string #typedesc
    aliases*: seq[string]
    #[long*:string
    short*:string]#
    required*: bool
    default*: string 
    help*: string

  Command* = object
    name*: string
    help*: string

  #[Example* = object
    name*: string
    command: string]#
  
  ParseResult* = ref object
    data*: Table[string, string]
    #flagType*: Table[string, string]
    #positionalArg*: seq[string]
    #command: Table*[string, string]
    #subcommand*: Table[string, string]



#i dropped schema because its too much stringy so a typo wont be obvious, this is bad
#maybe instead of args.flag("--input", "-i", "Show input")
#why not args.flag(input, @["-i", "--input"], help="Show input) #this requires pointers
#what of args.flag(@["-i", "--input"], help="Show input), perfect
#no macros, no template, just procs and no types


#proc flag*(args: Schema, seqParam: seq[string], help: string="") = 
proc newCmd*(app: string="", version: string="", description: string=""): Schema = 
  #no need to type name, get name from filename
  let appName = if app == "": getAppFileName().splitFile.name else: app
  result = Schema(app: appName, version: version, description: description)

  
proc flag*(schema: Schema, name: string, aliases: seq[string], help: string="") =
  schema.flags.add(Flag(name: name, aliases: aliases, help: help))


#template opt*(schema: Schema, name: untyped, aliases: openArray[string], help: string="", default: typedesc): untyped = 

proc opt*(schema: Schema, name: string, aliases: seq[string], help: string="", default: string="", required: bool=false) =
  schema.options.add(Option(name: name, aliases: aliases, help: help, default: default, required: required))



#auto generate and define what shows when --version is typed
proc generateHelp*(schema: Schema): string =
  var sections: seq[string] 
  #Cli header
  var header = ""
  let title = if schema.version == "": fmt "{schema.app.toUpperAscii()}" else: fmt "{schema.app.toUpperAscii()} v{schema.version}"

  let padding = " ".repeat((terminalWidth() - title.len) div 2)
  let borderPadding = " ".repeat((terminalWidth() - title.len-16) div 2)
  let border =  "=".repeat(title.len+16)
  header.add(fmt "\n{borderPadding}{border}\n")
  header.add(fmt "{padding}{title}\n")
  header.add(fmt "{borderPadding}{border}\n")
      #header.add(fmt "v{schema.cli.version}")
  if schema.description != "":
    header.add(fmt "\n{schema.description}")
  sections.add(header)

  #usage section
  var usage = "USAGE:\n"
  usage.add(fmt "    {schema.app}")
  if schema.commands.len > 0:
    usage.add(" [COMMAND]")
  usage.add(" [FLAGS]")
  if schema.flags.len > 0:
    usage.add(" [OPTIONS]")
  sections.add(usage)


  #commands section
  if schema.commands.len > 0:
    var commands = "COMMANDS:\n"
    for cmd in schema.commands:
      #left-align in a field of 15 chars wide.
      commands.add(fmt "    {cmd.name:<15} {cmd.help}")
    sections.add(commands)


  #flags section
  if schema.flags.len > 0:
    var flags = "FLAGS:\n"
    for flag in schema.flags:
      var flagLine = ""
      flagLine.add(flag.aliases.join(", "))

      while flagLine.len < 40:
        flagLine.add(" ")
      flagLine.add(fmt "{flag.help}")

      flags.add(fmt "    {flagLine}\n")
    sections.add(flags)
    

  #flags section
  if schema.options.len > 0:
    var options= "OPTIONS:\n"
    for opt in schema.options:
      var optLine = ""
      optLine.add(opt.aliases.join(", "))
      
      optLine.add(" VALUE")
      
      while optLine.len < 40:
        optLine.add(" ")
      optLine.add(fmt "{opt.help}")

      if opt.default != "":
        optLine.add(fmt " [default: {opt.default}]")
      
      if opt.required:
        optLine.add(fmt " (required)")
    
      options.add(fmt "    {optLine}\n")
    sections.add(options)
  #example section
  #[if schema.examples.len > 0:
    var examples = "EXAMPLES:\n"
    for example in schema.examples:
      examples.add(fmt "    {example.name}:\n")
      examples.add(fmt "        {example.command}\n\n")
    sections.add(examples)]#
  
  result = sections.join("\n\n")

# Public API
proc help*(schema: Schema): string =
  generateHelp(schema)


proc flagUsed(aliases: seq[string], args=commandLineParams()): bool = 
  var count = 0
  for alias in aliases:
    if alias in args:
      inc(count)
  if count > 0:
    return true
  else:
    return false
    
  #echo "COUNT: ", count

proc isFlag(arg: string): bool = 
  return arg.startsWith("--") or arg.startsWith("-")


proc parseCommandLine*(schema: Schema, args=commandLineParams()): ParseResult =
  var
    #flagType: initTable[string, string]
    data: Table[string, string]
    i = 0
  

  #while i < args.len:
  for arg in args:
    var flagFound = false
  
    if arg.isFlag(): #arg.startsWith("--") or arg.startsWith("-"):
     
      #find the value in schema
      for flag in schema.flags:
        if arg in flag.aliases:
          if arg in @["--help", "-h"] or flag.name == "help":
            echo schema.generateHelp
            quit(0)
          if schema.version != "":
            if arg in @["--version", "-v"] or flag.name == "version":
              echo fmt"{schema.app} v{schema.version}"
              quit(0)
          flagFound = true
          data[flag.name] = "true"
          
          
          #for options
      for option in schema.options:
        
        if not flagUsed(option.aliases, args) and option.required:
          echo fmt"Error: required option not set: {option.name}" 
          quit(1)
        
        if arg in option.aliases:
          flagFound = true
          #get the value (next argument)
          #inc i 
          if i+1 >= args.len:
            echo fmt "Error: missing value after option: {arg}"
            quit(1)
          data[option.name] = args[i+1]

      #for required
      #for option in schema.options:
        
        #else:

        

      if not flagFound:
        echo fmt "Error: unknown flag: {arg}"
        quit(1)

  
    #else: else handle positional argument or unknown
    inc i
  return ParseResult(data: data)

        


proc has*(parseRes: ParseResult, flagName: string): bool =
  # Check if flag with this name was used on commandLine
  return parseRes.data.hasKey(flagName)

proc asBool*(parseRes: ParseResult, flagName: string): bool = 
  return parseRes.data.hasKey(flagName)


proc asInt*(parseRes: ParseResult, flagName: string): int =
  let value = parseRes.data.getOrDefault(flagName)
  try:
    if value != "":
      return parseInt(value)
    else:
      return 0
  except ValueError:
    echo fmt "Error: Expected integer for flag '--{flagName}', but got '{value}'"
    quit(1)


proc asFloat*(parseRes: ParseResult, flagName: string): float = 
  let value = parseRes.data.getOrDefault(flagName)
  try:
    if value != "":
      return parseFloat(value)
    else:
      return 0.0
  except ValueError:
    echo fmt "Error: Expected float for flag '--{flagName}', but got  '{value}"
    quit(1)


proc asString*(parseRes: ParseResult, flagName: string): string = 
  let value = parseRes.data.getOrDefault(flagName)
  return value

proc getAllFlags*(schema: Schema): Table[string, Flag] =
  ## Get all flags as a table
  var parseRes = initTable[string, Flag]()
  for flag in schema.flags:
    parseRes[flag.name] = flag
