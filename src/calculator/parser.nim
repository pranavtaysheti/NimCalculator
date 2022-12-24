import std / strutils
import constants

type InvalidExpressionError = object of CatchableError

type
  TermType = enum
    TTNone, TTNumber, TTSymbol
  
  Term = object
    case termType: TermType
      of TTNone: discard
      of TTNumber: number: int
      of TTSymbol: symbol: Symbol

proc `$`(term: Term) : string =
  case term.termType:
    of TTNone: return ""
    of TTNumber: return $term.number
    of TTSymbol: return $term.symbol

type
  TermStringType = enum
    TSNone, TSDecimal, TSString

proc createTerm(termString: string, termStringType: TermStringType): Term =
  var newTerm: Term
    
  case termStringType:

    of TSNone: newTerm = Term(termType: TTNone)

    of TSDecimal:
      var num: int = 0
      for digit in termString:
        num = num*10 + parseInt($digit)
      newTerm = Term(termType: TTNumber, number: num)

    of TSString:
      var matchedSymbol : Symbol
      try: 
        matchedSymbol = matchNotation(termString)
        newTerm = Term(termType: TTSymbol, symbol: matchedSymbol)
      except InvalidNotationError: raise

  return newTerm

proc parseExpression(inputExpression: string) : seq[Term] =
  let rawExpression : string = inputExpression & ' '
  var parsedList : seq[Term]
  var termString = ""
  var termStringType = TSNone

  for token in rawExpression:
    let newTermStringType =
      if token.isDigit(): TSDecimal
      elif token == ' ': TSNone
      else: TSString

    if (termStringType != newTermStringType):

      try:
        let newTerm = createTerm(termString, termStringType)
        if newTerm.termType == TTNone: discard
        else: parsedList.add(newTerm)
        reset(termString)
        
        termStringType = newTermStringType

      except InvalidNotationError:
        let invalidString = getCurrentExceptionMsg()
        raise newException(InvalidExpressionError, invalidString)
    
    termString.add(token)


  return parsedList

when isMainModule:
  doAssert $parseExpression("22+33*42/6") == "@[22, +, 33, *, 42, /, 6]"
  doAssert $parseExpression(" 22 +33*4 2/6  ") == "@[22, +, 33, *, 4, 2, /, 6]"
  doAssertRaises(InvalidExpressionError) : discard parseExpression("22**68")