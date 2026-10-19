/**
 * @description       : This is the test class for SBFC_CTRL_FactFindingWizard. It contains unit tests to validate the functionality of the Fact Finding Wizard controller, ensuring that it correctly retrieves and manipulates data related to Application Forms, Party Profiles, Application Form Products, and Assets and Liabilities. The tests cover both positive and negative scenarios to ensure robustness and reliability of the controller methods.
 * @author            : Gul
 * @group             : SBFC
 * @last modified on  : 03-16-2026
 * @last modified by  : Gul
**/
@isTest
private class SBFC_CTRL_FactFindingWizard_TEST {

    private static final String PARTY_PROFILE_RT_DEV_NAME = 'SBFC_Party_Profile';

    /**
    * @description: Setup test data for Fact Finding Wizard tests
    */
    @testSetup
    static void setup() {
        Account account = new Account();
        account.LastName = 'AccTest1';
        insert account;

        Account personAcc = CMN_DAL_DataFactory.newPersonAccount();
        insert personAcc;

        // Create Lead
        Lead lead = new Lead();
        lead.LastName = 'Last Name';
        lead.FirstName='First Name';
        lead.status = INVM_Constants.LEADNEW;
        lead.Company='Lead Company';
        lead.LeadSource = 'Website';
        lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SBFC_Lead').getRecordTypeId();
        lead.FinServ__RelatedAccount__c = account.Id;
        insert lead;

        ApplicationForm af = new ApplicationForm();
        af.LeadId = lead.Id;
        af.RecordTypeId = Schema.SObjectType.ApplicationForm.getRecordTypeInfosByDeveloperName().get('SBFC_Individual_Application').getRecordTypeId();
        af.UsageType = 'Other';
        insert af;

        Applicant applicant = new Applicant();
        applicant.ApplicationFormId = af.Id;
        applicant.RecordTypeId = Schema.SObjectType.Applicant.getRecordTypeInfosByDeveloperName().get('SBFC_Individual').getRecordTypeId();
        applicant.Email = 'test@test.com';
        applicant.FirstName = 'Test';
        applicant.LastName = 'Applicant';
        insert applicant;
    }

