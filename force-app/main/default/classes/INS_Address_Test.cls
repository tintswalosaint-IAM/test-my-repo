/**
 *  @description  class  INS_Address_Test   class fro INS_Address.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * 
 *
 * @date Feb 19th 2024
 */
@isTest
public class INS_Address_Test {
    /**
 *  @description method class  testCountryOptions.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * 
 * @return List<Country_Codes__mdt>
 * @date Feb 21th 2024
 */
    @isTest
    public static void testCountryOptions() {
         Test.startTest();
         Final List<Country_Codes__mdt> countryCodes =  INS_Address.getCountryOptions();
         Test.stopTest();
         Assert.areNotEqual(null, countryCodes, 'No country codes'); 
    }
}