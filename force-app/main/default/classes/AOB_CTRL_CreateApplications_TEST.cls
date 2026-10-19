/**
* @description Test class for AOB_CTRL_FormCreator
* @author Narendra
* @date Jan 25th 2023 
* @ Last Modified By : Dayakar
* @ Last Modified On : 08-08-2023
* @ Modification Description : added new test data methods
*/
@isTest
public class AOB_CTRL_CreateApplications_TEST {
/**
* @description Test data for AOB_CTRL_CreateApplications_Test class
*/
    @testSetup
    static void setup() {
        AOB_BOTS_DAL_TestFactory.application();
        
    } 
/**
* @description Test method for AOB_CTRL_CreateApplications.creatApplication
*/
    @istest static void creatApplicationTest(){
        try{
        String productName = 'SOCTY';
        String json3 = '{"OPEN APPLICATION":"FALSE","ENTITY TYPE":"Formal Body with CIPA","LEGAL NAME":"DON DOT Proprietary Limited","CIPA REGISTRATION NUMBER":"BW54678365612","GROSS ANNUAL TURNOVER (GTA)":"7000","directordetails":[{"key":1,"fullName":"Venkat test","omagIDNum":"345678233","KeyContactPhone":"+26546766657","keyContactEmail":"venkat@gmail.com","directorEntity":"Yes","signatory":"Yes","keyContact":"Yes","directorEntityError":false,"signatoryError":false,"keyContactError":false,"showRemoveButton":false,"showAddButton":true,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"anyonekeycontactError":false},{"key":2,"fullName":"Rajesh","omagIDNum":"354567656","cellNumber":"+26546789234","emailAddress":"rajesh@gmail.com","directorEntity":"No","signatory":"Yes","keyContact":"No","directorEntityError":false,"signatoryError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup11","value":"Yes","name":"radioGroup11"},{"Id":"radioGroup111","value":"No","name":"radioGroup11"}],"radioGroup2":[{"Id":"radioGroup21","value":"Yes","name":"radioGroup21"},{"Id":"radioGroup211","value":"No","name":"radioGroup21"}],"radioGroup3":[{"Id":"radioGroup31","value":"Yes","name":"radioGroup31"},{"Id":"radioGroup311","value":"No","name":"radioGroup31"}],"showAddButton":true,"showRemoveButton":true,"anyonekeycontactError":false}],"consent":true}';
        AOB_BOTS_DAL_TestFactory.creatProduct();
        Test.startTest();
        String participantId =AOB_CTRL_CreateApplications.creatApplication(json3,productName);
        Test.stopTest();
          Assert.areNotEqual(null, participantId);
            
        } catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
    }
    
