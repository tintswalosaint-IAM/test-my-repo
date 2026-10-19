/**
 *  @description  class  INS_Address getting config details from custom metadata types.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * 
 * @date Feb 19th 2024
 * 
 * @description : Add with sharing declaration as per AppOmni finding
 * @story       : SFP-60091
 * @modified    : Jaco de Lange
 * @date        : 16 September 2026
 */
public with sharing class INS_Address {
    
    /**
 *  @description method class  getCountryOptions.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * 
 * @return List<Country_Codes__mdt>
 * @date Feb 19th 2024
 */
	@AuraEnabled(cacheable=true)
    public static List<Country_Codes__mdt> getCountryOptions() {
      	 return Country_Codes__mdt.getAll().values(); 
    }
}