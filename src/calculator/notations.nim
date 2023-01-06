type InvalidNotationError* = object of CatchableError

type
  NotationType = enum ntOperator, ntParenthesis, ntIgnore
  ParenthesisType = enum ptNone, ptOpen, ptClose

  Notation* = ref NotationObj
  NotationObj = object
    token: string
    case notationType: NotationType
      of ntOperator: discard
      of ntParenthesis: parenthesisType: ParenthesisType
      of ntIgnore: discard

proc newNotation(token: string, notationType: NotationType, parenthesisType = ptNone): Notation =
  var newObject: NotationObj
  if notationType == ntParenthesis:
    newObject = NotationObj(token: token, notationType: ntParenthesis, parenthesisType: parenthesisType)
  else:
    newObject = NotationObj(token: token, notationType: notationType)
  new(result)
  result[] = newObject

let notations*: seq[Notation] = @[
    newNotation(token = "+", notationType = ntOperator),
    newNotation(token =  "-",notationType = ntOperator),
    newNotation(token = "*", notationType = ntOperator),
    newNotation(token = "/", notationType = ntOperator),
    newNotation(token = "//", notationType = ntOperator),
    newNotation(token = "(", notationType = ntParenthesis#[, parenthesisType: ptOpen]#),
    newNotation(token = ")", notationType = ntParenthesis#[, parenthesisType: ptClose]#),
    newNotation(token = ".", notationType = ntOperator),
    newNotation(token = ",", notationType = ntIgnore),
    newNotation(token = "i", notationType = ntOperator)]

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