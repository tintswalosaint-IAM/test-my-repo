/**
 * @description       : DTO for the AR NBA customer portolio 
 * @author            : Gul Aamir
 * @group             : Personalisation
 * @last modified on  : 25-04-2024
 * @last modified by  : Derek Hughes
**/
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.StdCyclomaticComplexity') // this is a DTO that has many public attributes
public with sharing class PER_DTO_NBA_CustomerOverview {
    
    /**
    * @description Converts the API DTO into this generic DTO structure 
    * @author Gul Aamir | 26-03-2024 
    * @param custOverData 
    * @return DTO_CustomerOverview 
    **/
	
	@SuppressWarnings('PMD.StdCyclomaticComplexity,PMD.CognitiveComplexity,PMD.NcssMethodCount,PMDCyclomaticComplexity') // many atributes to be mapped to the DTO
	public static DTO_CustomerOverview transformCustomerOverviewData(PER_API_NBA_GetSingleCoap.DTO custOverData) {  

        DTO_CustomerOverview wrap = new DTO_CustomerOverview();

		Map<String, ProductDetail> productsByName = new Map<String, ProductDetail>{
			'Current_Account' => new ProductDetail('Current_Account','/per_overview_images/small/icn_wallet.png'),
			'Card' => new ProductDetail('Card','/per_overview_images/small/icn_card_standard.png'),
			'Home_Loan' => new ProductDetail('Home_Loan','/per_overview_images/small/icn_house.png'),
			'Vehicle_Finance' => new ProductDetail('Vehicle_Finance','/per_overview_images/small/icn_vehicles_car.png'),
			'Personal_Loan' => new ProductDetail('Personal_Loan','/per_overview_images/small/icn_cash_coins_and_note.png'),
			'Savings' => new ProductDetail('Savings','/per_overview_images/small/icn_product_savings.png'),
			'Other' => new ProductDetail('Other','/per_overview_images/small/icn_diamond_hand.png')
		};

		if (custOverData.coapStatsAR != null) {

			wrap.coapStatsAR = new CoapStatsAR();

			wrap.coapStatsAR.cif_num = custOverData.coapStatsAR.cif_num;
			wrap.coapStatsAR.new_cust_n = convertToLong(custOverData.coapStatsAR.new_cust_n);
			wrap.coapStatsAR.active_customer_ind = custOverData.coapStatsAR.active_customer_ind; 
			wrap.coapStatsAR.primary_customer_ind = custOverData.coapStatsAR.primary_customer_ind;
			wrap.coapStatsAR.tot_oi = convertToLong(custOverData.coapStatsAR.tot_oi);
			wrap.coapStatsAR.oi_top20 = custOverData.coapStatsAR.oi_top20;
			wrap.coapStatsAR.avg_ct_book_bal = convertToLong(custOverData.coapStatsAR.avg_ct_book_bal);
			wrap.coapStatsAR.avg_cr_bal_top20 = custOverData.coapStatsAR.avg_cr_bal_top20;
			wrap.coapStatsAR.avg_dt_book_bal = convertToLong(custOverData.coapStatsAR.avg_dt_book_bal);
			wrap.coapStatsAR.avg_dt_bal_top20 = custOverData.coapStatsAR.avg_dt_bal_top20;
			wrap.coapStatsAR.dig_mb_status = custOverData.coapStatsAR.dig_mb_status;
			wrap.coapStatsAR.dig_mb_dt = custOverData.coapStatsAR.dig_mb_dt ==null ? null : convertToDate(custOverData.coapStatsAR.dig_mb_dt);
			wrap.coapStatsAR.dig_app_status = custOverData.coapStatsAR.dig_app_status;
			wrap.coapStatsAR.dig_app_dt = custOverData.coapStatsAR.dig_app_dt ==null ? null : convertToDate(custOverData.coapStatsAR.dig_app_dt);
			wrap.coapStatsAR.dig_ib_status = custOverData.coapStatsAR.dig_ib_status;
			wrap.coapStatsAR.dig_ib_dt = custOverData.coapStatsAR.dig_ib_dt ==null ? null : convertToDate(custOverData.coapStatsAR.dig_ib_dt);
		}
		else {
			wrap.coapStatsAR = null;
		}
      
		if (custOverData.coapProductsAR != null) {

			wrap.coapProductsAR  = new coapProductsAR();

			wrap.coapProductsAR.cif_num = custOverData.coapProductsAR.cif_num;
			wrap.coapProductsAR.new_cust_n = convertToLong(custOverData.coapProductsAR.new_cust_n);

			addProductDetail(productsByName, custOverData.coapProductsAR.prod1_name, custOverData.coapProductsAR.prod1_cnt, custOverData.coapProductsAR.prod1_bal);
			addProductDetail(productsByName, custOverData.coapProductsAR.prod2_name, custOverData.coapProductsAR.prod2_cnt, custOverData.coapProductsAR.prod2_bal);
			addProductDetail(productsByName, custOverData.coapProductsAR.prod3_name, custOverData.coapProductsAR.prod3_cnt, custOverData.coapProductsAR.prod3_bal);
			addProductDetail(productsByName, custOverData.coapProductsAR.prod4_name, custOverData.coapProductsAR.prod4_cnt, custOverData.coapProductsAR.prod4_bal);
			addProductDetail(productsByName, custOverData.coapProductsAR.prod5_name, custOverData.coapProductsAR.prod5_cnt, custOverData.coapProductsAR.prod5_bal);
			addProductDetail(productsByName, custOverData.coapProductsAR.prod6_name, custOverData.coapProductsAR.prod6_cnt, custOverData.coapProductsAR.prod6_bal);

			wrap.coapProductsAR.products = productsByName.values();

			for (ProductDetail product : wrap.coapProductsAR.products) {
				product.name = product.name.replaceAll('_', ' ');
			}

		}
		
		if (custOverData.coapDetailsAR != null) {

			wrap.coapDetailsAR  = new coapDetailsAR();

			wrap.coapDetailsAR.cif_num = custOverData.coapDetailsAR.cif_num;
			wrap.coapDetailsAR.new_cust_n = convertToLong(custOverData.coapDetailsAR.new_cust_n);
			wrap.coapDetailsAR.first_name = custOverData.coapDetailsAR.first_name;
			wrap.coapDetailsAR.last_name = custOverData.coapDetailsAR.last_name;
			wrap.coapDetailsAR.dateofbirth = custOverData.coapDetailsAR.dateofbirth == null ? null : convertToDate(custOverData.coapDetailsAR.dateofbirth);
			wrap.coapDetailsAR.gender = custOverData.coapDetailsAR.gender;
			wrap.coapDetailsAR.kyc_flag = custOverData.coapDetailsAR.kyc_flag;
			wrap.coapDetailsAR.martl_status = custOverData.coapDetailsAR.martl_status;
			wrap.coapDetailsAR.segment = custOverData.coapDetailsAR.segment;
			wrap.coapDetailsAR.brnch = custOverData.coapDetailsAR.brnch;
			wrap.coapDetailsAR.sub_segment = custOverData.coapDetailsAR.sub_segment;
			wrap.coapDetailsAR.id_type = custOverData.coapDetailsAR.id_type;
			wrap.coapDetailsAR.id_num = custOverData.coapDetailsAR.id_num;
			wrap.coapDetailsAR.pref_phn_num = custOverData.coapDetailsAR.pref_phn_num; 
			wrap.coapDetailsAR.pref_cell_num = custOverData.coapDetailsAR.pref_cell_num;
			wrap.coapDetailsAR.pref_email = custOverData.coapDetailsAR.pref_email;
			wrap.coapDetailsAR.emplmnt_status = custOverData.coapDetailsAR.emplmnt_status; 
			wrap.coapDetailsAR.emplr_name = custOverData.coapDetailsAR.emplr_name;
			wrap.coapDetailsAR.address = custOverData.coapDetailsAR.address;
			wrap.coapDetailsAR.indstry = custOverData.coapDetailsAR.indstry;
			wrap.coapDetailsAR.gross_sal = Double.valueof(custOverData.coapDetailsAR.gross_sal);
			wrap.coapDetailsAR.occuptn = custOverData.coapDetailsAR.occuptn;
			wrap.coapDetailsAR.staff = custOverData.coapDetailsAR.staff;
		}
       
		if (custOverData.coapMaturityAR != null) {

			wrap.coapMaturityAR  = new coapMaturityAR();

			wrap.coapMaturityAR.cif_num = custOverData.coapMaturityAR.cif_num;
			wrap.coapMaturityAR.new_cust_n = convertToLong(custOverData.coapMaturityAR.new_cust_n);
			wrap.coapMaturityAR.mat_term_1 = convertToLong(custOverData.coapMaturityAR.mat_term_1);
			wrap.coapMaturityAR.mat_prod_1 = custOverData.coapMaturityAR.mat_prod_1;
			wrap.coapMaturityAR.mat_dt_1 = custOverData.coapMaturityAR.mat_dt_1 == null ? null : convertToDate(custOverData.coapMaturityAR.mat_dt_1);
			wrap.coapMaturityAR.mat_book_bal_1 = custOverData.coapMaturityAR.mat_book_bal_1; 
			wrap.coapMaturityAR.mat_intrnl_acc_num_1 = custOverData.coapMaturityAR.mat_intrnl_acc_num_1;
			wrap.coapMaturityAR.mat_accrued_interest_1 = custOverData.coapMaturityAR.mat_accrued_interest_1;
			wrap.coapMaturityAR.mat_term_2 = convertToLong(custOverData.coapMaturityAR.mat_term_2);
			wrap.coapMaturityAR.mat_prod_2 = custOverData.coapMaturityAR.mat_prod_2;
			wrap.coapMaturityAR.mat_dt_2 = custOverData.coapMaturityAR.mat_dt_2 == null ? null : convertToDate(custOverData.coapMaturityAR.mat_dt_2);
			wrap.coapMaturityAR.mat_book_bal_2 = custOverData.coapMaturityAR.mat_book_bal_2;
			wrap.coapMaturityAR.mat_intrnl_acc_num_2 = custOverData.coapMaturityAR.mat_intrnl_acc_num_2;
			wrap.coapMaturityAR.mat_accrued_interest_2 = custOverData.coapMaturityAR.mat_accrued_interest_2;
			wrap.coapMaturityAR.mat_term_3 = convertToLong(custOverData.coapMaturityAR.mat_term_3);
			wrap.coapMaturityAR.mat_prod_3 = custOverData.coapMaturityAR.mat_prod_3;
			wrap.coapMaturityAR.mat_dt_3 = custOverData.coapMaturityAR.mat_dt_3 == null ? null : convertToDate(custOverData.coapMaturityAR.mat_dt_3);
			wrap.coapMaturityAR.mat_book_bal_3 = custOverData.coapMaturityAR.mat_book_bal_3;
			wrap.coapMaturityAR.mat_intrnl_acc_num_3 = custOverData.coapMaturityAR.mat_intrnl_acc_num_3;
			wrap.coapMaturityAR.mat_accrued_interest_3 = custOverData.coapMaturityAR.mat_accrued_interest_3;
		}

        return wrap;
    }

	/**
	* @description Adds a product detail to the map if there is a product name
	* @author Derek Hughes | 04-04-2024 
	* @param productsByName 
	* @param name 
	* @param cnt 
	* @param bal 
	**/
	@SuppressWarnings('PMD.ExcessiveParameterList') 
	private static void addProductDetail (Map<String, ProductDetail> productsByName, String name, String cnt, String bal) {

		if (String.IsNotBlank(name)) {
		
			ProductDetail productDetail = productsByName.get(name);
			
			if (productDetail == null) {
				productDetail = new ProductDetail(name, '');
				productsByName.put(name, productDetail);
			}

			productDetail.count = convertToLong(cnt);
			productDetail.balance = convertToLong(bal);
		}

	}

	/**
	* @description Converts a string into a long 
	* @author Gul Aamir | 26-03-2024 
	* @param numberText 
	* @return long 
	**/
	private static long convertToLong (String numberText) {
		try {
			return Long.valueof(numberText);
		}
		catch (Exception ex) {
			return null;
		}	

	}

	/**
	* @description Converts a UNIX milissecond data value into a date
	* @author Gul Aamir | 26-03-2024 
	* @param numberText 
	* @return Date 
	**/
	private static Date convertToDate(String numberText){
		try{
			return DateTime.newInstance(convertToLong(numberText)).Date();
		}
		catch (Exception ex) {
			return null;
		}	
	}

	/**
	 * DTO as defined by the API specs
	 */
    @SuppressWarnings('PMD') 
    public class DTO_CustomerOverview {
        @AuraEnabled public Account account;
        @AuraEnabled public CoapStatsAR coapStatsAR;
        @AuraEnabled public CoapProductsAR coapProductsAR;
        @AuraEnabled public CoapDetailsAR coapDetailsAR;
        @AuraEnabled public CoapMaturityAR coapMaturityAR;
    }
	
    @SuppressWarnings('PMD') 
	public class ProductDetail {
		@AuraEnabled public String name;
		@AuraEnabled public String iconName;
		@AuraEnabled public Long count;
		@AuraEnabled public Long balance;

		public ProductDetail (String productName, String iconName) {
			this.name = productName;
			this.iconName = iconName;
		}
	}

    @SuppressWarnings('PMD') 
    public class CoapProductsAR {
		@AuraEnabled public String cif_num;
		@AuraEnabled public Long new_cust_n;
		@AuraEnabled public List<ProductDetail> products;
	}


    @SuppressWarnings('PMD') 
	public class CoapDetailsAR {
		@AuraEnabled public String cif_num;
		@AuraEnabled public Long new_cust_n;
		@AuraEnabled public String first_name;
		@AuraEnabled public String last_name;
		@AuraEnabled public Date dateofbirth;
		@AuraEnabled public String gender;
		@AuraEnabled public String kyc_flag;
		@AuraEnabled public String martl_status;
		@AuraEnabled public String segment;
		@AuraEnabled public String brnch;
		@AuraEnabled public String sub_segment;
		@AuraEnabled public String id_type;
		@AuraEnabled public String id_num;
		@AuraEnabled public String pref_phn_num;
		@AuraEnabled public String pref_cell_num;
		@AuraEnabled public String pref_email;
		@AuraEnabled public String emplmnt_status;
		@AuraEnabled public String emplr_name;
		@AuraEnabled public String address;
		@AuraEnabled public String indstry;
		@AuraEnabled public Double gross_sal;
		@AuraEnabled public String occuptn;
		@AuraEnabled public String staff;
	}

    @SuppressWarnings('PMD') 
	public class CoapMaturityAR {
		@AuraEnabled public String cif_num;
		@AuraEnabled public Long new_cust_n;
		@AuraEnabled public Long mat_term_1;
		@AuraEnabled public String mat_prod_1;
		@AuraEnabled public Date mat_dt_1;
		@AuraEnabled public String mat_book_bal_1;
		@AuraEnabled public String mat_intrnl_acc_num_1;
		@AuraEnabled public String mat_accrued_interest_1;
		@AuraEnabled public Long mat_term_2;
		@AuraEnabled public String mat_prod_2;
		@AuraEnabled public Date mat_dt_2;
		@AuraEnabled public String mat_book_bal_2;
		@AuraEnabled public String mat_intrnl_acc_num_2;
		@AuraEnabled public String mat_accrued_interest_2;
		@AuraEnabled public Long mat_term_3;
		@AuraEnabled public String mat_prod_3;
		@AuraEnabled public Date mat_dt_3;
		@AuraEnabled public String mat_book_bal_3;
		@AuraEnabled public String mat_intrnl_acc_num_3;
		@AuraEnabled public String mat_accrued_interest_3;
	}

    @SuppressWarnings('PMD') 
	public class CoapStatsAR {
		@AuraEnabled public String cif_num;
		@AuraEnabled public Long new_cust_n;
		@AuraEnabled public String active_customer_ind;
		@AuraEnabled public String primary_customer_ind;
		@AuraEnabled public Long tot_oi;
		@AuraEnabled public String oi_top20;
		@AuraEnabled public Long avg_ct_book_bal;
		@AuraEnabled public String avg_cr_bal_top20;
		@AuraEnabled public Long avg_dt_book_bal;
		@AuraEnabled public String avg_dt_bal_top20;
		@AuraEnabled public String dig_mb_status;
		@AuraEnabled public Date dig_mb_dt;
		@AuraEnabled public String dig_app_status;
		@AuraEnabled public Date dig_app_dt;
		@AuraEnabled public String dig_ib_status;
		@AuraEnabled public Date dig_ib_dt;
	}
}