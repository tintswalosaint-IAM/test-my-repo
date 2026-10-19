/**
 * Class used as Wrapper Class to display select options
 * 
 * <p>DBP-1108</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 23th 2020
 */
public class AOB_DTO_Contacts {
  public String type_Z { get; set; } // in json: type
  public String value { get; set; }
  public String countryCode { get; set; }
  public String extension { get; set; }
  public String preferredInd { get; set; }
  public String contactPeriod { get; set; }
  public String obsoleteInd { get; set; }
  public String phoneType { get; set; }
  public String startDate { get; set; }
  public String endDate { get; set; }

  public AOB_DTO_Contacts(JSONParser parser) {
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String text = parser.getText();
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          if (text == 'type') {
            type_Z = parser.getText();
          } else if (text == 'value') {
            value = parser.getText();
          } else if (text == 'countryCode') {
            countryCode = parser.getText();
          } else if (text == 'extension') {
            extension = parser.getText();
          } else if (text == 'preferredInd') {
            preferredInd = parser.getText();
          } else if (text == 'contactPeriod') {
            contactPeriod = parser.getText();
          } else if (text == 'obsoleteInd') {
            obsoleteInd = parser.getText();
          } else if (text == 'phoneType') {
            phoneType = parser.getText();
          } else if (text == 'startDate') {
            startDate = parser.getText();
          } else if (text == 'endDate') {
            endDate = parser.getText();
          } else {
            System.debug(
              LoggingLevel.WARN,
              'JSON2Apex consuming unrecognized property: ' + text
            );
            consumeObject(parser);
          }
        }
      }
    }
  }

  public static List<AOB_DTO_Contacts> parse(String json) {
    System.JSONParser parser = System.JSON.createParser(json);
    return arrayOfJSON2Apex(parser);
  }

  public static void consumeObject(System.JSONParser parser) {
    Integer depth = 0;
    do {
      System.JSONToken curr = parser.getCurrentToken();
      if (
        curr == System.JSONToken.START_OBJECT ||
        curr == System.JSONToken.START_ARRAY
      ) {
        depth++;
      } else if (
        curr == System.JSONToken.END_OBJECT ||
        curr == System.JSONToken.END_ARRAY
      ) {
        depth--;
      }
    } while (depth > 0 && parser.nextToken() != null);
  }

  private static List<AOB_DTO_Contacts> arrayOfJSON2Apex(System.JSONParser p) {
    List<AOB_DTO_Contacts> res = new List<AOB_DTO_Contacts>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new AOB_DTO_Contacts(p));
    }
    return res;
  }
}