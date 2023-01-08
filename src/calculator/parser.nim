import operators
import token

type NumberOperationMismatchError = object of CatchableError

type
  ParserData = ref object
    operationStack: seq[Operation]
    numberStack: seq[Number]
    operationStackStage: NumberType
    operationStackPrecedence: uint
    lastToken: Term

proc popOperation(pd: var ParserData): Operation =
  try:
    result = pd.operationStack.pop() 
    pd.operationStackStage = pd.operationStack[^1].numberStage
    pd.operationStackPrecedence = pd.operationStack[^1].precedence
    return
  
  except:
    pd.operationStackStage = ntComplex
    pd.operationStackPrecedence = high(uint)

proc uninaryValidity(pd: ParserData, operator: Operator): bool =
  result = false
  
  if pd.lastToken.termType in [ttNotation, ttNone]:
    try:
      let uo = operator.uninaryOperation
      
      try:
        let bo = operator.binaryOperation 
      
        if uo.numberStage <= bo.numberStage:
          if uo.precedence <= bo.precedence:
            return true
      
      except UnsupportedOperationError: return
    
    except UnsupportedOperationError: return

proc pushOperation(pd: var ParserData, operation: Operation) =
  pd.operationStackStage = operation.numberStage
  pd.operationStackPrecedence = operation.precedence
  pd.operationStack.add(operation)

proc operate(pd: var ParserData) =
  var o: Operation = pd.popOperation()
  if o is UninaryOperation:
    try:
      let right = convertNumber(pd.numberStack.pop(), o.numberStage)
      UninaryOperation(o).uninaryOperate(right)
    except: 
      raise newException(NumberOperationMismatchError, "")
  
  elif o is BinaryOperation:
    try:
      let left = convertNumber(pd.numberStack.pop(), o.numberStage)
      let right = convertNumber(pd.numberStack.pop(), o.numberStage)
      BinaryOperation(o).binaryOperate(left, right)
    except:
      raise newException(NumberOperationMismatchError, "")

proc processOperator(pd: var ParserData, operator: Operator) =
  var validOperation: Operation = case uninaryValidity(pd, operator):
    of true: operator.uninaryOperation
    of false: operator.binaryOperation

  while pd.operationStackStage < validOperation.numberStage: 
    operate(pd)
  
  while pd.operationStackStage == validOperation.numberStage:
    while pd.operationStackPrecedence <= validOperation.precedence:
      operate(pd)

  pushOperation(pd, validOperation)
    
proc parseTokens(termList: seq[Term]) : Number =
  var parserData: ParserData
  
  for term in termList:
    case term.termType:
    of ttNumber: 
      parserData.numberStack.add(toNumber(term.number))
    of ttNotation:
      try:
        processOperator(parserData, matchOperator(term.notation))
      except: raise
    of ttNone: quit()
    
    parserData.lastToken = term

when isMainModule:
  discard