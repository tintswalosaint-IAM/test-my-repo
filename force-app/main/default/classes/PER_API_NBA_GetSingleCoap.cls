/**
 * @description       : Get the customer overview data for a single client
 * @author            : Gul Aamir
 * @group             : Personalisation
 * @last modified on  : 25-04-2024
 * @last modified by  : Derek Hughes
**/
@SuppressWarnings('PMD.ExcessivePublicCount') // there is a DTO that has many public attributes
public with sharing class PER_API_NBA_GetSingleCoap extends PER_API_NBA_Service {
	
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PER_API_NBA_GetSingleCoap');

    private static final String PATH_SINGLE_COAP = '/smart-conversations/single-coap';
    
    /**
    * @description Calls the API to get the customer overview data for the specified customer number (CIF)
    * @author Derek Hughes | 18-04-2024 
	* @param countryCode
    * @param custNum       -- the CIF number without the country code or system code
    * @return DTO 
    **/
    public DTO call(String countryCode, String custNum) {
		if (String.isBlank(custNum)) {
			return new DTO();
		}

        Long custNumber = Long.valueof(custNum);

        String requestBody = '{"countryCode": "'+countryCode+'","newCustN":'+custNumber+'}';

		setResponseDtoType(DTO.class);

        DTO dto = (DTO) post(PATH_SINGLE_COAP, requestBody);

		if(dto.coapMaturityAR != null){
			if (String.IsBlank(dto.coapMaturityAR.mat_prod_1)) {
				dto.coapMaturityAR.mat_term_1 = null;
			}
			if (String.IsBlank(dto.coapMaturityAR.mat_prod_2)) {
				dto.coapMaturityAR.mat_term_2 = null;
			}
			if (String.IsBlank(dto.coapMaturityAR.mat_prod_3)) {
				dto.coapMaturityAR.mat_term_3 = null;
			}
		}

		LOGGER.info('call: dto: '+dto);

        return dto;
    }

	/**
     * DTO object to represnet the API dto
	 * DTO's violate many PMD rules such as public count and attribute naming conventions.
	 * JsonAccess required to allowed package code in another namepace to use this class
     */
	@SuppressWarnings('PMD') 
    @JsonAccess(deserializable='always') 
	public class DTO {
        public CoapStatsAR coapStatsAR;
        public CoapProductsAR coapProductsAR;
        public CoapDetailsAR coapDetailsAR;
        public CoapMaturityAR coapMaturityAR;
    }

	@SuppressWarnings('PMD') 
    @JsonAccess(deserializable='always')
    public class CoapProductsAR {
		public String cif_num;
		public String new_cust_n;
		public String prod1_name;
		public String prod2_name;
		public String prod3_name;
		public String prod4_name;
		public String prod5_name;
		public String prod6_name;
		public String prod7_name;
		public String prod8_name;
		public String prod1_cnt;
		public String prod2_cnt;
		public String prod3_cnt;
		public String prod4_cnt;
		public String prod5_cnt;
		public String prod6_cnt;
		public String prod7_cnt;
		public String prod8_cnt;
		public String prod1_bal;
		public String prod2_bal;
		public String prod3_bal;
		public String prod4_bal;
		public String prod5_bal;
		public String prod6_bal;
		public String prod7_bal;
		public String prod8_bal;
	}

	@SuppressWarnings('PMD') 
    @JsonAccess(deserializable='always')
	public class CoapDetailsAR {
		public String cif_num;
		public String new_cust_n;
		public String first_name;
		public String last_name;
		public String dateofbirth;
		public String gender;
		public String kyc_flag;
		public String martl_status;
		public String segment;
		public String brnch;
		public String sub_segment;
		public String id_type;
		public String id_num;
		public String pref_phn_num;
		public String pref_cell_num;
		public String pref_email;
		public String emplmnt_status;
		public String emplr_name;
		public String address;
		public String indstry;
		public Double gross_sal;
		public String occuptn;
		public String staff;
	}

	@SuppressWarnings('PMD') 
    @JsonAccess(deserializable='always')
	public class CoapMaturityAR {
		public String cif_num;
		public String new_cust_n;
		public String mat_term_1;
		public String mat_prod_1;
		public String mat_dt_1;
		public String mat_book_bal_1;
		public String mat_intrnl_acc_num_1;
		public String mat_accrued_interest_1;
		public String mat_term_2;
		public String mat_prod_2;
		public String mat_dt_2;
		public String mat_book_bal_2;
		public String mat_intrnl_acc_num_2;
		public String mat_accrued_interest_2;
		public String mat_term_3;
		public String mat_prod_3;
		public String mat_dt_3;
		public String mat_book_bal_3;
		public String mat_intrnl_acc_num_3;
		public String mat_accrued_interest_3;
	}

	@SuppressWarnings('PMD') 
    @JsonAccess(deserializable='always')
	public class CoapStatsAR {
		public String cif_num;
		public String new_cust_n;
		public String active_customer_ind;
		public String primary_customer_ind;
		public String tot_oi;
		public String oi_top20;
		public String avg_ct_book_bal;
		public String avg_cr_bal_top20;
		public String avg_dt_book_bal;
		public String avg_dt_bal_top20;
		public String dig_mb_status;
		public String dig_mb_dt;
		public String dig_app_status;
		public String dig_app_dt;
		public String dig_ib_status;
		public String dig_ib_dt;
	}
}