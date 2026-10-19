/**
 * Class used as Wrapper Class to display select options
 *
 * <p>DBP-1159</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 23th 2020
 */
public class AOB_DTO_Customers {
    /*
     * @description CustomerRole class
     */
    public class CustomerRole {
        @AuraEnabled
        public String role { get; set; }
        @AuraEnabled
        public String startDate { get; set; }
        @AuraEnabled
        public String endDate { get; set; }
    }
    /*
     * @description PersonDetails class
     */
    public class PersonDetails {
        @AuraEnabled
        public String firstName { get; set; }
        @AuraEnabled
        public String lastName { get; set; }
        @AuraEnabled
        public String initials { get; set; }
        @AuraEnabled
        public String otherName { get; set; }
        @AuraEnabled
        public String birthName { get; set; }
        @AuraEnabled
        public String preferredName { get; set; }
        @AuraEnabled
        public String dob { get; set; }
        @AuraEnabled
        public String gender { get; set; }
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String maritalStatus { get; set; }
        @AuraEnabled
        public String citizenshipCountry { get; set; }
        @AuraEnabled
        public String nationality { get; set; }
        @AuraEnabled
        public String residenceCountry { get; set; }
        @AuraEnabled
        public String countryOfBirth { get; set; }
        @AuraEnabled
        public String ethnicity { get; set; }
    }
    /*
     * @description ProminentInfluentialPerson class
     */
    public class ProminentInfluentialPerson {
        @AuraEnabled
        public string pipInd { get; set; }
        @AuraEnabled
        public string relatedInd { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String relationType { get; set; }
    }
    /*
     * @description Customer class
     */
    public class Customer {
        @AuraEnabled
        public String uuid { get; set; }
        @AuraEnabled
        public String customerType { get; set; }
        @AuraEnabled
        public String relManagerLink { get; set; }
        @AuraEnabled
        public List<Tax> tax { get; set; }
        @AuraEnabled
        public String citizenshipCountry { get; set; }
        @AuraEnabled
        public String nationality { get; set; }
        @AuraEnabled
        public String countryOfBirth { get; set; }
        @AuraEnabled
        public String residenceCountry { get; set; }
        @AuraEnabled
        public PersonDetails personDetails { get; set; }
        @AuraEnabled
        public Links links { get; set; }
        @AuraEnabled
        public ProminentInfluentialPerson prominentInfluentialPerson { get; set; }
        @AuraEnabled
        public String prefLanguage { get; set; }
        @AuraEnabled
        public String mktgSegment { get; set; }
        @AuraEnabled
        public List<CustomerRole> customerRole { get; set; }
    }
    /*
     * @description Tax class
     */
    public class Tax {
        @AuraEnabled
        public String taxType;
        @AuraEnabled
        public String taxNumber;
    }
    /*
     * @description SourceOfFunds class
     */
    public class SourceOfFunds {
        @AuraEnabled
        public String sourceFundType;
        @AuraEnabled
        public String sourceFundTypeX;
        @AuraEnabled
        public String sourceFundAmount;
        @AuraEnabled
        public String currency_Z;

        public SourceOfFunds(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'currency') {
                            currency_Z = parser.getText();
                        } else if (text == 'sourceFundAmount') {
                            sourceFundAmount = parser.getText();
                        } else if (text == 'sourceFundType') {
                            sourceFundType = parser.getText();
                        } else if (text == 'sourceFundTypeX') {
                            sourceFundTypeX = parser.getText();
                        }else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    /*
     * @description parseFunds 
     * @param json
    */
    public static List<SourceOfFunds> parseFunds(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfJSON2Apex(parser);
    }
    /*
     * @description Links class
     */
    public class Links {
        public String allContacts;
        public String allAddresses;
        public String allIdentifications;
        public String allSourceOfFunds;
        public String allStatuses;
        public String allEmployments;
    }
    @AuraEnabled
    public Customer customer { get; set; }

    /*
     * @description parse 
     * @param json
    */
    public static AOB_DTO_Customers parse(String json) {
        return (AOB_DTO_Customers) System.JSON.deserialize(json, AOB_DTO_Customers.class);
    }
    /*
     * @description consumeObject 
     * @param parser
    */
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT || curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    /*
     * @description arrayOfJSON2Apex 
     * @param p
    */
    private static List<SourceOfFunds> arrayOfJSON2Apex(System.JSONParser p) {
        List<SourceOfFunds> res = new List<SourceOfFunds>();
        if (p.getCurrentToken() == null){
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new SourceOfFunds(p));
        }
        return res;
    }
}