    /**
* @description Test method for AOB_CTRL_CreateApplications.creatApplication
*/
    @istest
    static void creatApplicationwithoutcipaod005(){
        try{
        String productName = 'OD001';
        String json2 = '{"OPEN APPLICATION":"FALSE","ENTITY TYPE":"Sole Proprietor","LEGAL NAME":"DON DOTs Proprietary Limited","CIPA REGISTRATION NUMBER":"BW54678345613","GROSS ANNUAL TURNOVER (GTA)":"10000000","directordetails":[{"key":1,"fullName":"Venkattest","omagIDNum":"345678255","cellNumber":"+26546766658","emailAddress":"venkat@gmail.com","directorEntity":"No","signatory":"No","keyContact":"Yes","directorEntityError":false,"signatoryError":false,"keyContactError":false,"showRemoveButton":false,"showAddButton":true,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"anyonekeycontactError":false},{"key":2,"fullName":"Rajesh","omagIDNum":"354567656","cellNumber":"+26546789234","emailAddress":"rajesh@gmail.com","directorEntity":"No","signatory":"Yes","keyContact":"No","directorEntityError":false,"signatoryError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup11","value":"Yes","name":"radioGroup11"},{"Id":"radioGroup111","value":"No","name":"radioGroup11"}],"radioGroup2":[{"Id":"radioGroup21","value":"Yes","name":"radioGroup21"},{"Id":"radioGroup211","value":"No","name":"radioGroup21"}],"radioGroup3":[{"Id":"radioGroup31","value":"Yes","name":"radioGroup31"},{"Id":"radioGroup311","value":"No","name":"radioGroup31"}],"showAddButton":true,"showRemoveButton":true,"anyonekeycontactError":false}],"consent":true}';
        AOB_BOTS_DAL_TestFactory.creatProduct1();
        Test.startTest();
        string participantId =AOB_CTRL_CreateApplications.creatApplication(json2,productName);
        Test.stopTest();
        Assert.areNotEqual(null, participantId);
       }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
        
    }
   
/**
* @description Test method for AOB_CTRL_CreateApplications.creatApplication
*/
    @istest static void creatApplicationFailTest(){
        try{
        String productName = 'SOCTY';
        String json3 = '{"OPEN APPLICATION":"FALSE","ENTITY TYPE":"Formal Body with CIPA","LEGAL NAME":"DON DOT Proprietary Limited","CIPA REGISTRATION NUMBER":"BW54678365612","GROSS ANNUAL TURNOVER (GTA)":"7000","directordetails":[{"key":1,"fullName":"Venkat test","omagIDNum":"345678233","cellNumber":"+26546766657","emailAddress":"venkat@gmail.com","directorEntity":"Yes","signatory":"Yes","keyContact":"Yes","directorEntityError":false,"signatoryError":false,"keyContactError":false,"showRemoveButton":false,"showAddButton":true,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"anyonekeycontactError":false},{"key":2,"fullName":"Rajesh","omagIDNum":"354567656","cellNumber":"+26546789234","emailAddress":"rajesh@gmail.com","directorEntity":"No","signatory":"Yes","keyContact":"No","directorEntityError":false,"signatoryError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup11","value":"Yes","name":"radioGroup11"},{"Id":"radioGroup111","value":"No","name":"radioGroup11"}],"radioGroup2":[{"Id":"radioGroup21","value":"Yes","name":"radioGroup21"},{"Id":"radioGroup211","value":"No","name":"radioGroup21"}],"radioGroup3":[{"Id":"radioGroup31","value":"Yes","name":"radioGroup31"},{"Id":"radioGroup311","value":"No","name":"radioGroup31"}],"showAddButton":true,"showRemoveButton":true,"anyonekeycontactError":false}],"consent":true}';
        AOB_BOTS_DAL_TestFactory.creatProduct();
        Test.startTest();
        String participantId =AOB_CTRL_CreateApplications.creatApplication(json3,productName);
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Assert.areNotEqual(null, participantId);
        Test.stopTest();
        }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
         
    }
/**
* @description Test method for AOB_CTRL_CreateApplications.creatApplication
*/
    @istest static void creatApplicationTemMTest(){
        try{
        String productName = 'SOCTY';
        String json3 = '{"OPEN APPLICATION":"FALSE","ENTITY TYPE":"Formal Body without CIPA","LEGAL NAME":"DON DOT Proprietary Limited","CIPA REGISTRATION NUMBER":"BW54678789564","GROSS ANNUAL TURNOVER (GTA)":"100000000","directordetails":[{"key":1,"fullName":"Venkat test","omagIDNum":"345678233","cellNumber":"+26546766657","emailAddress":"venkat@gmail.com","directorEntity":"Yes","signatory":"Yes","keyContact":"Yes","directorEntityError":false,"signatoryError":false,"keyContactError":false,"showRemoveButton":false,"showAddButton":true,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"anyonekeycontactError":false},{"key":2,"fullName":"Rajesh","omagIDNum":"354567656","cellNumber":"+26546789234","emailAddress":"rajesh@gmail.com","directorEntity":"No","signatory":"Yes","keyContact":"No","directorEntityError":false,"signatoryError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup11","value":"Yes","name":"radioGroup11"},{"Id":"radioGroup111","value":"No","name":"radioGroup11"}],"radioGroup2":[{"Id":"radioGroup21","value":"Yes","name":"radioGroup21"},{"Id":"radioGroup211","value":"No","name":"radioGroup21"}],"radioGroup3":[{"Id":"radioGroup31","value":"Yes","name":"radioGroup31"},{"Id":"radioGroup311","value":"No","name":"radioGroup31"}],"showAddButton":true,"showRemoveButton":true,"anyonekeycontactError":false}],"consent":true}';
        AOB_BOTS_DAL_TestFactory.creatProduct();
        Test.startTest();
        String participantId=AOB_CTRL_CreateApplications.creatApplication(json3,productName);
        Test.stopTest();
        Assert.areNotEqual(null, participantId);
        }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
     
    }
/**
* @description Test method for AOB_CTRL_CreateApplications.creatApplication
*/
     @istest static void creatApplicationNoTest(){
         try{
        String productName = 'SOCTY';
        String json3 = '{"OPEN APPLICATION":"FALSE","ENTITY TYPE":"Formal Body without CIPA","LEGAL NAME":"DON DOT Proprietary Limited","CIPA REGISTRATION NUMBER":"BW54678365612","GROSS ANNUAL TURNOVER (GTA)":"7501","directordetails":[{"key":1,"fullName":"Venkat test","omagIDNum":"345678233","cellNumber":"+26546766657","emailAddress":"venkat@gmail.com","directorEntity":"Yes","signatory":"Yes","keyContact":"Yes","directorEntityError":false,"signatoryError":false,"keyContactError":false,"showRemoveButton":false,"showAddButton":true,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"anyonekeycontactError":false},{"key":2,"fullName":"Rajesh","omagIDNum":"354567656","cellNumber":"+26546789234","emailAddress":"rajesh@gmail.com","directorEntity":"No","signatory":"Yes","keyContact":"No","directorEntityError":false,"signatoryError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup11","value":"Yes","name":"radioGroup11"},{"Id":"radioGroup111","value":"No","name":"radioGroup11"}],"radioGroup2":[{"Id":"radioGroup21","value":"Yes","name":"radioGroup21"},{"Id":"radioGroup211","value":"No","name":"radioGroup21"}],"radioGroup3":[{"Id":"radioGroup31","value":"Yes","name":"radioGroup31"},{"Id":"radioGroup311","value":"No","name":"radioGroup31"}],"showAddButton":true,"showRemoveButton":true,"anyonekeycontactError":false}],"consent":true}';
        AOB_BOTS_DAL_TestFactory.creatProduct();
        Test.startTest();
     string participantId = AOB_CTRL_CreateApplications.creatApplication(json3,productName);
        Test.stopTest();
             Assert.areNotEqual(null, participantId);
          }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
    }
/**
* @description Test method for AOB_CTRL_CreateApplications.creatApplication
*/
     @istest static void creatApplicationNegTest1(){
        try{
            AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select Id,AOB_Memo_Code__c from Product2 limit 1];
            update prod;
            String json3 = '{"OPEN APPLICATION":"FALSE","ENTITY TYPE":"Formal Body with CIPA","LEGAL NAME":"DON DOT Proprietary Limited","CIPA REGISTRATION NUMBER":"BW54678365612","GROSS ANNUAL TURNOVER (GTA)":"7000","directordetails":[{"key":1,"fullName":"Venkat test","omagIDNum":"345678233","cellNumber":"+26546766657","emailAddress":"venkat@gmail.com","directorEntity":"No","signatory":"No","keyContact":"Yes","directorEntityError":false,"signatoryError":false,"keyContactError":false,"showRemoveButton":false,"showAddButton":true,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"anyonekeycontactError":false},{"key":2,"fullName":"Rajesh","omagIDNum":"354567656","cellNumber":"+26546789234","emailAddress":"rajesh@gmail.com","directorEntity":"No","signatory":"Yes","keyContact":"No","directorEntityError":false,"signatoryError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup11","value":"Yes","name":"radioGroup11"},{"Id":"radioGroup111","value":"No","name":"radioGroup11"}],"radioGroup2":[{"Id":"radioGroup21","value":"Yes","name":"radioGroup21"},{"Id":"radioGroup211","value":"No","name":"radioGroup21"}],"radioGroup3":[{"Id":"radioGroup31","value":"Yes","name":"radioGroup31"},{"Id":"radioGroup311","value":"No","name":"radioGroup31"}],"showAddButton":true,"showRemoveButton":true,"anyonekeycontactError":false}],"consent":true}';
            Application__c app=New Application__c();
            app.Status__c='In Progress';
            app.AOB_RegistrationNumber__c='BW54678365612';
            app.AOB_Product__c=prod.Id;
            insert app;
            Test.startTest();
            string participantId=AOB_CTRL_CreateApplications.creatApplication(json3,prod.AOB_Memo_Code__c);
            Test.stopTest();
           Assert.areNotEqual(null, participantId,'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
/**
* @description Test method for AOB_CTRL_CreateApplications.creatApplication
*/
    @istest static void creatApplicationNegTest2(){
        try{
        String productName = 'SOCTY';
        String json3 = '{"OPEN APPLICATION":"FALSE","ENTITY TYPE":"Formal Body without CIPA","LEGAL NAME":"DON DOT Proprietary Limited","CIPA REGISTRATION NUMBER":"BW54678365612","GROSS ANNUAL TURNOVER (GTA)":"7000","directordetails":[{"key":1,"fullName":"Venkat test","omagIDNum":"345678233","KeyContactPhone":"+26546766657","keyContactEmail":"venkat@gmail.com","directorEntity":"Yes","signatory":"Yes","keyContact":"Yes","directorEntityError":false,"signatoryError":false,"keyContactError":false,"showRemoveButton":false,"showAddButton":true,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"anyonekeycontactError":false},{"key":2,"fullName":"Rajesh","omagIDNum":"354567656","cellNumber":"+26546789234","emailAddress":"rajesh@gmail.com","directorEntity":"No","signatory":"Yes","keyContact":"No","directorEntityError":false,"signatoryError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup11","value":"Yes","name":"radioGroup11"},{"Id":"radioGroup111","value":"No","name":"radioGroup11"}],"radioGroup2":[{"Id":"radioGroup21","value":"Yes","name":"radioGroup21"},{"Id":"radioGroup211","value":"No","name":"radioGroup21"}],"radioGroup3":[{"Id":"radioGroup31","value":"Yes","name":"radioGroup31"},{"Id":"radioGroup311","value":"No","name":"radioGroup31"}],"showAddButton":true,"showRemoveButton":true,"anyonekeycontactError":false}],"consent":true}';
        AOB_BOTS_DAL_TestFactory.creatProduct();
        Test.startTest();
        string participantId =AOB_CTRL_CreateApplications.creatApplication(json3,productName);
        Test.stopTest();
         Assert.areNotEqual(null, participantId,'Test Meassage');
        }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
    }
     
     
/**
* @description Test method for AOB_CTRL_CreateApplications.createMatsheloAppliaction
*/
     @istest static void creatApplicationproductTest(){
         try{
        String json4 = '{"OPEN APPLICATION":"FALSE","ENTITY TYPE":"Formal Body with CIPA","LEGAL NAME":"DON DOT Proprietary Limited","CIPA REGISTRATION NUMBER":"BW54678365612","GROSS ANNUAL TURNOVER (GTA)":"7000","directordetails":[{"key":1,"fullName":"Venkat test","omagIDNum":"345678233","KeyContactPhone":"+26546766657","keyContactEmail":"venkat@gmail.com","directorEntity":"Yes","signatory":"Yes","keyContact":"Yes","directorEntityError":false,"signatoryError":false,"keyContactError":false,"showRemoveButton":false,"showAddButton":true,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"anyonekeycontactError":false},{"key":2,"fullName":"Rajesh","omagIDNum":"354567656","cellNumber":"+26546789234","emailAddress":"rajesh@gmail.com","directorEntity":"No","signatory":"Yes","keyContact":"No","directorEntityError":false,"signatoryError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup11","value":"Yes","name":"radioGroup11"},{"Id":"radioGroup111","value":"No","name":"radioGroup11"}],"radioGroup2":[{"Id":"radioGroup21","value":"Yes","name":"radioGroup21"},{"Id":"radioGroup211","value":"No","name":"radioGroup21"}],"radioGroup3":[{"Id":"radioGroup31","value":"Yes","name":"radioGroup31"},{"Id":"radioGroup311","value":"No","name":"radioGroup31"}],"showAddButton":true,"showRemoveButton":true,"anyonekeycontactError":false}],"consent":true}';
        Product2 prd=new Product2();
        prd.ProductCode='OD001';
        prd.AOB_Memo_Code__c='OD001';
        prd.Name='test test';
        insert prd;
        Test.startTest(); 
        string participantId=AOB_CTRL_CreateApplications.creatApplication(json4,prd.ProductCode);
        Test.stopTest(); 
          Assert.areNotEqual(null, participantId,'Test Meassage');
         }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
    }
   
/**
* @description Test method for AOB_CTRL_CreateApplications.createMatsheloAppliaction
*/
     @istest static void createMatsheloAppliactionTest(){
         try{
        String productName = 'SOCTY';
       String json5=        '{"MATSHELO OPEN APPLICATION":"FALSE","ENTITY TYPE CATEGORY":"TRUE","ENTITY TYPE":"Churches","GROUP NAME":"test","DATE OF REGISTRATION":"2023-04-19","directordetails":[{"key":1,"fullName":"mmm","omagIDNum":"852963147","cellNumber":"0785214963","emailAddress":"iknmk@gmail.com","uploadfile":"","signatory":"Yes","keyContact":"Yes","showRemoveButton":false,"showAddButton":true,"signatoryYes":true,"signatoryNo":false,"mobileNumberMatch":false,"directorEntityError":false,"signatoryError":false,"uploadfileError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"signatoryLimitedError":false,"anyonekeycontactError":false}],"consent":true}';
        
        AOB_BOTS_DAL_TestFactory.creatProduct();
        Test.startTest();
        AOB_CTRL_CreateApplications.createMatsheloAppliaction(json5,productName);
        Test.stopTest();
        Lead ld = [Select id,Phone,LeadSource from Lead];
        Assert.areNotEqual(null, ld,'Test Meassage');
         }
         
         catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
    }
/**
* @description Test method for AOB_CTRL_CreateApplications.createMatsheloAppliaction
*/
     @istest 
       static void createMatsheloAppliactionwithoutcipaTest(){
       try{
        String productName = 'SOCTY';
        String json1 = '{"OPEN APPLICATION":"FALSE","DATE OF REGISTRATION": "2023-04-20","ENTITY TYPE":"Formal Body without CIPA","LEGAL NAME":"DON DOT Proprietary Limited","CIPA REGISTRATION NUMBER":"BW54678365612","GROSS ANNUAL TURNOVER (GTA)":"100000000","directordetails":[{"key":1,"fullName":"Venkat test","omagIDNum":"345678233","cellNumber":"+26546766657","emailAddress":"venkat@gmail.com","directorEntity":"No","signatory":"No","keyContact":"Yes","directorEntityError":false,"signatoryError":false,"keyContactError":false,"showRemoveButton":false,"showAddButton":true,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"anyonekeycontactError":false},{"key":2,"fullName":"Rajesh","omagIDNum":"354567656","cellNumber":"+26546789234","emailAddress":"rajesh@gmail.com","directorEntity":"No","signatory":"Yes","keyContact":"No","directorEntityError":false,"signatoryError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup11","value":"Yes","name":"radioGroup11"},{"Id":"radioGroup111","value":"No","name":"radioGroup11"}],"radioGroup2":[{"Id":"radioGroup21","value":"Yes","name":"radioGroup21"},{"Id":"radioGroup211","value":"No","name":"radioGroup21"}],"radioGroup3":[{"Id":"radioGroup31","value":"Yes","name":"radioGroup31"},{"Id":"radioGroup311","value":"No","name":"radioGroup31"}],"showAddButton":true,"showRemoveButton":true,"anyonekeycontactError":false}],"consent":true}';
        AOB_BOTS_DAL_TestFactory.creatProduct();
        Test.startTest();
        AOB_CTRL_CreateApplications.createMatsheloAppliaction(json1,productName);
        Test.stopTest();
        Lead ld = [Select id,Phone,LeadSource from Lead];
        Assert.areNotEqual(null, ld,'Test Meassage');
       }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
    }
/**
* @description Test method for AOB_CTRL_CreateApplications.createMatsheloAppliaction
*/
    @istest 
       static void createMatsheloAppliactionwithoutcipaNegTest(){
       try{
        String productName = 'SOCTY';
        String json1=' {"MATSHELO OPEN APPLICATION":"FALSE","ENTITY TYPE CATEGORY":"TRUE","ENTITY TYPE":"Churches","GROUP NAME":"test","DATE OF REGISTRATION":"2023-04-19","directordetails":[{"key":1,"fullName":"trdt","omagIDNum":"741852963","cellNumber":"0852963741","emailAddress":"murali8522@gmali.com","uploadfile":true,"signatory":"No","keyContact":"","showRemoveButton":false,"showAddButton":true,"signatoryYes":false,"signatoryNo":true,"mobileNumberMatch":false,"directorEntityError":false,"signatoryError":false,"uploadfileError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"signatoryLimitedError":false}],"consent":true}';
        AOB_BOTS_DAL_TestFactory.creatProduct();
        Test.startTest();
        AOB_CTRL_CreateApplications.createMatsheloAppliaction(json1,productName);
        Test.stopTest();
        Lead ld = [Select id,Phone,LeadSource from Lead];
        Assert.areNotEqual(null, ld,'Test Meassage');
       }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
    }
      /**
* @description Test method for AOB_CTRL_CreateApplications.createMatsheloAppliaction
*/
    @istest static void createMatsheloAppliactionNegTest(){
        try{
            AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select Id,AOB_Memo_Code__c from Product2 limit 1];
            update prod;
            String json3=' {"MATSHELO OPEN APPLICATION":"FALSE","ENTITY TYPE CATEGORY":"TRUE","ENTITY TYPE":"Churches","GROUP NAME":"test","DATE OF REGISTRATION":"2023-04-19","directordetails":[{"key":1,"fullName":"trdt","omagIDNum":"741852963","cellNumber":"0852963741","emailAddress":"murali8522@gmali.com","uploadfile":true,"signatory":"No","keyContact":"","showRemoveButton":false,"showAddButton":true,"signatoryYes":false,"signatoryNo":true,"mobileNumberMatch":false,"directorEntityError":false,"signatoryError":false,"uploadfileError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"signatoryLimitedError":false}],"consent":true}';
            Application__c app=New Application__c();
            app.Status__c='In Progress';
            app.AOB_RegistrationNumber__c='BW54678365612';
            app.AOB_Product__c=prod.Id;
            insert app;
            Test.startTest();
            string participantId=AOB_CTRL_CreateApplications.createMatsheloAppliaction(json3,prod.AOB_Memo_Code__c);
            Test.stopTest();
             Assert.areNotEqual(null, participantId,'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
    }
/**
* @description Test method for AOB_CTRL_CreateApplications.creatApplication
*/
    @istest
    static void creatApplicationwithoutcipa(){
        try{
        String productName = 'SOCTY';
        String json2 = '{"OPEN APPLICATION":"FALSE","ENTITY TYPE":"Formal Body without CIPA","LEGAL NAME":"DON DOTs Proprietary Limited","CIPA REGISTRATION NUMBER":"BW54678345613","GROSS ANNUAL TURNOVER (GTA)":"10000000","directordetails":[{"key":1,"fullName":"Venkat test","omagIDNum":"345678255","cellNumber":"+26546766658","emailAddress":"venkat@gmail.com","directorEntity":"No","signatory":"No","keyContact":"No","directorEntityError":false,"signatoryError":false,"keyContactError":false,"showRemoveButton":false,"showAddButton":true,"radioGroup1":[{"Id":"radioGroup1","value":"Yes","name":"radioGroup1"},{"Id":"radioGroup01","value":"No","name":"radioGroup1"}],"radioGroup2":[{"Id":"radioGroup2","value":"Yes","name":"radioGroup2"},{"Id":"radioGroup02","value":"No","name":"radioGroup2"}],"radioGroup3":[{"Id":"radioGroup3","value":"Yes","name":"radioGroup3"},{"Id":"radioGroup03","value":"No","name":"radioGroup3"}],"anyonekeycontactError":false},{"key":2,"fullName":"Rajesh","omagIDNum":"354567656","cellNumber":"+26546789234","emailAddress":"rajesh@gmail.com","directorEntity":"No","signatory":"Yes","keyContact":"No","directorEntityError":false,"signatoryError":false,"keyContactError":false,"radioGroup1":[{"Id":"radioGroup11","value":"Yes","name":"radioGroup11"},{"Id":"radioGroup111","value":"No","name":"radioGroup11"}],"radioGroup2":[{"Id":"radioGroup21","value":"Yes","name":"radioGroup21"},{"Id":"radioGroup211","value":"No","name":"radioGroup21"}],"radioGroup3":[{"Id":"radioGroup31","value":"Yes","name":"radioGroup31"},{"Id":"radioGroup311","value":"No","name":"radioGroup31"}],"showAddButton":true,"showRemoveButton":true,"anyonekeycontactError":false}],"consent":true}';
        AOB_BOTS_DAL_TestFactory.creatProduct();
        Test.startTest();
        string participantId =AOB_CTRL_CreateApplications.creatApplication(json2,productName);
        Test.stopTest();
        Assert.areNotEqual(null, participantId,'Test Meassage');
       }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
        
    }
   
/**
* @description Test method for AOB_CTRL_CreateApplications.createUserselectLineitem
*/
    @isTest
    static void createUserselectLineitemTest() {
        String applicationId = [SELECT Id FROM Application_Participant__c LIMIT 1].Id;
        String productdata = '[{"tag": "tag1", "header": "header1", "subTitle": "subTitle1", "cardLineItemIcon": "icon1", "cardLineItems": [{"name": "name1", "value": "value1"}]}]';
        Test.startTest();
        AOB_CTRL_CreateApplications.createUserselectLineitem(applicationId, productdata);
        Test.stopTest();
        List<Application_Line_Item__c> appLineItems = [SELECT Id FROM Application_Line_Item__c];
        Assert.areEqual(2, appLineItems.size(),'Test Meassage');
    }
/**
* @description Test method for AOB_CTRL_CreateApplications.deleteLineItems
*/
    @isTest static void deleteLineItemsTest() {
        Application__c app = AOB_BOTS_DAL_TestFactory.createTestRecords();
        AOB_BOTS_DAL_TestFactory.insertLineItem(app.Id);
        List<String> applicationIds = new List<String>{ app.Id };
            Test.startTest();
        AOB_CTRL_CreateApplications.deleteLineItems(applicationIds);
        Test.stopTest();
        List<Application_Line_Item__c> deletedLineItems = [SELECT Id FROM Application_Line_Item__c WHERE Application__c = :app.Id ];
        delete deletedLineItems;
        Assert.areEqual(1, deletedLineItems.size(), 'Expected the line item to be deleted.');
    }



    @isTest
    static void getLineItemsTest() {
        Application__c app = new Application__c();
       // app.Name = 'Test Application';
        insert app;
        Application_Participant__c participant = new Application_Participant__c();
        participant.Application__c = app.Id;
        insert participant;
        Application_Line_Item__c lineItem = new Application_Line_Item__c();
        lineItem.Application__c = app.Id;
        lineItem.Name = 'Test Line Item';
        lineItem.AOB_Status__c = 'Accepted';
        lineItem.AOB_Main__c = false;
        lineItem.Details__c = 'Test details';
        insert lineItem;
        Test.startTest();
        Map<String, String> result = AOB_CTRL_CreateApplications.getLineItems(participant.Id);
        Test.stopTest();
        Assert.areNotEqual(null, result,'test message');
       Assert.areEqual(2, result.size(),'test message');
        List<Application_Line_Item__c> lineItemsFromJson = (List<Application_Line_Item__c>) JSON.deserialize(result.get('applicationItems'), List<Application_Line_Item__c>.class);
       assert.areNotEqual(null, lineItemsFromJson,'test message');
       Assert.areEqual(1, lineItemsFromJson.size(),'test message');
        Application_Line_Item__c retrievedLineItem = lineItemsFromJson[0];
        Assert.areEqual('Test Line Item', retrievedLineItem.Name, 'Name does not match expected value');
        Assert.areEqual('Accepted', retrievedLineItem.AOB_Status__c, 'AOB Status does not match expected value');
        Assert.areEqual(false, retrievedLineItem.AOB_Main__c, 'AOB Main flag does not match expected value');
        Assert.areEqual('Test details', retrievedLineItem.Details__c, 'Details do not match expected value');
       
    }
    
/**
* @description Test method for AOB_CTRL_CreateApplications.getLineItemsFail
*/
    @isTest
    static void getLineItemsFailTest() {
        try{
             Application__c app = AOB_BOTS_DAL_TestFactory.createAppParticipant();
        Application_Participant__c appParticipant = [SELECT Id FROM Application_Participant__c WHERE Application__c = :app.Id];
        
        Test.startTest();
        Map<String, String> result2 = AOB_CTRL_CreateApplications.getLineItems(appParticipant.Id);
        Test.stopTest();
        Assert.areNotEqual(null, result2,'Test Meassage');
        }
        catch (Exception e){ 
          assert.areNotEqual(null, e.getMessage(),'Test Meassage');
        }
       
    }
    
/**
* @description Test method for AOB_CTRL_CreateApplications.updateInflight
*/
    @isTest
    static void updateInflightTest() {
        try{
        Application__c app = AOB_BOTS_DAL_TestFactory.createAppParticipant();
        Application_Participant__c appParticipant = [SELECT Id FROM Application_Participant__c WHERE Application__c = :app.Id];
        String appData = '[{"cardId":"BO007","id":"3462","cardName":"Business Online","header":"Business Online","subTitle":"More than just banking","cardLineItemIcon":"/assets/images/triangle.png","cardLineItems":[{"label":"For broader advice beyond the technicalities of banking"},{"label":"Our experts will guide you through important decisions"},{"label":"Ipsum lorem"},{"label":"Ipsum lorem"}]},{"cardId":"BO008","id":"1248","cardName":"Fixed Deposit","header":"Fixed Deposit","subTitle":"No monthly fees","cardLineItemIcon":"/assets/images/triangle.png","cardLineItems":[{"label":"Interest rate is based on account balance and investment period"},{"label":"Capital is guaranteed"},{"label":"Make a minimum opening deposit of P 1000"},{"label":"Interst is calculated daily and paid monthly, quarterly, annually or at maturity"}]},{"cardId":"BO009","id":"1248","cardName":"Business Call Account","header":"Business Call Account","subTitle":"Electronic statements","cardLineItemIcon":"/assets/images/triangle.png","cardLineItems":[{"label":"Access to our innovative and simple Enterprise Online platform or Business Online (BOL)"},{"label":"Put surplus money to work in this account that offers competitive rates"},{"label":"Immediate access to funds"},{"label":"No monthly fees"}]}]';
        Id applicationId = appParticipant.Id;      
        Test.startTest();
         AOB_CTRL_CreateApplications.updateInflight(applicationId, appData);
        Test.stopTest();
        
        }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
    }
/**
* @description Test method for AOB_CTRL_CreateApplications.updateInflight
*/
    @isTest
    static void updateInflightNegTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createTestRecords();
            String appData= '[{"cardId":"BO007","id":"3462","cardName":"Business Online","header":"Business Online","subTitle":"More than just banking","cardLineItemIcon":"/assets/images/triangle.png","cardLineItems":[{"label":"For broader advice beyond the technicalities of banking"},{"label":"Our experts will guide you through important decisions"},{"label":"Ipsum lorem"},{"label":"Ipsum lorem"}]},{"cardId":"BO008","id":"1248","cardName":"Fixed Deposit","header":"Fixed Deposit","subTitle":"No monthly fees","cardLineItemIcon":"/assets/images/triangle.png","cardLineItems":[{"label":"Interest rate is based on account balance and investment period"},{"label":"Capital is guaranteed"},{"label":"Make a minimum opening deposit of P 1000"},{"label":"Interst is calculated daily and paid monthly, quarterly, annually or at maturity"}]},{"cardId":"BO009","id":"1248","cardName":"Business Call Account","header":"Business Call Account","subTitle":"Electronic statements","cardLineItemIcon":"/assets/images/triangle.png","cardLineItems":[{"label":"Access to our innovative and simple Enterprise Online platform or Business Online (BOL)"},{"label":"Put surplus money to work in this account that offers competitive rates"},{"label":"Immediate access to funds"},{"label":"No monthly fees"}]}]';
            Test.startTest(); 
             AOB_CTRL_CreateApplications.updateInflight(null, appData);
            Test.stopTest();
            Application__c updatedApp = [SELECT Id, Inflight__c FROM Application__c WHERE Id = :app.Id];
            assert.areNotEqual(null, updatedApp,'Test Meassage');
           
        }
        catch(Exception e){
            assert.areNotEqual(null, e.getMessage(),'Test Meassage');
            
        } 
    }
    
/**
* @description Test method for AOB_CTRL_CreateApplications.updateLeadStatusLineItems
*/
    @IsTest
    static void updateLeadStatusLineItemsTest() {
        try{
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='AOB_Bots_BCC_Lending' Limit 1].Queue.Id;
        ID queueId2 = [SELECT Queue.Id FROM queuesobject WHERE queue.name='AOB_Bots_BCC_Savings' Limit 1].Queue.Id;
        Application_Line_Item__c appItem1 = new Application_Line_Item__c(
            Application__c = app.Id,
            AOB_ProductCode__c = 'BO001'
        );
        Application_Line_Item__c appItem2 = new Application_Line_Item__c(
            Application__c = app.Id,
            AOB_ProductCode__c = 'BO002'
        );
        
        List<Application_Line_Item__c> lineItems = new List<Application_Line_Item__c>{appItem1, appItem2};
            AOB_BOTS_DAL_TestFactory lineItemCreator = new AOB_BOTS_DAL_TestFactory();
        lineItemCreator.createLineItems(lineItems);
        List<Application_Line_Item__c> appItemlist=[select Id,Application__c,AOB_ProductCode__c from Application_Line_Item__c where Application__c=:appParticipant.Application__c];
        List<Lead> ldinsertList= new List<Lead>();
        for(Application_Line_Item__c ap:appItemlist){
            Lead lc= new Lead();
            if(ap.AOB_ProductCode__c=='BO001' || ap.AOB_ProductCode__c=='BO004' || ap.AOB_ProductCode__c=='BO005' || ap.AOB_ProductCode__c=='BO006'){
                
                String name = appParticipant.AOB_FullName__c;
                lc.LastName = name;
                lc.Description='ApplicationId '+appParticipant.Application__c;
                lc.AOB_Status__c='Cross Sell selected';
                lc.OwnerId=queueId2;
                ldinsertList.add(lc);
            }if(ap.AOB_ProductCode__c=='BO002' || ap.AOB_ProductCode__c=='BO008' || ap.AOB_ProductCode__c=='BO009'){
                String name = appParticipant.AOB_FullName__c;
                lc.LastName = name;
                lc.Description='ApplicationId '+appParticipant.Application__c;
                lc.AOB_Status__c='Cross Sell selected';
                lc.OwnerId=queueId;
                ldinsertList.add(lc);
                
            }
            
        }
        Test.startTest();
        Integer result3 = AOB_CTRL_CreateApplications.updateLeadStatusLineItems(appParticipant.Id);
        assert.areNotEqual(null, result3,'Test Meassage');
        Test.stopTest();
    }
    Catch(exception e){  
        assert.areNotEqual(null, e.getMessage(),'Test Meassage');
    }

    }
    
/**
* @description Test method for AOB_CTRL_CreateApplications.testGetParticipantApplication
*/
    @IsTest
    static void testGetParticipantApplicationTest() {
        try{
            Test.startTest();
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);     
            Map<String, Object> result7 = AOB_CTRL_CreateApplications.getParticipantApplication(appParticipant.Id);
            Assert.areEqual(appParticipant.AOB_IDNumber__c, result7.get('OmangId'),'test message');
            Assert.areEqual(appParticipant.AOB_FullName__c, result7.get('FullName'),'test message');
            Assert.areEqual(app.AOB_RegistrationNumber__c, result7.get('CIPA REGISTRATION NUMBER'),'test message');
            Assert.areEqual(appParticipant.CNGCU_Email__c, result7.get('EMAIL ADDRESS'),'test message');
            Assert.areEqual(String.valueOf(appParticipant.AOB_KeyContactPerson__c), result7.get('ARE YOU A DIRECTOR ON THE ENTITY/BUSINESS?'),'test message');
            Assert.areEqual(String.valueOf(appParticipant.AOB_Signatory__c), result7.get('ARE YOU GOING TO BE A SIGNATORY ON THE ACCOUNT?'),'test message');
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'test message'); 
        }
    }
    /**
* @description Test method for AOB_CTRL_CreateApplications.getCardSelection
*/
    @istest
    static void getCardSelectionTest(){
    try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            test.startTest();
            String result = AOB_CTRL_CreateApplications.getCardSelection(app.id);
            test.stopTest();
            Assert.areEqual(false, result,'test message');
        }
       catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'test message');
        }
    }
 /**
* @description Test method for AOB_CTRL_CreateApplications.getapplication
*/
    @istest
    static void getapplicationIdTest(){
    try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            test.startTest();
            String result = AOB_CTRL_CreateApplications.getapplicationId(appParticipant.id);
            test.stopTest();
        }
       catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'test message');
        }
    }
/**
* @description Test method for AOB_CTRL_CreateApplications.getapplication
*/
    @istest
    static void getExistcustomerGroupTest(){
    try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            test.startTest();
            Boolean result = AOB_CTRL_CreateApplications.getExistcustomerGroup(app.AOB_GroupName__c);
            test.stopTest();
        }
       catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'test message');
        }
    }
     /**
    * @description Test method for AOB_CTRL_CreateApplications.getSelectedCardName
    */
    @istest
    static void getSelectedCardNameTest(){
    try{
            Test.startTest();
            String result = AOB_CTRL_CreateApplications.getSelectedCardName('062097');
            Test.stopTest(); 
            Assert.areEqual(false, result,'test message');
        }
       catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'test message');
        }
    }

    /**
    * @description Test method for AOB_CTRL_CreateApplications.getEntityType
    */
    @istest
    static void getEntityTypeTest(){
    try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            test.startTest();
            String result = AOB_CTRL_CreateApplications.getEntityType(app.id);
            test.stopTest();
           Assert.areEqual(false, result,'test message');
        }
       catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'test message');
        }
    }
}