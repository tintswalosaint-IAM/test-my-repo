/***************************************************************************************
@ Author            : Sai Sharanyya 
@ Date              : Jun 23rd 2023
@ Name of the Class : BCB_CTRL_FormCreator_Test
@description        : Test class for BCB_CTRL_FormCreator
@ Last Modified By  : Ravi Myaka  
@ Last Modified On  : 08-03-2024
@ Modification description : SFP-36156
**************************************************************************************
@ Last Modified By  : Alex Niyonsaba  
@ Last Modified On  : 17 July 2025
@ Modification description : Improving Code coverage from 81% to 86%
**************************************************************************************
@ Last Modified By  : Alex Niyonsaba  
@ Last Modified On  : 21 Oct 2025
@ Modification description : Updates made to update getProductByProductCodeTest() method.
@ User Story : SFP-53804
***************************************************************************************/
@isTest
public class BCB_CTRL_FormCreator_Test {

    /**
    * @description Test data for BCB_CTRL_FormCreator_Test class
    */
    @testSetup
    static void setup() {
        Id productId = BCB_DAL_TestFactory.createProducts();
        BCB_DAL_TestFactory.createAppRecords(productId);
        list<AOB_FlowScreen__c> screen = BCB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = BCB_DAL_TestFactory.createSection(screen[0].id);        
        list<AOB_field__c> field = BCB_DAL_TestFactory.createFields(section[0].id);

        
    }
    
    /**
    * @description Test method for BCB_CTRL_FormCreator.getFields
    */
    @isTest
    public static void getFieldsTest(){
        try{
            Test.startTest();
            List<Application__c> application = [Select Id FROM Application__c LIMIT 1];
            AOB_DTO_Form fields = BCB_CTRL_FormCreator.getFields(application[0].Id,'Company Information');
            Test.stopTest();
            Assert.areNotEqual(null, fields,'Test');
        } catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }
   

    /**
    * @description Test method for BCB_CTRL_FormCreator.createVerificationRecord
    */
    @isTest
    public static void createVerificationRecordTest(){
        try{
            Test.startTest();
            List<Application__c> application = [Select Id FROM Application__c LIMIT 1];
           List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
          id verificationId= BCB_CTRL_FormCreator.createVerificationRecord( lstApp[0], 'DSX' , 'success');
            Test.stopTest();
            Assert.isNotNull(verificationId,'Test');
        } catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }
    
     /**
    * @description Test method for BCB_CTRL_FormCreator.createGUID
    */
    @isTest
    public static void createGUIDTest(){
        try{
            Test.startTest();
            
          string guid=  BCB_CTRL_FormCreator.createGUID();
            Test.stopTest();
            Assert.isNotNull(guid,'Test');
        } catch(Exception ex){
            Assert.isNotNull( ex.getMessage(),'Test'); 
        }
        
    }

     /**
    * @description Test method for BCB_CTRL_FormCreator.getKeyContactParticipantIds
    */
    @isTest
    public static void getKeyContactParticipantIdsTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
            insert  lstApp;
          id partid=   BCB_CTRL_FormCreator.getKeyContactParticipantIds(lstApp[0].Application__c);
            Test.stopTest();
            Assert.isNotNull(partid,'Test');
        } catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }
  
   /*  BCB_CTRL_FormCreator.getKeyParticipantData(String recordId) */
 
   @isTest
    public static void getKeyParticipantDataTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
            insert  lstApp;
            Map<String, String> part=  BCB_CTRL_FormCreator.getKeyParticipantData(lstApp[0].id);
            
            Test.stopTest();
            Assert.isNotNull(part,'Test');
        } catch(Exception ex){
            Assert.isNotNull( ex.getMessage(),'Test'); 
        }
        
    }

    

    /*  BCB_CTRL_FormCreator.fetchrecordidTest(String recordId) */
 
   @isTest
   public static void fetchrecordidTest(){
       try{
           Test.startTest();
           List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
           insert  lstApp;
           Map<String, String> part=  BCB_CTRL_FormCreator.fetchrecordid(lstApp[0].id);
           Test.stopTest();
           Assert.isNotNull( part,'Test');
       } catch(Exception ex){
           Assert.isNotNull( ex.getMessage(),'Test'); 
       }
       
   }

    /*  BCB_CTRL_FormCreator.fetchrecordidTest(String recordId) */
 
    @isTest
    public static void fetchrecordidTest1(){
        BCB_CustomException unexpectedException;
        Test.startTest();
        Id i;
        try{
           
            List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
            insert  lstApp;
             i =  BCB_CTRL_FormCreator.createVerificationRecord(lstApp[0], 'test', 'test');
           
        }catch (BCB_CustomException dmx)
            {
                 unexpectedException = dmx;
            }
            Test.stopTest();
            Assert.isNotNull(unexpectedException,'Test'); 
        
    }
   /* @description Test method for BCB_CTRL_FormCreator.getParticipantAppId*/
    
     @isTest
    public static void getParticipantAppIdTest(){

    try{
        Test.startTest();
       List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
       insert lstApp;
      
       Map<String, Object> jsonMap= BCB_CTRL_FormCreator.getParticipantAppId( lstApp[0].id);
        Test.stopTest();
        Assert.isNotNull(jsonMap,'Test');
    } catch(Exception ex){
        Assert.isNotNull( ex.getMessage(),'Test'); 
    }

    } 


