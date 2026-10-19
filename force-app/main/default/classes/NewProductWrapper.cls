/**
 *  @description wrapper class  NewProductWrapper for INS_Product_Rules.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param .
 * @return .
 * @date Nov 07th 2023
 */
public class NewProductWrapper {

	public ProductKey productKey;
	public String productId;	//4d4ad02e-3a29-4bcf-a0a9-13b38d2121f2
	public String country;	//UG
	public String companyId;	//7a0ffbb8-8c10-41cf-9197-6f81f5363bc1
	public String underwriterId;	//7b0ffbb8-8c10-41cf-9197-6f81f5363bc1
	public String name;	//Flexi Protector (Uganda)
	public String productCode;	//UFA
	public String description;	//Flexi Protector (Uganda)
	public Integer productStatus;	//0
	public String version;	//1
	public ClsCurrencies[] currencies;
	public ProductSections[] sections;
	public ProductRating productRating;
	public boolean allowMultipleVersions;
	public String startDate;	//2023-09-01T00:00:00
	public String endDate;	//2000-06-23T00:00:00
	public String regionCode;	//
	public Integer countryCode;	//0
	public clsTaxType taxType;
	public String quoteNumberPrefix;	//UFA
	public String policyNumberPrefix;	//UFA
	public String claimNumberPrefix;	//
	public Integer quoteSequenceNumber;	//0
	public Integer policySequenceNumber;	//0
	public Integer claimSequenceNumber;	//0
	public ProductItems[] productItems;
    
    /**
 * @description wrapper class  ProductKey.
 *
 * @param .
 * @return .
 */
	class ProductKey {
	}
    /**
 * @description wrapper class  ClsCurrencies.
 *
 * @param .
 * @return .
 */
    
	class ClsCurrencies {
	}
    
    /**
 * @description wrapper class  ProductSections.
 *
 * @param .
 * @return .
 */
	public class ProductSections {
		public ProductSectionKey productSectionKey;
		public String productSectionId;	//b7701d9f-0407-4d70-9b6a-6ff9814a41e2
		public String productId;	//4d4ad02e-3a29-4bcf-a0a9-13b38d2121f2
		public Integer sectionType;	//0
		public String parentSectionId;	//00000000-0000-0000-0000-000000000000
		public String description;	//Flexi Protector Main Insured Member(s)
		public String name;	//MainInsured
		public Integer minItems;	//1
		public Integer maxItems;	//1
		public Integer minValue;	//1250000
		public Integer maxValue;	//30000000
		public boolean required;
		public boolean isDisplay;
		public ProductItems[] productItems;
	}
    
     /**
 * @description wrapper class  ProductSectionKey.
 *
 * @param .
 * @return .
 */
	public class ProductSectionKey {
	}
    
     /**
 * @description wrapper class  ProductItems.
 *
 * @param .
 * @return .
 */
	public class ProductItems {
        /**
         * @description isDisplay.         
        */
        public Boolean isDisplay{get;set;}
        /**
         * @description maxItems.         
        */
		public Integer maxItems{get;set;}
        /**
         * @description minItems.         
        */
		public Integer minItems{get;set;}
        /**
         * @description minValue.         
        */
		public Integer minValue{get;set;}
        /**
         * @description itemType.         
        */
		public String itemType{get;set;}
        /**
         * @description maxValue.         
        */
		public Integer maxValue{get;set;}
        /**
         * @description description.         
        */
		public String description{get;set;}
        /**
         * @description required.         
        */
		public Boolean required{get;set;}
        /**
         * @description status.         
        */
		public String status{get;set;}
        /**
         * @description requiredItemTypes.         
        */
		public list<String> requiredItemTypes{get;set;}
        /**
         * @description isChildCollection.         
        */
		public Boolean isChildCollection{get;set;}
        /**
         * @description childItems.         
        */
		public list<ChildItems> childItems{get;set;}
        /**
         * @description name.         
        */
		public String name{get;set;}
        /**
         * @description itemProperties.         
        */
		public list<ItemProperties> itemProperties{get;set;}
        /**
         * @description sectionId.         
        */
		public String sectionId{get;set;}
        /**
         * @description parentItemId.         
        */
		public String parentItemId{get;set;}
        /**
         * @description productItemId.         
        */
		public String productItemId{get;set;}
        /**
         * @description productId.         
        */
		public String productId{get;set;}
        /**
         * @description productItemKey.         
        */
		public String productItemKey{get;set;}
	}
    /**
 * @description wrapper class  ProductItemKey.
 *
 * @param .
 * @return .
 */
    
	public class ProductItemKey {
	}
    /**
 * @description wrapper class  RequiredItemTypes.
 *
 * @param .
 * @return .
 */
    
	public class RequiredItemTypes {
	}
    /**
 * @description inner class xhilditems
 */
    
	public class ChildItems {
    /**
 * @description getter setter status
 */
        public String status{get;set;}
            /**
 * @description getter setter minItems
 */
		public Integer minItems{get;set;}
            /**
 * @description getter setter itemType
 */
		public String itemType{get;set;}
            /**
 * @description getter setter maxItems
 */
		public Integer maxItems{get;set;}
            /**
 * @description getter setter description
 */
		public String description{get;set;}
            /**
 * @description getter setter minValue
 */
		public Integer minValue{get;set;}
            /**
 * @description getter setter isChildCollection
 */
		public Boolean isChildCollection{get;set;}
            /**
 * @description getter setter maxValue
 */
		public Integer maxValue{get;set;}
            /**
 * @description getter setter name
 */
		public String name{get;set;}
            /**
 * @description getter setter required
 */
		public Boolean required{get;set;}
            /**
 * @description getter setter sectionId
 */
		public String sectionId{get;set;}
            /**
 * @description getter setter isDisplay
 */
		public Boolean isDisplay{get;set;}
            /**
 * @description getter setter productId
 */
		public String productId{get;set;}
            /**
 * @description getter setter requiredItemTypes
 */
		public list<String> requiredItemTypes{get;set;}
            /**
 * @description getter setter parentItemId
 */
		public String parentItemId{get;set;}
            /**
 * @description getter setter childItems
 */
		public list<ChildItems> childItems{get;set;}
            /**
 * @description getter setter productItemId
 */
		public String productItemId{get;set;}
            /**
 * @description getter setter itemProperties
 */
		public list<ItemProperties> itemProperties{get;set;}
            /**
 * @description getter setter productItemKey 
 */
		public String productItemKey{get;set;}
        
	}
    /**
 * @description wrapper class  ItemProperties.

 */
    
	public class ItemProperties {
		public String itemPropertyId;	//0fc4d3d7-77cf-408e-a28f-eca66fa283d3
		public String productItemId;	//d9df4a88-b86f-4663-b7de-b4e67780ad7d
		public String name;	//Surname
		public clsValue value;
		public String valueType;	//Number
		public boolean required;
		public String validator;	//0
		public String validatorType;	//0
		public String default_g;	// 
		public boolean isLookup;
		public String lookupName;	//flexifuneral
		public String controlType;	//text
		public boolean isRatingFactor;
		public String lookUpValue;	//
		public String label;	//Surname
		public String categories;	//funeral
		public String description;	//Main insureds surname
		public boolean isDisplay;
		public Integer ordinal;	//0
	}
    /**
 * @description wrapper class  cls_value.

 */
    
	class clsValue {
	}
    /**
 * @description wrapper class  ProductRating.

 */
	class ProductRating {
	}
    /**
 * @description wrapper class  clsTaxType.

 */
	class clsTaxType {
	}
	
}