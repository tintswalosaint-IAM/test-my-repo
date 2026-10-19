/**
* @description Ping Registration handler Test to create User and person account
*
* <p>DBP-1106</p>
*
* @author Asmae ESSBAI (aessbai@salesforce.com)
*
* @date Nov 3th 2020
*/
@isTest
public class AOB_PingRegistrationHandler_Test {  
    /**
	 * @description Test setup method to insert all Test data
	 */
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
    }
    /**
    * @description Simple direct test of the UpdateUser method.  Create the user first 
    * and then attempt to update some properties.
    **/ 
    @isTest
    private static void updateCommunityUserTest() { 
        AOB_PingRegistrationHandler handler = new AOB_PingRegistrationHandler();       
        //User communityUser = [SELECT Id,contactId,accountId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew', '0000000000','aaaa@a.com','0000000');    
        User admin = AOB_DAL_TestFactory.createUser('System Administrator', false);
        system.debug('Community User'+communityUser);
        UserRole r = [select id from UserRole limit 1];
        admin.UserRoleId = r.id;
        insert admin;
        Test.startTest();   
        data.LastName = 'Tom';
    
        system.runAs(admin){
            
            try {
                Account acc1 = AOB_DAL_TesTFactory.createPersonAccount();
                //Account acc =[SELECT Id, PersonContactId FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id = :communityUser.contactId)];
    			handler.updateUser(communityUser.Id, acc1.Id, data);
            } catch (Exception e) {
                System.debug(e);
            }
             try {
                Account acc1 = AOB_DAL_TesTFactory.createPersonAccount();
        		handler.updateUser(communityUser, acc1, data.attributeMap);
                
            } catch (Exception e) {
                System.debug(e);
            }
        }
        Test.stopTest();
    }
    
   
    /**
    * @description Helper method to Validate the the User we've created
    * @param theUser - the User that we created
    * @param data - the original AuthData supplied by FaceBook
    */ 
    private static void validate(User theUser,Auth.UserData data) {
        System.Assert(theUser != null,'User must not be null');
        System.AssertEquals(theUser.email,data.email,'Email address must be the same');
    }
    
    /**
    * @description Helper method to instantiate the handler UserData
    * @param email
    * @param lastName
    * @param firstName
    * @param id
    * @param sub
    * @param num
    * @return Auth.UserData that looks like what we expect from FaceBook
    */ 
    private static Auth.UserData createUser(String email,String lastName, String firstName, String id, String sub, String num) {
         Map<String, String> attributeMap =new Map<String,String>();
	     attributeMap.put(AOB_Constants.PING_LAST_NAME, lastName);
         attributeMap.put(AOB_Constants.PING_FIRST_NAME, firstName);
         attributeMap.put(AOB_Constants.PING_EMAIL, email);
         attributeMap.put(AOB_Constants.ID_STRING, id);
         attributeMap.put(AOB_Constants.PING_SUB, sub);
         attributeMap.put(AOB_Constants.PING_BPID, num);
         attributeMap.put(AOB_Constants.PING_BPGUID, AOB_Utils.generateGUID());
         String identifier = lastName+System.currentTimeMillis();
         String locale = 'en_US';
         return new Auth.UserData(identifier,
               firstName,
               lastName,
              '', // fullname
               email,
               '', // link
               '', // userName
               locale,
               '', // provider
               '', // siteLoginUrl
               attributeMap); 
            
    }
        
    /**
    * @description Simple scenario to create a Community user
    */ 
    @isTest
    private static void createCommunityUserTest() {
         AOB_PingRegistrationHandler handler = new AOB_PingRegistrationHandler();
        Auth.UserData data = createUser('tjones@example3.com','Thomas','Jones-Drew', '2222222222','aaaaa','1111111'); 
        User admin = AOB_DAL_TestFactory.createUser('System Administrator', true);
        System.runAs(admin){
            Test.startTest();
            String theCommunityId = '';
            data.attributeMap.put('sfdc_networkid',theCommunityId);
            User theUser = handler.createUser(null, data);
            validate(theUser,data);  
            // Additional validations for Community User
            System.Assert(theUser.ContactId != null,'Contact must be set for user'); 
            //Test SIYA
            data.attributeMap.put(AOB_Constants.ID_STRING,theUser.id);
			//handler.createUser(null, data);
            Test.stopTest();      
        }            
    }
    
      /**
    * @description Simple scenario to create a Community user
    */ 
   /* @isTest
    private static void createCommunityUserFailTest() {
         AOB_PingRegistrationHandler handler = new AOB_PingRegistrationHandler();
        Auth.UserData data = createUser('tjones@example3.com','Thomas','Jones-Drew', '99d1de31-d147-4f87-8112-c5600890a268','aaaaa','1111111'); 
        User admin = AOB_DAL_TestFactory.createUser('System Administrator', true);
        System.runAs(admin){
            Test.startTest();
            String theCommunityId = '';
            data.attributeMap.put('sfdc_networkid',theCommunityId);
            User theUser = handler.createUser(null, data);
            validate(theUser,data);  
            // Additional validations for Community User
            System.Assert(theUser.ContactId != null,'Contact must be set for user'); 
            //Test SIYA
            data.attributeMap.put(AOB_Constants.ID_STRING,theUser.id);
			//handler.createUser(null, data);
            Test.stopTest();      
        }            
    }*/
    
    /**
    * @description Simple scenario to update a Community user
    */ 
   /*  @isTest
    private static void createCommunityUserTest2() {
         AOB_PingRegistrationHandler handler = new AOB_PingRegistrationHandler();
        User testUser = AOB_DAL_TestFactory.createCommunityUser();
        Auth.UserData data = createUser('tjones@example3.com','Thomas','Jones-Drew', '2222222222','aaaaa','1111111'); 
        User admin = AOB_DAL_TestFactory.createUser('System Administrator', true);
        System.runAs(admin){
            Test.startTest();
            String theCommunityId = '';
            data.attributeMap.put('id',testUser.Id); //added
            data.attributeMap.put('sfdc_networkid',theCommunityId);
            User theUser = handler.createUser('test', data);
            validate(theUser,data);  
            // Additional validations for Community User
            System.Assert(theUser.ContactId != null,'Contact must be set for user'); 
            //Test SIYA
            data.attributeMap.put(AOB_Constants.ID_STRING,theUser.id);
			//handler.createUser(null, data);
            Test.stopTest();      
        }            
    }*/
    
  /*   @isTest
    private static void createCommunityUserFailureTest() {
         AOB_PingRegistrationHandler handler = new AOB_PingRegistrationHandler();
        Auth.UserData data = createUser('tjones@example3.com','Thomas','Jones-Drew', '2222222222','aaaaa','1111111'); 
        User admin = AOB_DAL_TestFactory.createUser('System Administrator', true);
        System.runAs(admin){
            Test.startTest();
            String theCommunityId = '';
            data.attributeMap.put('sfdc_networkid',theCommunityId);
            User theUser = handler.createUser(null, null);
            validate(theUser,data);  
            // Additional validations for Community User
            System.Assert(theUser.ContactId != null,'Contact must be set for user'); 
            //Test SIYA
            data.attributeMap.put(AOB_Constants.ID_STRING,theUser.id);
			//handler.createUser(null, data);
            Test.stopTest();      
        }            
    }
   */
    
}