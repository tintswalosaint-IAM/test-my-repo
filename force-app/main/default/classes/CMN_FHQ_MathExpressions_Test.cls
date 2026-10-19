/**
* @description       : Test class for CMN_FHQ_MathExpressions utility.
*                      Provides coverage for arithmetic operators, precedence,
*                      parentheses, unary operations, power operator, decimal handling,
*                      whitespace handling, and complex expression evaluation.
Ver       Date         Author                                                                             Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026       Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270))
*/
@IsTest
private class CMN_FHQ_MathExpressions_Test {

    /**
    * @description Verifies addition operation.
    */
    @IsTest
    static void testAddition() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval('2+3');

            Assert.areEqual(5, result);

        } catch(Exception e) {
         Assert.fail(e.getMessage());        }
        Test.stopTest();
    }


    /**
    * @description Verifies subtraction operation.
    */
    @IsTest
    static void testSubtraction() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval('10-4');

            Assert.areEqual(6, result);

        } catch(Exception e) {
             Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }


    /**
    * @description Verifies multiplication operation.
    */
    @IsTest
    static void testMultiplication() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval('5*6');

            Assert.areEqual(30, result);

        } catch(Exception e) {
             Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }


    /**
    * @description Verifies division operation.
    */
    @IsTest
    static void testDivision() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval('20/4');

            Assert.areEqual(5, result);

        } catch(Exception e) {
             Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }


    /**
    * @description Verifies power operator evaluation.
    */
    @IsTest
    static void testPowerOperator() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval('2^3');

            Assert.areEqual(8, result);

        } catch(Exception e) {
             Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }


    /**
    * @description Verifies operator precedence and parentheses handling.
    */
    @IsTest
    static void testParentheses() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval('(2+3)*4');

            Assert.areEqual(20, result);

        } catch(Exception e) {
             Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }


    /**
    * @description Verifies unary minus operation.
    */
    @IsTest
    static void testUnaryMinus() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval('-5+10');

            Assert.areEqual(5, result);

        } catch(Exception e) {
             Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }


    /**
    * @description Verifies unary minus within parentheses.
    */
    @IsTest
    static void testUnaryMinusParentheses() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval('(-2+5)*2');

            Assert.areEqual(6, result);

        } catch(Exception e) {
             Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }


    /**
    * @description Verifies decimal number handling.
    */
    @IsTest
    static void testDecimalNumbers() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval('2.5*4');

            Assert.areEqual(10, result);

        } catch(Exception e) {
             Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }


    /**
    * @description Verifies right-associative power operator evaluation.
    */
    @IsTest
    static void testRightAssociativePower() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval('2^3^2');

            Assert.areEqual(512, result);

        } catch(Exception e) {
             Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }


    /**
    * @description Verifies evaluation of complex mathematical expressions.
    */
    @IsTest
    static void testComplexExpression() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval('(1+2)*(3+4)/7');

            Assert.areEqual(3, result);

        } catch(Exception e) {
             Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }


    /**
    * @description Verifies expression parsing with whitespace.
    */
    @IsTest
    static void testWhitespaceExpression() {

        Test.startTest();
        try {

            Decimal result =
                CMN_FHQ_MathExpressions.eval(' ( 2 + 3 ) * 2 ');

            Assert.areEqual(10, result);

        } catch(Exception e) {
             Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }

}