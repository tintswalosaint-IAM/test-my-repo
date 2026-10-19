@isTest
public class AOB_DTO_Customers_TEST {
  @isTest
  static void testParse() {
    String json = '{\"customer\":{\"uuid\":\"02002100-0039-1eeb-88e9-2b7dc1bb9594\",\"customerType\":\"INDIVIDUAL\",\"relManagerLink\":\"\",\"personDetails\":{\"firstName\":\"NKHUMBULEN\",\"lastName\":\"RATSHITANGA\",\"initials\":\"N\",\"otherName\":\"\",\"birthName\":\"\",\"preferredName\":\"\",\"dob\":\"1972-06-19\",\"gender\":\"MALE\",\"title\":\"MR\",\"maritalStatus\":\"SINGLE\",\"citizenshipCountry\":\"AD\",\"nationality\":\"ZA\",\"countryOfBirth\":\"ZA\",\"ethnicity\":\"\"},\"links\":{\"allContacts\":\"/external-partner/customers/02002100-0039-1eeb-88e9-2b7dc1bb9594/contacts\",\"allAddresses\":\"/external-partner/customers/02002100-0039-1eeb-88e9-2b7dc1bb9594/addresses\",\"allIdentifications\":\"/external-partner/customers/02002100-0039-1eeb-88e9-2b7dc1bb9594/identifications\",\"allSourceOfFunds\":\"/external-partner/customers/02002100-0039-1eeb-88e9-2b7dc1bb9594/sourceOfFunds\",\"allStatuses\":\"/external-partner/customers/02002100-0039-1eeb-88e9-2b7dc1bb9594/statuses\",\"allEmployments\":\"/external-partner/customers/02002100-0039-1eeb-88e9-2b7dc1bb9594/employment\"},\"prominentInfluentialPerson\":{\"pipInd\":\"false\",\"relatedInd\":\"false\",\"name\":\" \",\"relationType\":\"\"},\"prefLanguage\":\"EN\",\"mktgSegment\":\"110\",\"customerRole\":[{\"role\":\"BUP014\",\"startDate\":\"2020-11-10\",\"endDate\":\"9999-12-31\"}]}}';
    AOB_DTO_Customers obj = AOB_DTO_Customers.parse(json);
    System.assert(obj != null);
  }
}