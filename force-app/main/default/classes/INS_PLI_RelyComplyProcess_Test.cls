/**
 * @description Test class for INS_PLI_RelyComplyProcess class
 * @author Alexandr Goryachko
 * @since 21-11-2025
 * @UserStory : SFP-54457
 */
@IsTest
public class INS_PLI_RelyComplyProcess_Test {
    private static Id personAccountProspectRT = Schema.SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('Person_Account_Prospect').getRecordTypeId();
    private static Id opportunityGeneralRT = Schema.SObjectType.Opportunity
        .getRecordTypeInfosByDeveloperName()
        .get('General').getRecordTypeId();
    
    public static String response = '{"result":"Success","serviceReferenceId":"","policyPayloadHash":"b1684402a5040e8e44350bd406bb16e0","policyPayload":{"ownerPassportNo":"saddafsdsadf9","bankName":"","bankBranchCode":"","bankAccountType":"","bankAccountNo":"123654789632","debitDay":"7","abi":"5","consultantCode":"","policyFee":"","thirdPartyPolicy":"","policyDiscountRand":"","policyDiscountPercent":"","policyNettPremium":"8345.81","lastSkipDate":"","collectionMethod":"","waiveWaitingPeriod":"","policyNote":"","ownerRegistrationNo":"","status":"Active","policyNumber":"KLA00114","product":"","ownerFirstName":"Three","ownerLastName":"Zebra","ownerCellphone":"0662252866","ownerEmailAddress":"nivasha.ramborosa@mobi.co.za","sumAssured":"25000000","externalPolicyNumber":"KLA00114","dateCreated":"2025-12-1815:24:18","ownerIdNo":"0000213654084","ownerSaIdNo":"0000213654084","anniversaryDate":"","inceptionDate":"","contractStatusDateTime":"","contractStatusReason":"","contractStatusReasonDate":"","automaticContributionIncrease":"","coverPercentage":"","ownerAge":"25","servicingChannel":"","servicingAgent":"","saleChannel":"","policyEndDate":"","campaignCode":"","promoCode":"","mandateReferenceNumber":"","leadId":"","ownerRegistrationType":"","policyRoleplayerArray":[{"policyRoleplayerType":"AccountPayer","policyRoleplayerFirstname":"Three","policyRoleplayerMiddlename":"","policyRoleplayerInitials":"T","policyRoleplayerLastname":"Zebra","policyRoleplayerCellphone":"0662252866","policyRoleplayerEmailAddress":"nivasha.ramborosa@mobi.co.za","policyRoleplayerIdNumber":"0000213654084","policyRoleplayerPassportNumber":"saddafsdsadf9","policyRoleplayerDateOfBirth":"2000-10-13","policyRoleplayerExternalCustomerReference":"","policyRoleplayerRelationshipToOwner":"","policyRoleplayerRelationshipTo":"","policyRoleplayerPercentage":"","policyRoleplayerUniqueIdentifier":"KLA00114RP0033308414","policyRoleplayerGender":"M","passportData":{},"addressArray":[]},{"policyRoleplayerType":"Owner","policyRoleplayerFirstname":"Three","policyRoleplayerMiddlename":"","policyRoleplayerInitials":"T","policyRoleplayerLastname":"Zebra","policyRoleplayerCellphone":"0662252866","policyRoleplayerEmailAddress":"nivasha.ramborosa@mobi.co.za","policyRoleplayerIdNumber":"0000213654084","policyRoleplayerPassportNumber":"saddafsdsadf9","policyRoleplayerDateOfBirth":"2000-10-13","policyRoleplayerExternalCustomerReference":"","policyRoleplayerRelationshipToOwner":"","policyRoleplayerRelationshipTo":"","policyRoleplayerPercentage":"","policyRoleplayerUniqueIdentifier":"KLA00114RP0033308415","policyRoleplayerGender":"M","passportData":{},"addressArray":[]},{"policyRoleplayerType":"PrimaryLifeAssured","policyRoleplayerFirstname":"Three","policyRoleplayerMiddlename":"","policyRoleplayerInitials":"T","policyRoleplayerLastname":"Zebra","policyRoleplayerCellphone":"0662252866","policyRoleplayerEmailAddress":"nivasha.ramborosa@mobi.co.za","policyRoleplayerIdNumber":"0000213654084","policyRoleplayerPassportNumber":"saddafsdsadf9","policyRoleplayerDateOfBirth":"2000-10-13","policyRoleplayerExternalCustomerReference":"","policyRoleplayerRelationshipToOwner":"","policyRoleplayerRelationshipTo":"","policyRoleplayerPercentage":"","policyRoleplayerUniqueIdentifier":"KLA00114RP0033308416","policyRoleplayerGender":"M","passportData":{},"addressArray":[]},{"policyRoleplayerType":"Spouse","policyRoleplayerFirstname":"Three","policyRoleplayerMiddlename":"","policyRoleplayerInitials":"T","policyRoleplayerLastname":"Zebra","policyRoleplayerCellphone":"0662252866","policyRoleplayerEmailAddress":"nivasha.ramborosa@mobi.co.za","policyRoleplayerIdNumber":"0000213654084","policyRoleplayerPassportNumber":"saddafsdsadf9","policyRoleplayerDateOfBirth":"2000-10-13","policyRoleplayerExternalCustomerReference":"","policyRoleplayerRelationshipToOwner":"","policyRoleplayerRelationshipTo":"","policyRoleplayerPercentage":"","policyRoleplayerUniqueIdentifier":"KLA00114RP0033308417","policyRoleplayerGender":"M","passportData":{},"addressArray":[]},{"policyRoleplayerType":"Parent","policyRoleplayerFirstname":"Three","policyRoleplayerMiddlename":"","policyRoleplayerInitials":"T","policyRoleplayerLastname":"Zebra","policyRoleplayerCellphone":"0662252866","policyRoleplayerEmailAddress":"nivasha.ramborosa@mobi.co.za","policyRoleplayerIdNumber":"0000213654084","policyRoleplayerPassportNumber":"saddafsdsadf9","policyRoleplayerDateOfBirth":"2000-10-13","policyRoleplayerExternalCustomerReference":"","policyRoleplayerRelationshipToOwner":"","policyRoleplayerRelationshipTo":"","policyRoleplayerPercentage":"","policyRoleplayerUniqueIdentifier":"KLA00114RP0033308418","policyRoleplayerGender":"M","passportData":{},"addressArray":[]},{"policyRoleplayerType":"Child","policyRoleplayerFirstname":"Three","policyRoleplayerMiddlename":"","policyRoleplayerInitials":"T","policyRoleplayerLastname":"Zebra","policyRoleplayerCellphone":"0662252866","policyRoleplayerEmailAddress":"nivasha.ramborosa@mobi.co.za","policyRoleplayerIdNumber":"0000213654084","policyRoleplayerPassportNumber":"saddafsdsadf9","policyRoleplayerDateOfBirth":"2000-10-13","policyRoleplayerExternalCustomerReference":"","policyRoleplayerRelationshipToOwner":"","policyRoleplayerRelationshipTo":"","policyRoleplayerPercentage":"","policyRoleplayerUniqueIdentifier":"KLA00114RP0033308419","policyRoleplayerGender":"M","passportData":{},"addressArray":[]}],"benefitArray":[{"benefitId":"1","benefitPremium":"8345.81","benefitAmount":"8345.81","benefitSumAssured":"25000000","benefitTerm":"","benefitFrequency":"","benefitDiscountPercent":"","benefitFee":"","benefitUniqueIdentifier":"KLA00114B0012265908","benefitStatus":"Active","benefitUnderwritingArray":{"questionArray":[{"questionUniqueIdentifier":"pIUaD2zP1D2","selectedAnswerArray":["2366666"]},{"questionUniqueIdentifier":"pIUaD2zP1D5","selectedAnswerArray":["VPO5490NA5d"]},{"questionUniqueIdentifier":"Cg76Hh6vg5","selectedAnswerArray":["Hgmxb3hLWv"]},{"questionUniqueIdentifier":"we6AaOQ2Ae","selectedAnswerArray":["6NPb3znpJs"]},{"questionUniqueIdentifier":"PESRoJ0isX","selectedAnswerArray":["YUX5vxy5Dd"]},{"questionUniqueIdentifier":"WKL5LZzxwx","selectedAnswerArray":["OxWDSKCX5n"]},{"questionUniqueIdentifier":"GnCBgGCcFS","selectedAnswerArray":["W0CdWp1Num"]},{"questionUniqueIdentifier":"kBjJzsdemh","selectedAnswerArray":["CZ0f9wHjxG"]},{"questionUniqueIdentifier":"syKZU1e6lF","selectedAnswerArray":["Q6br0rdtRh"]},{"questionUniqueIdentifier":"86WiQYgFmX","selectedAnswerArray":["YGFoqzcytm"]},{"questionUniqueIdentifier":"P9LcJrbCQz","selectedAnswerArray":["xORCuuDvZb"]},{"questionUniqueIdentifier":"fBhvLkChHe","selectedAnswerArray":["Y8c3m3GCAS"]},{"questionUniqueIdentifier":"4uToxAi4tj","selectedAnswerArray":["XpAfXTFmRB"]},{"questionUniqueIdentifier":"yhdUfXIXeM","selectedAnswerArray":["vn78PYeGsq"]},{"questionUniqueIdentifier":"CriXWR2Ajq","selectedAnswerArray":["RerEIJ1HV0"]},{"questionUniqueIdentifier":"6jxTkPNJ7t","selectedAnswerArray":["oZwzBq614q"]},{"questionUniqueIdentifier":"XNvyiU11Il","selectedAnswerArray":["IdBcEH6lyu"]}]},"benefitRoleplayerArray":[{"benefitRoleplayerType":"LifeAssured","benefitRoleplayerFirstname":"Three","benefitRoleplayerMiddlename":"","benefitRoleplayerInitials":"T","benefitRoleplayerLastname":"Zebra","benefitRoleplayerCellphone":"0662252866","benefitRoleplayerEmailAddress":"nivasha.ramborosa@mobi.co.za","benefitRoleplayerIdNumber":"0000213654084","benefitRoleplayerPassportNumber":"saddafsdsadf9","benefitRoleplayerDateOfBirth":"2000-10-13","benefitRoleplayerExternalCustomerReference":"","benefitRoleplayerRelationshipToOwner":"","benefitRoleplayerRelationshipTo":"","benefitRoleplayerPercentage":"","benefitRoleplayerUniqueIdentifier":"KLA00114BRP0033308420","benefitRoleplayerGender":"M","passportData":{}},{"benefitRoleplayerType":"Beneficiary","benefitRoleplayerFirstname":"Three","benefitRoleplayerMiddlename":"","benefitRoleplayerInitials":"","benefitRoleplayerLastname":"benefish","benefitRoleplayerCellphone":"254123658965","benefitRoleplayerEmailAddress":"three@gmail.com","benefitRoleplayerIdNumber":"12365478","benefitRoleplayerPassportNumber":"","benefitRoleplayerDateOfBirth":"2000-01-01","benefitRoleplayerExternalCustomerReference":"","benefitRoleplayerRelationshipToOwner":"Spouse","benefitRoleplayerRelationshipTo":"","benefitRoleplayerPercentage":"100","benefitRoleplayerUniqueIdentifier":"KLA00114BRP0033308421","benefitRoleplayerGender":"","passportData":{}}]}],"loanAccountArray":[]},"message":"Success"}';

