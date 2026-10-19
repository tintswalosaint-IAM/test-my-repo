/**
* @description Class used as Wrapper Class to display field info
*
* @author Yashwanth Tikkisetti (yaswanth.tikkisetti@standadrdbank.co.za)
*
* @date 12-03-2023
*
**********************************************
* @last modified on  : 09-05-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* @Modification Description : SFP-36380, Class to display Field types used for SBO-UK
*/

public class AOB_DTO_Field implements Comparable{
    /**
  * @description helpTxt
  * @return String
  */
  @AuraEnabled
  public String helpTxt { get; set;} 
  /**
  * @description value
  * @return String
  */
  @AuraEnabled
  public String value { get; set;}
  /**
  * @description placeholder
  * @return String
  */
  
  @AuraEnabled
  public String placeholder { get; set;}
  /**
  * @description pattern
  * @return String
  */
  @AuraEnabled
  public String pattern { get; set;}
  /**
  * @description sequence
  * @return Decimal
  */
  @AuraEnabled
  public Decimal sequence { get; set; }
    /**
  * @description order
  * @return Decimal
  */
  @AuraEnabled
  public Decimal order { get; set; }
  /**
  * @description id
  * @return String
  */
  @AuraEnabled
  public String id { get; set; }
  /**
  * @description name
  * @return String
  */
  @AuraEnabled
  public String name { get; set; }
  /**
  * @description values
  * @return String
  */
  @AuraEnabled
  public String values { get; set; }
  /**
  * @description errorMessage
  * @return String
  */
  @AuraEnabled
  public String errorMessage { get; set; }
  /**
  * @description label
  * @return String
  */
  @AuraEnabled
  public String label { get; set; }
  /**
  * @description isRequired
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isRequired { get; set; }
  /**
  * @description isCheckbox
  * @return Boolean
  */
  @AuraEnabled 
  public Boolean isCheckbox { get; set; }  
  /**
  * @description isInputreadonly
  * @return Boolean
  */  
  @AuraEnabled
  public Boolean isInputreadonly { get; set; }
  /**
  * @description isInput
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isInput { get; set; }
    /**
  * @description isInputdefault
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isInputdefault { get; set; }
    /**
  * @description isPleasenote
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isLabel { get; set; }
    /**
  * @description isSubaccordian
  * @return Boolean
  */
   @AuraEnabled
  public Boolean issubAccordian { get; set; }
    /**
  * @description isMasterDetail
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isMasterDetail { get; set; }
    /**
  * @description isPleasenote
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isPleasenote { get; set; }
    /**
  * @description isAccordianCount
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isAccordianCount { get; set; }
   /**
  * @description isInputcountry
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isInputcountry { get; set; }
    /**
  * @description isInputsource
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isInputsource { get; set; }
   /**
  * @description isPhotosignature
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isPhotosignature { get; set; }
  /**
  * @description isDate
  * @return Boolean
  */
   @AuraEnabled
  public Boolean isDate { get; set; }
  /**
  * @description isExpDate
  * @return Boolean
  */
   @AuraEnabled
  public Boolean isExpDate { get; set; }
  /**
  * @description isPercent
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isPercent { get; set; }
  /**
  * @description isEmail
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isEmail { get; set; }
  /**
  * @description isCombobox
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isCombobox { get; set; }
/**
  * @description isComboboxreadonly
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isComboboxReadonly { get; set; }
    /**
  * @description isEmpty
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isEmpty { get; set; }
  /**
  * @description isCombobox
  * @return Boolean
  */
   @AuraEnabled
  public Boolean isMutipleFiles { get; set; }
  /**
  * @description isConsentBox
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isConsentBox { get; set; }
  /**
  * @description isButton
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isButton { get; set; }
  /**
  * @description isRadio
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isRadio { get; set; }
  /**
  * @description isAdd
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isAddbutton { get; set; }
  /**
  * @description isParentAccordian
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isParentAccordian { get; set; }
   /**
  * @description isTable
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isTable { get; set; }
  /**
  * @description isOutput
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isOutput { get; set; }
  /**
  * @description isCurrency
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isCurrency { get; set; }
  /**
  * @description isNumber
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isNumber {get; set;}
  /**
  * @description isMultiselect
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isMultiselect { get; set; }

   /**
  * @description isMultiselectReadonly
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isMultiselectReadonly { get; set; }

  @AuraEnabled
  /** @description ispicklistWithInput parameter */
  public Boolean ispicklistWithInput { get; set; }
  /**
  * @description isTextArea
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isTextArea { get; set; }
  /**
    * @description maxlength
    * @return String
    */
  @AuraEnabled
  public String maxlength { get; set;}
  /**
  * @description parent
  * @return String
  */
  @AuraEnabled
  public String parent { get; set; }
  /**
  * @description showError
  * @return Boolean
  */
  @AuraEnabled
  public Boolean showError { get; set; }
  /**
  * @description isHidden
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isHidden { get; set; }
  /**
  * @description options
  * @return List<AOB_DTO_SelectOption>
  */
  @AuraEnabled
  public List<AOB_DTO_SelectOption> options { get; set; }
  /**
  * @description childShowingValue
  * @return String
  */
  @AuraEnabled
  public String childShowingValue { get; set; }
  /**
  * @description parentControllingValue
  * @return String
  */
  @AuraEnabled
  public String parentControllingValue { get; set; }
  /**
  * @description maxSelected
  * @return String
  */
  @AuraEnabled
  public Double maxSelected { get; set; }
  /**
  * @description mriTable
  * @return String
  */
  @AuraEnabled
  public string mriTable { get; set; }
  /**
  * @description sfFieldAPIName
  * @return String
  */
  @AuraEnabled 
  public String sfFieldAPIName {get; set;}
   /**
  * @description industr
  * @return String
  */
  @AuraEnabled 
  public Boolean industry {get; set;}
  /**
  * @description sfObjectAPIName
  * @return String
  */
  @AuraEnabled 
  public String sfObjectAPIName {get; set;}
  /**
  * @description isControllingField
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isControllingField {get; set;}
  /**
  * @description informalModal
  * @return Boolean
  */   
  @AuraEnabled
  public Boolean informalModal {get; set;}
  /**
  * @description directordetails
  * @return Boolean
  */   
   @AuraEnabled
  public Boolean directordetails {get; set;}
  /**
  * @description memberdetails
  * @return Boolean
  */
  @AuraEnabled
  public Boolean memberdetails {get; set;}
  /**
  * @description ischeckbox group
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isCheckboxGroup {get; set;}
  /**
  * @description isdataprivacy
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isdataprivacy {get; set;}
  /**
  * @description isCrossCellCard
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isCrossCellCard {get; set;} 
 /**
  * @description isTermsEngagement
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isTermsEngagement {get; set;} 
  /**
  * @description isTermsEngagement
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isFATCADefinitions {get; set;} 
  /**
  * @description isTermsEngagement
  * @return Boolean
  */
   @AuraEnabled
  public Boolean iscrsDefinitions {get; set;} 
  /**
  * @description isTermsEngagement
  * @return Boolean
  */
  @AuraEnabled
  public Boolean ismobile {get; set;} 
   /**
    * @description minlength
    * @return String
    */
    @AuraEnabled
    public String minlength { get; set;}
  /**
  * @description isaddAccordian
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isaddAccordian {get; set;} 

 /**
  * @description isWarningInfo
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isWarningInfo {get; set;} 
  
  /**
  * @description isTextContent
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isTextContent {get; set;} 

  /**
  * @description isFileUpload
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isFileUpload {get; set;}

  /**
  * @description isFileUpload
  * @return Boolean
  */
   @AuraEnabled
  public Boolean subSection {get; set;}
  /**
  * @description isLookup
  * @return Boolean
  */
  @AuraEnabled
  public Boolean isLookup { get; set; }
  /**
  * @description defaultValue
  * @return String
  */
  
