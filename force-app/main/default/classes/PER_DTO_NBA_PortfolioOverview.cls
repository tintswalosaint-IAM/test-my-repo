/**
 * @description       : API DTO for the NBA portfolio overview	
 * @author            : Gul
 * @group             : Personalisation
 * @last modified on  : 25-04-2024
 * @last modified by  : Derek Hughes
**/
@SuppressWarnings('PMD.ExcessivePublicCount') // this is a DTO that has many public attributes
public with sharing class PER_DTO_NBA_PortfolioOverview {
    
    /**
    * @description Transforms the API DTO in a generic object for internal use
    * @author Derek Hughes | 25-04-2024 
    * @param portOverData 
    * @return DTO_PortfolioOverview 
    **/
    public static DTO_PortfolioOverview transformPortfolioOverviewData(PER_API_NBA_GetSinglePoap.DTO portOverData) {        
      
        DTO_PortfolioOverview wrap = new DTO_PortfolioOverview();

		Map<String, ProductDetail> productsByName = new Map<String, ProductDetail>{
			'Current_Account' => new ProductDetail('Current_Account','/per_overview_images/small/icn_wallet.png'),
			'Card' => new ProductDetail('Card','/per_overview_images/small/icn_card_standard.png'),
			'Home_Loan' => new ProductDetail('Home_Loan','/per_overview_images/small/icn_house.png'),
			'Vehicle_Finance' => new ProductDetail('Vehicle_Finance','/per_overview_images/small/icn_vehicles_car.png'),
			'Personal_Loan' => new ProductDetail('Personal_Loan','/per_overview_images/small/icn_cash_coins_and_note.png'),
			'Savings' => new ProductDetail('Savings','/per_overview_images/small/icn_product_savings.png'),
			'Other' => new ProductDetail('Other','/per_overview_images/small/icn_diamond_hand.png')
		};

        wrap.state = 'NODATA';
        wrap.portfolioOptions = new List<SelectOption>();

        if (portOverData.poapProducts != null) {
            wrap.state = 'OK';
            
            wrap.poapProducts = new PoapProducts();

            wrap.poapProducts.aeNumber = portOverData.poapProducts.aeNumber;
            wrap.poapProducts.portfolio_cd = portOverData.poapProducts.portfolio_cd;

			addProductDetail(productsByName, portOverData.poapProducts.prod1_name_rm, portOverData.poapProducts.prod1_cnt_rm, portOverData.poapProducts.prod1_bal_rm);
			addProductDetail(productsByName, portOverData.poapProducts.prod2_name_rm, portOverData.poapProducts.prod2_cnt_rm, portOverData.poapProducts.prod2_bal_rm);
			addProductDetail(productsByName, portOverData.poapProducts.prod3_name_rm, portOverData.poapProducts.prod3_cnt_rm, portOverData.poapProducts.prod3_bal_rm);
			addProductDetail(productsByName, portOverData.poapProducts.prod4_name_rm, portOverData.poapProducts.prod4_cnt_rm, portOverData.poapProducts.prod4_bal_rm);
			addProductDetail(productsByName, portOverData.poapProducts.prod5_name_rm, portOverData.poapProducts.prod5_cnt_rm, portOverData.poapProducts.prod5_bal_rm);
			addProductDetail(productsByName, portOverData.poapProducts.prod6_name_rm, portOverData.poapProducts.prod6_cnt_rm, portOverData.poapProducts.prod6_bal_rm);

            wrap.poapProducts.products = productsByName.values();

			for (ProductDetail product : wrap.poapProducts.products) {
				product.name = product.name.replaceAll('_', ' ');
			}
           
        }
       
        if (portOverData.PoapStats != null) {
            wrap.state = 'OK';

            wrap.poapStats = new PoapStats();

            wrap.poapStats.aeNumber = portOverData.PoapStats.aeNumber;
            wrap.poapStats.portfolio_cd = portOverData.poapStats.portfolio_cd;
            wrap.poapStats.rltnship_mngr_name = portOverData.poapStats.rltnship_mngr_name;
            wrap.poapStats.avg_ct_book_rm = Long.valueof(portOverData.poapStats.avg_ct_book_rm)/1000000;
            wrap.poapStats.avg_dt_book_rm = Long.valueof(portOverData.poapStats.avg_dt_book_rm)/1000000;
            wrap.poapStats.tot_oi_rm = Long.valueof(portOverData.poapStats.tot_oi_rm)/1000000;
            wrap.poapStats.tot_nii_rm = Long.valueof(portOverData.poapStats.tot_nii_rm)/1000000;
            wrap.poapStats.tot_nir_rm = Long.valueof(portOverData.poapStats.tot_nir_rm)/1000000;
            wrap.poapStats.active_cnt = Long.valueof(portOverData.poapStats.active_cnt);
            wrap.poapStats.primary_cnt = Long.valueof(portOverData.poapStats.primary_cnt);
            wrap.poapStats.dig_mb_cnt = Long.valueof(portOverData.poapStats.dig_mb_cnt);
            wrap.poapStats.dig_ib_cnt = Long.valueof(portOverData.poapStats.dig_ib_cnt);
            wrap.poapStats.dig_app_cnt = Long.valueof(portOverData.poapStats.dig_app_cnt);
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
	 * DTO as defined in the API specs
	 */
	@SuppressWarnings('PMD') 
    public class DTO_PortfolioOverview {
        @AuraEnabled public String state;   // NOCODE, NODATA, OK
        @AuraEnabled public List<SelectOption> portfolioOptions;
        @AuraEnabled public String portfolioCode;
        @AuraEnabled public String rmName;
        @AuraEnabled public PoapStats poapStats;
        @AuraEnabled public PoapProducts poapProducts;
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
    public class PoapProducts {
        @AuraEnabled public String aeNumber;
		@AuraEnabled public String portfolio_cd;
		@AuraEnabled public List<ProductDetail> products;
    }

	@SuppressWarnings('PMD') 
    public class PoapStats {
        @AuraEnabled public String aeNumber;
        @AuraEnabled public String portfolio_cd;
        @AuraEnabled public String rltnship_mngr_name;
		@AuraEnabled public Long avg_ct_book_rm;
		@AuraEnabled public Long avg_dt_book_rm;
		@AuraEnabled public Long tot_oi_rm;
		@AuraEnabled public Long tot_nii_rm;
		@AuraEnabled public Long tot_nir_rm;
		@AuraEnabled public Long active_cnt;
		@AuraEnabled public Long primary_cnt;
		@AuraEnabled public Long dig_mb_cnt;
		@AuraEnabled public Long dig_ib_cnt;
		@AuraEnabled public Long dig_app_cnt;
    }

	@SuppressWarnings('PMD') 
    public class SelectOption {
        @AuraEnabled public String 	label { get;set; }
        @AuraEnabled public String 	value { get;set; }
        @AuraEnabled public Boolean disabled { get;set; }
    }
}