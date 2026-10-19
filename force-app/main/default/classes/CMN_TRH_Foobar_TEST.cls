/**
 * @description Test class is use to test the base object methods that support the INT_Trigger interface
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false)
private class CMN_TRH_Foobar_TEST {
  private static final String OBJECT_FOO = CMN_Foobar__c.SObjectType.getDescribe()
    .getLocalName();
  private static final String FIELD_PICKLIST = CMN_Foobar__c.CMN_Picklist__c.getDescribe()
    .getLocalName();

  /**
   * @description Static method to construct foo object
   *
   * @return foobar
   */
  public static CMN_Foobar__c getFoobar() {
    CMN_Foobar__c foobar = new CMN_Foobar__c();
    return foobar;
  }

  /**
   * @description To test the INT_Trigger on insertion
   */
  @IsTest
  private static void testInsert() {
    CMN_Foobar__c f = getFoobar();

    Test.startTest();

    CMN_DAL_SObjectDomain.insertDBObject(f);

    Test.stopTest();

    List<CMN_Foobar__c> newFoobars = CMN_DAL_Foobar.getAll();
    System.assertEquals(
      2,
      newFoobars.size(),
      'The trigger either executed multiple times or did not fire'
    );
  }

  /**
   * @description Tests the framework when an exception is thrown by the Trigger Handler
   */
  @IsTest
  private static void throwException() {
    CMN_Foobar__c f = getFoobar();

    CMN_TRH_Foobar.INSERT_NEW_FOO = false;
    CMN_TRH_Foobar.INITIATE_EXCEPTION = true;

    Test.startTest();

    try {
      CMN_DAL_SObjectDomain.insertDBObject(f);
      System.assert(false, 'No Exception Thrown');
    } catch (Exception error) {
      System.assert(true, 'Exception thrown as expected');
    }

    Test.stopTest();
  }

  /**
   * @description To test the INT_Trigger on insertion
   */
  @IsTest
  private static void disableTrigger() {
    CMN_Foobar__c f = getFoobar();

    CMN_DAL_DataFactory.disableTrigger(CMN_TRH_Foobar.class.getName());

    Test.startTest();

    CMN_DAL_SObjectDomain.insertDBObject(f);

    Test.stopTest();

    List<CMN_Foobar__c> newFoobars = CMN_DAL_Foobar.getAll();
    System.assertEquals(
      1,
      newFoobars.size(),
      'Trigger Fired and created additional row'
    );
  }

  /**
   * @description To test the INT_Trigger on deletion
   */
  @IsTest
  private static void testDelete() {
    CMN_Foobar__c f = getFoobar();

    CMN_DAL_SObjectDomain.insertDBObject(f);

    Test.startTest();

    CMN_DAL_SObjectDomain.deleteDBObject(f);

    Test.stopTest();
  }

  /**
   * @description To test the INT_Trigger on undelete
   */
  @IsTest
  private static void testUndelete() {
    CMN_Foobar__c f = getFoobar();

    CMN_DAL_SObjectDomain.insertDBObject(f);

    CMN_DAL_SObjectDomain.deleteDBObject(f);

    Test.startTest();

    CMN_DAL_SObjectDomain.undeleteDBObject(f);

    Test.stopTest();
  }

  /**
   * @description To test the INT_Trigger on updation
   */
  @IsTest
  private static void testUpdate() {
    List<String> pickvals = CMN_UTIL_System.getPicklistValues(
      OBJECT_FOO,
      FIELD_PICKLIST
    );
    CMN_Foobar__c f = getFoobar();

    f.CMN_Picklist__c = pickvals[0];
    CMN_DAL_SObjectDomain.insertDBObject(f);

    Test.startTest();

    f.CMN_Picklist__c = pickvals[1];
    CMN_DAL_SObjectDomain.updateDBObject(f);

    Test.stopTest();
  }

  /**
   * @description This method is use to test the exceptions
   */
  @IsTest
  private static void handlerCreationError() {
    Test.startTest();
    try {
      CMN_FACTORY_TriggerHandler.createHandler(null);
      System.assert(false, 'Exception was not thrown.');
    } catch (CMN_FACTORY_TriggerHandler.TriggerFactoryException error) {
      System.assert(true, 'Exception was thrown as expected.');
    }
    Test.stopTest();
  }
}