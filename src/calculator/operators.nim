import notations
 
type 
  UndefinedOperatorError* = object of CatchableError
  InvalidNumberConversionError* = object of CatchableError
  UnsupportedOperationError* = object of CatchableError

type
  NumberType* = enum ntNone, ntPrimitive, ntFloat, ntComplex
  Number* = object
    case numberType*: NumberType:
      of ntNone: discard
      of ntPrimitive: primitive: uint
      of ntFloat: `float`: float
      of ntComplex: 
        real:float
        imaginary: float

proc toNumber*(termNumber: uint): Number =
  return Number(numberType: ntPrimitive, primitive: termNumber)

proc convertNumber*(number: Number, newNumberType: NumberType): Number =
  
  if ord(newNumberType) < ord(number.numberType):
    raise newException(InvalidNumberConversionError, "Hi")

  elif ord(newNumberType) == ord(number.numberType):
    return number

  else:
    var newNumber: float = case number.numberType:
      of ntPrimitive: float(number.primitive)
      of ntFloat: number.`float`
      else: 0.0 #case should not be possible
    
    case newNumberType:
    of ntNone: discard #function shouldnt be called with "ntNone" parameter.
    of ntPrimitive: discard #case should not be possible
    of ntFloat: result = Number(numberType: ntFloat, `float`: newNumber)
    of ntComplex: result = Number(numberType: ntComplex, real: newNumber, imaginary: 0.0)

using
  left: Number
  right: Number

proc `$`*(number: Number) : string =
  case number.numberType:
    of ntPrimitive:
      return $number.primitive
    of ntFloat:
      return $number.`float`
    of ntComplex:
      return $number.real & " + i" & $number.imaginary
    of ntNone: discard

type
  Operation* = ref object of RootObj
    numberStage*: NumberType
    precedence*: uint
  
  UninaryOperation* = ref object of Operation
    uninaryOperation: proc (right: Number) : Number
  BinaryOperation* = ref object of Operation
    binaryOperation: proc (left: Number, right: Number) : Number

  Operator* = ref object
    notation: Notation
    
    case supportBinaryOperation: bool:
    of true: binaryOperation*: BinaryOperation
    else: discard
    
    case supportUninaryOperation: bool:
    of true: uninaryOperation*: UninaryOperation
    else: discard

proc addition(left, right) : Number =
  result.real = left.real + right.real
  result.imaginary = left.imaginary + right.imaginary

proc substraction(left, right) : Number =
  result.real = left.real - right.real
  result.imaginary = left.imaginary - right.imaginary

proc multiplication(left, right) : Number =
  result.real = left.real*right.real - left.imaginary*right.imaginary
  result.imaginary = left.real*right.imaginary + left.imaginary*right.real

proc division(left, right) : Number =
  let denominator: float = left.real*left.real + right.real*right.real
  result.real = 
    (left.real*right.real + left.imaginary*right.imaginary)/denominator
  result.imaginary = 
    (left.imaginary*right.real - left.real*right.imaginary)/denominator

proc decimal(left, right) : Number =
  var preDecimal = float(left.primitive)
  var postDecimal = float(right.primitive)
  for i in 0 ..< len($right.primitive):
    postDecimal = postDecimal/10
  result = Number(numberType: ntFloat, `float`: preDecimal + postDecimal)

proc turnImaginary(right) : Number =
  result = Number(numberType: ntComplex, real: 0.0, imaginary: right.`float`)

proc turnPositive(right) : Number = discard

proc turnNegative(right) : Number =
  result = Number(numberType: ntFloat, `float`: -right.`float`)

let operators*: seq[Operator] = @[

  Operator(notation: matchNotation("+"), 
    supportBinaryOperation: true, binaryOperation: BinaryOperation(
      numberStage: ntComplex, precedence: 2,binaryOperation: addition),
    supportUninaryOperation: true, uninaryOperation: UninaryOperation(
      numberStage: ntFloat, uninaryOperation: turnPositive)),
  
  Operator(notation: matchNotation("-"), 
    supportBinaryOperation: true, binaryOperation: BinaryOperation(
      numberStage: ntComplex, precedence: 2,binaryOperation: substraction),
    supportUninaryOperation: true, uninaryOperation: UninaryOperation(
      numberStage: ntFloat, uninaryOperation: turnNegative)),

  Operator(notation: matchNotation("*"), 
    supportBinaryOperation: true, binaryOperation: BinaryOperation(
      numberStage: ntComplex, precedence: 2, binaryOperation: multiplication),
    supportUninaryOperation: false),

  Operator(notation: matchNotation("/"), 
    supportBinaryOperation: true, binaryOperation: BinaryOperation(
      numberStage: ntComplex, precedence: 2, binaryOperation: division),
    supportUninaryOperation: false),

  Operator(notation: matchNotation("."), 
    supportBinaryOperation: true, binaryOperation: BinaryOperation(
      numberStage: ntPrimitive, precedence: 1, binaryOperation: decimal),
    supportUninaryOperation: false),
  
  Operator(notation: matchNotation("i"), 
    supportBinaryOperation: false,
    supportUninaryOperation: true, uninaryOperation: UninaryOperation(
      numberStage: ntFloat, precedence: 1, uninaryOperation: turnImaginary))
]

proc matchOperator*(searchTerm: Notation) : Operator =
  for operator in operators:
    if searchTerm == operator.notation:
      return operator
  raise newException(UndefinedOperatorError, $searchTerm)

proc uninaryOperation*(operator: Operator): Operation =
  if operator.supportUninaryOperation:
    result = operator.uninaryOperation
  else:
    raise newException(UnsupportedOperationError, 
      "Uninary operation not supported.")

proc binaryOperation*(operator: Operator): Operation =
  if operator.supportBinaryOperation:
    result = operator.binaryOperation
  else:
    raise newException(UnsupportedOperationError, 
      "Binary operation not supported.")

proc uninaryOperate*(operation: UninaryOperation; right): Number =
  result = operation[].uninaryOperation(right)

proc binaryOperate*(operation: BinaryOperation; left, right): Number =
  result = operation[].binaryOperation(left, right)


when isMainModule:
  
  doAssert $Number(numberType: ntPrimitive, primitive: 56) == "56"
  doAssert $Number(numberType: ntComplex, real: 56.01, imaginary: 78.3) == 
    "56.01 + i78.3"
  
  let leftPrimitive = Number(numberType: ntPrimitive, primitive: 20)
  let rightPrimitive = Number(numberType: ntPrimitive, primitive: 1001)
  let decimalNumber = decimal(leftPrimitive, rightPrimitive)
  doAssert $decimalNumber == "20.1001"
  doAssert $turnImaginary(decimalNumber) == "0.0 + i20.1001"