# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest, tables, strformat
import sparc
let schema = parseSchema """
[cli app="myTool" version="0.1.0" description="Just a tool for test"]
[flag name="input" type="string" help="An input for test(string test)"]
[flag name="thread" short="t" type="int" help="Worker threads for test (int test)"]
[flag name="verbose" short="v" type="bool" help="Enable verbose for test (bool test)"]
[flag name="help"  short="h" type="bool" help="display this help for auto help generation test"]
[example name="Try My Tool" command="./myTool --input testMe]
"""

suite "Command Line Parsing Test":
  test "Get Runtime Inputed Commands":
    let runtimeValues: seq[string] = @["--input", "testPending", "-v"]
    let parsed = schema.parseCommandLine(runtimeValues)
    check parsed.data == {"input": "testPending", "verbose": "true"}.toTable


suite "Value Conversions":
    let runtimeValues: seq[string] = @["--thread", "8", "--input", "letsTest", "-h"]
    let parsed = schema.parseCommandLine(runTimeValues)
   
    test "String Conversion":
      let input = parsed.asString("input")
      check input.type is  string

    test "Integer Conversion":
      let thread = parsed.asString("thread")
      check thread.type is not int
      
      #string to integer conversion
      check parsed.asInt("thread") is int

      #conversion with errors
      let input = parsed.asInt("Input")
      check input is int #fmt "Error: Expected integer for flag 'input', but got 'input'"
    

    test "Bool Check":
      let help = parsed.asString("help")
      check help.type is not bool
      #string to bool conversion
      check parsed.flagExists("help") is bool

    #test for float will also be donw


suite "Testing Helper Flags":
  let runtimeValues: seq[string] = @["--thread", "8", "-h"]
  let parsed = schema.parseCommandLine(runTimeValues)
  
  test "Runtime Flags Used":
    let input = parsed.asString("input")
    check parsed.flagExists(input) == false
    check parsed.flagExists("thread") == true

      
      
    
