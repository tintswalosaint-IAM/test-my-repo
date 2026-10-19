/**
 * @description       : Test class for PER_CTRL_NBA_Overview_Test
 * @author            : Derek Hughes
 * @group             : Personalisation
 * @last modified on  : 14-05-2024
 * @last modified by  : Derek Hughes
**/
@IsTest
public with sharing class PER_CTRL_NBA_Overview_Test {
    
    @TestSetup
    public static void testSetUp() {

        User admin = AOB_DAL_TestFactory.createUser('System Administrator', false);
        UserRole role = [SELECT id FROM UserRole LIMIT 1];
        admin.UserRoleId = role.id;
        admin.Portfolio_Codes__c = 'UGPV01';
        admin.User_Country__c = 'UG';
        insert admin;
    }

    @isTest
    private static void testfetchPortfolioOverviewForCode(){

        User admin = [SELECT id FROM User WHERE Alias = 'aob' LIMIT 1];

        System.runAs(admin) {
            PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview portfolioOverviewDTO = new PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview();

            sbgplatform.ApiService.setMock(HttpCalloutMock.class, new PER_API_NBA_Service_Test.MockSuccess());

            Test.startTest();
                portfolioOverviewDTO = PER_CTRL_NBA_Overview.fetchPortfolioOverviewForCode('E165');
            Test.stopTest();

            Assert.areEqual('OK', portfolioOverviewDTO.state, 'Successfull call received  state OK');
            Assert.areEqual('E165', portfolioOverviewDTO.poapStats.aeNumber, 'Get data for expected portfolio code');
        }
    }

    @isTest
    private static void testFetchPortfolioOverviewForCodeNegative() {

        User admin = [SELECT id FROM User WHERE Alias = 'aob' LIMIT 1];

        System.runAs(admin) {

            PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview portfolioOverviewDTO = new PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview();
            
            Test.startTest();
                try{
                    portfolioOverviewDTO = PER_CTRL_NBA_Overview.fetchPortfolioOverviewForCode('E165');
                    Assert.fail('Expected an exception');
                }
                catch(exception ex){
                    Assert.areEqual(null, portfolioOverviewDTO.state, 'Unsuccessfull call received  state null');
                    Assert.areEqual(null, portfolioOverviewDTO.poapStats, 'Get null as there is no response');
                }
            Test.stopTest();
        }
    }

    @isTest 
    private static void testFetchPortfolioOverview() {

        User admin = [SELECT id FROM User WHERE Alias = 'aob' LIMIT 1];

        System.runAs(admin) {

            PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview portfolioOverviewDTO = new PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview();

            sbgplatform.ApiService.setMock(HttpCalloutMock.class, new PER_API_NBA_Service_Test.MockSuccess());

            Test.startTest();
                portfolioOverviewDTO = PER_CTRL_NBA_Overview.fetchPortfolioOverview();
            Test.stopTest();

            Assert.areEqual('OK', portfolioOverviewDTO.state, 'Successfull call received  state OK');
            Assert.areEqual('E165', portfolioOverviewDTO.poapStats.aeNumber, 'Get data for expected portfolio code');
    }
    }

    @isTest 
    private static void testFetchPortfolioOverviewNegative() {

        User admin = [SELECT id FROM User WHERE Alias = 'aob' LIMIT 1];
        
        System.runAs(admin) {
        
            PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview portfolioOverviewDTO = new PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview();
        
            Test.startTest();
                try {
                    portfolioOverviewDTO = PER_CTRL_NBA_Overview.fetchPortfolioOverview();
                    Assert.fail('Expected an exception');
                }
                catch(exception ex) {
                    Assert.areEqual(null, portfolioOverviewDTO.state, 'Unsuccessfull call received  state null');
                    Assert.areEqual(null, portfolioOverviewDTO.poapStats, 'Get null as there is no response');
                }
            Test.stopTest();
        }
    }

    @isTest 
    private static void testFetchCustomerOverview(){
        
        User admin = [SELECT id FROM User WHERE Alias = 'aob' LIMIT 1];
        
        System.runAs(admin) {
            Account testAccount = createTestAccount();

            sbgplatform.ApiService.setMock(HttpCalloutMock.class, new PER_API_NBA_Service_Test.MockSuccess());
            
            PER_DTO_NBA_CustomerOverview.DTO_CustomerOverview customerOverviewDTO = new PER_DTO_NBA_CustomerOverview.DTO_CustomerOverview();
           
            Test.startTest();
                customerOverviewDTO = PER_CTRL_NBA_Overview.fetchCustomerOverview(testAccount.Id);
            Test.stopTest();

            Assert.areEqual(testAccount.ExternalCIFId__c, customerOverviewDTO.coapStatsAR.cif_num, 'Get data for expected CIF number');
        }
    }

    @isTest 
    private static void testFetchCustomerOverviewNegative() {

        User admin = [SELECT id FROM User WHERE Alias = 'aob' LIMIT 1];
        
        System.runAs(admin) {
            Account testAccount = createTestAccount();
            PER_DTO_NBA_CustomerOverview.DTO_CustomerOverview customerOverviewDTO = new PER_DTO_NBA_CustomerOverview.DTO_CustomerOverview();
            Test.startTest();
                try{
                    customerOverviewDTO = PER_CTRL_NBA_Overview.fetchCustomerOverview(testAccount.Id);
                    Assert.fail('Expected an exception');
                }
                catch(exception ex){
                    Assert.areEqual(null, customerOverviewDTO.coapDetailsAR, 'Get null as there is no response');
                }
            Test.stopTest();
        }
    }
   
    private static Account createTestAccount() {
        Account testAccount;
        testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.ExternalCIFId__c = '10302476842';
        testAccount.RelationshipMgrCode__c = '0054321';
        insert testAccount;
        return testAccount;
    }
}