  @AuraEnabled 
  public String defaultValue {get; set;} 
  
  /**
  * @description constructs a jsField based on AOB_Field__c record
  * @param field
  * @param apps
  *   
  */
  public AOB_DTO_Field(AOB_Field__c field, List<Application__c> apps) {
      this.isRequired = field.AOB_Required__c;
      if(String.isNotBlank(field.AOB_Parent__c)){
          this.parent = field.AOB_Parent__c;
          this.isHidden = true;
      } else {
          this.isHidden = false;
      }
      this.pattern = field.AOB_pattern__c;
      this.values = field.AOB_Values__c;
      this.errorMessage = field.AOB_ErrorMessage__c;
      this.id = field.id;
      this.label = field.AOB_Label__c;
      this.name = field.name;
      this.helpTxt = field.AOB_HelpText__c;
      this.placeholder = field.AOB_Placeholder__c;
      this.sfFieldAPIName = field.AOB_SFField__c;
      this.sfObjectAPIName = field.AOB_SFObject__c;
      this.mriTable =field.AOB_MRITable__c;
      this.parentControllingValue = field.AOB_ParentControllingValue__c;
      this.maxlength=field.AOB_Max_Length__c;
      this.minlength=field.AOB_MinLength__c;
      this.defaultValue =field.Default_Value__c;
      this.isControllingField=field.AOB_Controlling_Field__c;
      if(field.AOB_sequence__c != null){
          this.sequence = Decimal.valueOf(field.AOB_sequence__c);
          this.order= Decimal.valueOf(field.AOB_sequence__c);
      }   
      this.setFieldType(field,apps);
    
  }
  