    @TestSetup
    private static void testSetup() {
        Profile guestProfile = [
            SELECT Id FROM Profile
            WHERE Name = 'Generic Country Site Profile'
                AND UserLicense.Name = 'Guest User License' LIMIT 1
        ];

        User guestUser = new User(
            Alias = 'guest',
            Email='random@standardbank.co.za',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Guest PLI',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = guestProfile.Id,
            TimeZoneSidKey ='America/Los_Angeles',
            UserName ='randomuser@standardbank.co.za'
        );
        //Insert user record
        insert guestUser;
        User accountOwner = [
            SELECT Id
            FROM User
            WHERE IsActive = true
                AND Profile.Name = 'System Administrator'
                AND UserRoleId != null
            LIMIT 1
        ];
        System.runAs(accountOwner) {
            Account acc = new Account(
                RecordTypeId = personAccountProspectRT,
                FirstName = 'Jane',
                LastName = 'Smith',
                PersonEmail = 'jane@test.com',
                PersonBirthdate = Date.newInstance(1995,5,5),
                CMN_IdentityNumber__pc = 'EXIST123'
            );
            insert acc;

            Opportunity opp = new Opportunity(
                Name = 'Doc Status Opp 2',
                RecordTypeId = opportunityGeneralRT,
                AccountId = acc.Id,
                StageName = 'Proposal',
                Pricebook2Id = Test.getStandardPricebookId(),
                Country__c = 'KE',
                CurrencyIsoCode = 'KES',
                CloseDate = Date.today()
            );
            insert opp;

            Quote qt = new Quote(
                Name = 'Doc Status Quote 2',
                OpportunityId = opp.Id,
                Pricebook2Id = opp.Pricebook2Id,
                INS_PolicyDocumentLatestStatus__c = 'Pending Signature'
            );
            insert qt;
        }
    }