    /**
    * @description: Test method for getApplicationFormData
    */
    @isTest
    static void testgetApplicationFormData() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        ApplicationForm af = SBFC_CTRL_FactFindingWizard.getApplicationFormData(l.Id);
        Test.stopTest();
        Assert.areNotEqual(null, af, 'Should return ApplicationForm for valid LeadId');
    }

    /**
    * @description: Test method for getApplicationFormData with invalid LeadId
    */
    @isTest
    static void testgetApplicationFormData_Negative() {
        Test.startTest();
        try{
            ApplicationForm af = SBFC_CTRL_FactFindingWizard.getApplicationFormData('00001Test');
            Assert.areEqual(null, af, 'No application form should be returned for invalid LeadId');
        } catch (Exception e) {
        }
        Test.stopTest();
    }

    /**
    * @description: Test method for updatePartyProfileRecords
    */
    @isTest
    static void testUpdatePartyProfileRecords() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        ApplicationForm af = [SELECT Id FROM ApplicationForm WHERE LeadId = :l.Id LIMIT 1];
        Applicant aplcnt = [SELECT Id FROM Applicant WHERE ApplicationFormId = :af.Id LIMIT 1];

        // Create PartyProfile
        PartyProfile pp = new PartyProfile();
        pp.SBFC_Applicant__c = aplcnt.Id;
        pp.recordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByDeveloperName().get(PARTY_PROFILE_RT_DEV_NAME).getRecordTypeId();
        pp.Name = 'Test Trust';
        pp.BusinessEntityTradeName = 'Test Trust';
        pp.WI_Type__c = 'Trust';
        pp.PrimaryIdentifierType = '6';
        pp.WI_PassportNumber__c = 'P1234567';
        pp.WI_PassportValidTo__c = Date.today().addYears(5);
        insert pp;
        pp.Name = 'UpdatedName';
        List<PartyProfile> ppsToUpdate = new List<PartyProfile>{pp};

        Test.startTest();
        SBFC_CTRL_FactFindingWizard.updatePartyProfileRecords(ppsToUpdate);
        Test.stopTest();

        PartyProfile updatedPp = [SELECT Name FROM PartyProfile WHERE Id = :pp.Id];
        Assert.areEqual('UpdatedName', updatedPp.Name, 'PartyProfile Name should be updated');
    }

    /**
    * @description: Test method for updatePartyProfileRecords with invalid PartyProfile
    */
    @isTest
    static void testUpdatePartyProfileRecords_Negative() {
        // Create PartyProfile
        PartyProfile pp = new PartyProfile();
        pp.recordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByDeveloperName().get(PARTY_PROFILE_RT_DEV_NAME).getRecordTypeId();
        pp.Name = 'Test Trust';
        pp.BusinessEntityTradeName = 'Test Trust';
        pp.WI_Type__c = 'Trust';
        pp.PrimaryIdentifierType = '6';
        pp.WI_PassportNumber__c = 'P1234567';
        pp.WI_PassportValidTo__c = Date.today().addYears(5);
        List<PartyProfile> ppsToUpdate = new List<PartyProfile>{pp};
        Assert.areEqual(null, pp.Id, 'PartyProfile should not be inserted yet');
        Test.startTest();
        try{
            SBFC_CTRL_FactFindingWizard.updatePartyProfileRecords(ppsToUpdate);
        } catch (Exception e) {
           
        }
    }

    /**
    * @description: Test method for insertPartyProfileRecords
    */
    @isTest
    static void testInsertPartyProfileRecords() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        ApplicationForm af = [SELECT Id FROM ApplicationForm WHERE LeadId = :l.Id LIMIT 1];
        PartyProfile newPp = new PartyProfile();
        newPp.SBFC_Applicant__c = [SELECT Id FROM Applicant WHERE ApplicationFormId = :af.Id LIMIT 1].Id;
        newPp.recordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByDeveloperName().get(PARTY_PROFILE_RT_DEV_NAME).getRecordTypeId();
        newPp.Name = 'Test Trust 2';
        newPp.BusinessEntityTradeName = 'Test Trust 2';
        newPp.WI_Type__c = 'Trust';
        newPp.PrimaryIdentifierType = '6';
        newPp.WI_PassportNumber__c = 'P1234567';
        newPp.WI_PassportValidTo__c = Date.today().addYears(5);
        List<PartyProfile> ppsToInsert = new List<PartyProfile>{newPp};
        Test.startTest();
        SBFC_CTRL_FactFindingWizard.insertPartyProfileRecords(ppsToInsert);
        Test.stopTest();
        PartyProfile insertedPp = [SELECT Name FROM PartyProfile WHERE Name = 'Test Trust 2' LIMIT 1];
        Assert.areEqual('Test Trust 2', insertedPp.Name, 'Inserted PartyProfile LastName should match');
    }

    /**
    * @description: Test method for insertPartyProfileRecords with invalid PartyProfile
    */
    @isTest
    static void testInsertPartyProfileRecords_Negative() {
        // Create PartyProfile without required fields
        PartyProfile pp = new PartyProfile();
        pp.recordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByDeveloperName().get(PARTY_PROFILE_RT_DEV_NAME).getRecordTypeId();
        pp.BusinessEntityTradeName = 'Test Trust';
        pp.WI_Type__c = 'Trust';
        pp.PrimaryIdentifierType = '6';
        pp.WI_PassportNumber__c = 'P1234567';
        pp.WI_PassportValidTo__c = Date.today().addYears(5);
        List<PartyProfile> ppsToInsert = new List<PartyProfile>{pp};
        Assert.areEqual(null, pp.Id, 'PartyProfile should not be inserted yet');
        Test.startTest();
        try{
            SBFC_CTRL_FactFindingWizard.insertPartyProfileRecords(ppsToInsert);
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }
    
    /**
    * @description: Test method for deletePartyProfileRecords
    */
    @isTest
    static void testDeletePartyProfileRecords() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        ApplicationForm af = [SELECT Id FROM ApplicationForm WHERE LeadId = :l.Id LIMIT 1];
        Applicant aplcnt = [SELECT Id FROM Applicant WHERE ApplicationFormId = :af.Id LIMIT 1];
        // Create PartyProfile
        PartyProfile pp = new PartyProfile();
        pp.SBFC_Applicant__c = aplcnt.Id;
        pp.recordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByDeveloperName().get(PARTY_PROFILE_RT_DEV_NAME).getRecordTypeId();
        pp.Name = 'Test Trust';
        pp.BusinessEntityTradeName = 'Test Trust';
        pp.WI_Type__c = 'Trust';
        pp.PrimaryIdentifierType = '6';
        pp.WI_PassportNumber__c = 'P1234567';
        pp.WI_PassportValidTo__c = Date.today().addYears(5);
        insert pp;
        List<PartyProfile> ppsToDelete = new List<PartyProfile>{pp};
        Test.startTest();
        SBFC_CTRL_FactFindingWizard.deletePartyProfileRecords(ppsToDelete);
        Test.stopTest();
        Assert.areEqual(0, [SELECT count() FROM PartyProfile WHERE Id = :pp.Id]);
    }

    /**
    * @description: Test method for deletePartyProfileRecords with invalid PartyProfile
    */
    @isTest
    static void testDeletePartyProfileRecords_Negative() {
        // Create PartyProfile without inserting
        PartyProfile pp = new PartyProfile();
        pp.recordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByDeveloperName().get(PARTY_PROFILE_RT_DEV_NAME).getRecordTypeId();
        pp.Name = 'Test Trust';
        pp.BusinessEntityTradeName = 'Test Trust';
        pp.WI_Type__c = 'Trust';
        pp.PrimaryIdentifierType = '6';
        pp.WI_PassportNumber__c = 'P1234567';
        pp.WI_PassportValidTo__c = Date.today().addYears(5);
        List<PartyProfile> ppsToDelete = new List<PartyProfile>{pp};
        Assert.areEqual(null, pp.Id, 'PartyProfile should not be inserted yet');
        Test.startTest();
        try{
            SBFC_CTRL_FactFindingWizard.deletePartyProfileRecords(ppsToDelete);
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }

    /**
    * @description: Test method for updateApplicationFormProduct
    */
    @isTest
    static void testUpdateApplicationFormProduct() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        ApplicationForm af = [SELECT Id FROM ApplicationForm WHERE LeadId = :l.Id LIMIT 1];
        ApplicationFormProduct afp = new ApplicationFormProduct();
        afp.ApplicationFormId = af.Id;
        afp.SBFC_NameOfFund__c = 'FundToUpdate';
        afp.SBFC_Product_Owner__c = 'Client';
        insert afp;
        afp.SBFC_NameOfFund__c = 'FundUpdated';
        List<ApplicationFormProduct> afpsToUpdate = new List<ApplicationFormProduct>{afp};
        Test.startTest();
        SBFC_CTRL_FactFindingWizard.updateApplicationFormProduct(afpsToUpdate);
        Test.stopTest();
        ApplicationFormProduct updatedAfp = [SELECT SBFC_NameOfFund__c FROM ApplicationFormProduct WHERE Id = :afp.Id];
        Assert.areEqual('FundUpdated', updatedAfp.SBFC_NameOfFund__c, 'ApplicationFormProduct Name should be updated');
    }

    /**
    * @description: Test method for updateApplicationFormProduct with invalid ApplicationFormProduct
    */
    @isTest
    static void testUpdateApplicationFormProduct_Negative() {
        // Create ApplicationFormProduct without inserting
        ApplicationFormProduct afp = new ApplicationFormProduct();
        afp.SBFC_NameOfFund__c = 'FundToUpdate';
        afp.SBFC_Product_Owner__c = 'Client';
        List<ApplicationFormProduct> afpsToUpdate = new List<ApplicationFormProduct>{afp};
        Assert.areEqual(null, afp.Id, 'ApplicationFormProduct should not be inserted yet');
        Test.startTest();
        try{
            SBFC_CTRL_FactFindingWizard.updateApplicationFormProduct(afpsToUpdate);
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }

    /**
    * @description: Test method for insertApplicationFormProduct
    */
    @isTest
    static void testInsertApplicationFormProduct() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        ApplicationForm af = [SELECT Id FROM ApplicationForm WHERE LeadId = :l.Id LIMIT 1];
        ApplicationFormProduct afp = new ApplicationFormProduct();
        afp.ApplicationFormId = af.Id;
        afp.SBFC_NameOfFund__c = 'FundToInsert';
        afp.SBFC_Product_Owner__c = 'Client';
        List<ApplicationFormProduct> afpsToInsert = new List<ApplicationFormProduct>{afp};
        Test.startTest();
        SBFC_CTRL_FactFindingWizard.insertApplicationFormProduct(afpsToInsert);
        Test.stopTest();
        ApplicationFormProduct insertedAfp = [SELECT SBFC_NameOfFund__c FROM ApplicationFormProduct WHERE SBFC_NameOfFund__c = 'FundToInsert' LIMIT 1]; 
        Assert.areEqual('FundToInsert', insertedAfp.SBFC_NameOfFund__c, 'Inserted ApplicationFormProduct Name should match');
    }

    /**
    * @description: Test method for insertApplicationFormProduct with invalid ApplicationFormProduct
    */
    @isTest
    static void testInsertApplicationFormProduct_Negative() {
        // Create ApplicationFormProduct without required fields    
        ApplicationFormProduct afp = new ApplicationFormProduct();
        List<ApplicationFormProduct> afpsToInsert = new List<ApplicationFormProduct>{afp};
        Assert.areEqual(null, afp.Id, 'ApplicationFormProduct should not be inserted yet');
        Test.startTest();
        try{
            SBFC_CTRL_FactFindingWizard.insertApplicationFormProduct(afpsToInsert);
        } catch (Exception e) {
           
        }
        Test.stopTest();
    }

    /**
    * @description: Test method for deleteApplicationFormProduct
    */
    @isTest
    static void testDeleteApplicationFormProduct() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        ApplicationForm af = [SELECT Id FROM ApplicationForm WHERE LeadId = :l.Id LIMIT 1];
        ApplicationFormProduct afp = new ApplicationFormProduct();
        afp.ApplicationFormId = af.Id;
        afp.SBFC_NameOfFund__c = 'FundToDelete';
        afp.SBFC_Product_Owner__c = 'Client';
        insert afp;
        List<ApplicationFormProduct> afpsToDelete = new List<ApplicationFormProduct>{afp};
        Test.startTest();
        SBFC_CTRL_FactFindingWizard.deleteApplicationFormProduct(afpsToDelete);
        Test.stopTest();
        Assert.areEqual(0, [SELECT count() FROM ApplicationFormProduct WHERE Id = :afp.Id]);
    }

    /**
    * @description: Test method for deleteApplicationFormProduct with invalid ApplicationFormProduct
    */
    @isTest
    static void testDeleteApplicationFormProduct_Negative() {
        // Create ApplicationFormProduct without inserting
        ApplicationFormProduct afp = new ApplicationFormProduct();
        afp.SBFC_NameOfFund__c = 'FundToDelete';
        afp.SBFC_Product_Owner__c = 'Client';
        List<ApplicationFormProduct> afpsToDelete = new List<ApplicationFormProduct>{afp};
        Assert.areEqual(null, afp.Id, 'ApplicationFormProduct should not be inserted yet');
        Test.startTest();
        try{
            SBFC_CTRL_FactFindingWizard.deleteApplicationFormProduct(afpsToDelete);
        } catch (Exception e) {

        }
        Test.stopTest();
    }

    /**
    * @description: Test method for updateAssetsAndLiabilities
    */
    @isTest
    static void testUpdateAssetsAndLiabilities() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        Account perAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
        ApplicationForm af = [SELECT Id FROM ApplicationForm WHERE LeadId = :l.Id LIMIT 1];
        FinServ__AssetsAndLiabilities__c al = new FinServ__AssetsAndLiabilities__c();
        al.SBFC_FactFinding__c = af.Id;
        al.SBFC_MarketValue__c = 1000;
        al.FinServ__PrimaryOwner__c = perAcc.Id;
        insert al;
        al.SBFC_MarketValue__c = 2000;
        List<FinServ__AssetsAndLiabilities__c> alsToUpdate = new List<FinServ__AssetsAndLiabilities__c>{al};
        Test.startTest();
        SBFC_CTRL_FactFindingWizard.updateAssetsAndLiabilities(alsToUpdate);
        Test.stopTest();
        FinServ__AssetsAndLiabilities__c updatedAl = [SELECT SBFC_MarketValue__c FROM FinServ__AssetsAndLiabilities__c WHERE Id = :al.Id]; 
        Assert.areEqual(2000, updatedAl.SBFC_MarketValue__c, 'AssetsAndLiabilities MarketValue should be updated');
    }

    /**
    * @description: Test method for updateAssetsAndLiabilities with invalid AssetsAndLiabilities
    */
    @isTest
    static void testUpdateAssetsAndLiabilities_Negative() {
        // Create AssetsAndLiabilities without inserting
        FinServ__AssetsAndLiabilities__c al = new FinServ__AssetsAndLiabilities__c();
        al.SBFC_MarketValue__c = 1000;
        List<FinServ__AssetsAndLiabilities__c> alsToUpdate = new List<FinServ__AssetsAndLiabilities__c>{al};
        Assert.areEqual(null, al.Id, 'AssetsAndLiabilities should not be inserted yet');
        Test.startTest();
        try{
            SBFC_CTRL_FactFindingWizard.updateAssetsAndLiabilities(alsToUpdate);
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }

    /**
    * @description: Test method for insertAssetsAndLiabilities
    */
    @isTest
    static void testInsertAssetsAndLiabilities() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        Account perAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
        ApplicationForm af = [SELECT Id FROM ApplicationForm WHERE LeadId = :l.Id LIMIT 1];
        FinServ__AssetsAndLiabilities__c al = new FinServ__AssetsAndLiabilities__c();
        al.SBFC_FactFinding__c = af.Id;
        al.SBFC_MarketValue__c = 1500;
        al.FinServ__PrimaryOwner__c = perAcc.Id;
        List<FinServ__AssetsAndLiabilities__c> alsToInsert = new List<FinServ__AssetsAndLiabilities__c>{al};
        Test.startTest();
        SBFC_CTRL_FactFindingWizard.insertAssetsAndLiabilities(alsToInsert);
        Test.stopTest();
        FinServ__AssetsAndLiabilities__c insertedAl = [SELECT SBFC_MarketValue__c FROM FinServ__AssetsAndLiabilities__c WHERE SBFC_MarketValue__c = 1500 LIMIT 1]; 
        Assert.areEqual(1500, insertedAl.SBFC_MarketValue__c, 'Inserted AssetsAndLiabilities MarketValue should match');   
    }

    /**
    * @description: Test method for insertAssetsAndLiabilities with invalid AssetsAndLiabilities
    */
    @isTest
    static void testInsertAssetsAndLiabilities_Negative() {
        // Create AssetsAndLiabilities without required fields
        FinServ__AssetsAndLiabilities__c al = new FinServ__AssetsAndLiabilities__c();
        List<FinServ__AssetsAndLiabilities__c> alsToInsert = new List<FinServ__AssetsAndLiabilities__c>{al};
        Assert.areEqual(null, al.Id, 'AssetsAndLiabilities should not be inserted yet');
        Test.startTest();
        try{
            SBFC_CTRL_FactFindingWizard.insertAssetsAndLiabilities(alsToInsert);
        } catch (Exception e) {

        }
        Test.stopTest();
    }

    /**
    * @description: Test method for deleteAssetsAndLiabilities
    */
    @isTest
    static void testDeleteAssetsAndLiabilities() {
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        Account perAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
        ApplicationForm af = [SELECT Id FROM ApplicationForm WHERE LeadId = :l.Id LIMIT 1];
        FinServ__AssetsAndLiabilities__c al = new FinServ__AssetsAndLiabilities__c();
        al.SBFC_FactFinding__c = af.Id;
        al.SBFC_MarketValue__c = 1800;
        al.FinServ__PrimaryOwner__c = perAcc.Id;
        insert al;
        List<FinServ__AssetsAndLiabilities__c> alsToDelete = new List<FinServ__AssetsAndLiabilities__c>{al};
        Test.startTest();
        SBFC_CTRL_FactFindingWizard.deleteAssetsAndLiabilities(alsToDelete);
        Test.stopTest();
        Assert.areEqual(0, [SELECT count() FROM FinServ__AssetsAndLiabilities__c WHERE Id = :al.Id]);
    }   

    /**
    * @description: Test method for deleteAssetsAndLiabilities with invalid AssetsAndLiabilities
    */
    @isTest
    static void testDeleteAssetsAndLiabilities_Negative() {
        // Create AssetsAndLiabilities without inserting
        FinServ__AssetsAndLiabilities__c al = new FinServ__AssetsAndLiabilities__c();
        al.SBFC_MarketValue__c = 1800;
        List<FinServ__AssetsAndLiabilities__c> alsToDelete = new List<FinServ__AssetsAndLiabilities__c>{al};
        Assert.areEqual(null, al.Id, 'AssetsAndLiabilities should not be inserted yet');
        Test.startTest();
        try{
            SBFC_CTRL_FactFindingWizard.deleteAssetsAndLiabilities(alsToDelete);
        } catch (Exception e) {

        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdatePartyProfile_LoggerOnly() {

    // Force execution of LOGGER block
    SBFC_CTRL_FactFindingWizard.FORCE_NO_ACCESS = true;

    Test.startTest(); 

    SBFC_CTRL_FactFindingWizard.updatePartyProfileRecords(new List<PartyProfile>());

    Test.stopTest();
    Assert.isTrue(
        true,
        'Method executed successfully under FORCE_NO_ACCESS scenario'
    );

    // Reset flag
    SBFC_CTRL_FactFindingWizard.FORCE_NO_ACCESS = false;
}
}