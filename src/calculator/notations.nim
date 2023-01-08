type InvalidNotationError* = object of CatchableError

type
  NotationType = enum ntOperator, ntParenthesis, ntIgnore
  ParenthesisType = enum ptNone, ptOpen, ptClose

  Notation* = ref object
    token: string
    case notationType: NotationType
      of ntIgnore: discard
      of ntOperator: discard
      of ntParenthesis: parenthesisType: ParenthesisType

let notations*: seq[Notation] = @[
    Notation(token: "+", notationType: ntOperator),
    Notation(token: "-",notationType: ntOperator),
    Notation(token: "*", notationType: ntOperator),
    Notation(token: "/", notationType: ntOperator),
    Notation(token: "//", notationType: ntOperator),
    Notation(token: "(", notationType: ntParenthesis, parenthesisType: ptOpen),
    Notation(token: ")", notationType: ntParenthesis, parenthesisType: ptClose),
    Notation(token: ".", notationType: ntOperator),
    Notation(token: ",", notationType: ntIgnore),
    Notation(token: "i", notationType: ntOperator)]

iterator notationsStrings*() : string =
  for notation in notations:
    yield notation.token

proc matchNotation*(searchTerm: string) : Notation =
  for notation in notations:
    if searchTerm == notation.token:
      return notation
  raise newException(InvalidNotationError, searchTerm)

proc `$`*(notation: Notation) : string =
  return notation.token

when isMainModule:
  echo $notations
  doAssert $notations[2] == "*"
  doAssert matchNotation("*") is Notation