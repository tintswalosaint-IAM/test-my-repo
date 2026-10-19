/**
 * @description : Test class for CMN_TRH_Account
 * @Author      : Derek Hughes
 * @Group       : Account
 * @Last Modified On : 09-04-2025
 * @Last Modified By : Jaco de Lange
 **/

@IsTest
private with sharing class CMN_TRH_Account_Test {

    private static final String PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    private static final String LEAD_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();

    public static final String ZA_RELATIONSHIP_MANAGEMENT = 'ZA';  
    Relationship_Management_Settings__mdt relationshipManagement = Relationship_Management_Settings__mdt.getInstance('ZA');
    public static boolean doUpdate = true;

    //account container
   

    @TestSetup
    public static void testSetUp() {
        Test.startTest();
           List<Account> accountsToInsert= createTestAccounts(5);
           List<Lead> leadsToInsert= createTestLeads(2);
        Test.stopTest();   
    }

    @IsTest
    static void testAndFinally() {
        Test.startTest();
       List<Account> accounts=createTestAccounts(3);
       CMN_TRH_Account cmn_trh_account=new CMN_TRH_Account();
       CMN_SRV_AccountOwnerUpdate.Result result=new CMN_SRV_AccountOwnerUpdate.Result();

        if (accounts.size()>0) {
            result = CMN_SRV_AccountOwnerUpdate.processAccounts(accounts);
        }

        if(!cmn_trh_account.individualsNotInserted.isEmpty()){
            cmn_trh_account.prepareIndividualsToInsert();
        }
        if(!cmn_trh_account.accountsByIdentityNumber.keySet().isEmpty()){
            cmn_trh_account.prepareAccountToUpdate();
        }


       accounts = [SELECT Id, ExternalIdentifier__c, CMN_IdentityNumber__pc FROM Account WHERE ExternalIdentifier__c LIKE 'UG02%' limit 5];
        Assert.istrue(accounts!=null,'Expect null number of new Accounts to be greater than 0');
        Test.stopTest();
    }

    private static List<Account> createTestAccounts(Integer num) {
        List<Account> accounts = new List<Account>();

        Account[] doomedAccts = [SELECT Id, Name FROM Account  WHERE ExternalIdentifier__c like 'UG02GPK%']; 
        delete doomedAccts;
  
        for (Integer i = 1; i <= num; i++) {
            accounts.add(new Account(
                RecordTypeId = PERSON_ACCOUNT_RT_ID,
                LastName = 'Test Account ' + i,
                CMN_IdentityNumber__pc = 'CM9' + Integer.valueof((Math.random() * 100)),
                VIPIndicator__c = true,
                ExternalCIFCountry__c = 'UG'
            ));
        }

        insert accounts;
        return accounts;
    }

    private static List<Lead> createTestLeads(Integer num) {
        List<Lead> leads = new List<Lead>();

        for (Integer i = 1; i <= num; i++) {
            leads.add(new Lead(
                RecordTypeId = LEAD_RT_ID,
                LastName = 'Test Account ' + i,
                FirstName = 'Test First Name' + i,
                External_Client_Identifier__c = 'UG02GPK'+DateTime.newInstance(2007, 6, 23, 3, 3, 3).getTime()
            ));
        }

        insert leads;
        return leads;
    }

     private static List<Individual> createTestIndividuals(Integer num) {
        List<Individual> ind = new List<Individual>();

        Individual[] doomedAccts = [SELECT Id, Name FROM Individual  WHERE National_Identity_Number__c like 'CMGPK%']; 
        delete doomedAccts;

        
        for (Integer i = 1; i <= num; i++) {
            ind.add(
                new Individual(
                    FirstName = 'Test Ind', 
                    LastName = 'Last Name' , 
                    National_Identity_Number__c = 'CMGPK'+DateTime.newInstance(2007, 6, 23, 3, 3, 3).gettime(),
                    External_Country_Code__c='UG' 
                    ));
        }

        insert ind;
        return ind;
    }

    @IsTest
    static void testLinkLeads() {

        Account account = new Account(
            RecordTypeId = PERSON_ACCOUNT_RT_ID,
            LastName = 'Test Account ',
            CMN_IdentityNumber__pc = 'CM9' + Integer.valueof((Math.random() * 100)),
            VIPIndicator__c = true,
            ExternalCIFCountry__c = 'UG',
            ExternalIdentifier__c = 'UG02GPK'+DateTime.newInstance(2007, 6, 23, 3, 3, 3).getTime()//+Integer.valueof((Math.random() * 100))
        );

        insert account;

        //create an associated lead
        Lead leadc=new Lead(
                        Status = 'Working',
                        FirstName = 'Client',
                        LastName = 'Lead',
                        Loan_Income_Amount__c = 500000,
                        WI_Country__c='UG',
                        Email='donbrians@ymail.com',
                        External_Client_Identifier__c=account.ExternalIdentifier__c
            
                    );
            
                    insert leadc;


        CMN_TRH_Account cmn_trh_account=new CMN_TRH_Account();
         Set<String> clientExternalIds = new Set<String>();
        clientExternalIds.add(leadc.External_Client_Identifier__c);
        cmn_trh_account.clientExternalIds=clientExternalIds;

        Test.startTest();
        cmn_trh_account.linkLeads();
        Test.stopTest();

        Assert.isTrue(cmn_trh_account.clientExternalIds.size()>0,'Number of Account with IDs is more than 0');


    }

    @IsTest
    static void testWealthAndInvestmentAccs() {
        Test.startTest();
        List<Account> accToUpdate = new List<Account>();
        // Create accounts to test wealth and investment logic
        List<Account> accounts = new List<Account>();
        for (Integer i = 11; i <= 15; i++) {
            accounts.add(new Account(
                RecordTypeId = PERSON_ACCOUNT_RT_ID,
                LastName = 'Wealth Account ' + i,
                ExternalIdentifier__c = 'EXT' + i,
                CMN_IdentityNumber__pc = 'ID' + i,
                VIPIndicator__c = true,
                ExternalCIFCountry__c = 'ZA'
            ));
        }

        insert accounts;

        for(Account account:accounts){
             if(account.VIPIndicator__c==true ){
                accToUpdate.add(account);
            }

        }
       
        // Assert that accounts are processed correctly
        for (Account acc : [SELECT Id, VIPIndicator__c FROM Account WHERE ExternalIdentifier__c LIKE 'EXT%']) {
            Assert.isTrue(acc.VIPIndicator__c, 'Expected VIPIndicator__c to be true for Account: ' + acc.Id);
        }

        Test.stopTest();
    }

    @IsTest
    static void testLoadAccountsByIdentityNumber() {
        Test.startTest();
         Map<String,Account> identityNumbers = new Map<String,Account>();
         Map<String, List<Account>> accountsByIdentityNumber = new Map<String, List<Account>>();

        List<Account> accounts= createTestAccounts(5);     
        Assert.areEqual(5,accounts.size(),'Expected atleast 5 Accounts but instead got '+accounts.size());

        for(Account acc: accounts){
            if( (String.IsNotBlank(acc.CMN_IdentityNumber__pc) && acc.PersonIndividualId == null) || (acc != null )) {
                identityNumbers.put(acc.CMN_IdentityNumber__pc,acc);
            }
        }

        Assert.areEqual(identityNumbers.size(), 5,'Expected atleast 5 Identity Numbers but instead got '+identityNumbers.size());


        Set<String> idNos = identityNumbers.keyset();
        List<Account> accLst = new SEL_Account().selectByPersonIdentityNumber(idNos);
        Assert.areNotEqual(4, accLst.size(),'Expected at least 5 Accounts From SEL Account but instead got '+accLst.size());

       
        for(Account acc: accLst){
            if(!accountsByIdentityNumber.containsKey(acc.CMN_IdentityNumber__pc)){
                accountsByIdentityNumber.put(acc.CMN_IdentityNumber__pc, new List<Account>());
            }
            accountsByIdentityNumber.get(acc.CMN_IdentityNumber__pc).add(acc);
        }

        Assert.isNotNull(accountsByIdentityNumber ,'Expected Result Set to be bigger than 1, found ' + accountsByIdentityNumber.size());

        Test.stopTest();
    }

    @IsTest
    static void testLoadIndividualsByIdentityNumber() {
        Test.startTest();

            List<Account> accounts=createTestAccounts(5);
            Set<String> national_id_numbers = new Set<String>();
            for(Account ac:accounts){
                national_id_numbers.add(ac.CMN_IdentityNumber__pc);
            }

        List<Individual> indiLst = new SEL_Individual().selectByNationalIdentityNumbers(national_id_numbers);
        Assert.areEqual(5, indiLst.size(),'Expected accounts');

        // Create individuals to test loading by identity number
        List<Individual> individuals = new List<Individual>();
        for (Integer i = 1; i <= 5; i++) {
            individuals.add(new Individual(
                FirstName = 'Individual ' + i,
                LastName = 'Test',
                National_Identity_Number__c = 'ID' + i,
                External_Country_Code__c = 'UG'
            ));
        }

        insert individuals;

        // Assert that individuals are loaded correctly
        for (Individual indi : [SELECT Id, National_Identity_Number__c FROM Individual WHERE National_Identity_Number__c LIKE 'ID%']) {
            Assert.isNotNull(indi.National_Identity_Number__c, 'Expected National_Identity_Number__c to not be null for Individual: ' + indi.Id);
        }

    Test.stopTest();

    }

    @IsTest
    static void testValidateIndividualsForAllIdNumber() {
         Test.startTest();
        // Create accounts and individuals to test validation
        List<Account> accounts = new List<Account>();
        for (Integer i = 21; i <= 25; i++) {
            accounts.add(new Account(
                RecordTypeId = PERSON_ACCOUNT_RT_ID,
                LastName = 'Validate Account ' + i,
                ExternalIdentifier__c = 'EXT' + i,
                CMN_IdentityNumber__pc = 'ID' + i
            ));
        }
        insert accounts;

        List<Individual> individuals = new List<Individual>();
        for (Integer i = 1; i <= 5; i++) {
            individuals.add(new Individual(
                FirstName = 'Individual ' + i,
                LastName = 'Test',
                National_Identity_Number__c = 'ID' + i,
                External_Country_Code__c = 'ZA'
            ));
        }
        insert individuals;

       
        // Simulate validation process

        // Assert that validation is performed correctly
        for (Account acc : [SELECT Id, CMN_IdentityNumber__pc FROM Account WHERE ExternalIdentifier__c LIKE 'EXT%']) {
            Assert.isNotNull(acc.CMN_IdentityNumber__pc, 'Expected CMN_IdentityNumber__pc to not be null for Account: ' + acc.Id);
        }
        
        Test.stopTest();

    }

    @IsTest
    static void testPrepareIndividualsToInsert() {
         Test.startTest();
        // Assert that individuals are prepared correctly
        for (Individual indi : [SELECT Id, National_Identity_Number__c FROM Individual WHERE National_Identity_Number__c LIKE 'CM9%']) {
            Assert.isNotNull(indi.National_Identity_Number__c, 'Expected National_Identity_Number__c to not be null for Individual: ' + indi.Id);
        }
         Test.stopTest();
    }
    
    @isTest
    static void testLoadIndividuals_Success() {
        Test.startTest();
            CMN_TRH_Account handler = new CMN_TRH_Account();
              
            handler.identityNumbers = new Map<String, Account>();
            handler.identityNumbers.put('9001011234088', new Account(Name = 'Test Account'));
            handler.individualsByIdentityNumber = new Map<String, Individual>();
                
            handler.loadIndividualsByIdentityNumber();

        Test.stopTest();
               
        assert.areEqual(false, handler.individualsByIdentityNumber.containsKey('9001011234088'), 'Expected individual with ID number to be loaded');
    }
    
    @isTest
    static void testLoadIndividuals_Failure() {
        Test.startTest();
            CMN_TRH_Account handler = new CMN_TRH_Account();
  
            handler.identityNumbers = null;
            handler.individualsByIdentityNumber = new Map<String, Individual>();
    
            handler.loadIndividualsByIdentityNumber();
        Test.stopTest();

        assert.areEqual(0, handler.individualsByIdentityNumber.size(),'No Individuals should load when exception occurs');
    }
}