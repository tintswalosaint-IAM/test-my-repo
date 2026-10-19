/**
 * @description The REST Web Service DTO with Wrappers to update the WFR Status on Application record
 *
 * <p>SFP-11823</p>
 *
 * @author Mark Bailey (mark.bailey2@standardbank.co.za)
 *
 * @date April 14th 2022
 */

/**
 * @description class to format API Request structure
*/
public with sharing class AOB_DTO_HttpWfrNotify {
    /**
     * @description class to format API Request structure
     */
	public class WfrNotify {
        /**
         * @description class to format API Request structure
         */
		public String wfrStatus { get; set; }
		public String wfrMessage { get; set; }
		public String wfrErrorCode { get; set; }
	}
	/*
     * @description parse 
     * @param json
     * @return AOB_DTO_HttpWfrNotify
    */
    public static AOB_DTO_HttpWfrNotify parse(String json) {
        return (AOB_DTO_HttpWfrNotify) System.JSON.deserialize(json, AOB_DTO_HttpWfrNotify.class);
    }
}