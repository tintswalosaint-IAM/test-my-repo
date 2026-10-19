/**
* @description Class is called from a flow (Lead_Allocate_Send_leads_to_dialer_via_API) for generating access tokens and calling Experience Lead Api to create a record in SAP
* @author Raja Arsalan (raja.arsalan@standardbank.co.za)
* @date Sept 2023
*/

public without sharing class INS_CozaLeadToSAP {
/**
* @description       : Invokable method called from a flow (Lead_Allocate_Send_leads_to_dialer_via_API) to send data to SAP.
* @author            : Raja Arsalan (Raja.Arsalan@standardbank.co.za)
* @param leadIds
**/
@InvocableMethod(label='Send Lead to SAP')
public static void sendLeadToSAP(List<String> leadIds) {
    INS_CozaLeadAPICallout.sendLeadToSAP(leadIds); 
}

/**
* @description       : This method gets the data from salesforce, create a json body and then call sendtoSAP method
* @author            : Raja Arsalan (Raja.Arsalan@standardbank.co.za)
* @param leadIds
* @return cozaLeadJsonString
**/
public static string createLeadJson(List<String> leadIds)
{
    
    String leadId = leadIds[0];
    List<CampaignMember> campMember = New INS_SEL_CampaignMember().selectCampaignMemberById(leadId);
    
    list<lead> currentLead = New SEL_Lead().selectLeadByRecId(leadIds[0]);    
    if(currentLead[0] != null && currentLead[0].Expressed_Interest_Product__c != null)
    {
       List<Leads_ProductQueueAllocation__c> expressedInterestProduct = new INS_SEL_Leads_ProductQueueAllocation().selectProductQueueAllocationById(currentLead[0].Expressed_Interest_Product__c); 
    

    
    // Create an instance of INS_CozaLeadJson
    INS_CozaLeadJson cozaLeadJson = new INS_CozaLeadJson();
    cozaLeadJson.LeadGeneration = new INS_CozaLeadJson.ClsLeadGeneration();
    cozaLeadJson.LeadGeneration.Reference = new INS_CozaLeadJson.ClsReference();
    cozaLeadJson.LeadGeneration.LeadandOpportunityProcedure = new INS_CozaLeadJson.ClsLeadandOpportunityProcedure();
    
    // Create instances of INS_CozaLeadJson.ClsPartyName and add them to the list
    List<INS_CozaLeadJson.ClsPartyName> partyName = new List<INS_CozaLeadJson.ClsPartyName>();
    
    INS_CozaLeadJson.ClsPartyName firstName = new INS_CozaLeadJson.ClsPartyName();
    firstName.PartyNameType = 'FirstName';  
    firstName.PartyNameValue = currentLead[0].firstname; 
    
    INS_CozaLeadJson.ClsPartyName lastName = new INS_CozaLeadJson.ClsPartyName();
    lastName.PartyNameType = 'LastName';  
    lastName.PartyNameValue = currentLead[0].lastname; 
    
    partyName.add(firstName);
    partyName.add(lastName);
    
    // Create instances of INS_CozaLeadJson.ClsTelephonicAddress and add them to the list
    INS_CozaLeadJson.ClsPartyContactPoint partyContactPoint = new INS_CozaLeadJson.ClsPartyContactPoint();
    List<INS_CozaLeadJson.ClsTelephonicAddress> telephoneicAdd = new list<INS_CozaLeadJson.ClsTelephonicAddress>();
    
    //Primary Number
    INS_CozaLeadJson.ClsTelephonicAddress primaryPhone = new INS_CozaLeadJson.ClsTelephonicAddress();
    primaryPhone.PhoneType = 'PrimaryPhone';  
    primaryPhone.PhoneNumber = currentLead[0].mobilePhone;
    
    //Alternate Number
    INS_CozaLeadJson.ClsTelephonicAddress alternatePhone = new INS_CozaLeadJson.ClsTelephonicAddress();
    alternatePhone.PhoneType = 'AlternatePhone';  
    alternatePhone.PhoneNumber = currentLead[0].Phone;
    
    telephoneicAdd.add(primaryPhone);
    telephoneicAdd.add(alternatePhone);
    partyContactPoint.TelephonicAddress = telephoneicAdd;
    
    INS_CozaLeadJson.ClsElectronicAddress electronicAdd = new INS_CozaLeadJson.ClsElectronicAddress();  
    electronicAdd.EmailAddress = currentLead[0].email;
    partyContactPoint.ElectronicAddress = electronicAdd;
    
    // Set ClsReference
    cozaLeadJson.LeadGeneration.Reference.Salutation = currentLead[0].salutation;
    cozaLeadJson.LeadGeneration.Reference.PartyName = partyName;
    cozaLeadJson.LeadGeneration.Reference.PartyContactPoint = partyContactPoint;
    
    INS_CozaLeadJson.ClsLeadIdentification leadIdentificationjson = new INS_CozaLeadJson.ClsLeadIdentification();
    leadIdentificationjson.LeadIdentifcationType = 'LeadIdentifier';
    leadIdentificationjson.LeadIdentifierValue = currentLead[0].Id;
    
    List<INS_CozaLeadJson.ClsCustomerCampaignReference> campaignData = new List<INS_CozaLeadJson.ClsCustomerCampaignReference>();
    
    INS_CozaLeadJson.ClsCustomerCampaignReference campaiagnIdjson = new INS_CozaLeadJson.ClsCustomerCampaignReference();
    campaiagnIdjson.CampaignIdentifierValue = campMember[0].campaignId;  
    campaiagnIdjson.CampaignName = 'CampaignID';  
    
    INS_CozaLeadJson.ClsCustomerCampaignReference campaiagnNamejson = new INS_CozaLeadJson.ClsCustomerCampaignReference();
    campaiagnNamejson.CampaignIdentifierValue = currentLead[0].Campaign_Name__c;  
    campaiagnNamejson.CampaignName = 'CampaignName';
    
    campaignData.add(campaiagnIdjson);
    campaignData.add(campaiagnNamejson);
    
    List<INS_CozaLeadJson.ClsLeadOrigin> leadOrigintData = new List<INS_CozaLeadJson.ClsLeadOrigin>();
    
    INS_CozaLeadJson.ClsLeadOrigin leadOrigintjson = new INS_CozaLeadJson.ClsLeadOrigin();
    leadOrigintjson.LeadOriginType = currentLead[0].campaign_source_id__c;
    leadOrigintjson.LeadOriginType = currentLead[0].campaign_source_id__c;
    leadOrigintjson.LeadOriginChannel = 'Website';  
    leadOrigintData.add(leadOrigintjson);
    
    cozaLeadJson.LeadGeneration.LeadandOpportunityProcedure.LeadIdentification = leadIdentificationjson;
    cozaLeadJson.LeadGeneration.LeadandOpportunityProcedure.CustomerCampaignReference = campaignData;
    cozaLeadJson.LeadGeneration.LeadandOpportunityProcedure.LeadOrigin = leadOrigintData;
    
    INS_CozaLeadJson.ClsProductIdentification prodIdjson = new INS_CozaLeadJson.ClsProductIdentification();  
    prodIdjson.ProductIdentifierValue = expressedInterestProduct[0].Leads_Product_Name__c;
    prodIdjson.ProductType = expressedInterestProduct[0].Leads_Product_Group__c;
    
    List<INS_CozaLeadJson.ClsProductClassification> prodClassData = new List<INS_CozaLeadJson.ClsProductClassification>();
    
    INS_CozaLeadJson.ClsProductClassification prodFamJson = new INS_CozaLeadJson.ClsProductClassification();  
    prodFamJson.ProductCategoryType = 'Family';
    prodFamJson.ProductCategory = expressedInterestProduct[0].Leads_Product_Family__c;
    
    INS_CozaLeadJson.ClsProductClassification prodsubjson = new INS_CozaLeadJson.ClsProductClassification();  
    prodsubjson.ProductCategoryType = 'Sub Family';
    prodsubjson.ProductCategory = expressedInterestProduct[0].Leads_ProductSubFamily__c;
    
    prodClassData.add(prodFamJson);
    prodClassData.add(prodsubjson);
    
    INS_CozaLeadJson.ClsProductSeller prodsellerjson = new INS_CozaLeadJson.ClsProductSeller();  
    prodsellerjson.Country = expressedInterestProduct[0].Leads_Jurisdiction__c;
    
    // Set ClsProductDirectoryEntry
    INS_CozaLeadJson.ClsProductDirectoryEntry productDirectoryEntry = new INS_CozaLeadJson.ClsProductDirectoryEntry();
    productDirectoryEntry.ProductIdentification = prodIdjson;
    productDirectoryEntry.ProductClassification = prodClassData;
    productDirectoryEntry.ProductSeller = prodsellerjson;
    
    cozaLeadJson.LeadGeneration.ProductDirectoryEntry = productDirectoryEntry;
    
    // Serialize the INS_CozaLeadJson object to JSON
    String cozaLeadJsonString = JSON.serialize(cozaLeadJson);
    
    return cozaLeadJsonString;
        
}
    else{
        return null;
    }
    
    
}
}