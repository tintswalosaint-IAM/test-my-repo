// Author: [Mthandeni Gumede]
// Date: [07/01/2023]
// Description: CMN_API_DeleteCases_Grax 
@isTest
public class CMN_API_DeleteCases_Grax_AWS_TEST {
      
    /* 
   * @description testAPIcalloutAWS test AWS callout
   */
    @IsTest
	private static void testAwsCallout()
	{
	     // Populate testCases with sample Case records
        List<Case> testCases =[SELECT Id, CreatedDate, amazonconnect__AC_Contact_Id__c FROM Case WHERE Status = 'Closed'AND DR_Retain_Until_Date__c <= TODAY];
         List<CMN_API_DeleteVoiceAndChatTranscripts.TranscriptsToDelete> TranscriptsToDeleteList = new List<CMN_API_DeleteVoiceAndChatTranscripts.TranscriptsToDelete>();
        
        for (Case cse : testCases) {
            if(!String.isBlank(cse.amazonconnect__AC_Contact_Id__c)){
                CMN_API_DeleteVoiceAndChatTranscripts.TranscriptsToDelete TranscriptsToDelete = new CMN_API_DeleteVoiceAndChatTranscripts.TranscriptsToDelete();
                TranscriptsToDelete.ContactId = cse.amazonconnect__AC_Contact_Id__c;
                TranscriptsToDelete.Timestamp = cse.CreatedDate.format('yyyy-MM-dd-HH');
                
                TranscriptsToDeleteList.add(TranscriptsToDelete); 
            }
        }
        CMN_API_DeleteVoiceAndChatTranscripts.ContactIdsToDeleteWrapper contactIdWrapper = new CMN_API_DeleteVoiceAndChatTranscripts.ContactIdsToDeleteWrapper();
        contactIdWrapper.TranscriptsToDelete = TranscriptsToDeleteList;

        Test.startTest();
        CMN_API_DeleteCases_AWS awsCall = new CMN_API_DeleteCases_AWS(JSON.serialize(contactIdWrapper));
        CMN_WebserviceCallQueue__c objAws = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_DeleteCases_AWS.SERVICE_NAME);
        awsCall.process(objAws);
        Test.stopTest();
        Assert.areEqual(200, awsCall.getResponseStatusCode(), 'failure message: The values are not equal.'); 
	}
    
     /* 
   * @description testAPIcalloutAWS test Grax callout
   */
    @IsTest
	private static void testGraxCallout()
    {
        List<String> idsSet = new List<String>();
        List<Case> testCases =[SELECT Id, CreatedDate, amazonconnect__AC_Contact_Id__c FROM Case WHERE Status = 'Closed'AND DR_Retain_Until_Date__c <= TODAY];
        
        for (Case cse : testCases) {
           idsSet.add(cse.Id);
        }
        CMN_API_DeleteVoiceAndChatTranscripts.GraxWrapper graxWrapper = new CMN_API_DeleteVoiceAndChatTranscripts.GraxWrapper();
        graxwrapper.ids = idsSet;
        
        Test.startTest();
        CMN_API_DeleteCases_Grax graxCall = new CMN_API_DeleteCases_Grax(JSON.serialize(graxWrapper));
        CMN_WebserviceCallQueue__c objGrax = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_DeleteCases_Grax.SERVICE_NAME);
        graxCall.process(objGrax);
        Test.stopTest();
        
        Assert.areEqual(202, graxCall.getResponseStatusCode(), 'failure message: The values are not equal.'); 
    }
    
   /* 
   * @description testAPIcalloutAWS test AWS And Grax callout
   */
    @isTest
    static void testAPIcalloutAWS() {
        
          // Populate testCases with sample Case records
        List<Case> testCases =[SELECT Id, CreatedDate, amazonconnect__AC_Contact_Id__c FROM Case WHERE Status = 'Closed' AND DR_Retain_Until_Date__c <= TODAY];

        // Call the method to be tested
        Test.startTest();
        Boolean deleteRecords = CMN_API_DeleteVoiceAndChatTranscripts.handleCaseDeletionWithTranscripts(testCases);
        Test.stopTest();

        Assert.areEqual(True ,deleteRecords, 'failure message: The values are not equal.');
   
    }
    
    /**
   * @description testSetUp to insert data needed to test
   */
    @TestSetup
    static void testSetUp() {

            Account acc = new Account();
            acc.name = 'accTest';
            acc.ExternalSystemId__c='01';
            acc.ExternalCIFCountry__c = 'ZA';
            
            insert acc;
            
            List<Case> testCases = new List<Case>();
            for (Integer i = 0; i < 20; i++) {
                Case testCase = new Case();
                testCase.Status = 'Closed';
                testCase.DR_Retain_Until_Date__c = Date.today();
                testCase.amazonconnect__AC_Contact_Id__c='TESTCONTACTID'+ i;
                testCase.AccountId = acc.Id;
                testCases.add(testCase);
            }
            
            insert testCases;
    }
    
}