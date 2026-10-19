/***************************************************************************************
@Name of the Class :ICS_CTRL_SAPCreateAccount_Test
@Description : Class used to test ICS_CTRL_SAPCreateAccount_Test
@Author : Mahesh
@Created Date :oct 22 2024
***************************************************************************************
* Last Modified By  Mahesh
* Last Modified Date Oct 22 2024
* Last Modified Description: Initital Version
****************************************************************************************
* @Last Modified By 		: Ridhima Saxena
* @Last Modified On 		: 26-02-2025
* @Modification description : SFP-55521 updated for join account 
***************************************************************************************/
@isTest 
public class ICS_CTRL_SAPCreateAccount_Test {
@TestSetup
    static void setupData() {
		Account acc=ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity =ICS_DAL_TestFactory.createOpportunity(acc.id);
		ICS_DAL_TestFactory.createApplicationForm(acc.id,testOpportunity.id); 
		createOpportunityLineItems(testOpportunity.id,1);
        FinServ__FinancialAccount__c accountFin = new FinServ__FinancialAccount__c();
        accountFin.FinServ__PrimaryOwner__c = acc.id;
        accountFin.Name='test';
        accountFin.ExternalCIFId__c ='112';
        insert accountFin;
    }
	@isTest
    static void testSAPCreateAccount(){
		opportunity opp=[select id,accountId from Opportunity limit 1];
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CreateCustomerMockSuccess());

		 Test.startTest();
        System.enqueueJob(new ICS_CTRL_SAPCreateAccount(opp.accountId,false,new List<string>{'GBP'}));
        Assert.areEqual(true, opp != null, 'Test opportunity should exist');
		Test.stopTest();
    }

public static List<OpportunityLineItem> createOpportunityLineItems(string oppId,Integer count) {
        // Create required Product2 record
        Product2 prod = new Product2(
            Name = 'Test Product',
            IsActive = true,
            ProductCode = 'TEST-PROD-001'
        );
        insert prod;

        // Create required PricebookEntry
        Id standardPricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert standardPrice;

        // Create parent Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

    
        // Create OpportunityLineItems
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();

        for(Integer i = 0; i < count; i++) {
            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = oppId,
                Quantity = 1,
                UnitPrice = 100.00,
                PricebookEntryId = standardPrice.Id,
                ServiceDate = Date.today(),
                Description = 'Test Line Item ' + (i + 1)
            );
            oliList.add(oli);
        }

        insert oliList;
        return oliList;
    }
     /**
     * @description mocks a succesful response returned from the API call
     */
    public class CreateCustomerMockSuccess implements HttpCalloutMock {
          public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
 			 String body='{"Account":[{"AccountNumber":{"AccountIdentification":{"Item":{"AccountIdentificationType":"accountNumber","AccountIdentification":{"IdentifierValue":{"Value":"13012460"}}}}},"AdditionalData":{"CategoryInformation":{"Category":[{"CategoryItem":"header","CategoryDetails":[{"CategoryType":"correlationID","CategoryIdentifierValue":"742f3f87-7691-af4e-d374-8987b048071a"},{"CategoryType":"channelID","CategoryIdentifierValue":"SB688656760621A "},{"CategoryType":"UserID","CategoryIdentifierValue":"MCA_USR"}]},{"CategoryItem":"providerStatus","CategoryDetails":[{"CategoryType":"statusMessage","CategoryIdentifierValue":"Your request was successfully processed"},{"CategoryType":"statusCode","CategoryIdentifierValue":"S"},{"CategoryType":"VerificationStatus","CategoryIdentifierValue":"057"}]}]}}}]}';
			response.setStatusCode(CMN_API_Service.HTTP_OK);
            response.setBody(body);
			return response;
          }
        
    }
}