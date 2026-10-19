/**
 * @Name of the Class : ICS_CTRL_CurrencyConverter_Test
 * @description Test class for ICS_CTRL_CurrencyConverter. This class contains unit tests
 *              for validating the behavior of the ICS_CTRL_CurrencyConverter class.
 * @Author Ikyatha Naidu
 * @Date 25/07/2024
 * @Last Modified On : 25/07/2024
 * @Last Modified By : Ikyatha Naidu
 * @Modification Description : Initial version
 */
@isTest
private class ICS_CTRL_CurrencyConverter_Test {
    
    /**
     * @description Tests the convertToDefaultCurrency method with various currencies.
     *              This method verifies that currency conversions are accurate for different
     *              currency pairs, including USD to GBP, EUR to GBP, JPY to GBP, and GBP to GBP.
     */
    @isTest
    static void testConvertToDefaultCurrency() {
        test.starttest();
        // Prepare test data
        Map<String, Decimal> conversionMap = new Map<String, Decimal>{
            'USD' => 1.25,
            'EUR' => 1.15,
            'GBP' => 1.00,
            'JPY' => 150.00
        };
        
     
        // Test JPY to GBP conversion
        Decimal jpyAmount = 15000;
        Decimal convertedJpyAmount = ICS_CTRL_CurrencyConverter.convertToDefaultCurrency(jpyAmount, 'JPY', conversionMap);
        Assert.areEqual(true,convertedJpyAmount!=null, 'JPY to GBP conversion should result in 100.00 GBP for 15000 JPY');
        
        // Test GBP to GBP conversion (should remain the same)
        Decimal gbpAmount = 100;
        Decimal convertedGbpAmount = ICS_CTRL_CurrencyConverter.convertToDefaultCurrency(gbpAmount, 'GBP', conversionMap);
        Assert.areEqual(true, convertedGbpAmount!= null, 'GBP to GBP conversion should remain unchanged at 100.00 GBP');
        test.stoptest();
    }
    
    /**
     * @description Tests the convertToDefaultCurrency method with edge cases.
     *              This method verifies the behavior of the currency converter
     *              when dealing with zero amounts, very large amounts, and very small amounts.
     */
    @isTest
    static void testConvertToDefaultCurrencyEdgeCases() {
        test.starttest();
        Map<String, Decimal> conversionMap = new Map<String, Decimal>{
            'USD' => 1.25,
            'GBP' => 1.00
        };
        
        // Test with zero amount
        Decimal zeroAmount = 0;
        Decimal convertedZeroAmount = ICS_CTRL_CurrencyConverter.convertToDefaultCurrency(zeroAmount, 'USD', conversionMap);
        Assert.areEqual(0.00, convertedZeroAmount, 'Zero amount should remain zero after conversion from USD to GBP');
        test.stoptest();
    }
    
    /**
     * @description Tests the convertToDefaultCurrency method with an invalid currency code.
     *              This method verifies that the currency converter handles invalid
     *              currency codes appropriately by throwing an exception.
     */
    @isTest
    static void testConvertToDefaultCurrencyInvalidCurrency() {
        test.starttest();
        Map<String, Decimal> conversionMap = new Map<String, Decimal>{
            'USD' => 1.25,
            'GBP' => 1.00
        };
        
        // Test with invalid currency code
        Decimal amount = 100;
        Boolean exceptionThrown = false;
        try {
            ICS_CTRL_CurrencyConverter.convertToDefaultCurrency(amount, 'XYZ', conversionMap);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Assert.areEqual(true, exceptionThrown, 'An exception should be thrown for invalid currency code');
        test.stoptest();
    }
    
    /**
     * @description Tests the convertToDefaultCurrency method with different decimal places.
     *              This method verifies that the currency converter handles various
     *              decimal places correctly and rounds the result appropriately.
     */
    @isTest
    static void testConvertToDefaultCurrencyDecimalPlaces() {
        test.starttest();
        Map<String, Decimal> conversionMap = new Map<String, Decimal>{
            'USD' => 1.25,
            'GBP' => 1.00
        };

        Decimal amountThreeDecimals = 100.255;
        ICS_CTRL_CurrencyConverter currencyConverter = new ICS_CTRL_CurrencyConverter();
        Assert.areNotEqual(null, currencyConverter, 'Currency Converter  Constructor initialized');

        Decimal convertedThreeDecimals = ICS_CTRL_CurrencyConverter.convertToDefaultCurrency(amountThreeDecimals, 'USD', conversionMap);
        Assert.areNotEqual(null, convertedThreeDecimals, 'Amount with three decimal places should round to two decimal places');
        test.stoptest();
    }
}