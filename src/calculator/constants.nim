type
  InvalidNotationError* = object of CatchableError

type

  SymbolType = enum
    Operator, NumberModifier, Parenthesis, MatrixParenthesis, TermModifier

  ParenthesisType = enum
    Open, Close

  NumberModifierType = enum
    Decimal, Ignore
  
  TermModifierType = enum
    Imaginary

  Symbol* = object
    notation: string
    precedene: int
    case symbol_type: SymbolType
      of Operator:
        operation: int
      of NumberModifier: 
        modifier_type: NumberModifierType
      of TermModifier: 
        term_modifier_type: TermModifierType
      of Parenthesis: 
        parenthesis_type: ParenthesisType
      of MatrixParenthesis: 
        matrix_parenthesis_type: ParenthesisType

  SymbolArray = seq[Symbol]

const
  symbols*: SymbolArray = @[
    Symbol(notation: "+", symbol_type: Operator, operation: 0),
    Symbol(notation: "-", symbol_type: Operator, operation: 1),
    Symbol(notation: "*", symbol_type: Operator, operation: 2),
    Symbol(notation: "/", symbol_type: Operator, operation: 3),
    Symbol(notation: "//", symbol_type: Operator, operation: 4),
    Symbol(notation: "(", symbol_type: Parenthesis, parenthesis_type: Open),
    Symbol(notation: ")", symbol_type: Parenthesis, parenthesis_type: Close),
    Symbol(notation: ".", symbol_type: NumberModifier, modifier_type: Decimal),
    Symbol(notation: ",", symbol_type: NumberModifier, modifier_type: Ignore),
    Symbol(notation: "i", symbol_type: TermModifier, term_modifier_type: Imaginary)
  ]

iterator notations*() : string =
  for symbol in symbols:
    yield symbol.notation

proc matchNotation*(notation: string) : Symbol =
  for symbol in symbols:
    if notation == symbol.notation:
      return symbol
  raise newException(InvalidNotationError, notation)

proc `$`*(symbol: Symbol) : string =
  return symbol.notation

when isMainModule:
  echo $symbols
  doAssert $symbols[2] == "*"
  doAssert matchNotation("*") is Symbol