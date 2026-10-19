/**
* @description    :Test Class for INS_CozaLeadJson generating the json body for SAP API
* @author         :Raja Arsalan (raja.arsalan@standardbank.co.za)
* @date Oct 2023
*/

@isTest
public class INS_CozaLeadJsonTest {
/**
* @description    : Test method for generating json
**/
    @isTest
    static void testParse() {
        // Create a JSON string with sample data
        String jsonString = '{"LeadGeneration": {"Reference": {"Salutation": "Mrs", "PartyName": [{"PartyNameType": "FirstName", "PartyNameValue": "Vicky2"}], "PartyContactPoint": {"TelephonicAddress": [{"PhoneType": "PrimaryPhone", "PhoneNumber": "0746841560"}], "ElectronicAddress": {"EmailAddress": "test@domain2.com"}}}, "LeadandOpportunityProcedure": {"LeadIdentification": {"LeadIdentifcationType": "LeadIdentifier", "LeadIdentifierValue": "90.79"}, "CustomerReference": {"PartyIdentificationType": "01", "PartyIdentificationValue": "8400000000000", "CountryofIssue": "ZA"}, "CustomerCampaignReference": [{"CampaignIdentifierValue": "123", "CampaignName": "CampaignID"}], "LeadOrigin": [{"LeadOriginType": "740", "LeadOriginChannel": "Website"}]}}}';
        
        // Call the parse method to deserialize the JSON string
        INS_CozaLeadJson result = INS_CozaLeadJson.parse(jsonString);
        Assert.areEqual('PrimaryPhone', result.LeadGeneration.Reference.PartyContactPoint.TelephonicAddress[0].PhoneType, 'PhoneType should be "PrimaryPhone"');
        
    }
}