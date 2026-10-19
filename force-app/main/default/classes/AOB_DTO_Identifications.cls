/**
 * Class used to Perform an API call to get Access token
 * 
 * <p>DBP-1279</p>
 * 
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 * 
 * @date Nov 23th 2020
 */
public with sharing class AOB_DTO_Identifications extends CMN_DTO_JsonBase{

    public AOB_DTO_Identifications(){}
    @auraEnabled
	public String type_Z {get;set;} // in json: type
    @auraEnabled
	public String number_Z {get;set;} // in json: number
	@auraEnabled
	public String issuingCountry {get;set;} 
	@auraEnabled
	public String issuedDate {get;set;} 
	@auraEnabled
	public String expirationDate {get;set;} 

    /**
	 * @description constuctor of the class used to explicitly parse the DTO object(reason: Use of reserved terms in the json response)
	 *
	 */
	public AOB_DTO_Identifications(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'type') {
						type_Z = parser.getText();
					} else if (text == 'number') {
						number_Z = parser.getText();
					} else if (text == 'issuingCountry') {
						issuingCountry = parser.getText();
					} else if (text == 'issuedDate') {
						issuedDate = parser.getText();
					} else if (text == 'expirationDate') {
						expirationDate = parser.getText();
					} else {
						consumeObject(parser);
					}
				}
			}
		}
	}
	 
	/**
	 * @description method used to parse to the DTO 
	 *
	 * @return AOB_DTO_Identifications
	 */
	public static AOB_DTO_Identifications parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new AOB_DTO_Identifications(parser);
	}
	
    /**
	 * @description helper method used whithin the parser
	 *
	 */
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	


}