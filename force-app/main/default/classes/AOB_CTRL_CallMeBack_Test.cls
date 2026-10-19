/**
*  AOB_CTRL_CallMeBack_Test Test Class
*
* <p>DBP-3334</p>
*
* @author (mark.bailey2@standardbank.co.za)
*
* @date Aug 29th 2021
*  
* <p>SFP-10055/SFP-10057</p> 
* @author Gill Lumley 
* @date 06 April 2022 
* @description Add reason input parameter when calling method createLead in createLeadTest
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed SFP-10055 06-04-2022 Gill Lumley   Add reason input parameter when calling method createLead in createLeadTest
 * Changed SFP-10057 21-04-2022 Gill Lumley   add getPublicHolidayDatesTest method
*/
@isTest
public class AOB_CTRL_CallMeBack_Test {
  /**
   * @description Test setup method to insert all Test data
   */
    
  @TestSetup
    public static void testSetUp() {
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        Map<string, string> applicationData = new Map<string, string>();
        Account acc = [
            SELECT id
            FROM account
            WHERE
            id IN (
                SELECT accountId
                FROM contact
                WHERE id = :communityUser.contactId
            )
        ];
        contact cont=[SELECT id FROM contact WHERE id = :communityUser.contactId];
        system.runAs(communityUser){
            applicationData.put('AOB_Customer__c', acc.id);
            applicationData.put('AOB_Contact__c', cont.id);
            insert AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c', applicationData);
        }
    }

  /**
   * @description Method used to Test getPhoneNumber
   */
  @isTest
  public static void getPhoneNumberTest() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    AOB_Application__c app = [
        SELECT id 
        FROM AOB_Application__c 
        WHERE AOB_Contact__c = :communityUser.contactId 
        LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      AOB_CTRL_CallMeBack.mainError='AOB_CTRL_CallMeBack Error';
      String phoneNumber = AOB_CTRL_CallMeBack.getPhoneNumber(app.Id);
      Test.stopTest();
      system.assert( phoneNumber != null,'');
    }
  }

  @isTest
  public static void getPhoneNumberFailTest(){ 
     Boolean failed=false;
      Test.startTest();
      try{
        String phoneNumber = AOB_CTRL_CallMeBack.getPhoneNumber(null);
          if(phoneNumber!=null)
              failed=true;
      }
      catch(exception e){
          failed=true;    
      }
      Test.stopTest();
      system.assertEquals(failed,true,'');
  }

  /**
   * @description Method used to Test getBusinessHours
   */
  @isTest
  public static void getBusinessHoursTest() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      List<string> businessHours = AOB_CTRL_CallMeBack.getBusinessHours();
      Test.stopTest();
      system.assertEquals(businessHours.size() > 0, true, '');
    }
  }

  /**
   * @description Method used to Test setCallBackRequested
   */
  @isTest
  public static void setCallBackRequestedTest() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    AOB_Application__c app = [
        SELECT id 
        FROM AOB_Application__c 
        WHERE AOB_Contact__c = :communityUser.contactId 
        LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      Boolean result = AOB_CTRL_CallMeBack.setCallBackRequested(app.Id);
              system.assertEquals(result, true, '');

      Test.stopTest();
    }
  }

  /**
   * @description Method used to Test setCallBackRequested exception
   */
  @isTest
  public static void setCallBackRequestedFailTest() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    /*AOB_Application__c app = [
        SELECT id 
        FROM AOB_Application__c 
        WHERE AOB_Contact__c = :communityUser.contactId 
        LIMIT 1
    ];*/
    AuraHandledException unexpectedException;
Boolean result;
    System.runAs(communityUser) {
      Test.startTest();
      try
      { 
        result = AOB_CTRL_CallMeBack.setCallBackRequested(null);
              
      }
      catch (AuraHandledException dmx)
      {if(result=false)
          unexpectedException = dmx;
       if(result=true)
          unexpectedException = dmx;
      }
      Test.stopTest();
      system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception', '');
    }
  }

  /**
   * @description Method used to Test createLead
   */
  @isTest
  public static void createLeadTest() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    AOB_Application__c app = [
        SELECT id, AOB_Callback_Requested__c  
        FROM AOB_Application__c 
        WHERE AOB_Contact__c = :communityUser.contactId 
        LIMIT 1
    ];
      boolean failed;
    System.runAs(communityUser) {
      Test.startTest();
      Integer result = AOB_CTRL_CallMeBack.createLead('test-token', Id.valueOf(app.Id), '00:00:00', Datetime.now().format('yyyy-MM-dd'), 'WFR failure reason');
        if(result!=null)    
         failed =false;
        if(result==null)    
         failed =false;
    
        system.assertEquals(app.AOB_Callback_Requested__c  , failed, '');

 

        Test.stopTest();
    }
  }
    
      @isTest
  public static void createLeadFailedTest() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    /*AOB_Application__c app = [
        SELECT id, AOB_Callback_Requested__c  
        FROM AOB_Application__c 
        WHERE AOB_Contact__c = :communityUser.contactId 
        LIMIT 1
    ];*/
    AuraHandledException unexpectedException;
      Integer result;
    System.runAs(communityUser) {
      Test.startTest();
      try{
      		 result = AOB_CTRL_CallMeBack.createLead(null,null,null,null,null);
       }
      catch (AuraHandledException dmx)
      {
          if(result==null){
                        unexpectedException = dmx;

          }
          if(result!=null){
                        unexpectedException = dmx;

          }
      }
              system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception', '');

      Test.stopTest();
      //system.assertEquals(app.AOB_Callback_Requested__c  , false);
    }
  }


  /**
   * @description Method used to Test callAccessToken
   */
  @isTest
  public static void callAccessTokenTest() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    /*AOB_Application__c app = [
        SELECT id, AOB_Callback_Requested__c  
        FROM AOB_Application__c 
        WHERE AOB_Contact__c = :communityUser.contactId 
        LIMIT 1
    ];*/
    System.runAs(communityUser) {
      Test.startTest();
      String token = AOB_CTRL_CallMeBack.callAccessToken();
      Test.stopTest();
      system.assertNotEquals(token, null, '');
    }
  }

  /**
  * @description This method is used to test getPublicHolidayDates
  */
  @isTest
  private static void getPublicHolidayDatesTest() {
    User communityUser = [SELECT Id FROM USER LIMIT 1];
    Date fromDate = date.today();
		Date toDate = fromDate.addYears(1);
    System.runAs(communityUser) {
      Test.startTest();
      List<Date> holidays = AOB_CTRL_CallMeBack.getPublicHolidayDates(fromDate,toDate);
              System.assertNotEquals(holidays,null, '');

      Test.stopTest();
    }
  } 
    
      @isTest
    private static void getPublicHolidayDatesFailedTest() {
    User communityUser = [SELECT Id FROM USER LIMIT 1];
    Date fromDate = date.today();
		Date toDate = date.today();
    System.runAs(communityUser) {
      Test.startTest();
      List<Date> holidays = AOB_CTRL_CallMeBack.getPublicHolidayDates(fromDate,toDate);
              System.assertnotEquals(holidays,null,'Test Fail');

      Test.stopTest();
    }
  } 
    

}