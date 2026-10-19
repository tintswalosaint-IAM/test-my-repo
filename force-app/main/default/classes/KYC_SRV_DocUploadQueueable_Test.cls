/**
    ***************************************************************************************
 */
@isTest
private class KYC_SRV_DocUploadQueueable_Test {

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
                'errorMessage' => 'Invalid'
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
        
        List<Id> docIds = new List<Id>();
        Id contentDocId = linkFileToProfile(profileProfileId);	
        docIds.add(contentDocId);	
        KYC_SRV_DocUpload.injectedMock = new SuccessMock();
        Test.startTest();
        System.enqueueJob(new KYC_SRV_DocUploadQueueable(profileProfileId, docIds));
        Test.stopTest();
        PartyProfile updated = [
            SELECT Document_Sync_Status__c, Document_Sync_Reason__c 
            FROM PartyProfile WHERE Id = :profileProfileId
        ];        
       
        Assert.areEqual('Success', updated.Document_Sync_Status__c);
        Assert.areEqual('Uploaded Successfully', updated.Document_Sync_Reason__c);
    }
    
    
}