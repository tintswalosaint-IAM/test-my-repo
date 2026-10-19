/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class KYC_SRV_CustomerCompliance_Response_Test {

    @isTest
    private static void testParseMethod() {
        // Sample JSON payload for testing
        String sampleJson = '{'+
            '"customerId": "CUST12345",'+
            '"assessmentResult": {'+
                '"assessmentId": "ASMNT001",'+
                '"status": "Completed",'+
                '"result": "Pass",'+
                '"screeningResults": ['+
                    '{'+
                        '"screeningId": "SCRN001",'+
                        '"screeningType": "PEP",'+
                        '"screeningName": "Politically Exposed Person",'+
                        '"result": "Clear"'+
                    '}'+
                '],'+
                '"additionalDetails": ['+
                    '{'+
                        '"Pep_Type": "Domestic",'+
                        '"TotalScore": 85.5,'+
                        '"CRA_Category": "Low Risk"'+
                    '}'+
                ']'+
            '}'+
        '}';

        // Act: Parse the JSON into wrapper
        KYC_SRV_CustomerCompliance_Response resp = 
            KYC_SRV_CustomerCompliance_Response.parse(sampleJson);

        // Assert: Validate deserialization worked
       
        Assert.areEqual('CUST12345', resp.customerId, 'CustomerId matched');
    }
}