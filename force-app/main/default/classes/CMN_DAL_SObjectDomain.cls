/**
 * @description This is the base Data Access Layer Object from which all
 * DAL objects should inherited It implements various common functions
 * CMN_DAL_SObjectDomain can be used statically (static methods for convenience)
 * or as its own extended instance
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public virtual class CMN_DAL_SObjectDomain implements ISObjectDomain {
  private SObjectType sobjectType;

  /**
   * @description Constructor
   *
   * @param sObjectType
   */
  public CMN_DAL_SObjectDomain(SObjectType sObjectType) {
    this.sobjectType = sObjectType;
  }

  /**
   * @description ISObjectDomain interface if extending class is required to hold state variables
   * or for mocking purposes
   */
  public interface ISObjectDomain {
    /**
     * @description Returns the SObjectType this Domain class represents
     *
     * @return sobject type
     **/
    Schema.SObjectType sObjectType();
  }

  public enum DatabaseOperation {
    DBO_INSERT,
    DBO_UPDATE,
    DBO_DELETE,
    DBO_UNDELETE
  }

  public static Map<Integer, Map<String, List<String>>> dmlOperationErrors = new Map<Integer, Map<String, List<String>>>();

  @TestVisible
  private static final String CONTACT_EMAIL_SUFFIX = '@example.com';

  //Used to retrieve record types during a transaction context, will be filled with all record types in system.
  private static List<RecordType> ALL_RECORD_TYPES = null;
  private static Map<String, Map<String, RecordType>> ALL_RECORD_TYPES_BY_OBJECT_MAP = null;
  private static Map<Id, RecordType> ALL_RECORD_TYPES_BY_ID_MAP = null;
  private static String MASTER_RECORDTYPE_NAME = 'Master';

  public static final String FIELD_ID = 'Id';
  public static final String FIELD_OWNER_ID = 'OwnerId';
  public static final String FIELD_NAME = 'Name';
  public static final String FIELD_RECORD_TYPE_ID = 'RecordTypeId';
  public static final String FIELD_LAST_MODIFIED_DATE = 'LastModifiedDate';
  public static final String OBJECT_RECORDTYPE = 'RecordType';
  public static final Integer LIMIT_NUMBER_OF_RECORDS = 50000;

  //Various Lengths
  public static final Integer FL_NAME = 80;
  private static final Integer DEFAULT_NAME_LEN = 15;
  private static final Integer DEFAULT_INTEGER_LENGTH = 8;

  public static final String PHONE_FMT = '({0})-{1}-{2}';

  private static Integer mockIdCount = 0;
  private static final String ID_PATTERN = '000000000000';

  /**
   * @description override if required
   *
   * @return sobject type
   */
  public SObjectType sObjectType() {
    return this.sobjectType;
  }

  /**
   * @description This method is use to insert the Object
   *
   * @param listOfObjects as input
   * @param allInsertsMustSucceed as input
   *
   * @return result
   */
  public static Boolean insertDBObjects(
    List<SObject> listOfObjects,
    Boolean allInsertsMustSucceed
  ) {
    return updateDatabase(
      listOfObjects,
      DatabaseOperation.DBO_INSERT,
      allInsertsMustSucceed
    );
  }

  /**
   * @description This method is use to delete the Object
   *
   * @param objectToUndelete as input
   */
  public static void undeleteDBObject(SObject objectToUndelete) {
    List<SObject> listOfObjects = new List<SObject>{ objectToUndelete };

    Database.undelete(listOfObjects);
  }

  /**
   * @description This method is use to insert the Object
   *
   * @param listOfObjects as input
   *
   * @return result
   */
  public static Boolean insertDBObjects(List<SObject> listOfObjects) {
    return insertDBObjects(listOfObjects, true);
  }

  /**
   * @description This method is use to insert the Object
   *
   * @param obj as input
   *
   * @return result
   */
  public static Boolean insertDBObject(SObject obj) {
    return insertDBObject(obj, true);
  }

  /**
   * @description This method is use to check the updates
   *
   * @param obj as input
   * @param allUpdatesMustSucceed as input
   *
   * @return result
   */
  public static Boolean insertDBObject(
    SObject obj,
    Boolean allUpdatesMustSucceed
  ) {
    return insertDBObjects(new List<SObject>{ obj }, allUpdatesMustSucceed);
  }

  /**
   * @description This method is use to check update operation
   *
   * @param listOfObjects as input
   * @param allUpdatesMustSucceed as input
   *
   * @return result
   */
  public static Boolean updateDBObjects(
    List<SObject> listOfObjects,
    Boolean allUpdatesMustSucceed
  ) {
    return updateDatabase(
      listOfObjects,
      DatabaseOperation.DBO_UPDATE,
      allUpdatesMustSucceed
    );
  }

  /**
   * @description Performs an upsert operation
   *
   * @param listOfObjects Objects to upsert
   * @param objectType Since upsert operations cannot be generic, this is used to typecast in list to correct type
   * @param allOperationsMustSucceed Indicate if all a partial commit is allowed (i.e. if some object updates are invalid, whole transaction doesn't rollback)
   *
   * @return Indicates whether all operations succeeded
   */
  public static Boolean dynamicUpsertDBObjects(
    List<SObject> listOfObjects,
    SObjectType objectType,
    Boolean allOperationsMustSucceed
  ) {
    dmlOperationErrors.clear();

    if (!listOfObjects.isEmpty()) {
      String listType = 'List<' + objectType + '>';

      List<SObject> castRecords = (List<SObject>) Type.forName(listType)
        .newInstance();

      castRecords.addAll(listOfObjects);

      List<Database.UpsertResult> upsertResults = new List<Database.UpsertResult>();
      upsertResults = Database.upsert(castRecords, allOperationsMustSucceed);

      processUpsertResults(upsertResults);
    }

    return dmlOperationErrors.isEmpty();
  }

  /**
   * @description will run through the results on an upsert and update dmlOperationErrors with any errors
   *
   * @param upsertResults The list of upsert results
   */
  private static void processUpsertResults(
    List<Database.UpsertResult> upsertResults
  ) {
    Integer objIndex = 0;

    for (Database.UpsertResult upsertResult : upsertResults) {
      if (!upsertResult.isSuccess()) {
        collectErrors(objIndex, upsertResult.getErrors());
      }

      objIndex++;
    }
  }

  /**
   * @description This method is use to check update action
   *
   * @param obj as input
   *
   * @return result
   */
  public static Boolean updateDBObject(SObject obj) {
    return updateDBObject(obj, true);
  }

  /**
   * @description This method is use to check update action
   *
   * @param obj as input
   * @param allUpdatesMustSucceed as input
   *
   * @return result
   */
  public static Boolean updateDBObject(
    SObject obj,
    Boolean allUpdatesMustSucceed
  ) {
    return updateDBObjects(new List<SObject>{ obj }, allUpdatesMustSucceed);
  }

  /**
   * @description This method is use to check update action
   *
   * @param listOfObjects as input
   *
   * @return result
   */
  public static Boolean updateDBObjects(List<SObject> listOfObjects) {
    return updateDBObjects(listOfObjects, true);
  }

  /**
   * @description This method is use to check update action
   *
   * @param listOfObjects as input
   * @param allDeletesMustSucceed as input
   *
   * @return result
   */
  public static Boolean deleteDBObjects(
    List<SObject> listOfObjects,
    Boolean allDeletesMustSucceed
  ) {
    return updateDatabase(
      listOfObjects,
      DatabaseOperation.DBO_DELETE,
      allDeletesMustSucceed
    );
  }

  /**
   * @description This method is use to check update action
   *
   * @param listOfObjects as input
   *
   * @return result
   */
  public static Boolean deleteDBObjects(List<SObject> listOfObjects) {
    return deleteDBObjects(listOfObjects, true);
  }

  /**
   * @description This method is use to check update action
   *
   * @param obj as input
   *
   * @return result
   */
  public static Boolean deleteDBObject(SObject obj) {
    return deleteDBObjects(new List<SObject>{ obj });
  }

  /**
   * @description Will perform a Database update on the list of SObject provided
   *
   * @param listOfObjects A list of SObjects to be processed
   * @param operation The DML operation to perform
   * @param allOperationsMustSucceed Whether partial update can happen; if true a single failure will abort transaction
   *
   * @return Whether the operation succeeded
   */
  private static Boolean updateDatabase(
    List<SObject> listOfObjects,
    DatabaseOperation operation,
    Boolean allOperationsMustSucceed
  ) {
    Savepoint saveTransaction = null;

    dmlOperationErrors.clear();

    if (listOfObjects.isEmpty()) {
      return true;
    }

    //remove duplicates (if we are doing delete or update)
    if (
      (operation == DatabaseOperation.DBO_UPDATE) ||
      (operation == DatabaseOperation.DBO_DELETE)
    ) {
      Set<SObject> setOfObject = new Set<SObject>();
      setOfObject.addAll(listOfObjects);
      listOfObjects.clear();
      listOfObjects.addAll(setOfObject);
    }

    if (allOperationsMustSucceed) {
      saveTransaction = Database.setSavepoint();
    }

    try {
      performDMLOperation(listOfObjects, operation, allOperationsMustSucceed);
    } catch (Exception error) {
      if (saveTransaction != null) {
        Database.rollback(saveTransaction);
      }

      CMN_UTIL_Logger.error(error, 'CMN_DAL_SObjectDomain.updateDatabase');

      throw error;
    }

    return dmlOperationErrors.isEmpty();
  }

  /**
   * @description Will perform the DML operation provided on the given a list of Sobjet
   *
   * @param listOfObjects A list of SObjects to be processed
   * @param operation The DML operation to perform
   * @param allOperationsMustSucceed Whether partial update can happen; if true a single failure will abort transaction
   */
  private static void performDMLOperation(
    List<SObject> listOfObjects,
    DatabaseOperation operation,
    Boolean allOperationsMustSucceed
  ) {
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
    List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();

    if (operation == DatabaseOperation.DBO_INSERT) {
      saveResults = Database.insert(listOfObjects, allOperationsMustSucceed);
    } else if (operation == DatabaseOperation.DBO_UPDATE) {
      saveResults = Database.update(listOfObjects, allOperationsMustSucceed);
    } else if (operation == DatabaseOperation.DBO_DELETE) {
      deleteResults = Database.delete(listOfObjects, allOperationsMustSucceed);
    }

    if (!saveResults.isEmpty()) {
      Integer objIndex = 0;

      for (Database.SaveResult saveResult : saveResults) {
        if (!saveResult.isSuccess()) {
          collectErrors(objIndex, saveResult.getErrors());
        }

        objIndex++;
      }
    } else if (!deleteResults.isEmpty()) {
      Integer objIndex = 0;

      for (Database.DeleteResult deleteResult : deleteResults) {
        if (!deleteResult.isSuccess()) {
          collectErrors(objIndex, deleteResult.getErrors());
        }

        objIndex++;
      }
    }
  }

  /**
   * @description This method is use get the database error of SObject
   *
   * @param error The error encountered
   * @param fieldToErrors A Map to update with relevant field and error
   */
  private static void collectError(
    Database.Error error,
    Map<String, List<String>> fieldToErrors
  ) {
    String errorMessage;

    if (error instanceof Database.DuplicateError) {
      Database.DuplicateError duplicateError = (Database.DuplicateError) error;
      errorMessage = duplicateError.getDuplicateResult().getErrorMessage();
    } else {
      errorMessage = error.getMessage();
    }

    List<String> fields = error.getFields();

    if (fields.isEmpty()) {
      List<String> errors = fieldToErrors.get(CMN_UTIL_String.EMPTY);

      if (errors == null) {
        errors = new List<String>();
        fieldToErrors.put(CMN_UTIL_String.EMPTY, errors);
      }

      errors.add(errorMessage);
    } else {
      for (String fieldName : fields) {
        List<String> errors = fieldToErrors.get(fieldName);

        if (errors == null) {
          errors = new List<String>();
          fieldToErrors.put(fieldName, errors);
        }

        errors.add(errorMessage);
      }
    }
  }

  /**
   * @description Will populate dmlOperationErrors with relevant error information
   *
   * @param objIndex The index of the object in original update operation
   * @param errors List of errors encountered
   */
  private static void collectErrors(
    Integer objIndex,
    List<Database.Error> errors
  ) {
    Map<String, List<String>> fieldToErrors = dmlOperationErrors.get(objIndex);

    if (fieldToErrors == null) {
      fieldToErrors = new Map<String, List<String>>();
      dmlOperationErrors.put(objIndex, fieldToErrors);
    }

    for (Database.Error error : errors) {
      collectError(error, fieldToErrors);
    }
  }

  /**
   * @description This method is use to run the Operation trigger
   *
   * @return This will return all the trigger operations
   */
  public static DatabaseOperation getTriggerDBOperation() {
    if (Trigger.isInsert) {
      return DatabaseOperation.DBO_INSERT;
    } else if (Trigger.isUpdate) {
      return DatabaseOperation.DBO_UPDATE;
    } else if (Trigger.isDelete) {
      return DatabaseOperation.DBO_DELETE;
    } else {
      return DatabaseOperation.DBO_UNDELETE;
    }
  }

  /**
   * @description Method is use to generate Date
   *
   * @return Date
   */
  public static Date generateRandomDate() {
    Date randomDate = Date.today();
    Date epochDate = CMN_UTIL_Date.getEpochDate();
    Integer daysBetween = epochDate.daysBetween(randomDate);
    //Generate years to subtract from current date
    Integer daysToSubtract = (Math.random() * daysBetween + 1).intValue();

    return randomDate.addDays(-daysToSubtract);
  }

  /**
   * @description Method is use to generate DateTime
   *
   * @return DateTime
   */
  public static Datetime generateRandomDateTime() {
    Date randomDate = Date.today();
    Date epochDate = CMN_UTIL_Date.getEpochDate();
    Integer daysBetween = epochDate.daysBetween(randomDate);
    //Generate years to subtract from current date
    Integer daysToSubtract = (Math.random() * daysBetween + 1).intValue();

    return System.now().addDays(-daysToSubtract);
  }

  /**
   * @description Method is use to generate Number
   *
   * @return generateRandomNumber
   */
  public static String generateRandomNumber() {
    return generateRandomNumber(DEFAULT_INTEGER_LENGTH);
  }

  /**
   * @description Generates random boolean value
   *
   * @return Either true or false
   */
  public static Boolean generateRandomBoolean() {
    return CMN_UTIL_Random.nextBoolean();
  }

  /**
   * @description Method is use to generate Number with length
   *
   * @param length as input
   *
   * @return integer
   */
  public static String generateRandomNumber(Integer length) {
    return CMN_UTIL_Random.randomNumeric(length);
  }

  /**
   * @description Method is use to generate Integer
   *
   * @return randomInteger
   */
  public static Integer generateRandomInteger() {
    return generateRandomInteger(DEFAULT_INTEGER_LENGTH);
  }

  /**
	 * @description <p>
	 * Returns a random integer within the specified range.
	 * </p>
	 *
	 * @param min the smallest value that can be returned, must be non-negative
	 * @param max the upper bound (not included)
	 * @throws IllegalArgumentException
	 *             if {@code startInclusive > endExclusive} or if
	 *             {@code startInclusive} is negative
	 *
	 * @return the random integer
	 */
	public static Integer generateRandomInteger(Integer min, Integer max)
	{
		return CMN_UTIL_Random.nextInteger(min, max);
	}
  /*
   * @description Will generate a random Double
   *
   * @return the double generated
   */
	public static Double generateRandomDouble()
	{
		Double randomDouble = generateRandomDouble(DEFAULT_INTEGER_LENGTH);
		return randomDouble;
	}

	/**
	 * @description Will generate a random Double
	 *
	 * @param length
	 *
	 * @return the double generated
	 */
	public static Double generateRandomDouble(Integer length)
	{
		Double randomDouble = Math.random() * Math.pow(10, length);
		return randomDouble;
	}

  /**
   * @description Will generate a random Double with Decimal with double digit precision
   *
   * @return the decimal generated
   */
	public static Decimal generateRandomDecimal()
	{
		return generateRandomDecimal(2);
	}

	/**
	 * @description Will generate a random Double with Decimal with double digit precision
	 *
	 * @param length
	 * @param scale
	 *
	 * @return the decimal generated
	 */
	public static Decimal generateRandomDecimal(Integer length, Integer scale)
	{
		Double randomDouble = generateRandomDouble(length);
		return Decimal.valueOf(randomDouble).setScale(scale);
	}

	/**
	 * @description Will generate a random Double with Decimal with double digit precision
	 *
	 * @param scale
	 *
	 * @return the decimal generated
	 */
	public static Decimal generateRandomDecimal(Integer scale)
	{
		Double randomDouble = generateRandomDouble();
		return Decimal.valueOf(randomDouble).setScale(scale);
	}

	/**
	 * @description Will generate a random Double with Decimal with double digit precision
	 *
	 * @param scale
	 *
	 * @return the decimal generated as a string
	 */
	public static String generateRandomDecimalAsString(Integer scale)
	{
		return String.valueOf(generateRandomDecimal(scale));
	}

	/**
	 * @description Will generate a random Currency with Decimal with double digit precision
	 *
	 * @return the decimal generated as a string
	 */
	public static String generateRandomCurrencyAsString()
	{
		return String.valueOf(generateRandomDecimalAsString(2));
	}

	/**
	 * @description Will generate a random Percentage between 0 and 100 with double digit precision
	 *
	 * @return the percentage generated as a string
	 */
	public static Decimal generateRandomPercentage()
	{
		return generateRandomDecimal(2, 2);
	}

	/**
	 * @description Will generate a random Percentage between 0 and 100 with double digit precision
	 *
	 * @return the percentage generated as a string
	 */
	public static String generateRandomPercentageAsString()
	{
		return String.valueOf(generateRandomPercentage());
	}

	/**
   * @description Method is use to generate Name
   *
   * @return String
   */
  public static String generateRandomName() {
    return CMN_UTIL_Random.randomAlphabetic(DEFAULT_NAME_LEN);
  }

  /**
   * @description Method is use to generate description
   *
   * @return String
   */
  public static String generateRandomDescription() {
    return CMN_UTIL_Random.randomAlphabetic(FL_NAME);
  }

  /**
   * @description Method is use to generate Email
   *
   * @return String
   */
  public static String generateRandomEmail() {
    return generateRandomName() + CONTACT_EMAIL_SUFFIX;
  }

  /**
   * @description Method is use to generate sobject id
   *
   * @param sType as input
   *
   * @return String
   */
  public static Id generateRandomSObjectId(SObjectType sType) {
    return CMN_UTIL_Random.randomSObjectId(sType);
  }
  /**
   * @description Method is use to generate phone number
   *
   * @return String
   */
  public static String generateRandomPhoneNumber() {
    String areaCode1 = CMN_UTIL_Random.random(3, 0, 9, false, true);

    //Ensure we only have numbers with 3 digits
    String phoneNumber1 = CMN_UTIL_Random.random(3, 100, 999, false, true);

    //Ensure we only have numbers with 4 digits
    String phoneNumber2 = CMN_UTIL_Random.random(4, 1000, 9999, false, true);

    return String.format(
      PHONE_FMT,
      new List<String>{ areaCode1, phoneNumber1, phoneNumber2 }
    );
  }

  /**
   * @description Method is use to get the List of recordtype of current user
   *
   * @param objectType as input
   *
   * @return recordTypes
   */
  public static List<RecordType> getRecordTypesForCurrentUser(
    SObjectType objectType
  ) {
    List<RecordType> recordTypes = new List<RecordType>();
    Set<Id> recordTypeIds = new Set<Id>();

    Schema.DescribeSObjectResult describeResult = objectType.getDescribe();

    List<Schema.RecordTypeInfo> recordTypeInfos = describeResult.getRecordTypeInfos();
    for (Schema.RecordTypeInfo recordTypeInfo : recordTypeInfos) {
      if (
        recordTypeInfo.isAvailable() &&
        !MASTER_RECORDTYPE_NAME.equalsIgnoreCase(recordTypeInfo.name)
      ) {
        recordTypeIds.add(recordTypeInfo.getRecordTypeId());
      }
    }

    recordTypes = getRecordTypesByIds(recordTypeIds);

    return recordTypes;
  }

  /**
   * @description Method is use to get the recordtype id of current user
   *
   * @param recordTypeId as input
   *
   * @return string Id of record type
   */
  public static String getRecordTypeById(Id recordTypeId) {
    populateRecordTypesMap();

    RecordType recordType = ALL_RECORD_TYPES_BY_ID_MAP.get(recordTypeId);

    if (recordType != null) {
      return recordType.Name;
    } else {
      return CMN_UTIL_String.EMPTY;
    }
  }

	/**
	 * @description Method will return the recordtype information request
	 *
	 * @param objectType Object Type for which you want to retrieve the Record Type
	 * @param recordTypeName Developer Name for the recordtype
	 *
	 * @return Null or RecordTypeInfo
	 */
	public static RecordTypeInfo getRecordTypeInfo(SObjectType objectType, String recordTypeName)
	{
		return objectType != null && String.isNotBlank(recordTypeName) ? objectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName) : null;
	}

  /**
   * @description Method is use to get the List of recordtype of current user by recordtype Id
   *
   * @param recordTypeIds as input
   *
   * @return List of recordTypes
   */
  public static List<RecordType> getRecordTypesByIds(Set<Id> recordTypeIds) {
    populateRecordTypesMap();

    List<RecordType> recordTypes = new List<RecordType>();

    for (Id recordTypeId : recordTypeIds) {
      RecordType recordType = ALL_RECORD_TYPES_BY_ID_MAP.get(recordTypeId);
      if (recordType != null) {
        recordTypes.add(recordType);
      }
    }

    return recordTypes;
  }

  /**
   * @description Method will retrieve the Id for the RecordType of an Object by DeveloperName (if it exists), else it will return a null
   *
   * @param objectType as input
   * @param recordTypeName as input
   *
   * @return This method can be called many times in the same transaction context but will only ever do one query
   */
  public static Id getRecordTypeByDeveloperName(
    SObjectType objectType,
    String recordTypeName
  ) {
    populateRecordTypesMap();

    Map<String, RecordType> recordTypesMap = ALL_RECORD_TYPES_BY_OBJECT_MAP.get(
      objectType.getDescribe().getLocalName()
    );

    RecordType recordType = recordTypesMap == null
      ? null
      : recordTypesMap.get(recordTypeName);

    return recordType == null ? null : recordType.Id;
  }

  /**
   * @description Generate random Integer of specified length within Integer limits
   *
   * @param length as input
   *
   * @return result
   */
  public static Integer generateRandomInteger(Integer length) {
    Integer startNumber = (Integer) Math.pow(10, length - 1);
    return Math.round((Math.random() * (9 * startNumber) + startNumber));
  }

  /**
   * @description Method will ensure all recordtypes are retrieved and popualted into map (assuminng map hasn't already been populated)
   */
  private static void populateRecordTypesMap() {
    if (ALL_RECORD_TYPES == null) {
      ALL_RECORD_TYPES_BY_OBJECT_MAP = new Map<String, Map<String, RecordType>>();

      ALL_RECORD_TYPES = CMN_DAL_RecordType.getAll();

      ALL_RECORD_TYPES_BY_ID_MAP = new Map<Id, RecordType>();

      for (RecordType recordType : ALL_RECORD_TYPES) {
        ALL_RECORD_TYPES_BY_ID_MAP.put(recordType.Id, recordType);

        Map<String, RecordType> recordTypesMap = ALL_RECORD_TYPES_BY_OBJECT_MAP.get(
          recordType.SobjectType
        );

        if (recordTypesMap == null) {
          recordTypesMap = new Map<String, RecordType>();
          ALL_RECORD_TYPES_BY_OBJECT_MAP.put(
            recordType.SobjectType,
            recordTypesMap
          );
        }

        recordTypesMap.put(recordType.DeveloperName, recordType);
      }
    }
  }

  /**
   * @description Method is use to get the sObject Type
   *
   * @param objectTypeName as input
   *
   * @return result
   */
  public static SObject newObject(String objectTypeName) {
    SObjectType objType = CMN_UTIL_System.getSObjectTypeByName(objectTypeName);

    return objType == null ? null : objType.newSObject();
  }

  /**
   * @description Generate a fake/mock Salesforce incremental Id for the given SObjectType
   *
   * @param sobjectType as input
   *
   * @return incremental id
   */
  public static Id generateIncrementalId(Schema.SObjectType sobjectType) {
    String keyPrefix = sobjectType.getDescribe().getKeyPrefix();

    mockIdCount++;

    String fakeIdPrefix = ID_PATTERN.substring(
      0,
      12 - String.valueOf(mockIdCount).length()
    );

    return Id.valueOf(keyPrefix + fakeIdPrefix + mockIdCount);
  }
}