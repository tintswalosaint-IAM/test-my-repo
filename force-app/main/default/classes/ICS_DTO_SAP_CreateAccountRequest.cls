/*************************************************************
 * @description SFP-32986 Wrapper Class used to frame data for create account
 *
 * @autor Ridhima
 *
 * @date OCT 21 2024
 ***************************************************************
 * Last Modified By Ridhima
 * Last Modified Date 21/10/2024
 * Last Modified Description: Initial Version
 */
public with sharing class ICS_DTO_SAP_CreateAccountRequest {

    public List<Account> Account;

    public class Account {
        public AccountNumber AccountNumber;
        public List<ProductInstanceReference> ProductInstanceReference;
        public List<CustomerCashFlowPosition> CustomerCashFlowPosition;
        public AdditionalData AdditionalData;
    }

    public class AccountNumber {
        public List<AccountIdentification> AccountIdentification;
    }

    public class AccountIdentification {
        public String AccountIdentificationType;
        public IdentifierValueWrapper AccountIdentification;
    }

    public class IdentifierValueWrapper {
        public IdentifierValue IdentifierValue;
        public IdentifierStartDate IdentifierStartDate;
        public IdentifierIssuingAuthority IdentifierIssuingAuthority;
    }

    public class IdentifierValue {
        public String Value;
    }

    public class IdentifierStartDate {
        public String DateTimeContent;
    }
	  public class IdentifierIssuingAuthority {
        public PartyInvolvement PartyInvolvement;
    }

    public class PartyInvolvement {
        public String PartyInvolvementType;
    }
    public class ProductInstanceReference {
        public String ProductIdentificationType;
        public ProductIdentification ProductIdentification;
    }

    public class ProductIdentification {
        public IdentifierValue IdentifierValue;
    }

    public class CustomerCashFlowPosition {
        public PositionAmount PositionAmount;
    }

    public class PositionAmount {
        public String AmountCurrency;
    }

    public class AdditionalData {
        public CategoryInformation CategoryInformation;
    }

    public class CategoryInformation {
        public List<Category> Category;
    }

    public class Category {
        public String CategoryItem;
        public List<CategoryDetail> CategoryDetails;
    }

    public class CategoryDetail {
        public String CategoryType;
        public String CategoryIdentifierValue;
    }
    public ICS_DTO_SAP_CreateAccountRequest(){
        String productInfo = 'Optimum';
        if (productInfo != null) {
            productInfo = 'Optimum';
        }
    }
}