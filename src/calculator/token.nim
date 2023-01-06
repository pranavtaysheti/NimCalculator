import std / strutils #TODO: impliment parseStr myself.
import notations

type UnexpectedTokenError = object of CatchableError

type
  TermType* = enum ttNone, ttNumber, ttNotation
  
  Term* = object
    case termType*: TermType
      of ttNone: discard
      of ttNumber: number*: int
      of ttNotation: notation*: Notation

proc `$`*(term: Term) : string =
  case term.termType:
    of ttNone: return ""
    of ttNumber: return $term.number
    of ttNotation: return $term.notation

type TermStringType = enum tsNone, tsDecimal, tsString

proc createTerm(termString: string, termStringType: TermStringType): Term =
  var newTerm: Term
    
  case termStringType:

    of tsNone: newTerm = Term(termType: ttNone)

    of tsDecimal:
      var num: int = 0
      for digit in termString:
        num = num*10 + parseInt($digit)
      newTerm = Term(termType: ttNumber, number: num)

    of tsString:
      var matchedSymbol : Notation
      try: 
        matchedSymbol = matchNotation(termString)
        newTerm = Term(termType: ttNotation, notation: matchedSymbol)
      except InvalidNotationError: raise

  return newTerm

proc tokenizeExpression*(inputExpression: string) : seq[Term] =
  let rawExpression : string = inputExpression & ' '
  var parsedList : seq[Term]
  var termString = ""
  var termStringType = tsNone

  for token in rawExpression:
    let newTermStringType =
      if token.isDigit(): tsDecimal
      elif token == ' ': tsNone
      else: tsString

    if (termStringType != newTermStringType):

      try:
        let newTerm = createTerm(termString, termStringType)
        if newTerm.termType == ttNone: discard
        else: parsedList.add(newTerm)
        reset(termString)
        
        termStringType = newTermStringType

      except InvalidNotationError:
        let invalidString = getCurrentExceptionMsg()
        raise newException(UnexpectedTokenError, invalidString)
    
    termString.add(token)

  return parsedList

when isMainModule:
  doAssert $tokenizeExpression("22+33*42/6") == "@[22, +, 33, *, 42, /, 6]"
  doAssert $tokenizeExpression(" 22 +33*4 2/6  ") == "@[22, +, 33, *, 4, 2, /, 6]"
  doAssertRaises(UnexpectedTokenError) : discard tokenizeExpression("22**68")