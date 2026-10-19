/**
 * Contains the card personalization data that will be displayed in protect your card and personalize your card
 *
 * <p>DPB-1285 and DPB-1286</p>
 *
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Nov 24th 2020
 * 
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed SFP-12975 16-05-2022 Gill Lumley   Remove hardcoded salutation (was hardcoded to "Mr")
 */
public with sharing class AOB_DTO_CardPersonalization {
    @AuraEnabled
    public Integer errorCode { get; set; }
    @AuraEnabled
    public String message { get; set; }
    @AuraEnabled
    public String currencyString { get; set; }
    @AuraEnabled
    public String customerFirstName { get; set; }
    @AuraEnabled
    public String salutation { get; set; }
    @AuraEnabled
    public String TermAndConditions { get; set; }
    @AuraEnabled
    public AOB_DTO_FlowScreenRecord estimatedMonthlyRepayment { get; set; }
    @AuraEnabled
    public AOB_DTO_FlowScreenRecord estimatedMonthlyRepaymentWithIns { get; set; }
    @AuraEnabled
    public Decimal minimumMonthlyRepayment { get; set; }
    @AuraEnabled
    public Decimal maxRepaymentAmount { get; set; }
    @AuraEnabled
    public Integer creditLimit { get; set; }
    @AuraEnabled
    public boolean mustHaveInsurrance { get; set; }
    @AuraEnabled
    public Boolean hasInsurance { get; set; }
    @AuraEnabled
    public String productName { get; set; }
    @AuraEnabled
    public String selectedInsurance { get; set; }
    @AuraEnabled
    public PersonalizeCard personalizeCard { get; set; }
    @AuraEnabled
    public Map<String, Insurance> insurances { get; set; }
    @AuraEnabled
    public List<AOB_DTO_FlowScreenRecord> assuranceFlowRecords { get; set; }
    @AuraEnabled
    public List<Scale> scales { get; set; } // To calculate the initiation fee
    @AuraEnabled
    public String productInsuranceId { get; set; }
    @AuraEnabled
    public String productId { get; set; }
    @AuraEnabled
    public Integer selectedTerm { get; set; }
    @AuraEnabled
    public Boolean insuranceEligibility { get; set; }
    @AuraEnabled
    public List<Object> termItems { get; set; } //This Attribute is used to get the Loan Term options
    @AuraEnabled
    public List<AOB_DTO_FlowScreenRecord> flowRecords { get; set; }
  
    public AOB_DTO_CardPersonalization() {
      personalizeCard = new PersonalizeCard();
      insurances = new Map<String, Insurance>();
      scales = new List<Scale>();
      flowRecords = new List<AOB_DTO_FlowScreenRecord>();
      assuranceFlowRecords = new List<AOB_DTO_FlowScreenRecord>();
      currencyString = 'R';
      customerFirstName = '';
      salutation = '';
      TermAndConditions = '';
      insuranceEligibility = true;
      estimatedMonthlyRepayment = new AOB_DTO_FlowScreenRecord();
      estimatedMonthlyRepaymentWithIns = new AOB_DTO_FlowScreenRecord();
    }
    //Personalize your card
    public class PersonalizeCard {
      @AuraEnabled
      public Integer minAmount { get; set; }
      @AuraEnabled
      public Integer maxAmount { get; set; }
      @AuraEnabled
      public Decimal interestRate { get; set; }
      @AuraEnabled
      public Integer initiationFee { get; set; }
      @AuraEnabled
      public Decimal monthlyServiceFee { get; set; }
      @AuraEnabled
      public Integer loanTerm { get; set; }
    }
    //Insurance
    public class Insurance {
      @AuraEnabled
      public Integer insuranceCoversUp { get; set; }
      @AuraEnabled
      public String insuranceId { get; set; }
      @AuraEnabled
      public String insuranceName { get; set; }
      @AuraEnabled
      public String insuranceProductDesc { get; set; }
      @AuraEnabled
      public Decimal planRate { get; set; }
      @AuraEnabled
      public Decimal percentageRate { get; set; }
      @AuraEnabled
      public Integer perValue { get; set; }
      @AuraEnabled
      public String policyFee { get; set; }
      @AuraEnabled
      public Decimal monthlyRepayment { get; set; }
      @AuraEnabled
      public List<String> benefits { get; set; }
  
      public Insurance() {
        benefits = new List<String>();
        perValue = 1000;
        insuranceCoversUp = 0;
        monthlyRepayment = 0;
        policyFee = '0';
        planRate = 0;
        percentageRate = 0;
        insuranceName = '';
      }
    }
  
    public class Scale {
      @AuraEnabled
      public Integer scaleAmount { get; set; }
      @AuraEnabled
      public Integer scaleMaxAmount { get; set; }
      @AuraEnabled
      public Decimal scaleRate { get; set; }
  
      public Scale() {
        scaleMaxAmount = 0;
      }
    }
  }