/**
 * @description Evaluates mathematical expression strings supporting operators +, -, *, /, ^
 *              and parentheses. Uses the Shunting-yard algorithm to convert infix notation
 *              to Reverse Polish Notation (RPN), then evaluates the RPN stack.
 *              Supports unary minus and right-associative power (^).
 *
 *              Used by CMN_FHQ_Calculations (formula-based categories) and
 *              CMN_FHQ_SRV_RetirementCalculation (compound interest power terms).
 *              RFLIB logger added for error paths per §6.7 and §11.3 standards.
 *
 * @author Taimoor.shaik@standardbank.co.za, Preetham.Thernakal-Gandla@standardbank.co.za
 * Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119, 172, 270)
 * @date Jan 2026
 */
public with sharing class CMN_FHQ_MathExpressions {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_FHQ_MathExpressions');

    /**
     * @description Private constructor to prevent instantiation.
     *              All methods are static utility methods.
     */
    private CMN_FHQ_MathExpressions() {
    }

    /**
     * @description Evaluates a mathematical expression string and returns the decimal result.
     *              Whitespace is stripped before parsing.
     * @param expression Mathematical expression string (e.g. (1+0.05)^10 or Q1+Q2)
     * @return Evaluated Decimal result
     */
    public static Decimal eval(String expression) {
        expression = expression.replace(' ', '');
        List<String> tokens    = tokenize(expression);
        List<String> rpnTokens = toRpn(tokens);
        return evalRpn(rpnTokens);
    }

    /**
     * @description Tokenises an expression string into numbers and operator characters.
     *              Handles unary minus at position 0, after an open parenthesis, or after
     *              another operator.
     * @param expression Whitespace-stripped expression string
     * @return Ordered list of token strings
     */
    private static List<String> tokenize(String expression) {
        List<String> tokens = new List<String>();
        String numberBuffer = '';

        for (Integer charIndex = 0; charIndex < expression.length(); charIndex++) {
            String currentChar = expression.substring(charIndex, charIndex + 1);
            Boolean isNumberChar = (currentChar >= '0' && currentChar <= '9')
                || currentChar == '.';

            if (isNumberChar) {
                numberBuffer += currentChar;
                continue;
            }

            // Unary minus: expression start, after '(', or after another operator
            Boolean isUnaryMinus = currentChar == '-'
                && (charIndex == 0
                    || expression.substring(charIndex - 1, charIndex) == '('
                    || isOperator(expression.substring(charIndex - 1, charIndex)));

            if (isUnaryMinus) {
                numberBuffer += currentChar;
                continue;
            }

            if (numberBuffer != '') {
                tokens.add(numberBuffer);
                numberBuffer = '';
            }
            tokens.add(currentChar);
        }

        if (numberBuffer != '') {
            tokens.add(numberBuffer);
        }

        return tokens;
    }

    /**
     * @description Returns true when the given token is a supported binary operator.
     * @param token Single-character token to test
     * @return True when token is +, -, *, /, or ^
     */
    private static Boolean isOperator(String token) {
        return token == '+' || token == '-' || token == '*' || token == '/' || token == '^';
    }

    /**
     * @description Returns the operator precedence level. Higher values bind more tightly.
     * @param operator Operator character string
     * @return Precedence integer: 1 (additive), 2 (multiplicative), 3 (power)
     */
    private static Integer precedence(String operator) {
        if (operator == '+' || operator == '-') {
            return 1;
        }
        if (operator == '*' || operator == '/') {
            return 2;
        }
        if (operator == '^') {
            return 3;
        }
        return 0;
    }

    /**
     * @description Returns true when the string can be parsed as a Decimal.
     * @param token String value to test
     * @return True when token represents a valid number
     */
    private static Boolean isNumber(String token) {
        try {
            Decimal.valueOf(token);
            return true;
        } catch (Exception parseException) {
            // Token is an operator or parenthesis, not a number — suppress exception
            LOGGER.debug(
                'CMN_FHQ_MathExpression.isNumber: Token is not a number - token={0}',
                new List<Object>{ token }
            );
            return false;
        }
    }

    /**
     * @description Converts an infix token list to Reverse Polish Notation (RPN)
     *              using the Shunting-yard algorithm. Power (^) is right-associative;
     *              all other operators are left-associative.
     * @param tokens Ordered infix token list from tokenize()
     * @return RPN-ordered token list
     */
    private static List<String> toRpn(List<String> tokens) {
        List<String> outputQueue   = new List<String>();
        List<String> operatorStack = new List<String>();

        for (String token : tokens) {
            if (isNumber(token)) {
                outputQueue.add(token);
            } else if (isOperator(token)) {
                handleOperatorToken(token, operatorStack, outputQueue);
            } else if (token == '(') {
                operatorStack.add(token);
            } else if (token == ')') {
                handleClosingParen(operatorStack, outputQueue);
            }
        }

        while (!operatorStack.isEmpty()) {
            outputQueue.add(operatorStack.remove(operatorStack.size() - 1));
        }

        return outputQueue;
    }

    /**
     * @description Helper method to handle operator tokens in Shunting-yard algorithm.
     *              Manages stack popping based on operator precedence and associativity.
     * @param token Current operator token
     * @param operatorStack Stack of operators being processed
     * @param outputQueue Output queue for RPN tokens
     */
    private static void handleOperatorToken(String token, List<String> operatorStack,
            List<String> outputQueue) {
        Boolean isRightAssociative = token == '^';

        while (!operatorStack.isEmpty()
                && isOperator(operatorStack[operatorStack.size() - 1])) {
            Integer topPrecedence = precedence(operatorStack[operatorStack.size() - 1]);
            Integer tokenPrecedence = precedence(token);

            Boolean shouldPop = isRightAssociative
                ? topPrecedence > tokenPrecedence
                : topPrecedence >= tokenPrecedence;

            if (!shouldPop) {
                break;
            }
            outputQueue.add(operatorStack.remove(operatorStack.size() - 1));
        }
        operatorStack.add(token);
    }

    /**
     * @description Helper method to handle closing parenthesis in Shunting-yard algorithm.
     * @param operatorStack Stack of operators being processed
     * @param outputQueue Output queue for RPN tokens
     */
    private static void handleClosingParen(List<String> operatorStack,
            List<String> outputQueue) {
        while (!operatorStack.isEmpty()
                && operatorStack[operatorStack.size() - 1] != '(') {
            outputQueue.add(operatorStack.remove(operatorStack.size() - 1));
        }
        if (!operatorStack.isEmpty()
                && operatorStack[operatorStack.size() - 1] == '(') {
            operatorStack.remove(operatorStack.size() - 1);
        }
    }

    /**
     * @description Evaluates an RPN token list using a numeric value stack.
     *              Supports +, -, *, / operators and ^ (exponentiation via Math.pow).
     * @param rpnTokens RPN-ordered token list from toRpn()
     * @return Final evaluated Decimal result
     */
    private static Decimal evalRpn(List<String> rpnTokens) {
        List<Decimal> valueStack = new List<Decimal>();

        for (String token : rpnTokens) {
            if (isOperator(token)) {
                Decimal rightOperand = valueStack.remove(valueStack.size() - 1);
                Decimal leftOperand  = valueStack.remove(valueStack.size() - 1);
                Decimal result = applyOperator(token, leftOperand, rightOperand);
                valueStack.add(result);
            } else {
                valueStack.add(Decimal.valueOf(token));
            }
        }

        return valueStack[0];
    }

    /**
     * @description Helper method to apply an operator to two operands.
     * @param operator Operator token (+, -, *, /, or ^)
     * @param leftOperand Left operand of the operation
     * @param rightOperand Right operand of the operation
     * @return Result of applying the operator
     */
    private static Decimal applyOperator(String operator, Decimal leftOperand,
            Decimal rightOperand) {
        switch on operator {
            when '+' {
                return leftOperand + rightOperand;
            }
            when '-' {
                return leftOperand - rightOperand;
            }
            when '*' {
                return leftOperand * rightOperand;
            }
            when '/' {
                return leftOperand / rightOperand;
            }
            when '^' {
                return Decimal.valueOf(
                    Math.pow(leftOperand.doubleValue(), rightOperand.doubleValue())
                );
            }
            when else {
                return Decimal.valueOf(0);
            }
        }
    }
}