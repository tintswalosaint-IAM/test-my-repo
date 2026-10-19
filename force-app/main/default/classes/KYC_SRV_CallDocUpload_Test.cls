@IsTest
private class KYC_SRV_CallDocUpload_Test {

    class SuccessMock extends CMN_API_HttpBaseOutboundMock {
        protected override void setResponse(HttpRequest req, HttpResponse res) {
            res.setStatusCode(200);
            Map<String, Object> payload = new Map<String, Object>{
                'documentStatus' => 'Success' , 
                'documentStatusMessage' => 'Uploaded Successfully'
                };
            res.setBody(JSON.serialize(payload));
        }
    }

    class FailedMock extends CMN_API_HttpBaseOutboundMock {
        protected override void setResponse(HttpRequest req, HttpResponse res) {
            res.setStatusCode(400);
            Map<String, Object> payload = new Map<String, Object>{
            'error' => new Map<String, Object>{
                'errorCode'    => 400,
                'errorDescription' => 'Invalid'
            }
            };
            res.setBody(JSON.serialize(payload));
        }
    }

    // Helper: get latest content + link it to the specific PartyProfile used by the test
    private static Id linkFileToProfile(Id partyProfileId) {
       // Create a test ContentVersion record
            ContentVersion cv = new ContentVersion(
                Title = 'Test Document',
                PathOnClient = 'test.pdf',
                VersionData = Blob.valueOf('Test data'),
                DocumentType__c = 'Proof of Address'
                
            );
            insert cv;
        system.debug('cv='+cv);
        // Link the ContentVersion to the PartyProfile
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
                LinkedEntityId = partyProfileId,
                ShareType = 'V'
            );
        insert cdl;
		Id ContentDocumentId =[SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        return ContentDocumentId;
    }

    @IsTest
    private static void testSuccessUpload() {
        // Use the profile created in @testSetup
        Id profileProfileId =KYC_TestDataFactory.createPartyProfile('KE');      
        

        Id contentDocId = linkFileToProfile(profileProfileId);		
        KYC_SRV_DocUpload.injectedMock = new SuccessMock();
        Test.startTest();
        KYC_SRV_CallDocUpload.callDocUploadService(profileProfileId, contentDocId);
        Test.stopTest();
        PartyProfile updated = [
            SELECT CMN_DocumentSyncStatus__c, CMN_DocumentSyncReason__c 
            FROM PartyProfile WHERE Id = :profileProfileId
        ];        
       
        Assert.areEqual('Success', updated.CMN_DocumentSyncStatus__c);
        Assert.areEqual('Uploaded Successfully', updated.CMN_DocumentSyncReason__c);
    }

    @IsTest
    private static void testFailedUpload() {
        
        Id profileProfileId =KYC_TestDataFactory.createPartyProfile('KE');  
        Id contentDocId = linkFileToProfile(profileProfileId);
	
         KYC_SRV_DocUpload.injectedMock = new FailedMock();

        Test.startTest();
        KYC_SRV_CallDocUpload.callDocUploadService(profileProfileId, contentDocId);
        Test.stopTest();

        PartyProfile updated = [
            SELECT CMN_DocumentSyncStatus__c, CMN_DocumentSyncReason__c 
            FROM PartyProfile WHERE Id = :profileProfileId
        ];
        
        
        Assert.areEqual('Invalid', updated.CMN_DocumentSyncReason__c);
        
    }

    

   
}