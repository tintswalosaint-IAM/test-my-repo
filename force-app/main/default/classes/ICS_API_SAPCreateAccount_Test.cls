/***************************************************************************************
@Name of the Class :ICS_API_SAPCreateAccount_Test
@Description : Class used to test ICS_API_SAPCreateAccount 
@Author : Mahesh
@Created Date :oct 22 2024
***************************************************************************************
* Last Modified By  Mahesh
* Last Modified Date Oct 22 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
private class ICS_API_SAPCreateAccount_Test { 

    @TestSetup
    static void makeData() {
        // Create test data
          Account testAccount=ICS_DAL_TestFactory.createAccount();
      

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpportunity;
 		ICS_DAL_TestFactory.createApplicationForm(testAccount.id,testOpportunity.id);
      Product2 prd1 = new Product2(
            ProductCode = 'TEST001',
            Name = 'Test Product 1',
             isactive=true,
            CurrencyIsoCode = 'USD'
        );
        insert prd1;
       ICS_DAL_TestFactory.createProduct2();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Pricebook2 customPB = new Pricebook2(Name = ICS_Constants.ICSPricebook, Description = 'Price Book 2009 Products', CurrencyIsoCode='GBP',IsActive = true );

        insert customPB;


        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = prd1.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert standardPrice;
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id,
            Product2Id = prd1.Id,
            UnitPrice = 90,
            IsActive = true
        );
        insert customPrice;

        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = customPrice.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert testOpportunityLineItem;
        FinServ__FinancialAccount__c accountInfo =new FinServ__FinancialAccount__c();
        accountInfo.FinServ__PrimaryOwner__c = testAccount.Id;
        accountInfo.ExternalCIFId__c = '12345';
        insert accountInfo;
    }

    @IsTest
    static void testGenerateJsonRequest() {
        Opportunity testOpp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];

        Test.startTest();
        ICS_API_SAPCreateAccount newAccountInstance = new ICS_API_SAPCreateAccount(testOpp.AccountId,'EUR');
        String jsonResult = newAccountInstance.jsonRequest;
        Test.stopTest();

        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);

        Assert.isTrue(resultMap.containsKey('Account'), 'Expected JSON to contain Account key but it was missing');
        List<Object> accounts = (List<Object>)resultMap.get('Account');
        Assert.areEqual(1, accounts.size(), 'Expected to one account in the accounts List but it was missing');

        Map<String, Object> account = (Map<String, Object>)accounts[0];

        // Check AccountNumber
        Map<String, Object> accountNumber = (Map<String, Object>)account.get('AccountNumber');
        List<Object> accountIdentifications = (List<Object>)accountNumber.get('AccountIdentification');
        Assert.areEqual(1, accountIdentifications.size(), 'There should be one AccountIdentification');
        Map<String, Object> accountIdentification = (Map<String, Object>)accountIdentifications[0];
        Assert.areEqual('accountHolderidentificationNumber', accountIdentification.get('AccountIdentificationType'), 'AccountIdentificationType should be accountHolderidentificationNumber');

        // Check ProductInstanceReference
        List<Object> productInstanceReferences = (List<Object>)account.get('ProductInstanceReference');
        Assert.areEqual(1, productInstanceReferences.size(), 'There should be one ProductInstanceReference');
        Map<String, Object> productInstanceReference = (Map<String, Object>)productInstanceReferences[0];
        Assert.areEqual('ExternalProduct', productInstanceReference.get('ProductIdentificationType'), 'ProductIdentificationType should be ExternalProduct');

        // Check CustomerCashFlowPosition
        List<Object> customerCashFlowPositions = (List<Object>)account.get('CustomerCashFlowPosition');
        Assert.areEqual(1, customerCashFlowPositions.size(), 'There should be one CustomerCashFlowPosition');
        Map<String, Object> customerCashFlowPosition = (Map<String, Object>)customerCashFlowPositions[0];
        Assert.areEqual('EUR', ((Map<String, Object>)customerCashFlowPosition.get('PositionAmount')).get('AmountCurrency'), 'AmountCurrency should be EUR');

        // Check AdditionalData
        Map<String, Object> additionalData = (Map<String, Object>)account.get('AdditionalData');
        Assert.isTrue(additionalData.containsKey('CategoryInformation'), 'AdditionalData should contain CategoryInformation');
        Map<String, Object> categoryInformation = (Map<String, Object>)additionalData.get('CategoryInformation');
        Assert.isTrue(categoryInformation.containsKey('Category'), 'CategoryInformation should contain Category');
        List<Object> categories = (List<Object>)categoryInformation.get('Category');
        Assert.areEqual(1, categories.size(), 'There should be one Category');
        Map<String, Object> category = (Map<String, Object>)categories[0];
        Assert.isTrue(category.containsKey('CategoryItem'), 'Category should contain CategoryItem');
        Assert.isTrue(category.containsKey('CategoryDetails'), 'Category should contain CategoryDetails');
    }
}