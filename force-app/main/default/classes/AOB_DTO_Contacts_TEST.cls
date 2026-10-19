@isTest
public class AOB_DTO_Contacts_TEST {
  @isTest
  static void testParse() {
    String json =
      '[' +
      '    {' +
      '        \"type\": \"PHONE\",' +
      '        \"value\": \"0824654443\",' +
      '        \"countryCode\": \"ZA\",' +
      '        \"extension\": \"\",' +
      '        \"preferredInd\": \"true\",' +
      '        \"contactPeriod\": \"ANYTIME\",' +
      '        \"obsoleteInd\": \"false\",' +
      '        \"phoneType\": \"2\"' +
      '    },' +
      '    {' +
      '        \"type\": \"PHONE\",' +
      '        \"value\": \"0823082431\",' +
      '        \"countryCode\": \"ZA\",' +
      '        \"extension\": \"\",' +
      '        \"preferredInd\": \"true\",' +
      '        \"contactPeriod\": \"DAYTIME\",' +
      '        \"obsoleteInd\": \"false\",' +
      '        \"phoneType\": \"1\"' +
      '    },' +
      '    {' +
      '        \"type\": \"EMAIL\",' +
      '        \"value\": \"testing@testing.com\",' +
      '        \"preferredInd\": \"true\",' +
      '        \"obsoleteInd\": \"false\"' +
      '    }' +
      ']';
    List<AOB_DTO_Contacts> r = AOB_DTO_Contacts.parse(json);
    System.assert(r != null);

    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    AOB_DTO_Contacts objJSON2Apex = new AOB_DTO_Contacts(
      System.JSON.createParser(json)
    );
    System.assert(objJSON2Apex != null);
    System.assert(objJSON2Apex.type_Z == null);
    System.assert(objJSON2Apex.value == null);
    System.assert(objJSON2Apex.countryCode == null);
    System.assert(objJSON2Apex.extension == null);
    System.assert(objJSON2Apex.preferredInd == null);
    System.assert(objJSON2Apex.contactPeriod == null);
    System.assert(objJSON2Apex.obsoleteInd == null);
    System.assert(objJSON2Apex.phoneType == null);
  }
}