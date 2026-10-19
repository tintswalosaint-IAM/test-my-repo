/**
 * @Name of the Class : ICS_CTRL_CurrencyConverter.cls
 * @description class used as currency converter for applicationform Controller.
 * @Author Ikyatha Naidu 
 * @Date 01/06/2024
 * @Last Modified On  : 01/07/2024
 * @Last Modified By  : Ikyatha Naidu
 * @Modification Description : Updated to latest version, made class abstract, and added constructor logic
 */
public with Sharing class ICS_CTRL_CurrencyConverter {
    Private static final string DEFAULT_CURRENCY='GBP';
    @testVisible
    Private  ICS_CTRL_CurrencyConverter(){

    }
    
    
    public static Decimal convertToDefaultCurrency(Decimal amount, String fromCurrencyIsoCode, Map<String, Decimal> conversionMap) {
        // Fetch the exchange rate for the fromCurrencyIsoCode
        Decimal exchangeRate = getExchangeRate(fromCurrencyIsoCode, conversionMap);
       
        // Fetch the exchange rate for the corporate currency
        Decimal corporateExchangeRate = getExchangeRate(DEFAULT_CURRENCY, conversionMap);
        
        // Convert the amount to the corporate currency
        Decimal convertedAmount = (amount / exchangeRate) * corporateExchangeRate;
        
        return convertedAmount.setScale(2); // Adjust the scale as needed
    }
    
    private static Decimal getExchangeRate(String currencyIsoCode, Map<String, Decimal> conversionMap) {
        Decimal conversionRate;
        
        if(conversionMap.containskey(currencyIsoCode)){
        	conversionRate = conversionMap.get(currencyIsoCode);
        }else{
            conversionRate =0;
        }
        return conversionRate;
    }
}