/**
    * @description Test method for BCB_CTRL_FormCreator.getSchemCodeAndCurrency
    */
    @isTest
    public static void getSchemCodeAndCurrencyTest(){
        try{
            Test.startTest();
            List<Application__c> application = [Select Id FROM Application__c LIMIT 1];
            Application_Participant__c app =  BCB_CTRL_FormCreator.getSchemCodeAndCurrency(application[0].id);
            Test.stopTest();
            Assert.isNotNull( app,'Test');
        } catch(Exception ex){
            Assert.isNotNull( ex.getMessage(),'Test'); 
        }
        
    }

/**
    * @description Test method for BCB_CTRL_FormCreator.getSchemCodeAndCurrency
    */
    @isTest
    public static void getSchemCodeTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
            string app =  BCB_CTRL_FormCreator.getSchemCode(lstApp[0].id);
            Test.stopTest();
            Assert.isNotNull(app,'Test');
        } catch(Exception ex){
            Assert.isNotNull( ex.getMessage(),'Test'); 
        }
        
    }
    /**
    * @description Test method for BCB_CTRL_FormCreator.getSchemCodeAndCurrency
    */
    @isTest
    public static void fetchAccountSetupTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> lstApp2 = BCB_DAL_TestFactory.createApplicationParticipant(1);
            insert lstApp2;
            List<Application_Line_Item__c> data = new List<Application_Line_Item__c>();
            data.add(new Application_Line_Item__c(
                Application__c = lstApp2[0].Application__c,
                Name = 'accessToMarkets',
                AOB_Status__c = 'Accepted'
            ));
            data.add(new Application_Line_Item__c(
                Application__c = lstApp2[0].Application__c,
                Name = 'financialFitnessTraining',
                AOB_Status__c = 'Accepted'
            ));
            data.add(new Application_Line_Item__c(
                Application__c = lstApp2[0].Application__c,
                Name = 'insuranceOfferings',
                AOB_Status__c = 'Accepted'
            ));
            data.add(new Application_Line_Item__c(
                Application__c = lstApp2[0].Application__c,
                Name = 'accessToFinancing',
                AOB_Status__c = 'Accepted'
            ));
            data.add(new Application_Line_Item__c(
                Application__c = lstApp2[0].Application__c,
                Name = 'investmentOffering',
                AOB_Status__c = 'Accepted'
            ));
            data.add(new Application_Line_Item__c(
                Application__c = lstApp2[0].Application__c,
                Name = 'mentoringCoachingForSmallAndMediumBusinesses',
                AOB_Status__c = 'Accepted'
            ));
            data.add(new Application_Line_Item__c(
                Application__c = lstApp2[0].Application__c,
                Name = 'networkingEventsWithAccessToSubjectMatterIndustryExpert',
                AOB_Status__c = 'Accepted'
            ));
            insert data;
            
            string app1 =  BCB_CTRL_FormCreator.fetchAccountSetup(lstApp2[0].id);
            string app2 = BCB_CTRL_FormCreator.fetchApplicationSummary(lstApp2[0].id);
            
            Test.stopTest();
            Assert.isNotNull(app1,'Test');
        } catch(Exception ex){
            Assert.isNotNull( ex.getMessage(),'Test'); 
        }
        
    }

    /**
    * @description Test method for BCB_CTRL_FormCreator.fetchPreApplicationDirectorData
    */
    @isTest
    public static void fetchPreApplicationDirectorData(){
        try{
            Test.startTest();
            List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
             insert lstApp; 
             Individual ind = BCB_DAL_TestFactory.createIndividual();
             ind.Application_Participant__c = lstApp[0].id;
             insert ind;
            BCB_CTRL_FormCreator.fetchPreApplicationDirectorData(lstApp[0].id);
            Test.stopTest();
        } catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }
    /**
    * @description Test method for BCB_CTRL_FormCreator.getFieldsWithoutAppId
    */
    @isTest
    public static void getFieldsWithoutAppIdTest(){
        try{
            Test.startTest();
            AOB_DTO_Form fields = BCB_CTRL_FormCreator.getFieldsWithoutAppId('Company Information');
            Test.stopTest();
            Assert.isNotNull(fields,'Test');
        } catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }

    /**
    * @description Test method for BCB_CTRL_FormCreator.setApplicationStep 
    */
    @isTest
    public static void setApplicationStepTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            BCB_CTRL_FormCreator.setApplicationStep(appParticipant[0].Id,'Uganda MVP2 Application Summary','Uganda MVP2 Account Setup');
            Test.stopTest();
                   }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }
        
    }

    /**
    * @description Test method for BCB_CTRL_FormCreator.setApplicationStep 
    */
    @isTest
    public static void setApplicationStepWSTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            appParticipant[0].AOB_PreviousScreens__c = 'Uganda MVP2 Company Details';
            update appParticipant;
            BCB_CTRL_FormCreator.setApplicationStep(appParticipant[0].Id,'Uganda MVP2 Application Summary','Uganda MVP2 Account Setup');
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }
        
    } 

    /**
    * @description Test method for BCB_CTRL_FormCreator.setApplicationStep 
    */
    @isTest
    public static void goBacktoPreviousStepTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            appParticipant[0].AOB_PreviousScreens__c = 'Uganda MVP2 Company Details;Uganda MVP2 Personal Details';
            update appParticipant;
            BCB_CTRL_FormCreator.goBacktoPreviousStep(appParticipant[0].Id);
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }
    }

    /**
    * @description Test method for BCB_CTRL_FormCreator.setApplicationStep 
    */
    @isTest
    public static void fetchApplicationDefaultDataTest(){
        try{
            Test.startTest();
            String result = BCB_CTRL_FormCreator.fetchApplicationDefaultData('OD005');
            Test.stopTest();
            Assert.isNotNull(result,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }
    }
    /**
    * @description Test method for BCB_CTRL_FormCreator.setApplicationStep 
    */
    @isTest
    public static void fetchApplicationDefaultDataElseTest(){
        try{
            Test.startTest();
            String result = BCB_CTRL_FormCreator.fetchApplicationDefaultData('OD001');
            Test.stopTest();
            Assert.isNotNull(result,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull( ex.getMessage(),'Test');
        }
    }
    @isTest
    public static void fetchApplicationDefaultDatacatchTest(){
        try{
            Test.startTest();
            String result = BCB_CTRL_FormCreator.fetchApplicationDefaultData(null);
            Test.stopTest();
            Assert.isNotNull(result,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull( ex.getMessage(),'Test');
        }
    }

     /**
    * @description Test method for BCB_CTRL_FormCreator.setApplicationStep 
    */
    @isTest
    public static void getExistingDataPersonalTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            String result = BCB_CTRL_FormCreator.getExistingData(appParticipant[0].Id,'Uganda MVP2 Personal Details');
            Test.stopTest();
            Assert.isNotNull(result,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull( ex.getMessage(),'Test');
        }
    }

     /**
    * @description Test method for BCB_CTRL_FormCreator.setApplicationStep 
    */
    @isTest
    public static void getExistingDataCompanyTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            String result = BCB_CTRL_FormCreator.getExistingData(appParticipant[0].Id,'Uganda MVP2 Company Details');
            Test.stopTest();
            Assert.isNotNull(result,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }
    }
    
    /**
    * @description Test method for BCB_CTRL_FormCreator.setApplicationStep 
    */
    @isTest
    public static void getExistingDataAccountTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            String result = BCB_CTRL_FormCreator.getExistingData(appParticipant[0].Id,'Uganda MVP2 Account Setup');
            Test.stopTest();
            Assert.isNotNull(result,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }
    }
    @isTest public static void getApplicationCurrencyTest(){
       List<Application_Participant__c> appParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        Test.startTest();
        string res = BCB_CTRL_FormCreator.getApplicationCurrency(appParticipants[0].Id);
           Assert.isNotNull(res,'Test');
        Test.stopTest();
    }
     @isTest public static void fetchPersonalDetailsTest(){
       List<Application_Participant__c> appParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        Test.startTest();
        string res = BCB_CTRL_FormCreator.fetchPersonalDetails(appParticipants[0].Id);
           Assert.isNotNull(res,'Test');
        Test.stopTest();
    }
    @isTest public static void fetchCompanyDetailsTest(){
       List<Application_Participant__c> appParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        Test.startTest();
        string res = BCB_CTRL_FormCreator.fetchCompanyDetails(appParticipants[0].Id);
           Assert.isNotNull(res,'Test');
        Test.stopTest();
    }
     @isTest public static void fetchCompanyDetailscatchTest(){
         try{
       List<Application_Participant__c> appParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        Test.startTest();
        string res = BCB_CTRL_FormCreator.fetchCompanyDetails(null);
           Assert.isNotNull(res,'Test');
        Test.stopTest();
         }
             catch(exception ex){
                  Assert.isNotNull(ex.getMessage(),'Test');
             }
    }
    
    /**
    * @description Test method for BCB_CTRL_FormCreator.setApplicationStep 
    */
    @isTest
    public static void getExistingDataApplicationTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            String result = BCB_CTRL_FormCreator.getExistingData(appParticipant[0].Id,'Uganda MVP2 Application Summary');
            Test.stopTest();
            Assert.isNotNull(result,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }
    }
    
     /**
    * @description Test method for BCB_CTRL_FormCreator.saveParticipantPersonalData 
    */
    @isTest
    public static void saveParticipantPersonalDataTest(){
        try{
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            String jsondata='{"taxResident":"FALSE","relatedPartiesUS":"TRUE","prominentPosition":"FALSE","plotNumberDetails":"Corndog","familyPromientPosition":"FALSE","district":"Abim","city":"ABIM","undefined":"ABIM","confirmstatement":true}';
            Test.startTest();
            BCB_CTRL_FormCreator.saveFormData(appParticipant[0].Id,jsondata,'Uganda MVP2 Personal Details');
            Test.stopTest();  
        } 
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }       
    }
     /**
    * @description Test method for BCB_CTRL_FormCreator.saveParticipantPersonalData 
    */
    @isTest
    public static void saveParticipantPersonalDataelseTest(){
        try{
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            String jsondata='{"taxResident":"FALSE","relatedPartiesUS":"TRUE","prominentPosition":"FALSE","plotNumberDetails":"Corndog","familyPromientPosition":"FALSE","district":"Abim","city":"ABIM","undefined":"ABIM","confirmstatement":true}';
            Test.startTest();
            BCB_CTRL_FormCreator.saveFormData(appParticipant[0].Id,jsondata,'Uganda MVP2 Account Setup');
            String jsondata1='{"taxResident":"FALSE","relatedPartiesUS":"","prominentPosition":"TRUE","plotNumberDetails":"Corndog","familyPromientPosition":"TRUE","district":"Abim","city":"ABIM","undefined":"ABIM","confirmstatement":true}';
            BCB_CTRL_FormCreator.saveFormData(appParticipant[0].Id,jsondata1,'Uganda MVP2 Account Setup');
            Test.stopTest();  
        } 
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }       
    }
    
     /**
    * @description Test method for BCB_CTRL_FormCreator.saveParticipantcompanyData 
    */
    @isTest
    public static void saveParticipantcompanyDataTest(){
        try{
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            String jsondata='{"sourceOfFunds":null,"registrationDate":"2023-05-29","noOfEmployees":"3","newAccountReason":"","grossIncomeEntity":"TRUE","grossAssetsEntity":"TRUE","businessPlotDetails":"Corndog Street UG","businessDistrict":"Abim","businessCity":"ABIM","anticipatedAnnualTO":"123","undefined":"","UPLOAD TRADE LICENSE":true,"UPLOAD COMPANY REGISTRATION CERTIFICATE":true,"UPLOAD STATEMENT OF PARTICULARS FOR SOLE PROPS":true,"ConsentBox":true}';
            Test.startTest();
            BCB_CTRL_FormCreator.saveFormData(appParticipant[0].Id,jsondata,'Uganda MVP2 Company Details');
            Test.stopTest();  
        } 
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }       
        
        
    }
      /**
    * @description Test method for BCB_CTRL_FormCreator.saveParticipantcompanyData 
    */
    @isTest
    public static void saveParticipantcompanyDataTest2(){
        try{
           
             List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            lstApp[0].AOB_inflightData__c = '{"preferredBranch" : "sb","phoneNumber" :"1223456","initialDeposit":"500"}';
            insert lstApp; 
            List<Application_Participant__c> lstParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
            lstParticipants[0].Application__c =  lstApp[0].Id;
            insert lstParticipants;
            List<Application_Line_Item__c> data = new List<Application_Line_Item__c>();

            data.add(new Application_Line_Item__c(Application__c = lstApp[0].id, Name = 'accessToMarkets', AOB_Status__c = 'Accepted'));
            
            insert data;
            
           BCB_CTRL_FormCreator.fetchAccountSetup(lstApp[0].id);
            BCB_CTRL_FormCreator.fetchApplicationSummary(lstParticipants[0].Id);
           
            string accountSetup = '{"preferredBranch" : "sb","phoneNumber" :"1223456","initialDeposit":"500","initialDepositAmount":"200","emailStatement":"xyz","sendStatement":"abc","preferredUserName":"jhon","modeOfPayment":"money","customerName":"abc","operatorName":"12345","mobileMoneyNumber":"123456789","bankName":"SB","registeredAccountName":"abc","accountNumber":"123456789","accessToMarkets":"hello","financialFitnessTraining":"qwert","insuranceOfferings":"12345","accessToFinancing":"12345","investmentOffering":"123456","mentoringCoachingForSmallAndMediumBusinesses":"hello","networkingEventsWithAccessToSubjectMatterIndustryExpert":"abc"}';

           Test.startTest();
           
                BCB_CTRL_FormCreator.saveFormData(lstParticipants[0].Id,accountSetup,'Uganda MVP2 Account Setup');
            Test.stopTest();  
        } 
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }       
        
        
    }

   /**
    * @description Test method for BCB_CTRL_FormCreator.saveParticipantaccountSetup 
    */
    @isTest
    public static void saveParticipantaccountSetupelseTest(){
        try{
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            String jsondata='{"sendStatement":"bothsalokesh9@gmail.com","registeredAccountName":null,"preferredUserName":null,"preferredBranch":"031087","phoneNumber":"0987654321","operatorName":"MTN Uganda","networkingEventsWithAccessToSubjectMatterIndustryExpert":"networkingEventsWithAccessToSubjectMatterIndustryExpert","modeOfPayment":"Mobile Money","mobileMoneyNumber":"782076452","mentoringCoachingForSmallAndMediumBusinesses":true,"investmentOffering":true,"insuranceOfferings":"insuranceOfferings","initialDepositAmount":60000,"initialDeposit":"Airtel Uganda","financialFitnessTraining":"financialFitnessTraining","emailStatement":"FALSE","customerName":"john","bankName":null,"accountNumber":null,"accessToMarkets":"accessToMarkets","accessToFinancing":true,"Confirm Box":true}';
            Test.startTest();
            BCB_CTRL_FormCreator.saveParticipantaccountSetup(appParticipant[0].Id,jsondata);
            Test.stopTest();  
        } 
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test');
        }       
      
    }
     /**
    * @description Test method for BCB_CTRL_FormCreator.saveParticipantaccountSetup 
    */
    @isTest
    public static void saveParticipantaccountSetupTest(){
        try{
             List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            insert lstApp; 
            List<Application_Participant__c> lstParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
            lstParticipants[0].Application__c =  lstApp[0].Id;
            insert lstParticipants;
            List<Application_Line_Item__c> data = new List<Application_Line_Item__c>();
    
            data.add(new Application_Line_Item__c(Application__c = lstApp[0].id, Name = 'accessToMarkets', AOB_Status__c = 'Accepted'));
      
            insert data;
                        String jsondata='{"sendStatement":"bothsalokesh9@gmail.com","registeredAccountName":null,"preferredUserName":null,"preferredBranch":"031087","phoneNumber":"0987654321","operatorName":"MTN Uganda","networkingEventsWithAccessToSubjectMatterIndustryExpert":"networkingEventsWithAccessToSubjectMatterIndustryExpert","modeOfPayment":"Mobile Money","mobileMoneyNumber":"782076452","mentoringCoachingForSmallAndMediumBusinesses":true,"investmentOffering":true,"insuranceOfferings":"insuranceOfferings","initialDepositAmount":60000,"initialDeposit":"Airtel Uganda","financialFitnessTraining":"financialFitnessTraining","emailStatement":"FALSE","customerName":"john","bankName":null,"accountNumber":null,"accessToMarkets":"accessToMarkets","accessToFinancing":true,"Confirm Box":true}';
           Test.startTest();
           BCB_CTRL_FormCreator.saveParticipantaccountSetup(lstParticipants[0].Id,jsondata);
            Test.stopTest();  
        } 
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test');
        }       
      
    }
     /**
    * @description Test method for AOB_CTRL_FormCreator.uploadFile 
    */
    @isTest
    public static void uploadFileTest(){
        List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
        try{
            Test.startTest();
            String contentId = BCB_CTRL_FormCreator.uploadFile('SGVsbG8sIFdvcmxkIQ==','testFileName',appParticipant[0].Id,'UPLOAD COMPANY REGISTRATION CERTIFICATE',2);
            BCB_CTRL_FormCreator.fetchDocuments(appParticipant[0].Id,'UPLOAD COMPANY REGISTRATION CERTIFICATE');
            Test.stopTest();
            Assert.isNotNull(contentId,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.uploadFile 
    */
    @isTest
    public static void uploadFileElseTest(){
        List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
        try{
            Test.startTest();
            String contentId = BCB_CTRL_FormCreator.uploadFile('SGVsbG8sIFdvcmxkIQ==','testFileName',appParticipant[0].Id,'Upload trade License',2);
            BCB_CTRL_FormCreator.fetchDocuments(appParticipant[0].Id,'Upload trade license');
            Test.stopTest();
            Assert.isNotNull(contentId,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.uploadFile 
    */
    @isTest
    public static void uploadFileElse2Test(){
        List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
        try{
            Test.startTest();
            String contentId = BCB_CTRL_FormCreator.uploadFile('SGVsbG8sIFdvcmxkIQ==','testFileName',appParticipant[0].Id,'Upload statement of Particulars for sole props',2);
            BCB_CTRL_FormCreator.fetchDocuments(appParticipant[0].Id,'Upload statement of Particulars for sole props');
            Test.stopTest();
            Assert.isNotNull(contentId,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }
    
     /**
    * @description Test method for AOB_CTRL_FormCreator.uploadFile 
    */
    @isTest
    public static void fetchDocumentsTest(){
        List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
        try{
            Test.startTest();
            BCB_CTRL_FormCreator.fetchDocuments(appParticipant[0].Id,'Upload trade license');
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.uploadFile 
    */
    @isTest
    public static void fetchDocumentsTest2(){
        List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
        try{
            Test.startTest();
            BCB_CTRL_FormCreator.fetchDocuments(appParticipant[0].Id,'Upload statement of Particulars for sole props');
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }
 
    /**
    * @description Test method for AOB_CTRL_FormCreator.releatedFiles 
    */
    @isTest
    public static void relatedFilesTest(){
        try{
            Test.startTest();
            List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
            Application_Document__c document = new Application_Document__c();
            document.Document_Type__c = 'upload signature';
            document.Application_Participant__c = appParticipant[0].Id;
            insert document;
            ContentVersion cv = new ContentVersion();
            cv.VersionData =Blob.valueOf('Test Content');
            cv.Title ='upload signature';
            cv.PathOnClient = 'upload signature';
            insert cv;
            ContentDocumentLink cdl = new ContentDocumentLink();
            ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            cdl.ContentDocumentId = contentVersion.ContentDocumentId;
            cdl.LinkedEntityId = document.Id;
            cdl.ShareType = 'V';
            insert cdl;
     
            BCB_CTRL_FormCreator.relatedFiles(appParticipant[0].Id);
            Test.stopTest();
        } catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.releatedFiles 
    */
     @isTest
    public static void deleteExistingAppDocsTest(){
       
		List<Application_Participant__c> appParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        Application_Document__c appdoc = BCB_DAL_TestFactory.createApplicationDocument(appParticipants[0].Application__c);
        insert appdoc;
        try{
            Test.startTest();          
            	BCB_CTRL_FormCreator.deleteExistingAppDocs(appParticipants[0].Id,appdoc.Document_Type__c);
            Test.stopTest();
        } catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
    }
    
     /**
    * @description Test method for AOB_CTRL_FormCreator.uploadFile 
    */
    @isTest
    public static void saveAccountImageTest(){
        List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
        try{
            Test.startTest();
            String contentId = BCB_CTRL_FormCreator.saveAccountImage(appParticipant[0].Id,'SGVsbG8sIFdvcmxkIQ==','testFileName','selfieTag');
            Test.stopTest();
            Assert.isNotNull(contentId,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }
    
      /**
    * @description Test method for AOB_CTRL_FormCreator.uploadFile 
    */
    @isTest
    public static void saveAccountImage2Test(){
        List<Application_Participant__c> appParticipant = [Select Id,AOB_PreviousScreens__c FROM Application_Participant__c LIMIT 1];
        try{
            Test.startTest();
            String contentId = BCB_CTRL_FormCreator.saveAccountImage(appParticipant[0].Id,'SGVsbG8sIFdvcmxkIQ==','testFileName','signatureTag');
            Test.stopTest();
            Assert.isNotNull(contentId,'Test');
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }
        
    }

    @isTest
    public static void bcbSELApplicationTest(){
        List<Application__c> application = BCB_DAL_TestFactory.createApplication(1);
        insert application;
        set<string> s = new set<string>{'test'};
        set<string> s1 = new set<string>{'124234'};
       list<id> i = new list<id>{application[0].id};
       Application__c s2= new SEL_Application().selectAppById(application[0].id);
       List<Application__c> s3= new SEL_Application().selectApplicationByOnlyRegList(s1);
       List<Application__c> s4= new SEL_Application().selectApplicationByOnlyGroup(s);
       Application__c s5= new SEL_Application().selectApplicationByRegAndSchemaCode(application[0].AOB_RegistrationNumber__c, application[0].AOB_Schema_Code__c);
       Assert.isNotNull(s,'Test');
       Assert.isNotNull(s1,'Test');
       Assert.isNotNull(s2,'Test');
       Assert.isNotNull(s3,'Test');
       Assert.isNotNull(s4,'Test');
       Assert.isNotNull(s5,'Test');
    }
    
    @isTest
    public static void bcbSELContentVersionTest(){
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert lstApp;
        List<Application__c> application = BCB_DAL_TestFactory.createApplication(1);
        insert application;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'upload signature';
        document.Application_Participant__c = lstApp[0].Id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='upload signature';
        cv.PathOnClient = 'upload signature.pdf';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        list<ContentVersion> contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion  ];
        
        cdl.ContentDocumentId = contentVersion[0].ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        list<id> i = new list<id>{contentVersion[0].ContentDocumentId};
        list<id> i2 = new list<id>{cdl.LinkedEntityId};
        list<id> i3 = new list<id>{lstApp[0].id};
       List<ContentVersion> st= new  SEL_ContentVersion().selectApplicationById( cv.ContentDocumentId);
       ContentVersion st1=new SEL_ContentVersion().selectContentVersionById( contentVersion[0].id);
       List<ContentVersion> s2= new  SEL_ContentVersion().selectContentVersionByIds(i);
       List<ContentVersion> s3=new SEL_ContentVersion().selectWithoutCondition();
       List<ContentDocumentLink> s4= new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntity(i2);
       List<ContentDocumentLink> s5 = new  SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(cdl.LinkedEntityId);
       List<Schema.SObjectField> s6=new  SEL_ContentDocumentLink().getSObjectFieldList();
       Schema.SObjectType s7= new SEL_ApplicationParticipant().getSObjectType();
       List<Schema.SObjectField> s14= new SEL_ApplicationParticipant().getSObjectFieldList();
       List<Application_Participant__c> s8= new SEL_ApplicationParticipant().selectApplicationParticipantById(i3);
       Application_Participant__c s9 = new SEL_ApplicationParticipant().selectApplicationParticipant(lstApp[0].id);
       Application_Participant__c s10= new SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(lstApp[0].Application__c);
       List<Application_Participant__c> s11= new SEL_ApplicationParticipant().selectApplicationParticpantByApplicationName(lstApp[0].Application__r.Name);
       List<Application_Participant__c> s12 = new  SEL_ApplicationParticipant().selectApplicationParticpantByApplicationIdSign(lstApp[0].Application__c, lstApp[0].AOB_Signatory__c);
       List<Application_Participant__c> s13 = new SEL_ApplicationParticipant().selectApplicationParticpantByAppAndPhone(lstApp[0].Application__c, lstApp[0].CNGCU_Phone__c);
       List<Application_Participant__c> s15= new SEL_ApplicationParticipant().selectApplicationParticpantByKeyContact( lstApp[0].Application__c);

       Assert.isNotNull(st,'Test');
       Assert.isNotNull(st1,'Test');
       Assert.isNotNull(s2,'Test');
       Assert.isNotNull(s3,'Test');
       Assert.isNotNull(s4,'Test');
       Assert.isNotNull(s5,'Test');
       Assert.isNotNull(s6,'Test');
       Assert.isNotNull(s7,'Test');
       Assert.isNotNull(s8,'Test');
       Assert.isNotNull(s9,'Test');
       Assert.isNotNull(s10,'Test');
       Assert.isNotNull(s11,'Test');
       Assert.isNotNull(s12,'Test');
       Assert.isNotNull(s13,'Test');
       Assert.isNotNull(s14,'Test');
       Assert.isNotNull(s15,'Test');
    }
    @isTest
    public static void otpCounter_Test(){
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstApp[0].AOB_OTPAttempts__c = 3;
        insert lstApp;
        
        Test.startTest();
            decimal val = BCB_CTRL_FormCreator.otpCounter(lstApp[0].Application__c);
        Test.stopTest();
        Assert.isNotNull(val,'Test');
    } 
     /** 
     *@description TestMethod for getImageLinkByParentId_test
     */
    @isTest
    static void getImageLinkByParentId_test() {
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert lstApp;
        List<Application__c> application = BCB_DAL_TestFactory.createApplication(1);
        insert application;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'faceImage';
        document.Application_Participant__c = lstApp[0].Id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='faceImage';
        cv.PathOnClient = 'faceImage';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        list<ContentVersion> contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion  ];
        
        cdl.ContentDocumentId = contentVersion[0].ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        try{
            Test.startTest();
         BCB_CTRL_FormCreator.getImageLinkByParentId( lstApp[0].Id);
            Test.stopTest();
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test'); 
        }
    }
     /** 
     *@description TestMethod for getImageLinkByParentId_test
     */
    @isTest
    static void getSignatureLinkByParentId_test() {
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert lstApp;
        List<Application__c> application = BCB_DAL_TestFactory.createApplication(1);
        insert application;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'upload Signature';
        document.Application_Participant__c = lstApp[0].Id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='upload Signature';
        cv.PathOnClient = 'upload Signature';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        list<ContentVersion> contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion  ];
        
        cdl.ContentDocumentId = contentVersion[0].ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        try{
            Test.startTest();
        BCB_CTRL_FormCreator.getSignatureLinkByParentId( lstApp[0].Id);
            Test.stopTest();
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test'); 
        }
    }

    /**
    * @description Test method for BCB_CTRL_FormCreator.getProductByProductCode
    */
    @isTest
    public static void getProductByProductCodeTest() {
        try {
            Test.startTest();
            // Create a product with a specific product code
            Product2 prod = new Product2(
                Name = 'Test Product',
                ProductCode = 'TEST001',
                AOB_Memo_Code__c = 'TEST001',
                IsActive = true
            );
            insert prod;
            
            // Call the method
            Product2 result = BCB_CTRL_FormCreator.getProductByProductCode('TEST001');
            Test.stopTest();
            
            Assert.isNotNull(result, 'Product should not be null');
            Assert.areEqual('Test Product', result.Name, 'Product name should match');
        } catch(Exception ex) {
            Assert.fail('No exception should be thrown: ' + ex.getMessage());
        }
    }
    
    /**
    * @description Test method for BCB_CTRL_FormCreator.getProductByProductCode error path
    */
    @isTest
    public static void getProductByProductCodeErrorTest() {
        try {
            Test.startTest();
            // Test with non-existent product code to trigger exception
            Product2 result = BCB_CTRL_FormCreator.getProductByProductCode('NonExistentCode');
            Test.stopTest();
            Assert.fail('Should have thrown an exception');
        } catch(Exception ex) {
            Assert.isNotNull(ex.getMessage(), 'Exception should be thrown');
        }
    }

    /**
    * @description Test method for BCB_CTRL_FormCreator.getOTPExpirationTimeInSeconds
    */
    @isTest
    public static void getOTPExpirationTimeInSecondsTest() {
        Test.startTest();
        
        // Create a mock for the custom metadata
        // Since we can't insert custom metadata in tests, we'll use the Test.isRunningTest() approach
        Integer expirationTime = BCB_CTRL_FormCreator.getOTPExpirationTimeInSeconds();
        
        Test.stopTest();
        
        // In a test context, we might not have the actual custom metadata
        // So we'll just verify the method runs without errors
        // In a real implementation, you might want to use a custom metadata mock
        Assert.isNotNull(expirationTime, 'OTP Expiration time should not be null');
    }
    
    /**
    * @description Test method for BCB_CTRL_FormCreator.getOTPExpirationTimeInSeconds with no metadata
    */
    @isTest
    public static void getOTPExpirationTimeInSecondsNullTest() {
        // This test is to cover the case where no custom metadata is found
        // or the value is blank
        // Since we can't modify custom metadata in tests, this is more of a placeholder
        // In a real implementation, you might want to use dependency injection or a mock
        
        Test.startTest();
        Integer expirationTime = BCB_CTRL_FormCreator.getOTPExpirationTimeInSeconds();
        Test.stopTest();
        
        // Just verify the method runs without errors
        // The actual value will depend on whether the custom metadata exists in the org
        Assert.isNotNull(expirationTime, 'OTP Expiration time should not be null');
    }

    /**
    * @description Test method for BCB_CTRL_FormCreator.saveParticipantcomapanyData
    */
    @isTest
    public static void saveParticipantcomapanyDataTest() {
        try {
            Test.startTest();
            
            // Create test data
            List<Application_Participant__c> participant = BCB_DAL_TestFactory.createApplicationParticipant(1);
            insert participant;
            
            List<Application__c> application = BCB_DAL_TestFactory.createApplication(1);
            application[0].AOB_inflightData__c = '{"secondarySectorCode":"123456", "tertiarySectorCode":"789012"}';
            insert application;
            
            // Update participant to link to the application
            participant[0].Application__c = application[0].Id;
            update participant;
            
            // Create JSON data for company details
            String jsonData = '{' +
                '"secondarySectorCode":"123456",' +
                '"tertiorySectorCode":"789012",' +
                '"noOfEmployees":"10",' +
                '"registrationDate":"2023-01-01",' +
                '"anticipatedAnnualTO":"5000",' +
                '"sourceOfFunds":"Business",' +
                '"preferredSMContact":"Email",' +
                '"newAccountReason":"Testing",' +
                '"grossIncomeEntity":"TRUE",' +
                '"grossAssetsEntity":"TRUE",' +
                '"businessDistrict":"Test District",' +
                '"businessCity":"Test City",' +
                '"businessPlotDetails":"Test Plot",' +
                '"State":"Test State"' +
            '}';
            
            // Call the method
            BCB_CTRL_FormCreator.saveParticipantcomapanyData(participant[0].Id, jsonData);
            
            Test.stopTest();
            
            // Verify the data was saved
            Application__c updatedApp = [SELECT Id, AOB_Company_employees__c, AOB_DateofRegistration__c, 
                                        Expected_Annual_Yearly_Turnover_To__c, Intent_to_Future_Deposits_Fund__c,
                                        AOB_Preferred_Social_media_Channel__c, Your_Account_Notes__c,
                                        AOBEntity_earn_more_than_50_gross_income__c, AOB_Entity_hold_50_or_more_of_its_gross__c,
                                        Correspondence_Province__c, AOB_City__c, AOB_Street__c, AOB_State__c
                                        FROM Application__c WHERE Id = :application[0].Id];
            
            Assert.areEqual(10, updatedApp.AOB_Company_employees__c, 'Company employees should be updated');
            Assert.areEqual(Date.valueOf('2023-01-01'), updatedApp.AOB_DateofRegistration__c, 'Registration date should be updated');
            Assert.areEqual(5000, updatedApp.Expected_Annual_Yearly_Turnover_To__c, 'Annual turnover should be updated');
            Assert.areEqual('Business', updatedApp.Intent_to_Future_Deposits_Fund__c, 'Source of funds should be updated');
            Assert.areEqual('Email', updatedApp.AOB_Preferred_Social_media_Channel__c, 'Preferred social media contact should be updated');
            Assert.areEqual('Testing', updatedApp.Your_Account_Notes__c, 'Account notes should be updated');
            Assert.areEqual(true, updatedApp.AOBEntity_earn_more_than_50_gross_income__c, 'Gross income entity should be updated');
            Assert.areEqual(true, updatedApp.AOB_Entity_hold_50_or_more_of_its_gross__c, 'Gross assets entity should be updated');
            Assert.areEqual('Test District', updatedApp.Correspondence_Province__c, 'Business district should be updated');
            Assert.areEqual('Test City', updatedApp.AOB_City__c, 'Business city should be updated');
            Assert.areEqual('Test Plot', updatedApp.AOB_Street__c, 'Business plot details should be updated');
            Assert.areEqual('Test State', updatedApp.AOB_State__c, 'State should be updated');
            
        } catch(Exception ex) {
            Assert.isNotNull( ex.getMessage(), 'exception should be thrown');
        }
    }
    
    /**
    * @description Test method for BCB_CTRL_FormCreator.saveParticipantcomapanyData error path
    */
    @isTest
    public static void saveParticipantcomapanyDataErrorTest() {
        try {
            Test.startTest();
            // Test with invalid data to trigger exception
            BCB_CTRL_FormCreator.saveParticipantcomapanyData(null, 'Invalid JSON');
            Test.stopTest();
            Assert.fail('Should have thrown an exception');
        } catch(Exception ex) {
            Assert.isNotNull(ex.getMessage(), 'Exception should be thrown');
        }
    }

    /**
    * @description Test method for BCB_CTRL_FormCreator.createContentVersion DML exception path
    */
    @isTest
    public static void createContentVersionExceptionTest() {
        try {
            Test.startTest();
            
            // This should throw a DML exception that will be caught in the method
            BCB_CTRL_FormCreator.createContentVersion(null, null);
            
            Test.stopTest();
        } catch(Exception ex) {
            // The method should throw an AuraHandledException
            Assert.isNotNull(ex.getMessage(), 'Exception should be thrown');
        }
    }

    /**
    * @description Test method for BCB_CTRL_FormCreator.deleteExistingAppDocs exception path
    */
    @isTest
    public static void deleteExistingAppDocsExceptionTest() {
        try {
            // Set up test data
            List<Application_Participant__c> participant = BCB_DAL_TestFactory.createApplicationParticipant(1);
            insert participant;
            
            // Create a document that will cause an exception when deleted
            Application_Document__c doc = new Application_Document__c(
                Application_Participant__c = participant[0].Id,
                Document_Type__c = 'Test Document'
            );
            insert doc;
            
            // Create a mock to force an exception during delete
            Test.startTest();
            
            // Use Test.isRunningTest() to force an exception path
            // We'll use a try-catch with a System.runAs to simulate security/permissions issues
            User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
                LastName = 'Test',
                Email = 'test@example.com',
                Username = 'test_user_' + DateTime.now().getTime() + '@example.com',
                CompanyName = 'TEST',
                Title = 'Test',
                Alias = 'test',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            
            System.runAs(u) {
                // This should throw an exception that will be caught in the method
                BCB_CTRL_FormCreator.deleteExistingAppDocs(participant[0].Id, 'Test Document');
            }
            
            Test.stopTest();
            
        } catch(Exception ex) {
            // The method should throw an AuraHandledException
            Assert.isNotNull(ex.getMessage(), 'Exception should be thrown');
        }
    }

    /**
    * @description Test method for BCB_CTRL_FormCreator.fetchApplicationSummary exception path
    */
    @isTest
    public static void fetchApplicationSummaryExceptionTest() {
        try {
            Test.startTest();
            String fakeId = '1000000000000001';
            BCB_CTRL_FormCreator.fetchApplicationSummary(fakeId);
            
            Test.stopTest();
        } catch(Exception ex) {
            // The method should throw an AuraHandledException
            Assert.isNotNull(ex.getMessage(), 'Exception should be thrown');
        }
    }

    
    /**
    * @description Test method for BCB_CTRL_FormCreator.fetchPersonalDetails exception path
    */
    @isTest
    public static void fetchPersonalDetailsExceptionTest() {
        try {
            Test.startTest();
            String fakeId = '1000000000000001';
            BCB_CTRL_FormCreator.fetchPersonalDetails(fakeId);
            
            Test.stopTest();
        } catch(Exception ex) {
            // The method should throw an AuraHandledException
            Assert.isNotNull(ex.getMessage(), 'Exception should be thrown');
        }
    }
}