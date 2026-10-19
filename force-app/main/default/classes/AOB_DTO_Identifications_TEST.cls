@IsTest
public class AOB_DTO_Identifications_TEST {
  // This test method should give 100% coverage
  static testMethod void testParse() {
    String json =
      '{' +
      '        \"type\": \"NATIONAL IDENTITY DOCUMENT\",' +
      '        \"number\": \"7206195272089\",' +
      '        \"issuingCountry\": \"ZA\",' +
      '        \"issuedDate\": \"2020-11-10\",' +
      '        \"expirationDate\": \"9999-12-31\"' +
      '    }';
    AOB_DTO_Identifications r = AOB_DTO_Identifications.parse(json);
    System.assert(r != null);

    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    AOB_DTO_Identifications objAOB_DTO_Identifications = new AOB_DTO_Identifications(
      System.JSON.createParser(json)
    );
    System.assert(objAOB_DTO_Identifications != null);
    System.assert(objAOB_DTO_Identifications.type_Z == null);
    System.assert(objAOB_DTO_Identifications.number_Z == null);
    System.assert(objAOB_DTO_Identifications.issuingCountry == null);
    System.assert(objAOB_DTO_Identifications.issuedDate == null);
    System.assert(objAOB_DTO_Identifications.expirationDate == null);
  }
}