    @IsTest
    private static void runRecordsCreationPositive() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        String dto = '{"clientDetails":{"countryOfCitizenship":"KE","countryOfResidence":"KE","passportIssuingCountry":"KE","employmentType":"Part Time","ficPip":true,"ficPipRel":true,"ficPipRelFirstName":"Engineering","ficPipRelLastName":"Engineering","title":"Sir.","firstName":"alex","lastName":"test","gender":"Male","channel":"Website","idDocIssuingCountry":"KE","idNumber":"3223234","primaryIdType":"National Identity Document","primaryPhone":"+254223423423","primaryEmail":"alex@bsky.co.za","relatedId":"001bY00000bJJ0hQAG","nationality":"KE","dob":"2000-10-30","isEmployed":false,"occupationLevel":"Employed Full Time - Bank","cardNumber":"000092564","docAdd":"Proof Of Address","addresses":[{"primaryAddress":true,"city":"asd","countryCode":"KE","street":"sadasda, asdasd","type":"Residential Address","postalCode":"asd"}]}}';
        Map<String, String> ppUpdates = new Map<String, String>{
            'fundSource' => '	Salary'
        };
        Map<String, String> accUpdates = new Map<String, String>{
            'id' => acc.Id,
            'currentEmployer' => 'Test'
        };
        List<Map<String, String>> taxes = new List<Map<String, String>>();
        User guestUser = [SELECT Id FROM User WHERE LastName = 'Guest PLI'];
        Test.startTest();
            System.runAs(guestUser) {
                String result = INS_PLI_RelyComplyProcess.runRecordsCreation(dto, ppUpdates, accUpdates, taxes);
                Assert.areNotEqual(null, result, 'There was issue on records creation');
                KYC_DTO_ClientWrapper.Response response = (KYC_DTO_ClientWrapper.Response)JSON.deserialize(result, KYC_DTO_ClientWrapper.Response.class);
                Assert.areNotEqual(null, response.kycProfileId, 'Id was not returned');
            }
        Test.stopTest();
    }

    @IsTest
    private static void getAccountByQuoteIdPositive() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
            Map<String, Object> result = INS_PLI_RelyComplyProcess.getAccountByQuoteId(qt.Id);
            Assert.areNotEqual(null, result, 'There was issue on get account');
            Assert.areEqual(acc.Id, (Id)result.get('accountId'), 'Account was not found');
        Test.stopTest();
    }

    @IsTest
    private static void getAccountByQuoteIdException() {
        User guestUser = [SELECT Id FROM User WHERE LastName = 'Guest PLI'];
        Test.startTest();
            System.runAs(guestUser) {
                try {
                    INS_PLI_RelyComplyProcess.getAccountByQuoteId('WRONG_ID');
                } catch(Exception e) {
                    Assert.isTrue(e.getMessage().contains('exception'), 'Exception was not thrown');
                }
            }
        Test.stopTest();
    }

    @IsTest
    private static void updateRecordsPositive() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        User guestUser = [SELECT Id FROM User WHERE LastName = 'Guest PLI'];
        Test.startTest();
            System.runAs(guestUser) {
                INS_PLI_RelyComplyProcess.updateRecords(new Map<String, String>{
                    'opportunityId' => opp.Id,
                    'opportunityStatus' => 'Underwriting Review'
                });
                List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE StageName = 'Underwriting Review'];
                Assert.isFalse(opps.isEmpty(), 'Opportunity was not updated');
            }
        Test.stopTest();
    }

    @IsTest
    private static void convertQuotePositive() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        User guestUser = [SELECT Id FROM User WHERE LastName = 'Guest PLI'];
        Test.startTest();
            System.runAs(guestUser) {
                INS_PLI_RelyComplyProcess.convertQuote(
                    new Map<String, String>{
                        'quoteId' => qt.Id,
                        'reference' => '1234567890',
                        'accountId' => acc.Id,
                        'insurancePolicyName' => '1234567890',
                        'opportunityId' => opp.Id,
                        'status' => 'Closed Won',
                        'response' => response
                    }
                );
            }
            Assert.areEqual(
                'Closed Won',
                [SELECT StageName FROM Opportunity WHERE Id = :opp.Id].StageName,
                'Opportunity updated to close won'
            );
            InsurancePolicy policy = [
                SELECT Id, Name, ReferencePolicyNumber, Status, PaymentMethod__c, ProducerId,
                       CollectionDay__c, PremiumPaymentAccountNumber__c,
                       TotalSumInsured, PremiumAmount
                FROM InsurancePolicy
                WHERE SourceOpportunityId = :opp.Id
                LIMIT 1
            ];
            Assert.areEqual('KLA00114', policy.Name, 'Policy name should come from policyPayload.policyNumber');
            Assert.areEqual('KLA00114', policy.ReferencePolicyNumber, 'Policy reference should come from externalPolicyNumber');
            Assert.areEqual('Active', policy.Status, 'Policy status should be mapped from lowercase status');
            Assert.areEqual('123654789632', policy.PremiumPaymentAccountNumber__c, 'Payment account should be mapped');
            Assert.areEqual(25000000, policy.TotalSumInsured, 'Sum assured should be mapped');
            Assert.areEqual(8345.81, policy.PremiumAmount, 'Premium should be mapped');
            Producer producer = [
                SELECT Id, InternalUserId
                FROM Producer
                WHERE InternalUserId = :guestUser.Id
                LIMIT 1
            ];
            Assert.areEqual(producer.Id, policy.ProducerId, 'Policy producer should match the logged-in user');
            List<InsurancePolicyParticipant> participants = [
                SELECT Id, Role, FirstName__c, LastName__c, ExternalIdentifier__c,
                       Allocation__c, MobilePhone__c, Email__c, IdentityNumber__c, BirthDate__c
                FROM InsurancePolicyParticipant
                WHERE InsurancePolicyId = :policy.Id
            ];
            Assert.areEqual(1, participants.size(), 'Participants must come from benefitRoleplayerArray');
            Integer beneficiaryCount = 0;
            for (InsurancePolicyParticipant participant : participants) {
                if (participant.Role == 'Beneficiary') {
                    beneficiaryCount++;
                    Assert.areEqual('Three', participant.FirstName__c);
                    Assert.areEqual('benefish', participant.LastName__c);
                    Assert.areEqual(100, participant.Allocation__c);
                    Assert.areEqual('254123658965', participant.MobilePhone__c);
                    Assert.areEqual('three@gmail.com', participant.Email__c);
                    Assert.areEqual('12365478', participant.IdentityNumber__c);
                    Assert.areEqual(Date.newInstance(2000, 1, 1), participant.BirthDate__c);
                }
            }
            Assert.areEqual(1, beneficiaryCount, 'Beneficiary should be created from benefitRoleplayerArray');
        Test.stopTest();
    }

    @IsTest
    private static void updateSalesEventPositive() {
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        User guestUser = [SELECT Id FROM User WHERE LastName = 'Guest PLI'];
        Test.startTest();
            System.runAs(guestUser) {
                INS_PLI_RelyComplyProcess.updateSalesEvent(qt.Id, '123456');
            }
            Assert.isFalse(
                [SELECT Id FROM Quote WHERE Id = :qt.Id AND UnderwriterQuoteReferenceNumber__c = '123456'].isEmpty(),
                'Quote was not found'
            );
        Test.stopTest();
    }

    @IsTest
    private static void getSmsDataPositive() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        User guestUser = [SELECT Id FROM User WHERE LastName = 'Guest PLI'];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TinyUrlSuccessMock());
            System.runAs(guestUser) {
                Map<String, String> result = INS_PLI_RelyComplyProcess.getSmsData('https://www.example.com/page1', acc.Id);
                Assert.areEqual('https://tinyurl.com/test123', result.get('link'), 'Expected shortened URL returned');
            }
        Test.stopTest();
    }
    
    @IsTest
    private static void autoProcessRelyComplyTest() {
        Account account = [Select Id From Account LIMIT 1];
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Id recordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByDeveloperName().get('Insurance_Individual').getRecordTypeId();
        
        PartyProfile partyProfile = new PartyProfile(
            RecordTypeId = recordTypeId,
            accountId = account.Id,
            Name = 'Test'
        ); 
        insert partyProfile;
        User guestUser = [SELECT Id FROM User WHERE LastName = 'Guest PLI'];
        Test.startTest();
        System.runAs(guestUser) {
            try{
               INS_PLI_RelyComplyProcess.autoProcessRelyComply(partyProfile.Id,qt.Id);
            }
            catch(exception e){
                Assert.areEqual('Script-thrown exception', e.getMessage());
            }
            
        }
        Test.stopTest();
        
    }

    private class TinyUrlSuccessMock implements HttpCalloutMock {
        /**
         * @description mockup test wrapper
         * @param req test request
         * @return HTTPResponse
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"data":{"tiny_url":"https://tinyurl.com/test123","url":"https://www.example.com","domain":"tinyurl.com"}}');
            return res;
        }
    }
    
    
    
}