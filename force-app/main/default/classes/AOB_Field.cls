/**
*@description  Class used as Wrapper Class to display field info
*
* @author Yashwanth Tikkisetti (yaswanth.tikkisetti@standadrdbank.co.za)
*
* @date
*/
public class AOB_Field {
    @AuraEnabled
    /** @description helpTxt parameter */ 
    public String helpTxt { get; set;}
    @AuraEnabled
    /** @description value parameter */ 
    public String value { get; set;}
    @AuraEnabled
    /** @description placeholder parameter */ 
    public String placeholder { get; set;}
    @AuraEnabled
    /** @description pattern parameter */ 
    public String pattern { get; set;}
    @AuraEnabled
    /** @description sequence parameter */
    public Decimal sequence { get; set; }
    @AuraEnabled
    /** @description id  parameter */
    public String id { get; set; }
    @AuraEnabled
    /** @description name parameter */
    public String name { get; set; }
    @AuraEnabled
    /** @description errorMessage parameter */
    public String errorMessage { get; set; }
    @AuraEnabled
    /** @description label parameter */
    public String label { get; set; }
    @AuraEnabled
    /** @description isRequired parameter */
    public Boolean isRequired { get; set; }
    @AuraEnabled 
    /** @description isCheckbox  parameter */
    public Boolean isCheckbox { get; set; }    
    @AuraEnabled
    /** @description isTextInput parameter */
    public Boolean isTextInput { get; set; }
    @AuraEnabled
    /** @description isEmail parameter */
    public Boolean isEmail { get; set; }
    @AuraEnabled
    /** @description isCombobox parameter */
    public Boolean isCombobox { get; set; }
    @AuraEnabled
    /** @description isRadio parameter */
    public Boolean isRadio { get; set; }
    @AuraEnabled
    /** @description isOutput parameter */
    public Boolean isOutput { get; set; }
    @AuraEnabled
    /** @description isCurrency parameter */
    public Boolean isCurrency { get; set; }
    @AuraEnabled
    /** @description isNumber parameter */
    public Boolean isNumber {get; set;}
    @AuraEnabled
    /** @description isMultiselect parameter */
    public Boolean isMultiselect { get; set; }
    @AuraEnabled
    /** @description isCheckGroup parameter */
    public Boolean isCheckGroup { get; set; }
    @AuraEnabled
    /** @description isDate parameter */
    public Boolean isDate { get; set; }
    @AuraEnabled
    /** @description isTextArea parameter */
    public Boolean isTextArea { get; set; }
    @AuraEnabled
    /** @description isFileUpload parameter */
    public Boolean isFileUpload { get; set; }
    @AuraEnabled
    /** @description parent parameter */
    public String parent { get; set; }
    @AuraEnabled
    /** @description showError parameter */
    public Boolean showError { get; set; }
    @AuraEnabled
    /** @description isHidden parameter */
    public Boolean isHidden { get; set; }
    @AuraEnabled
    /** @description options parameter */
    public List<AOB_SelectOption> options { get; set; }
    @AuraEnabled
    /** @description childShowingValue parameter */
    public String childShowingValue { get; set; }
    @AuraEnabled
    /** @description parentControllingValue parameter */
    public String parentControllingValue { get; set; }
    @AuraEnabled
    /** @description maxSize parameter */
    public Decimal maxSize { get; set; }
    @AuraEnabled
    /** @description allowedExtn parameter */
    public String allowedExtn { get; set; }
    @AuraEnabled
    /** @description maxLength parameter */
    public String maxLength { get; set; }
    @AuraEnabled 
    /** @description sfFieldAPIName parameter */
    public String sfFieldAPIName {get; set;}
    @AuraEnabled 
    /** @description sfObjectAPIName parameter */
    public String sfObjectAPIName {get; set;}
    @AuraEnabled
    /** @description isControllingField parameter */
    public Boolean isControllingField {get; set;}
    @AuraEnabled
    /** @description defaultValue parameter */ 
    public String defaultValue {get; set;}   
    /**
    * @description constructs a jsField based on AOB_Field__c record
    * @param    field AOB_Field__c  
    * @param    apps List<Application__c>  
    */
    public AOB_Field(AOB_Field__c field, List<Application__c> apps) {
        // setting field type
        this.isRequired = field.AOB_Required__c;
        if(String.isNotBlank(field.AOB_Parent__c)){
            this.parent = field.AOB_Parent__c;
            this.isHidden = true;
        } else {
            this.isHidden = false;
        }
        this.pattern = field.AOB_pattern__c;
        this.errorMessage = field.AOB_ErrorMessage__c;
        this.id = field.id;
        this.label = field.AOB_Label__c;
        this.name = field.name;
        this.helpTxt = field.AOB_HelpText__c;
        this.placeholder = field.AOB_Placeholder__c;
        this.sfFieldAPIName = field.AOB_SFField__c;
        this.sfObjectAPIName = field.AOB_SFObject__c;
        this.parentControllingValue = field.AOB_ParentControllingValue__c;
        this.defaultValue = field.Default_Value__c;
        this.maxLength = field.AOB_Max_Length__c;
        this.isControllingField=field.AOB_Controlling_Field__c;
        this.sequence=field.AOB_sequence__c!=null?integer.valueof(field.AOB_sequence__c):null;
       // this.allowedExtn=field.AOB_Allowed_File_Extn__c;


        this.setFieldType(field,apps);

        if(field.AOB_Type__c == 'Combobox') {
            this.options = new List<AOB_SelectOption>{new AOB_SelectOption('', '--None--')};

            if(field.AOB_Values__c != null) {
                for(String option : field.AOB_Values__c.split(';')) {
                    this.options.add(new AOB_SelectOption(option, option));
                }
            } else if(field.AOB_SFObject__c != null && field.AOB_SFField__c != null) {
                Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(field.AOB_SFObject__c);
                Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
                Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
                List<Schema.PicklistEntry> lstPickListValues = mapFields.get(field.AOB_SFField__c).getDescribe().getPickListValues();
                for (Schema.PicklistEntry pickListVal : lstPickListValues) {
                   this.options.add(new AOB_SelectOption((String)pickListVal.getValue(), (String)pickListVal.getLabel(), pickListVal.isDefaultValue()));
                }
            }

        } else if((field.AOB_Type__c == 'Radio' || field.AOB_Type__c == 'Checkbox Group') && field.AOB_Values__c != null) {
            this.options = new List<AOB_SelectOption>();

            for(String option : field.AOB_Values__c.split(';')) {
                this.options.add(new AOB_SelectOption(option, option));
            }
        }
    }
    
    /**
    * @description sets object fields and returns field
    * @param    field AOB_Field__c 
    * @param    apps List<Application__c> 
    */
    private void setFieldType(AOB_Field__c field, List<Application__c> apps){
        switch on field.AOB_Type__c  {
            when 'Combobox' {
                this.isCombobox = true;
            }   
            when 'Radio' {
                this.isRadio = true;
            }
            when 'Text' {   
                this.isTextInput = true;
            }
            when 'Date' {   
                this.isDate = true;
            }
            when 'Text Area' {  
                this.isTextArea = true;
            }
            when 'File Upload' {  
                this.isFileUpload = true;
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
            when 'MultiSelectSearch' {  
                this.isMultiselect = true;
            }
            when 'Checkbox' {   
                this.isCheckbox = true;
            }
            when 'Checkbox Group' {   
                this.isCheckGroup = true;
            }
            when 'Output' { 
                this.isOutput = true;
                if(!apps.isEmpty() && field.AOB_SFField__c!=null){
                    this.value = String.valueOf(apps[0].get(field.AOB_SFField__c));
                }
            }
        }
    }

}