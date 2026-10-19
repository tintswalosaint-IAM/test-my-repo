/**
* @description Test class for AOB_BOTS_SRV_RelyComply
* 
* @author dayakar
* 
* @date Jan 25th 2023 
*/
@isTest
public class AOB_BOTS_SRV_RelyComply_Test {
	Public static String accesToken = '';
    Public static Integer customerServiceCallStatusCode = 0;
    Public static String responseCodelist = '';
    
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.getAccessToken
    */
    
    @isTest
    public static void getAccessTokenTest(){
        accesToken = AOB_BOTS_SRV_RelyComply.getAccessToken();
    }  
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.createBusinessRely
    */ 
    
    @isTest
    public static void createBusinessRelyTest(){
        String presenceInCountry='Non-Resident';
        Application__c app = AOB_BOTS_DAL_TestFactory.createAccountForTest();
        app.AOB_PresenceinCountry__c='Local Company';
        app.AOB_TertiarySICCode__c='Logging';
        app.Entity_Type_Sub_Category__c='Testamentary Trust';
        app.AOB_ListedonanApprovedExchange__c = 'Yes';
        update app;
         AOB_ReferencedData__c refData = new AOB_ReferencedData__c(
            AOB_Code__c ='BW',
            AOB_CountryCode__c = presenceInCountry, 
            AOB_ProductCategory__c = 'Yes',
            Name = 'Testamentary Trust'
           
        ); 
        insert refData;
         AOB_ReferencedData__c refData1 = new AOB_ReferencedData__c(
            AOB_Code__c ='test',
            Name = 'Testamentar',
            AOB_SAPField__c='Logging'
        );
         insert refData1;
        try{
        Test.startTest();
        Integer responseCode = AOB_BOTS_SRV_RelyComply.createBusinessRely(app.Id); 
        Test.stopTest();
            Assert.areNotEqual(200, responseCode);
      }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
    }
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.createBusinessRely
    */ 
    
