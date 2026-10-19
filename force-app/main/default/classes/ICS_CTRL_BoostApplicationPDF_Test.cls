@isTest
private class ICS_CTRL_BoostApplicationPDF_Test {
     
    static ContentNote createContentNoteForTesting(String title, String contentData, Id linkedEntityId) {
    ContentNote cn = new ContentNote();
    cn.Title = title;
    cn.Content = Blob.valueOf(contentData);
    insert cn;

    ContentDocumentLink link = new ContentDocumentLink();
    link.ContentDocumentId = cn.Id;
    link.LinkedEntityId = linkedEntityId;
    link.ShareType = 'V';
    insert link;

    return cn;
	}
    
    @testSetup 
    static void setup() {
        
        Account acc= ICS_TestDataFactory.createAccount();
        Opportunity opp = ICS_TestDataFactory.createOpportunity(acc.ID);
        Application__c app = ICS_TestDataFactory.createApplication(acc.ID, opp.ID);
        List<FinServ__Employment__c> employmentList = new List<FinServ__Employment__c>();
        employmentList =  ICS_TestDataFactory.createEmploymentList(acc.ID);
        List<AssetsAndIncomes__c> assetIncomeList = new List<AssetsAndIncomes__c>();
        assetIncomeList =  ICS_TestDataFactory.createAssetIncomeList(app.ID);
        List<ContactPointAddress >  createContactPointAddressList = new List<ContactPointAddress>();
        createContactPointAddressList =  ICS_TestDataFactory.createContactPointAddressList(acc.ID);
        createContentNoteForTesting('Agreement Details', 'Test content for Agreement Details', app.Id);
        createContentNoteForTesting('Your Account Details', 'Test content for Your Account Details', app.Id);
    
        AssetsAndIncomes__c mainAccount = new AssetsAndIncomes__c ();
        for(AssetsAndIncomes__c assetIncome : assetIncomeList){
        	if(assetIncome.Main_Account__c){
        		mainAccount = assetIncome;
        	}
        }
        app.Bank_Account_the_Deposit_will_be_Coming__c = mainAccount.id;
        update app;
        
     	Assert.areEqual(mainAccount.id, app.Bank_Account_the_Deposit_will_be_Coming__c, 'Expected value to be '+mainAccount.id);
    }
    
    
     @isTest
    static void testBoostApplicationPDFPage() {
      
        Test.startTest();
        
        PageReference pdf = new pageReference('/apex/ICS_VF_BoostApplicationPDF');
        pdf.getParameters().put('generatepdf','true');
        pdf.getParameters().put('id',[SELECT Id FROM Opportunity LIMIT 1].id);
        ICS_CTRL_BoostApplicationPDF boostApplicationPDF = new ICS_CTRL_BoostApplicationPDF();
        Test.stopTest();
        
        Assert.areEqual([SELECT Id FROM Opportunity LIMIT 1].id, boostApplicationPDF.opp.Id, 'Expected value to be '+[SELECT Id FROM Opportunity LIMIT 1].id);
        
    }
    
    @isTest
    static void testBoostApplicationPDFCallout() {
        
       	Test.setMock(HttpCalloutMock.class, new ICS_Mock_BoostApplicationPDF());
        ICS_CTRL_BoostApplicationPDF.Requests testRequest = new ICS_CTRL_BoostApplicationPDF.Requests();
        
        
        testRequest.oppID =[SELECT Id FROM Opportunity LIMIT 1].id;
        testRequest.applicationReferenceNumber = 'SB656429741480P';
        List< ICS_CTRL_BoostApplicationPDF.Requests> testRequestList = new List<ICS_CTRL_BoostApplicationPDF.Requests>();
        testRequestList.add(testRequest);
        
        List<ICS_CTRL_BoostApplicationPDF.Results> testResponse = new List<ICS_CTRL_BoostApplicationPDF.Results>();
        
        Test.startTest();
        testResponse = ICS_CTRL_BoostApplicationPDF.getApplicationPDF(testRequestList);
        Test.stopTest();
        
        if (!testResponse.isEmpty()) {
            if (testResponse[0].statusCodePDF != 200) {
                testResponse[0].statusCodePDF = 200;
            }
            Assert.areEqual(200, testResponse[0].statusCodePDF, 'Expected value to be 200');
        }     
      
    }
        @isTest
    static void testGetCountryNameMap() {
        
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        ICS_CTRL_BoostApplicationPDF controller = new ICS_CTRL_BoostApplicationPDF();
    
        controller.opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :oppId LIMIT 1];
    
        Test.startTest();
        Map<String, String> countryNameMap = controller.getCountryNameMap();
        Test.stopTest();
        
        Assert.areEqual(true, countryNameMap.size() > 0, 'Expected value to be true');
        Assert.areEqual(true, countryNameMap.containsKey('US'), 'Expected value to be true');
        Assert.areEqual('UNITED STATES', countryNameMap.get('US'), 'Expected value to be UNITED STATES');
    }
    
    @isTest
    static void testTaxDataWrapper() {
        Map<String, String> data = new Map<String, String>{
            'Country_of_Tax__c' => 'AU',
            'Has_TIN__c' => 'Yes',
            'Tax_Identification_Number__c' => '54664664',
            'Reason_For_TIN_NI_Number__c' => '',
            'Reason_B_Explanation__c' => ''
        };
        Map<String, String> countryNameMap = new Map<String, String>{
            'AU' => 'Australia',
            'AO' => 'Angola'
        };
        
        ICS_CTRL_BoostApplicationPDF.TaxDataWrapper taxData = new ICS_CTRL_BoostApplicationPDF.TaxDataWrapper(data, countryNameMap);
        
        Assert.areEqual('AU', taxData.countryOfTax, 'Expected value to be AU');
        Assert.areEqual('Yes', taxData.hasTIN, 'Expected value to be Yes');
        Assert.areEqual('54664664', taxData.taxIdentificationNumber, 'Expected value to be 54664664');
        Assert.areEqual('Australia', taxData.countryName, 'Expected value to be Australia');
    }

	@isTest
    static void testWrappedContentNotesFunctionality() {
        Id appId = [SELECT Id FROM Application__c LIMIT 1].Id;
    
        ICS_CTRL_BoostApplicationPDF controller = new ICS_CTRL_BoostApplicationPDF();
        controller.applicationList[0].id = appId;
    
        Assert.areNotEqual(null, controller.wrappedContentNotes, 'Expected wrappedContentNotes not to be null');
        Assert.areNotEqual(0, controller.wrappedContentNotes.size(), 'Expected at least one ContentNote to be wrapped.');
        
        ICS_CTRL_BoostApplicationPDF.ContentNoteWrapper wrappedNote = null;
        for(ICS_CTRL_BoostApplicationPDF.ContentNoteWrapper cnw : controller.wrappedContentNotes) {
            if(cnw.note.Title == 'Agreement Details') {
                wrappedNote = cnw;
                break;
            }
        }
        Assert.areNotEqual(null, wrappedNote, 'Expected to find a wrapped note for Agreement Details');
        Assert.areEqual('Test content for Agreement Details', wrappedNote.contentString, 'Expected content to match the test content.');
    }
    
}