   /**
    * @description sets object fields and returns field
    * @param    field AOB_Field__c 
    * @param    apps List<AOB_Application__c> 
    */
  private void setFieldType(AOB_Field__c field, List<Application__c> apps){
      switch on field.AOB_Type__c  {
          when 'Combobox' {
              this.isCombobox = true;
          }
           when 'ComboboxReadonly' {
              this.isComboboxReadonly = true;
          }
          when 'ConsentBox' {
            this.isConsentBox = true;
          }  
          when 'Button' {
            this.isButton = true;
          }  
          when 'Radio' {
              this.isRadio = true;
          }
          when 'Empty' {
              this.isEmpty = true;
          }
          when 'Text' {   
              this.isInput = true;
          }
           when 'Textdefault' {   
              this.isInputdefault = true;
          }
          when 'MasterDetail' {   
              this.isMasterDetail = true;
          }
            when 'defaultcountry' {   
              this.isInputcountry = true;
          }
           when 'Textfunds' {   
              this.isInputsource = true;
          }
            when 'Pleasenote' {   
              this.isPleasenote = true;
          }
            when 'Accordian Count' {   
              this.isAccordianCount = true;
          }
          when 'photosignature' {   
              this.isPhotosignature = true;
          }
          when 'TextReadOnly' {   
              this.isInputreadonly = true;
              }
          when 'Date' {   
              this.isDate = true;
          }
          when 'isExpDate' {   
              this.isExpDate = true;
          }
          when 'Text Area' {  
              this.isTextArea = true;
          }
            when 'isMutipleFiles' { 
               
              this.isMutipleFiles = true;
          }
           when 'Lookup' { 
              this.isLookup = true;
          }
          when 'Percent'{
              this.isPercent=true;
          }
          when 'Label' {
              this.isLabel = true;
          }
           when 'WarningInfo' {
              this.isWarningInfo = true;
          }
          when 'FATCADefinitions'{
          this.isFATCADefinitions = true;
          }
           when 'crsDefinitions'{
          this.iscrsDefinitions = true;
          }
            when 'mobile' {
              this.ismobile = true;
          }
            when 'industry' {
              this.industry = true;
          }
          when 'Addbutton' { 
               
              this.isAddbutton = true;
          }
          when 'Accordian' { 
               
              this.isParentAccordian = true;
          }
           when 'SubSection' { 
               
              this.subSection = true;
          }
          when 'Table' { 
               
              this.isTable = true;
          }
         
          when 'Email' {  
              this.isEmail = true;
          }
        
          when 'Currency' {   
              this.isCurrency = true;
          }
          when 'Number' { 
              this.isNumber = true;
          }
          when 'File Upload' { 
              this.isFileUpload = true;
          }
          when 'MultiSelectSearch' {  
              this.isMultiselect = true;
          }
             when 'MultiSelectReadonly' {  
              this.isMultiselectReadonly = true;
          }
          when 'PicklistWithInput' {  
              this.ispicklistWithInput = true;
          }
          when 'Sub Accordian'{
              this.issubAccordian= true;
          }
          when 'Add Accordian'{
              this.isaddAccordian = true;
          }
          when 'Checkbox' {   
              this.isCheckbox = true;
          }
          when 'Checkbox Group' {   
              this.isCheckboxGroup = true;
          }
          when 'informalModal' {   
              this.informalModal = true;
          }
           when 'isdataprivacy' {   
              this.isdataprivacy = true;
          }
          when 'directordetails' {
              this.directordetails = true;
          }
          when 'memberdetails' {
              this.memberdetails = true;
          }
          when 'Text Content'{
             this.isTextContent =true; 
          }
           when 'Card' {   
              this.isCrossCellCard = true;
          } when 'TermsEngagement' {   
              this.isTermsEngagement = true;
          }
          when 'Output' { 
              this.isOutput = true;
              if(!apps.isEmpty() && field.AOB_SFField__c!=null){
                  this.value = String.valueOf(apps[0].get(field.AOB_SFField__c));
              }
          }
      }
  }
  
  /**
  * @description Compare fields based on the sequence amount
  * @param compareTo Object 
  * @return Integer
  */
  public Integer compareTo(Object compareTo) {
      AOB_DTO_Field field = (AOB_DTO_Field)compareTo;
      
      Integer returnValue = 0;
      if ((this.sequence > field.sequence) || (this.order > field.order)) {
          // Set return value to a positive value.
          returnValue = 1;
      } else if ((this.sequence < field.sequence) || (this.order < field.order)) {
          // Set return value to a negative value.
          returnValue = -1;
      } else if (((this.sequence == null) && (field.sequence != null)) || (this.order == null) && (field.order != null)){
          // nulls-first implementation
          returnValue = -1;
      }      
      return returnValue;       
  }
}