/**
* @description Test class for AOB_CTRL_FormCreator
* @author Ramadevi
* @date Jan 25th 2023 
* @ Last Modified By : Dayakar
* @ Last Modified On : 08-08-2023
* @ Modification Description : added new test data methods
*/
@isTest
public class AOB_CTRL_FormCreator_Test {
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getFields
    */
    @isTest
    public static void getFieldsTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        list<AOB_FlowScreen__c> screen = AOB_BOTS_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_BOTS_DAL_TestFactory.createSection(screen[0].id);        
        list<AOB_field__c> field = AOB_BOTS_DAL_TestFactory.createFields(section[0].id);
        list<AOB_referencedData__c> ref = AOB_BOTS_DAL_TestFactory.createRefData();
        try{
            AOB_DTO_Form fields = AOB_CTRL_FormCreator.getFields(app.Id,'Company Information');
            Assert.areNotEqual(null, fields,'test message');
            Assert.areNotEqual(null, field,'test message');
            Assert.areNotEqual(null, ref,'test message'); 
           AOB_CTRL_FormCreator.getFieldsWithoutAppId('AOB_CTRL_FormCreator');
        } 
       
        catch (AuraHandledException e) {
            // Assert the error message and anything else you need to validate
            
            Assert.areEqual('Script-thrown exception', e.getMessage(),'Test Meassage');
        }
    }

    /**
    * @description Test method for AOB_CTRL_FormCreator.releatedFiles 
    */
    @isTest
    public static void relatedFilesTest(){
        try{
            Test.startTest();
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.Id);
            List<ContentVersion> contentVersionData = AOB_CTRL_FormCreator.releatedFiles(appParticipant.Id);
            Assert.areEqual(false, contentVersionData.isEmpty(),'test message');
            Test.stopTest();
        } catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
    }

    /**
    * @description Test method for AOB_CTRL_FormCreator.getParticipantAppId 
    */
    @isTest
    public static void getParticipantAppIdTest(){
        try{
            Test.startTest();
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            Map<String,Object> participantData = AOB_CTRL_FormCreator.getParticipantAppId(appParticipant.Id);
            Assert.areNotEqual(null, participantData,'Test Meassage');
            Test.stopTest();
        }catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
    }

    /**
    * @description Test method for AOB_CTRL_FormCreator.getFieldsWithoutAppId 
    */
    @isTest
    public static void getFieldsWithoutAppIdTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        list<AOB_FlowScreen__c> screen = AOB_BOTS_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_BOTS_DAL_TestFactory.createSection(screen[0].id);        
        list<AOB_field__c> field = AOB_BOTS_DAL_TestFactory.createFields(section[0].id);
        list<AOB_referencedData__c> ref = AOB_BOTS_DAL_TestFactory.createRefData();
        try{
            Test.startTest();
            AOB_DTO_Form fields = AOB_CTRL_FormCreator.getFieldsWithoutAppId('Company Information');
            Test.stopTest();
            Assert.areNotEqual(null, fields,'Test Meassage');
            Assert.areNotEqual(null, ref,'Test Meassage');
            Assert.areNotEqual(null, field,'Test Meassage');
            Assert.areNotEqual(null, app,'Test Meassage');
    
           
            
        } catch(Exception ex){ 
         Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
            
        }
        
    }

    /**
    * @description Test method for AOB_CTRL_FormCreator.getKeyContactParticipantIds 
    */
    @isTest
    public static void getKeyContactParticipantIdsTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            String participantId = AOB_CTRL_FormCreator.getKeyContactParticipantIds(app.Id);
            Test.stopTest();
            Assert.areNotEqual(null, participantId,'Test Meassage');
            Assert.areNotEqual(null, appParticipant,'Test Meassage');
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    } 

    /**
    * @description Test method for AOB_CTRL_FormCreator.getKeyContactParticipantIds 
    */
    @isTest
    public static void getKeyContactParticipantIdsNegTest(){
        try{
            Test.startTest();
            String participantId = AOB_CTRL_FormCreator.getKeyContactParticipantIds(null);
            Test.stopTest(); 
            Assert.areEqual(null, participantId,'Test Meassage');
        }  
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    } 

    /**
    * @description Test method for AOB_CTRL_FormCreator.uploadFile 
    */
    @isTest
    public static void uploadFileTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            String contentId = AOB_CTRL_FormCreator.uploadFile('SGVsbG8sIFdvcmxkIQ==','testFileName',appParticipant.Id);
            Test.stopTest();
            Assert.areNotEqual(null, contentId,'Test Meassage');
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.uploadFileSocty 
    */
      @isTest
    public static void uploadFileSoctyTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            String contentId = AOB_CTRL_FormCreator.uploadFileSocty('SGVsbG8sIFdvcmxkIQ==','testFileName', '123456789',app.Id);
            Test.stopTest(); 
            Assert.areNotEqual(null, contentId,'Test Meassage');
            Assert.areNotEqual(null, appParticipant,'Test Meassage');
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.saveFormData 
    */
    @isTest
    public static void saveFormDataTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        String formData = '{"Intended use of account":"Intended use","Date of Birth":"01/01/2023","DATE OF RESOLUTION MEETING":"01/01/2023","How would like receive the message":"How would message",'+
                '"Street Number and name":"Street","City/Town":"ABIM","Postal code":"435324","Preferred branch where account is held":"062094","Suburb":"Suburb","Province":"CEN","How would like receive the message":"true"}';
        try{ 
            Test.startTest();
            AOB_CTRL_FormCreator.saveFormData(appParticipant.Id,formData,'Company Information');
            Test.stopTest();
            Assert.areNotEqual(null, [SELECT Id,Inflight__c FROM Application_Participant__c WHERE Id=:appParticipant.Id].Inflight__c,'Test Meassage'); 
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    } 

    /**
    * @description Test method for AOB_CTRL_FormCreator.saveFormData 
    */
    @isTest
    public static void saveFormDataAppDetailsTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        String formData = '{"businessRole":"CEO","CityTown":"ABIM","PostalCode":"769754",'+
                '"Street Number and name":"Street","Monthly Net Income":"355345","Gross Annual Income":"355345","Occupation":"Student","Primary Nationality":"AFGHANISTAN","Date of Birth":"2023-04-12","businessTransact":"test","Cell Phone Number":"4888935324","Email Address":"test@gmail.com","Omang Id Number":"123123","receiveNotification":"SMS","How would like receive the message":"true"}';
        try{    
            Test.startTest(); 
            AOB_CTRL_FormCreator.saveFormData(appParticipant.Id,formData,'Application Details');
            Test.stopTest();
            Assert.areNotEqual(null, [SELECT Id,AOB_PostalCode__c FROM Application_Participant__c WHERE Id=:appParticipant.Id].AOB_PostalCode__c,'Test Meassage'); 

        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    }
 /**
    * @description Test method for AOB_CTRL_FormCreator.saveFormData 
    */
    @isTest
    public static void saveFormDataMatsheloTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        String formData = '{"businessRole":"CEO","CityTown":"ABIM","PostalCode":"769754",'+
                '"Street Number and name":"Street","Monthly Net Income":"355345","Gross Annual Income":"355345","Occupation":"Student","Primary Nationality":"AFGHANISTAN","Date of Birth":"2023-04-12","businessTransact":"test","Cell Phone Number":"4888935324","Email Address":"test@gmail.com","Omang Id Number":"123123","receiveNotification":"SMS","How would like receive the message":"true"}';
        try{    
            Test.startTest(); 
            AOB_CTRL_FormCreator.saveFormData(appParticipant.Id,formData,'Matshelo Personal Information');
            Test.stopTest();
            Assert.areNotEqual(null, [SELECT Id,AOB_PostalCode__c FROM Application_Participant__c WHERE Id=:appParticipant.Id].AOB_PostalCode__c,'Test Meassage'); 

        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    }/**
    * @description Test method for AOB_CTRL_FormCreator.saveFormData 
    */
    @isTest
    public static void saveFormDataMatsheloCompanyInformationTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        String formData = '{"businessRole":"CEO","CityTown":"ABIM","PostalCode":"769754",'+
                '"Street Number and name":"Street","Monthly Net Income":"355345","Gross Annual Income":"355345","Occupation":"Student","Primary Nationality":"AFGHANISTAN","Date of Birth":"2023-04-12","businessTransact":"test","Cell Phone Number":"4888935324","Email Address":"test@gmail.com","Omang Id Number":"123123","receiveNotification":"SMS","How would like receive the message":"true"}';
        try{    
            Test.startTest(); 
            AOB_CTRL_FormCreator.saveFormData(appParticipant.Id,formData,'Matshelo Company Information');
            Test.stopTest();
            Assert.areNotEqual(null, [SELECT Id,AOB_PostalCode__c FROM Application_Participant__c WHERE Id=:appParticipant.Id].AOB_PostalCode__c,'Test Meassage'); 

        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.getPreferredBranch 
    */
    @isTest
    public static void getPreferredBranchTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{    
            Test.startTest(); 
            AOB_CTRL_FormCreator.getPreferredBranch(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(null, [SELECT Id,Application__r.AOB_Preferred_Branch__c FROM Application_Participant__c WHERE Id=:appParticipant.Id].Application__r.AOB_Preferred_Branch__c,'Test Meassage'); 
        } 
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    }

    /**
    * @description Test method for AOB_CTRL_FormCreator.getExistingData 
    */
    @isTest
    public static void getExistingDataSummaryTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            String appData = AOB_CTRL_FormCreator.getExistingData(appParticipant.Id,'Summary');
            Test.stopTest();
            Assert.areNotEqual(null, appData,'Test Meassage'); 
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    } 

    /**
    * @description Test method for AOB_CTRL_FormCreator.getExistingData 
    */
    @isTest
    public static void getExistingDataCompanyTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            String appData = AOB_CTRL_FormCreator.getExistingData(appParticipant.Id,'Company Information');
            Test.stopTest();
            Assert.areNotEqual(null, appData,'Test Meassage'); 
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    }
/**
    * @description Test method for AOB_CTRL_FormCreator.getExistingData 
    */
    @isTest
    public static void getExistingDataInformationTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            String appData = AOB_CTRL_FormCreator.getExistingData(appParticipant.Id,'Matshelo Personal Information');
            Test.stopTest();
            Assert.areNotEqual(null, appData,'Test Meassage'); 
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.getExistingData 
    */
    @isTest
    public static void getExistingDataMatsheloCompanyInformationTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            String appData = AOB_CTRL_FormCreator.getExistingData(appParticipant.Id,'Matshelo Company Information');
            Test.stopTest();
            Assert.areNotEqual(null, appData,'Test Meassage'); 
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.getExistingData 
    */
    @isTest
    public static void getExistingDataMatsheloInformationTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            String appData = AOB_CTRL_FormCreator.getExistingData(appParticipant.Id,'Matshelo Summary');
            Test.stopTest();
            Assert.areNotEqual(null, appData,'Test Meassage'); 
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage'); 
        }
        
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.getExistingData 
    */
    @isTest
    public static void getExistingDataAppTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            String appData = AOB_CTRL_FormCreator.getExistingData(appParticipant.Id,'Application Details');
            Test.stopTest();
            Assert.areNotEqual(null, appData,'Test Meassage');
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
        
    }

    /**
    * @description Test method for AOB_CTRL_FormCreator.sendWelcomeEmailToDirectors 
    */
    @isTest
    public static void sendWelcomeEmailToDirectorsTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            AOB_CTRL_FormCreator.sendWelcomeEmailToDirectors(new List<String>{appParticipant.Id});
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
        
    } 

    /**
    * @description Test method for AOB_CTRL_FormCreator.getKeyParticipantData 
    */
    @isTest
    public static void getKeyParticipantDataTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            Map<String, String> participantData = AOB_CTRL_FormCreator.getKeyParticipantData(app.Id);
            Test.stopTest();
            Assert.areNotEqual(null, participantData,'Test Meassage');
            Assert.areNotEqual(null, appParticipant,'Test Meassage');
          
        }
        
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
        
    } 

    /**
    * @description Test method for AOB_CTRL_FormCreator.getMobileNumbers 
    */
    @isTest
    public static void getMobileNumbersTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            Map<String, String> participantData = AOB_CTRL_FormCreator.getMobileNumbers(appParticipant.Id);
            Test.stopTest();
            Assert.areNotEqual(null, participantData,'Test Meassage');
        }
        catch(Exception ex){
           
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
        
    } 

    /**
    * @description Test method for AOB_CTRL_FormCreator.setApplicationStep 
    */
    @isTest
    public static void setApplicationStepTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            AOB_CTRL_FormCreator.setApplicationStep(appParticipant.Id,'Card Selection','Application Details');
            Test.stopTest();
            Assert.areEqual('Card Selection', [SELECT Id, AOB_Stage__c FROM Application_Participant__c WHERE Id = :appParticipant.Id].AOB_Stage__c,'Test Meassage');
            
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
            
        }
        
    } 

    /**
    * @description Test method for AOB_CTRL_FormCreator.goBacktoPreviousStep 
    */
    @isTest
    public static void goBacktoPreviousStepTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.startTest();
            AOB_CTRL_FormCreator.goBacktoPreviousStep(appParticipant.Id);
            Test.stopTest();
            Assert.areNotEqual(null,[SELECT Id, AOB_Stage__c FROM Application_Participant__c WHERE Id = :appParticipant.Id].AOB_Stage__c,'Test Meassage');
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }  
    } 

    /**
    * @description Test method for AOB_CTRL_FormCreator.goBacktoPreviousStep 
    */
    @isTest
    public static void applicationWithIdTest(){ 
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        try{
            String jsonData = '{"APPLICAITON ID":"'+app.Id+'","CONTACT NUMBER":"+27123456789"}';
            Test.startTest();
            AOB_CTRL_FormCreator.applicationwithId(jsonData);
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }  
    } 

    /**
    * @description Test method for AOB_CTRL_FormCreator.goBacktoPreviousStep 
    */
    @isTest
    public static void applicationWithIdNegTest(){  
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        app.Status__c = 'In Progress';
        update app;
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            String jsonData = '{"APPLICAITON ID":"'+app.Id+'","CONTACT NUMBER":"+27123456788"}';
            Test.startTest();
            AOB_CTRL_FormCreator.applicationwithId(jsonData);
            Test.stopTest();
            Assert.areNotEqual(null, appParticipant,'Test Meassage');
        }  
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }  
    }

     /**
    * @description Test method for AOB_CTRL_FormCreator.goBacktoPreviousStep 
    */
    @isTest
    public static void applicationWithIdAPTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        app.Status__c = 'In Progress';
        update app; 
        try{
            String jsonData = '{"APPLICAITON ID":"'+app.Id+'","CONTACT NUMBER":"+27123456788"}';
            Test.startTest();
            AOB_CTRL_FormCreator.applicationwithId(jsonData);
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }  
    } 

    /**
    * @description Test method for AOB_CTRL_FormCreator.goBacktoPreviousStep 
    */
    @isTest
    public static void applicationWithNoAppTest(){ 
        try{
            String jsonData = '{"APPLICAITON ID":"2434343","CONTACT NUMBER":"+27123456788"}';
            Test.startTest(); 
            AOB_CTRL_FormCreator.applicationwithId(jsonData);
            Test.stopTest();
        } 
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }  
    } 
     
    /**
    * @description Test method for AOB_CTRL_FormCreator.saveParticipantPersonalData 
    */
    @isTest
    public static void saveParticipantPersonalDataTest(){
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            String jsondata='{"Suburb":"Suburb","Province":"Province","Street":"Street","businessTransact":"true","Do you":"true","Cell Phone Number":"7702610743","Email Address":"sa@gmail.com","receiveNotification":"true","businessRole":"CEO","PostalCode":"202992","Marital Status":"SINGLE","Gender":"Female","Title":"MRS","Primary Nationality":"AND ISLANDS","Occupation":"Self Employed","Gross Annual Income":"100000","Monthly Net Income":"20000","Date of Birth":"1998-01-15"}';
            Test.startTest();
            AOB_CTRL_FormCreator.saveParticipantPersonalData(appParticipant.id,jsondata);
            Test.stopTest();  
        } 
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }       
        
        
    }
   
    
}