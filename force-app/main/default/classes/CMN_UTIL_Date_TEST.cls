/**
 * @description Test class of CMN_UTIL_DATE class
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false)
private class CMN_UTIL_Date_TEST {
  /**
   * @description Method to test the Date of weekdays.
   */
  @IsTest
  private static void testDateMethods() {
    // This is a wednesday
    Date weekDay = Date.newInstance(2014, 7, 30);
    // This is a saturday
    Date weekendDay = Date.newInstance(2014, 8, 2);
    Date lastWeekDay = CMN_UTIL_Date.lastWeekDay();
    Date dateBeforeAddingWorkDays = Date.newInstance(2015, 1, 1); // 1 jan 2015 is a thursday
    Integer businessDaysToAdd = 5; // when added to 2015/1/1
    Date dateAfterAddingWorkDays = Date.newInstance(2015, 1, 8); // 5 days after the 1st excl weekends

    Test.startTest();
    Boolean checker = CMN_UTIL_Date.isWeekend(weekendDay);
    System.assertEquals(
      checker,
      true,
      'This date should be weekend day. Value must be True'
    );

    checker = CMN_UTIL_Date.isWeekDay(weekDay);
    System.assertEquals(
      checker,
      true,
      'This date should be week day. Value must be True'
    );

    checker = CMN_UTIL_Date.isWeekDay(lastWeekDay);
    System.assertEquals(
      checker,
      true,
      'This date should be week day. Value must be True'
    );
    Test.stopTest();

    Date dateCheck = CMN_UTIL_Date.addBusinessDays(
      dateBeforeAddingWorkDays,
      businessDaysToAdd
    );
    checker = (dateCheck == dateAfterAddingWorkDays);
    System.assertEquals(
      checker,
      true,
      'This date should exclude weekends, Value must be true'
    );
  }

  /**
   * @description Method to test the Datetime which return the in string
   */
  @IsTest
  private static void testFullDateTime() {
    Datetime testDateTime = Datetime.newInstance(2017, 4, 18, 9, 13, 0);
    String fullDateTimeString = String.valueOf(testDateTime);

    Test.startTest();

    String returnedString = CMN_UTIL_Date.fullDateTimeString(testDateTime);

    Test.stopTest();

    System.assertEquals(fullDateTimeString, returnedString);
  }

  /**
   * @description Method to test datetime
   */
  @IsTest
  private static void testFullDate() {
    Datetime testDateTime = Datetime.newInstance(2017, 4, 18, 9, 13, 0);
    String fullDateString = String.valueOf(testDateTime.date());

    Test.startTest();

    String returnedString = CMN_UTIL_Date.fullDateString(testDateTime);

    Test.stopTest();

    System.assertEquals(fullDateString, returnedString);
  }

  /**
   * @description Method to test the Datetime converted to string ISO8601
   */
  @IsTest
  private static void testDateTimeToIso8601String() {
    Datetime testDateTime = Datetime.now();

    Integer miliseconds = testDateTime.millisecondGmt();
    String milisecondsString;

    if (miliseconds < 10) {
      milisecondsString = '00' + miliseconds;
    } else if ((miliseconds >= 10) && (miliseconds < 100)) {
      milisecondsString = '0' + miliseconds;
    } else {
      milisecondsString = String.valueOf(miliseconds);
    }

    List<String> deconstructedDateTime = new List<String>{
      String.valueOf(testDateTime.yearGmt()),
      (testDateTime.monthGmt() < 10)
        ? '0' + String.valueOf(testDateTime.monthGmt())
        : String.valueOf(testDateTime.monthGmt()),
      (testDateTime.dayGmt() < 10)
        ? '0' + String.valueOf(testDateTime.dayGmt())
        : String.valueOf(testDateTime.dayGmt()),
      (testDateTime.hourGmt() < 10)
        ? '0' + String.valueOf(testDateTime.hourGmt())
        : String.valueOf(testDateTime.hourGmt()),
      (testDateTime.minuteGmt() < 10)
        ? '0' + String.valueOf(testDateTime.minuteGmt())
        : String.valueOf(testDateTime.minuteGmt()),
      (testDateTime.secondGmt() < 10)
        ? '0' + String.valueOf(testDateTime.secondGmt())
        : String.valueOf(testDateTime.secondGmt()),
      String.valueOf(milisecondsString)
    };

    String referenceDateTimeString = String.format(
      '{0}-{1}-{2}T{3}:{4}:{5}.{6}Z',
      deconstructedDateTime
    );

    Test.startTest();

    String formattedDateTime = CMN_UTIL_Date.dateTimeToIso8601String(
      testDateTime
    );

    Test.stopTest();

    System.assertEquals(referenceDateTimeString, formattedDateTime);
  }

  /**
   * @description Method to test the null Datetime converted to string ISO8601
   */
  @IsTest
  private static void testNullDateTimeToIso8601String() {
    Datetime testDateTime = null;

    Test.startTest();

    String isoDateTime = CMN_UTIL_Date.dateTimeToIso8601String(testDateTime);

    Test.stopTest();

    testDateTime = CMN_UTIL_Date.iso8601StringToDateTime(isoDateTime);

    System.assertEquals(CMN_UTIL_Date.getEpochDateTime(), testDateTime);
  }

  /**
   * @description Method to test the Date converted to string ISO8601
   */
  @IsTest
  private static void testNullDateToIso8601String() {
    Date testDate = null;

    Test.startTest();

    String isoDate = CMN_UTIL_Date.dateToIso8601String(testDate);

    Test.stopTest();

    testDate = CMN_UTIL_Date.iso8601StringToDate(isoDate);

    System.assertEquals(CMN_UTIL_Date.getEpochDate(), testDate);
  }

  /**
   * @description Method to test the Date converted to string ISO8601
   */
  @IsTest
  private static void testDateToIso8601String() {
    Date testDate = Date.today();

    List<String> deconstructedDate = new List<String>{
      String.valueOf(testDate.year()),
      (testDate.month() < 10)
        ? '0' + String.valueOf(testDate.month())
        : String.valueOf(testDate.month()),
      (testDate.day() < 10)
        ? '0' + String.valueOf(testDate.day())
        : String.valueOf(testDate.day())
    };

    String referenceDateString = String.format(
      '{0}-{1}-{2}T00:00:00.000Z',
      deconstructedDate
    );

    Test.startTest();

    String formattedDate = CMN_UTIL_Date.dateTimeToIso8601String(testDate);

    Test.stopTest();

    System.assertEquals(referenceDateString, formattedDate);
  }

  /**
   * @description Method to test the Datetime converted to string ISO8601
   */
  @IsTest
  private static void testIso8601StringToDateTime() {
    Datetime testDateTime = Datetime.now();

    String formattedDateTime = CMN_UTIL_Date.dateTimeToIso8601String(
      testDateTime
    );

    Test.startTest();

    Datetime convertedDatetime = CMN_UTIL_Date.iso8601StringToDateTime(
      formattedDateTime
    );

    Test.stopTest();

    System.assertEquals(
      testDateTime,
      convertedDatetime,
      'Datetime values are not equal'
    );
  }

  /**
   * @description Method to test the string ISO8601 to datetime
   */
  @IsTest
  private static void testIso8601StringToDate() {
    Datetime testDateTime = Datetime.now();

    Date testDate = testDateTime.date();

    String formattedDateTime = CMN_UTIL_Date.dateTimeToIso8601String(
      testDateTime
    );

    Test.startTest();

    Date convertedDate = CMN_UTIL_Date.iso8601StringToDate(formattedDateTime);

    Test.stopTest();

    System.assertEquals(testDate, convertedDate, 'Date values are not equal');
  }

  /**
   * @description Will check that the swapSeparators function works as expected
   *
   * @param aDate Date object for the associated dateString
   * @param dateString A Date formatted with different separators
   * @param dateFormat The format to apply when check date string
   */
  private static void testSwapSeparators(
    Date aDate,
    String dateString,
    String dateFormat
  ) {
    List<String> deconstructedDate = new List<String>{
      String.valueOf(aDate.year()),
      (aDate.month() < 10)
        ? '0' + String.valueOf(aDate.month())
        : String.valueOf(aDate.month()),
      (aDate.day() < 10)
        ? '0' + String.valueOf(aDate.day())
        : String.valueOf(aDate.day())
    };

    String referenceDateString = String.format(dateFormat, deconstructedDate);

    Test.startTest();

    String returnedDateString = CMN_UTIL_Date.swapSeparators(dateString);

    Test.stopTest();

    System.assertEquals(referenceDateString, returnedDateString);
  }

  /**
   * @description Method to test date format
   */
  @IsTest
  private static void testSwapDashSeparators() {
    Date testDate = Date.today();
    String testDateString = String.valueOf(testDate);
    testSwapSeparators(testDate, testDateString, '{0}/{1}/{2}');
  }

  /**
   * @description Method to test date format
   */
  @IsTest
  private static void testSwapSlashSeparators() {
    Date testDate = Date.today();
    String testDateString = String.valueOf(testDate).replaceAll('-', '/');
    testSwapSeparators(testDate, testDateString, '{0}-{1}-{2}');
  }

  /**
   * @description Various date function tests
   */
  @IsTest
  private static void testVariousDateMethods() {
    Date friday = Date.newInstance(2018, 1, 26);
    Date saturday = Date.newInstance(2018, 1, 27);
    Date workingDay = Date.newInstance(2018, 1, 31);

    //Since this is not a weekend, returns the date
    System.assertEquals(workingDay, CMN_UTIL_Date.lastWeekDay(workingDay));
    //Since the date given is a weekend, it will give first working day prior to the weekend
    System.assertEquals(friday, CMN_UTIL_Date.lastWeekDay(saturday));

    System.assertEquals(
      Date.newInstance(2018, 1, 29),
      CMN_UTIL_Date.firstWeekDay(saturday)
    );
    System.assertEquals(workingDay, CMN_UTIL_Date.firstWeekDay(workingDay));

    System.assertEquals(
      '2018-01-27',
      CMN_UTIL_Date.dateToIso8601String(saturday)
    );
    System.assertEquals(
      new Set<String>{
        String.valueOf(System.today().year() - 1),
        String.valueOf(System.today().year())
      },
      CMN_UTIL_Date.yearRange(1)
    );

    System.assertEquals(
      Datetime.newInstance(0),
      CMN_UTIL_Date.getEpochDateTime()
    );
    System.assertEquals(
      Datetime.newInstance(0).date(),
      CMN_UTIL_Date.getEpochDate()
    );
  }

  /**
   * @description Method to test the converted SAP string to Date
   */
  @IsTest
  private static void testSAPStringToDate() {
    String dateStr = '20190221';

    Test.startTest();

    Date convertedDate = CMN_UTIL_Date.sapStringToDate(dateStr);

    Test.stopTest();

    System.assertEquals(21, convertedDate.day(), 'Invalid day.');
    System.assertEquals(2, convertedDate.month(), 'Invalid month.');
    System.assertEquals(2019, convertedDate.year(), 'Invalid year.');
  }

  /**
   * @description Method to test the week number of the current date
   */
  @IsTest
  private static void testWeekNumberFromDate() {
    Date firstWeekDate = Date.newInstance(2019, 1, 1);
    Date testDate = Date.newInstance(2019, 8, 7);
    Date lastWeekDate = Date.newInstance(2019, 12, 25);

    Test.startTest();

    Integer firstWeek = CMN_UTIL_Date.weekNumberFromDate(firstWeekDate);
    Integer weekNumber = CMN_UTIL_Date.weekNumberFromDate(testDate);
    Integer lastWeek = CMN_UTIL_Date.weekNumberFromDate(lastWeekDate);

    Test.stopTest();

    System.assertEquals(1, firstWeek);
    System.assertEquals(32, weekNumber);
    System.assertEquals(52, lastWeek);
  }

  /**
   * @description Method to test the week end date of a week number
   */
  @IsTest
  private static void testWeekEndDateFromWeekNumber() {
    Test.startTest();

    Date firstWeekEndDate = CMN_UTIL_Date.weekEndDateFromWeekNumber(1, 2019);
    Date secondWeekEndDate = CMN_UTIL_Date.weekEndDateFromWeekNumber(2, 2019);
    Date thirdWeekEndDate = CMN_UTIL_Date.weekEndDateFromWeekNumber(3, 2019);

    Test.stopTest();

    System.assertEquals(Date.newInstance(2019, 1, 6), firstWeekEndDate);
    System.assertEquals(Date.newInstance(2019, 1, 13), secondWeekEndDate);
    System.assertEquals(Date.newInstance(2019, 1, 20), thirdWeekEndDate);
  }

  /**
   * @description Method to test the name of the month based on the date.
   */
  @IsTest
  private static void monthNameFromDate() {
    Test.startTest();

    Date epochDate = CMN_UTIL_Date.getEpochDate();

    String month = CMN_UTIL_Date.monthNameFromDate(epochDate);

    Test.stopTest();

    Datetime epochDateTime = Datetime.newInstance(
      epochDate.year(),
      epochDate.month(),
      epochDate.day()
    );

    System.assertEquals(
      epochDateTime.format(CMN_UTIL_Date.WHOLE_MONTH_FMT),
      month,
      'Invalid  Month Returned.'
    );
  }

  /**
   * @description Method to test the format expression
   */
  @IsTest
  private static void getCronExpression() {
    Test.startTest();

    Datetime epochDateTime = CMN_UTIL_Date.getEpochDateTime();

    String cron = CMN_UTIL_Date.getCronExpression(epochDateTime);

    Test.stopTest();

    String second = String.valueOf(epochDateTime.second());
    String minute = String.valueOf(epochDateTime.minute());
    String hour = String.valueOf(epochDateTime.hour());
    String day = String.valueOf(epochDateTime.day());
    String month = String.valueOf(epochDateTime.month());
    String year = String.valueOf(epochDateTime.year());

    String expectedCron = String.format(
      CMN_UTIL_Date.CRON_FMT,
      new List<String>{ second, minute, hour, day, month, year }
    );

    System.assertEquals(expectedCron, cron, 'Invalid Cron expression returned');
  }
}