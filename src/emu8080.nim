import macros
from sugar import `->`

type
  Emulator = ref object
    ram: array[65535, byte]
  EmuCall = ((Emulator, seq[byte]) -> void)
  Instruction = object
    ## The amount of bytes that the instruction uses
    insBytes: byte
    ## The name of the symbol that is used when disassembling 8080 code
    symbolName: string
    ## The function that is executed when it reaches the opcode this instruction
    ## is in
    call: EmuCall


macro defineInstructions(instructions: array[0xFF, Instruction],
    definitions: untyped): untyped =
  result = newStmtList()
  definitions.expectKind nnkStmtList

  let
    emu = newIdentNode("emu")
    ins = newIdentNode("ins")

  for i in definitions:
    i.expectKind nnkCommand

    i[0].expectKind nnkIntLit
    let opcode = i[0]

    i[1].expectKind nnkCommand
    i[1][0].expectKind nnkIntLit
    let insBytes = i[1][0]
    i[1][1].expectKind nnkStrLit
    let symbolName = i[1][1]

    i[2].expectKind nnkStmtList
    let prog = i[2]

    result.add quote do:
      `instructions`[`opcode`] = Instruction(
        insBytes: `insBytes`,
        symbolName: `symbolName`,
        call: proc (`emu`: Emulator, `ins`: seq[byte]) =
        `prog`
      )


var instructions: array[0xFF, Instruction]


defineInstructions instructions:
  0x00 0 "NOP":
    discard
  0x01 2 "LXI":
    echo "Hello!"


let emulator = Emulator()
let list = @[cast[byte](2)]

echo instructions[0].symbolName

instructions[0].call emulator, list
instructions[1].call emulator, list
