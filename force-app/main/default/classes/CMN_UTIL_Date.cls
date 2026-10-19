/**
 * @description Class containing utility routines focused on dates
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_UTIL_Date {
  private static final String DATE_FORMATTER = 'yyyy-MM-dd';
  private static final String DAY_FMT = 'E';
  private static final String FULL_TIME_FORMATTER = 'yyyy-MM-dd hh:mm:ss';
  private static final String JSON_QUOTE = '"';
  private static final String SATURDAY = 'Sat';
  private static final String SUNDAY = 'Sun';
  private static final String ISO_8601_DATE_INDICATOR = 'T';

  @TestVisible
  private static final String WHOLE_MONTH_FMT = 'MMMMM';
  @TestVisible
  private static final String CRON_FMT = '{0} {1} {2} {3} {4} ? {5}';

  /**
   * @description This method is return the datetime of weekend
   *
   * @param aDateTime as input
   *
   * @return return true if SATURDAY or SUNDAY
   */
  public static Boolean isWeekend(Datetime aDateTime) {
    return (aDateTime.format(DAY_FMT) == SATURDAY ||
    aDateTime.format(DAY_FMT) == SUNDAY);
  }

  /**
   * @description This method is return the date of weekend
   *
   * @param aDate as input
   *
   * @return return the date
   */
  public static Boolean isWeekend(Date aDate) {
    return isWeekend(
      Datetime.newInstance(aDate.year(), aDate.month(), aDate.day())
    );
  }

  /**
   * @description This method is return the datetime of week day
   *
   * @param day as input
   *
   * @return return the day
   */
  public static Boolean isWeekDay(Datetime day) {
    return !isWeekend(day);
  }

  /**
   * @description This method is return the day of week day
   *
   * @param aDate as input
   *
   * @return return the day
   */
  public static Boolean isWeekDay(Date aDate) {
    return isWeekDay(
      Datetime.newInstance(aDate.year(), aDate.month(), aDate.day())
    );
  }

  /**
   * @description This method is use to convert datetimt to string
   *
   * @param dateArg as input
   *
   * @return result
   */
  public static String fullDateTimeString(Datetime dateArg) {
    return dateArg.format(FULL_TIME_FORMATTER);
  }

  /**
   * @description This method is use to convert date to string
   *
   * @param dateArg as input
   *
   * @return dateArg
   */
  public static String fullDateString(Datetime dateArg) {
    return dateArg.format(DATE_FORMATTER);
  }

  /**
   * @description This method is use to add and calculate business day
   *
   * @param startDate as input
   * @param businessDaysToAdd as input
   *
   * @return the next business date
   */
  public static Date addBusinessDays(
    Date startDate,
    Integer businessDaysToAdd
  ) {
    Date finalDate = startDate;
    Integer direction = businessDaysToAdd < 0 ? -1 : 1;

    while (businessDaysToAdd != 0) {
      finalDate = finalDate.addDays(direction);
      if (!isWeekend(finalDate)) {
        businessDaysToAdd -= direction;
      }
    }
    return finalDate;
  }

  /**
   * @description returns the last day of the week prior to the one being passed, only if current day is on a weekend
   *
   * @param aDate The data to evaluate
   *
   * @return A date containing the last weekday
   */
  public static Date lastWeekDay(Date aDate) {
    Date result = aDate.addDays(0);

    if (isWeekend(result)) {
      do {
        result = result.addDays(-1);
      } while (isWeekend(result));
    }

    return result;
  }

  /**
   * @description returns the most recent weekday before today
   *
   * @return A date containing the last weekday
   */
  public static Date lastWeekDay() {
    return lastWeekDay(Date.today());
  }

  /**
   * @description returns the first day of the week subsequent to the one being passed if the current date is on a weekend
   *
   * @param aDate The data being evaluated
   *
   * @return A date containing the last first weekday
   */
  public static Date firstWeekDay(Date aDate) {
    Date result = aDate.addDays(0);

    if (isWeekend(result)) {
      do {
        result = result.addDays(1);
      } while (isWeekend(result));
    }

    return result;
  }

  /**
   * @description returns the Datetime
   *
   * @return result
   */
  public static Datetime getEpochDateTime() {
    return Datetime.newInstance(0);
  }

  /**
   * @description returns the date
   *
   * @return result
   */
  public static Date getEpochDate() {
    return getEpochDateTime().date();
  }

  /**
   * @description returns the string value of datetime in ISO8601 format
   *
   * @param aDateTime as input
   *
   * @return string
   */
  public static String dateTimeToIso8601String(Datetime aDateTime) {
    if (aDateTime == null) {
      aDateTime = getEpochDateTime();
    }

    String jsonDate = JSON.serialize(aDateTime);

    //Remove the quotes around the JSON Datetime.
    return CMN_UTIL_String.remove(jsonDate, JSON_QUOTE);
  }

  /**
   * @description returns the date value in ISO8601 format
   *
   * @param aDate as input
   *
   * @return string
   */
  public static String dateToIso8601String(Date aDate) {
    if (aDate == null) {
      aDate = getEpochDate();
    }

    return fullDateString(
      Datetime.newInstance(aDate.year(), aDate.month(), aDate.day())
    );
  }

  /**
   * @description returns the date value of datetime in ISO8601 format
   *
   * @param iso8601String as input
   *
   * @return string
   */
  public static Datetime iso8601StringToDateTime(String iso8601String) {
    return String.isBlank(iso8601String)
      ? null
      : (Datetime) JSON.deserialize(
          JSON_QUOTE +
          iso8601String +
          JSON_QUOTE,
          Datetime.class
        );
  }

  /**
   * @description returns the date value of date in ISO8601 format
   *
   * @param iso8601String as input
   *
   * @return string
   */
  public static Date iso8601StringToDate(String iso8601String) {
    Date returnDate = null;

    if (String.isNotBlank(iso8601String)) {
      Datetime iso8601DateTime = iso8601StringToDateTime(iso8601String);
      //If we get a full date time, we must assume that we will need to shift it to relevant timezone, otherwise assume UTC
      returnDate = iso8601String.contains(ISO_8601_DATE_INDICATOR)
        ? iso8601DateTime.date()
        : iso8601DateTime.dateGmt();
    }

    return returnDate;
  }

  /**
   * @description returns the date value
   *
   * @param dateValue as input
   *
   * @return string
   */
  public static String swapSeparators(String dateValue) {
    String year, month, day;

    if (dateValue.contains('-')) {
      year = dateValue.substringBefore('-');
      month = dateValue.substringAfter('-').substringBefore('-');
      day = dateValue.substringAfter('-').substringAfter('-');

      return year + '/' + month + '/' + day;
    } else {
      year = dateValue.substringBefore('/');
      month = dateValue.substringAfter('/').substringBefore('/');
      day = dateValue.substringAfter('/').substringAfter('/');

      return year + '-' + month + '-' + day;
    }
  }

  /**
   * @description This method is use to returns the set of year
   *
   * @param iterations as input
   *
   * @return stringDate
   */
  public static Set<String> yearRange(Integer iterations) {
    Set<String> yearsList = new Set<String>();
    Date nowDate = Date.today();

    for (Integer i = 0; i <= iterations; i++) {
      yearsList.add(String.valueOf(nowDate.year() - i));
    }
    return yearsList;
  }

  /**
   * @description This method is use to returns Date from sap value
   *
   * @param sapDateStr as input
   *
   * @return sapDate
   */
  public static Date sapStringToDate(String sapDateStr) {
    Date sapDate = null;

    if ((sapDateStr.length() == 8) && (Integer.valueOf(sapDateStr) > 0)) {
      Integer year = Integer.valueOf(CMN_UTIL_String.mid(sapDateStr, 0, 4));
      Integer month = Integer.valueOf(CMN_UTIL_String.mid(sapDateStr, 4, 2));
      Integer day = Integer.valueOf(CMN_UTIL_String.mid(sapDateStr, 6, 2));

      sapDate = Date.newInstance(year, month, day);
    }

    return sapDate;
  }

  /**
   * @description This method is use to returns the number of week of the current date
   *
   * @param dt as input
   *
   * @return weekNumber
   */
  public static Integer weekNumberFromDate(Date dt) {
    Datetime startOfTheYear = Datetime.newInstance(dt.year(), 1, 1); // This will get start of the year
    Integer yearStartOffset = Integer.valueOf(startOfTheYear.format('u')); // This will give the weekday Monday - 1, Tuesday - 2...

    Date startDate = startOfTheYear.date();
    Date newDate = dt;
    Integer weekNumber =
      (startDate.daysBetween(newDate) + yearStartOffset - 1) / 7 + 1;
    return weekNumber;
  }

  /**
   * @description This method to get the week end date based on week number and year
   *
   * @param weekNumber , year
   * @param year as input
   *
   * @return result
   */
  public static Date weekEndDateFromWeekNumber(
    Integer weekNumber,
    Integer year
  ) {
    Date endDate;
    Datetime startOfTheYear = Datetime.newInstance(year, 1, 1); // This will get start of the year
    Integer yearStartOffset = Integer.valueOf(startOfTheYear.format('u')); // This will give the weekday Monday - 1, Tuesday - 2...

    Date startDate = startOfTheYear.date();
    endDate = startDate - yearStartOffset + weekNumber * 7;
    return endDate;
  }

  /**
   * @description This method is use to returns datetime
   *
   * @param nextRun as input
   *
   * @return result
   */
  public static String getCronExpression(Datetime nextRun) {
    return nextRun == null
      ? null
      : String.format(
          CRON_FMT,
          new List<Object>{
            nextRun.second(),
            nextRun.minute(),
            nextRun.hour(),
            nextRun.day(),
            nextRun.month(),
            nextRun.year()
          }
        );
  }

  /**
   * @description This method is use to returns datetime
   *
   * @param aDatetime as input
   *
   * @return the full english month name
   */
  public static String monthNameFromDate(Datetime aDatetime) {
    return aDatetime == null ? null : aDatetime.format(WHOLE_MONTH_FMT);
  }

  /**
   * @description This method is use to returns month from date
   *
   * @param aDate as input
   *
   * @return The full english month name
   */
  public static String monthNameFromDate(Date aDate) {
    return aDate == null
      ? null
      : monthNameFromDate(
          Datetime.newInstance(aDate.year(), aDate.month(), aDate.day())
        );
  }
}