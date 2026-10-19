/**
 * @description : Test data factory class for DocumentManagementHelper_TEST and ESBDocumentRepositoryManager_TEST
 * @author : Jaco de Lange
 * @last modified on : 11-11-2024
**/

public with sharing class INS_DocumentManagementTestFactory_TEST {
    private INS_DocumentManagementTestFactory_TEST(){}

    public static Account createAccount() {
        Account acc = New Account (FirstName = 'First Name', LastName = 'Last Name');
        if (Account.sObjectType.getDescribe().isCreateable()){  
            insert acc;
        }
        return acc;
    }
    public static Claim createClaim() {
        Claim cl = new Claim (Name = 'TestClaim');
        if (Schema.sObjectType.Claim.isCreateable()){
            insert cl;
        }
        return cl;
    }
    public static Case createCase() {
        Case c = new Case(Subject = 'TestCase');
        if (Schema.sObjectType.Case.isCreateable()){
            insert c;
        }
        return c;
    }  
    public static Case createCaseWithClaim(Id claimId) {
        Case c = new Case(Subject = 'TestCase', Insurance_Claim__c=claimId);
        if (Schema.sObjectType.Case.isCreateable()){
            insert c;
        }
        return c;
     }  
     public static Case createCaseWithInsurancePolicy(Id policyId) {
        Case c = new Case(Subject = 'TestCase', Insurance_Policy__c=policyId);
        if (Schema.sObjectType.Case.isCreateable()){
            insert c;
        }
        return c;
     }  
    public static InsurancePolicy createInsurancePolicy(Id nameInsuredId) {
        InsurancePolicy ip = new InsurancePolicy (
            Name = 'TestPolicy',
            Status = 'Active',
            NameInsuredId = nameInsuredId);
            if (Schema.sObjectType.InsurancePolicy.isCreateable()){
                insert ip;
            }
        return ip;
    }
    public static ContentVersion createContentVersion(Id documentType) {
        return new ContentVersion(
            VersionData = Blob.valueOf('versiondata'),
            Title = 'doc upload',
            Document_Type_Id__c = documentType,
            PathOnClient = 'medical report.pdf'
        );
    }
    public static Document_Upload_Configuration__mdt getDocumentType() {
        return [
            SELECT
                DeveloperName,
                Entity_Type__c,
                BPID__c,
                Document_Type_Id__c
            FROM Document_Upload_Configuration__mdt
            WHERE Params_to_Exclude__c != null
            LIMIT 1
        ];
    }
}