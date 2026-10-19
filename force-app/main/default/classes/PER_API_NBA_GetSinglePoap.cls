/**
 * @description       : API Service for the Personlisation NBA Conversation reasons 
 * @test              : PER_API_NBA_Service_Test
 * @author            : Gul Aamir
 * @group             : Personalisation
 * @last modified on  : 25-04-2024
 * @last modified by  : Derek Hughes
**/
@SuppressWarnings('PMD.ExcessivePublicCount') // there is a DTO that has many public attributes
public with sharing class PER_API_NBA_GetSinglePoap extends PER_API_NBA_Service {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PER_API_NBA_GetSinglePoap');

    private static final String PATH_SINGLE_POAP = '/smart-conversations/single-poap';

    /**
    * @description Sends the API call for the specified customer and returns the response as a list of DTOs
    * @author Derek Hughes | 01-03-2024 
    * @param countryCode
    * @param rmAeCode 
    * @return DTO 
    **/
    public DTO call(String countryCode, String rmAeCode) {
        //TODO Country Code dynamic
        String requestBody = '{"countryCode": "{0}","aeNumber":"{1}"}';
        requestBody = requestBody.replace('{0}', countryCode);
        requestBody = requestBody.replace('{1}', rmAeCode);

		setResponseDtoType(DTO.class);

        DTO responses = (DTO) post(PATH_SINGLE_POAP, requestBody);

        return responses;
    }

    /**
     * DTO object to represnet the API responses
	 * DTO's violate many PMD rules such as public count and attribute naming conventions.
     */
	@SuppressWarnings('PMD') 
    @JsonAccess(deserializable='always')
    public class DTO {
        public PoapStats poapStats;
        public PoapProducts poapProducts;
    }

	@SuppressWarnings('PMD') 
    @JsonAccess(deserializable='always')
    public class PoapProducts {
        public String aeNumber;
        public String portfolio_cd;
        public String prod1_name_rm;
        public String prod1_cnt_rm;
        public String prod1_bal_rm;
        public String prod2_name_rm;
        public String prod2_cnt_rm;
        public String prod2_bal_rm;
        public String prod3_name_rm;
        public String prod3_cnt_rm;
        public String prod3_bal_rm;
        public String prod4_name_rm;
        public String prod4_cnt_rm;
        public String prod4_bal_rm;
        public String prod5_name_rm;
        public String prod5_cnt_rm;
        public String prod5_bal_rm;
        public String prod6_name_rm;
        public String prod6_cnt_rm;
        public String prod6_bal_rm;
        public String prod7_name_rm;
        public String prod7_cnt_rm;
        public String prod7_bal_rm;
        public String prod8_name_rm;
        public String prod8_cnt_rm;
        public String prod8_bal_rm;
    }

	@SuppressWarnings('PMD') 
    @JsonAccess(deserializable='always')
    public class PoapStats {
        public String aeNumber;
        public String portfolio_cd;
        public String rltnship_mngr_name;
        public String avg_ct_book_rm;
        public String avg_dt_book_rm;
        public String tot_oi_rm;
        public String tot_nii_rm;
        public String tot_nir_rm;
        public String active_cnt;
        public String primary_cnt;
        public String dig_mb_cnt;
        public String dig_ib_cnt;
        public String dig_app_cnt;
    }
 
}