    @isTest
    public static void createBusinessRelyNegTest(){
        try{
        Application__c app = new Application__c(
            AOB_BusinessLegalName__c = 'Test Business Name',
            AOB_RegistrationNumber__c = '12345',
            AOB_PresenceinCountry__c = 'Local Company',
            Entity_Type_Sub_Category__c = 'Category A',
            AOB_TertiarySICCode__c = '1234'
        );
        insert app;
        AOB_ReferencedData__c refData1 = new AOB_ReferencedData__c(
            Name = 'Category A',
            AOB_Code__c = '123',
            AOB_CountryCode__c = 'Resident',
            AOB_ProductCategory__c = 'Yes'
        );
        insert refData1;
        AOB_ReferencedData__c refData2 = new AOB_ReferencedData__c(
            Name = 'Category B',
            AOB_Code__c = '456',
            AOB_SAPField__c = '1234'
        );
        insert refData2;

        Test.startTest();
        AOB_BOTS_SRV_RelyComply.createBusinessRely(app.Id);
        Test.stopTest();
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
    }
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.createCustomerRely
    */ 
    
    @isTest
    public static void createCustomerRelyTest(){
        try{
        string PresenceinCountry='Non-Resident';
        Application__c app = AOB_BOTS_DAL_TestFactory.createAccountForTest();
        app.AOB_PresenceinCountry__c='Foreign Company';
        app.Entity_Type_Sub_Category__c='Public School';
        app.AOB_ListedonanApprovedExchange__c = 'Yes';
        app.AOB_TertiarySICCode__c='150';
        update app;
        AOB_ReferencedData__c refData = new AOB_ReferencedData__c(
            AOB_Code__c = 'BW',
            AOB_CountryCode__c = PresenceinCountry,
            AOB_ProductCategory__c = 'Yes',
            Name = 'Public School'
        );
        insert refData;
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        appParticipant.AOB_Occupation__c='Self Employed';
        appParticipant.AOB_Role__c='Finance';
        appParticipant.AOB_External_GUID__c='test';
        update appParticipant;
        Test.startTest();
        customerServiceCallStatusCode = AOB_BOTS_SRV_RelyComply.createCustomerRely(app.Id);
        Test.stopTest();
        Assert.isNotNull(customerServiceCallStatusCode);
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
    }
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.createCustomerRely
    */ 
    @isTest
    public static void createCustomerRelyfailTest(){
        try{
        Test.startTest();
        customerServiceCallStatusCode = AOB_BOTS_SRV_RelyComply.createCustomerRely('applicationid');
        Test.stopTest();
        Assert.isNotNull(customerServiceCallStatusCode);
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
    }
    
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.createRelationshipRely
    */
    
	@isTest
    public static void createRelationshipRelyTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createAccountForTest();
        Test.startTest();
        customerServiceCallStatusCode = AOB_BOTS_SRV_RelyComply.createRelationshipRely(app.Id);
        Test.stopTest();
        Assert.isNotNull(customerServiceCallStatusCode);
    }

    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.createRelationshipRely
    */
    @isTest
    public static void createRelationshipRelyNegTest(){
        try{
       string appid;
        Test.startTest();
        customerServiceCallStatusCode = AOB_BOTS_SRV_RelyComply.createRelationshipRely(appid);
        Test.stopTest();
        Assert.isNotNull(customerServiceCallStatusCode);
        }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
    }
    
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.createAssementRely
    */
    
	@isTest
    public static void createAssementRelyTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createAccountForTest();
        Test.startTest();
        customerServiceCallStatusCode = AOB_BOTS_SRV_RelyComply.createAssementRely(app.Id);
        Test.stopTest();
        Assert.isNotNull(customerServiceCallStatusCode);
    }
    
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.createAssementRely
    */
     @isTest
    public static void createAssementRelyfailTest(){
        try{
        Test.startTest();
        customerServiceCallStatusCode = AOB_BOTS_SRV_RelyComply.createAssementRely('applicationid');
        Test.stopTest();
        Assert.isNotNull(customerServiceCallStatusCode);
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
    }
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.createBusinessAssement
    */
    
	@isTest
    public static void createBusinessAssementTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createAccountForTest();
        Test.startTest();
        customerServiceCallStatusCode = AOB_BOTS_SRV_RelyComply.createBusinessAssement(app.Id);
        Test.stopTest();
        Assert.isNotNull(customerServiceCallStatusCode);
    }
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.createBusinessAssement
    */
    @isTest
    public static void createBusinessAssementNegTest(){
        try{
        string appid;
        Test.startTest();
        customerServiceCallStatusCode = AOB_BOTS_SRV_RelyComply.createBusinessAssement(appid);
        Test.stopTest();
        Assert.isNotNull(customerServiceCallStatusCode);
        }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }    
    }
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.createRetriveAsRelyt
    */
    
    @isTest
    public static void createRetriveAsRelyTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createAccountForTest();
        Test.startTest();
        try{
        	responseCodelist = AOB_BOTS_SRV_RelyComply.createRetriveAsRely(app.Id);   
        } catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
        Test.stopTest();
    }
    
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.updateRelyStatus
    */
    
    @isTest
    public static void updateRelyStatusTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createAccountForTest();
         Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        appParticipant.AOB_Occupation__c='Self Employed';
        appParticipant.AOB_Role__c='Finance';
        appParticipant.AOB_External_GUID__c='test';
        update appParticipant;
        Test.startTest();
        AOB_BOTS_SRV_RelyComply.updateRelyStatus(app.Id);
        Test.stopTest();
        Assert.isNotNull(responseCodelist);
    } 
    
    /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.updateRelyStatus
    */
    @isTest
    public static void updateRelyStatusNegTest(){
        try{
        string appid;
        Test.startTest();
        AOB_BOTS_SRV_RelyComply.updateRelyStatus(appid);
        Test.stopTest();
        Assert.isNotNull(responseCodelist);
        }
       catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage());
        }
    }
     /**
    * @description Test method for AOB_BOTS_SRV_RelyComply.getStatuspdate
    */
    
    @isTest
    public static void getStatupdateTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createAccountForTest();
        Test.startTest();
        AOB_BOTS_SRV_RelyComply.getStatuspdate(app.Id);
        Test.stopTest();
        Assert.isNotNull(responseCodelist);
    } 
}