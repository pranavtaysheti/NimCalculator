import notations

type UndefinedOperatorError = object of CatchableError

type
  NumberType = enum ntPrimitive, ntFloat, ntComplex

  Number* = object
    case numberType*: NumberType:
      of ntPrimitive: primitive*: uint
      of ntFloat: `float`: float
      of ntComplex: 
        real:float
        imaginary: float

proc `$`*(number: Number) : string =
  case number.numberType:
    of ntPrimitive:
      return $number.primitive
    of ntFloat:
      return $number.`float`
    of ntComplex:
      return $number.real & " + i" & $number.imaginary 

type
  OperationType = enum otInfixBinary, otPrefixUninary
  
  Operator* = ref OperatorObj
  OperatorObj = object
    notation: Notation
    numberType: NumberType
    precedence: int
    supportedOperation: set[OperationType]
    binaryOperation: proc (left: Number, right: Number) : Number
    uninaryOperation: proc (right: Number) : Number

using
  left: Number
  right: Number

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

proc imaginary(right) : Number =
  result = Number(numberType: ntComplex, real: 0.0, imaginary: right.`float`)

let operators*: seq[Operator] = @[

  Operator(notation: matchNotation("+"), numberType: ntComplex, precedence: 4, 
    supportedOperation: {otInfixBinary},
    binaryOperation: addition),
  
  Operator(notation: matchNotation("-"), numberType: ntComplex, precedence: 4,
    supportedOperation: {otInfixBinary},
    binaryOperation: substraction),

  Operator(notation: matchNotation("*"), numberType: ntComplex, precedence: 3,
    supportedOperation: {otInfixBinary},
    binaryOperation: multiplication),

  Operator(notation: matchNotation("/"), numberType: ntComplex, precedence: 3,
    supportedOperation: {otInfixBinary},
    binaryOperation: division),

  Operator(notation: matchNotation("."), numberType: ntPrimitive, precedence: 1,
    supportedOperation: {otInfixBinary},
    binaryOperation: decimal),
  
  Operator(notation: matchNotation("i"), numberType: ntFloat, precedence: 2,
    supportedOperation: {otPrefixUninary},
    uninaryOperation: imaginary)
]

proc matchOperator*(searchTerm: Notation) : Operator =
  for operator in operators:
    if searchTerm == operator.notation:
      return operator
  raise newException(UndefinedOperatorError, $searchTerm)

when isMainModule:
  
  doAssert $Number(numberType: ntPrimitive, primitive: 56) == "56"
  doAssert $Number(numberType: ntComplex, real: 56.01, imaginary: 78.3) == 
    "56.01 + i78.3"
  
  let leftPrimitive = Number(numberType: ntPrimitive, primitive: 20)
  let rightPrimitive = Number(numberType: ntPrimitive, primitive: 1001)
  let decimalNumber = decimal(leftPrimitive, rightPrimitive)
  doAssert $decimalNumber == "20.1001"
  doAssert $imaginary(decimalNumber) == "0.0 + i20.1001"