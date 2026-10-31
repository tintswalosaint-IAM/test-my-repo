public class INS_DTO_DiallerLeads {
    
    
    public class LeadWrapper {
        public LeadGeneration LeadGeneration;
    }
    
    public class LeadGeneration {
        public Reference Reference;
        public LeadandOpportunityProcedure LeadandOpportunityProcedure;
        public AdditionalData AdditionalData;
    }
    
    public class Reference {
        public List<PartyName> PartyName;
        public PartyContactPoint PartyContactPoint;
    }
    
    public class PartyName {
        public String PartyNameType;
        public String PartyNameValue;
        
        public PartyName(String type, String value) {
            this.PartyNameType = type;
            this.PartyNameValue = value;
        }
    }
    
    public class PartyContactPoint {
        public List<TelephonicAddress> TelephonicAddress;
        public ElectronicAddress ElectronicAddress;
    }
    
    public class TelephonicAddress {
        public String PhoneType;
        public String PhoneNumber;
        
        public TelephonicAddress(String type, String phoneNumber) {
            this.PhoneType = type;
            this.PhoneNumber = phoneNumber;
        }
    }
    
    public class ElectronicAddress {
        public String EmailAddress;
    }
    
    public class LeadandOpportunityProcedure {
        public String LeadStatus;
        public List<LeadIdentification> LeadIdentification;
        public List<CustomerReference> CustomerReference;
        public List<CustomerCampaignReference> CustomerCampaignReference;
        public String LeadandOpportunityDescription;
        public List<LeadPartyContactPoint> LeadPartyContactPoint;
    }
    
    public class LeadIdentification {
        public String LeadIdentifcationType;
        public String LeadIdentifierValue;
        
        public LeadIdentification(String type, String value) {
            this.LeadIdentifcationType = type;
            this.LeadIdentifierValue = value;
        }
    }
    
    public class CustomerReference {
        public String PartyIdentificationType;
        public String PartyIdentificationValue;
        
        public CustomerReference(String type, String value) {
            this.PartyIdentificationType = type;
            this.PartyIdentificationValue = value;
        }
    }
    
    public class CustomerCampaignReference {
        public String CampaignIdentifierValue;
        public String CampaignName;
        
        public CustomerCampaignReference(String value, String name) {
            this.CampaignIdentifierValue = value;
            this.CampaignName = name;
        }
    }
    
    public class LeadPartyContactPoint {
        public ContactPoint ContactPoint;
        
        public LeadPartyContactPoint(ContactPoint cp) {
            this.ContactPoint = cp;
        }
    }
    
    public class ContactPoint {
        public ContactPointPeriod ContactPointPeriod;
        
        public ContactPoint(ContactPointPeriod cpp) {
            this.ContactPointPeriod = cpp;
        }
    }
    
    public class ContactPointPeriod {
        public String FromDateTime;
        public String ToDateTime;
        
        public ContactPointPeriod(String fromDt, String toDt) {
            this.FromDateTime = fromDt;
            this.ToDateTime = toDt;
        }
    }
    
    public class AdditionalData {
        public CategoryInformation CategoryInformation;
    }
    
    public class CategoryInformation {
        public List<Category> Category;
    }
    
    public class Category {
        public List<CategoryDetails> CategoryDetails;
        
        public Category(List<CategoryDetails> details) {
            this.CategoryDetails = details;
        }
    }
    
    public class CategoryDetails {
        public String CategoryType;
        public String CategoryIdentifierValue;
        
        public CategoryDetails(String type, String value) {
            this.CategoryType = type;
            this.CategoryIdentifierValue = value;
        }
    }
    
    
    /**
* @description Builds a LeadWrapper from a Lead record.
* @param l                          
* @param employeeEmail              
* @param statusIdToUpdateOnConnex   
* @return LeadWrapper
*/
    public static LeadWrapper createWrapperFromLead(Lead l, String employeeEmail, String statusIdToUpdateOnConnex) {
        LeadWrapper wrapper = new LeadWrapper();
        wrapper.LeadGeneration = new LeadGeneration();
        
        wrapper.LeadGeneration.Reference = new Reference();
        wrapper.LeadGeneration.Reference.PartyName = new List<PartyName>{
            new PartyName('FirstName', l.FirstName),
                new PartyName('LastName', l.LastName)
                };
                    wrapper.LeadGeneration.Reference.PartyContactPoint = new PartyContactPoint();
        
        String normalizedMobile = l.MobilePhone;
        if (!String.isBlank(normalizedMobile)) {
            if (normalizedMobile.startsWith('0027')) {
                normalizedMobile = '+' + normalizedMobile.substring(4);
            } else if (normalizedMobile.startsWith('0')) {
                normalizedMobile = '+27' + normalizedMobile.substring(1);
            }
        }
        
        wrapper.LeadGeneration.Reference.PartyContactPoint.TelephonicAddress = new List<TelephonicAddress>{
            new TelephonicAddress('PrimaryPhone', normalizedMobile),
                new TelephonicAddress('AlternatePhone', l.Phone)
                };
                    
                    wrapper.LeadGeneration.Reference.PartyContactPoint.ElectronicAddress = new ElectronicAddress();
        wrapper.LeadGeneration.Reference.PartyContactPoint.ElectronicAddress.EmailAddress = l.Email;
        
        // -------- LeadandOpportunityProcedure --------
        LeadandOpportunityProcedure lop = new LeadandOpportunityProcedure();
        
        if (!String.isBlank(statusIdToUpdateOnConnex)) {
            lop.LeadStatus = statusIdToUpdateOnConnex;
        }
        
        lop.LeadIdentification = new List<LeadIdentification>{
            new LeadIdentification('LeadIdentifier', l.Id),
                new LeadIdentification('LoanAccountIdentifier', l.Loan_Account_Number__c),
                new LeadIdentification('OwnnerID', employeeEmail),
                new LeadIdentification('ExpressedInterestDetail', l.Expressed_Interest_Detail__c)
                };
                    
                    lop.CustomerReference = new List<CustomerReference>{
                        new CustomerReference('EmployeeNumber', l.SA_ID_or_Passport__c)
                            };
                                
                                lop.CustomerCampaignReference = new List<CustomerCampaignReference>{
                                    new CustomerCampaignReference(l.Id, 'CampaignID'),
                                        new CustomerCampaignReference(l.Campaign_Source_ID__c, 'CampaignSourceID')
                                        };
                                            
                                            lop.LeadandOpportunityDescription = l.Description;
        
        lop.LeadPartyContactPoint = new List<LeadPartyContactPoint>{
            new LeadPartyContactPoint(
                new ContactPoint(
                    new ContactPointPeriod(
                        String.valueOf(l.Preferred_Contact_Date_Time__c),
                        String.valueOf(l.Preferred_Contact_Date_Time_End__c)
                    )
                )
            )
                };
                    
                    wrapper.LeadGeneration.LeadandOpportunityProcedure = lop;
        
        // -------- AdditionalData --------
        wrapper.LeadGeneration.AdditionalData = new AdditionalData();
        wrapper.LeadGeneration.AdditionalData.CategoryInformation = new CategoryInformation();
        wrapper.LeadGeneration.AdditionalData.CategoryInformation.Category = new List<Category>{
            new Category(new List<CategoryDetails>{
                new CategoryDetails('DiallerQueueID', l.Dialler_Queue_ID__c)
                    })
                };
                    
                    return wrapper;
    }
    
    
    
    /**
* @description Generates POST request body for multiple leads.
*              - Removes blank LeadStatus
*              - Replaces null String values with blank ('')
*/
    public static String generateRequestBody(List<LeadWrapper> wrappers) {
        List<Object> sanitizedList = new List<Object>();
        
        for (LeadWrapper wrapper : wrappers) {
            Map<String, Object> wrapperMap = 
                (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(wrapper));
            
            Map<String, Object> leadGeneration = 
                (Map<String, Object>) wrapperMap.get('LeadGeneration');
            if (leadGeneration != null && leadGeneration.containsKey('LeadandOpportunityProcedure')) {
                Map<String, Object> lop = 
                    (Map<String, Object>) leadGeneration.get('LeadandOpportunityProcedure');
                if (lop != null && !String.isNotBlank((String) lop.get('LeadStatus'))) {
                    lop.remove('LeadStatus');
                }
            }
            
            wrapperMap = (Map<String, Object>) replaceNullStringsWithBlank(wrapperMap);
            sanitizedList.add(wrapperMap);
        }
        
        return JSON.serializePretty(sanitizedList);
    }
    
    /**
* @description Generates PUT request body for a single lead.
*              - Removes blank LeadStatus
*              - Replaces null String values with blank ('')
*/
    public static String generatePutRequestBody(Lead l, String employeeEmail, String statusIdToUpdateOnConnex) {
        LeadWrapper originalWrapper = createWrapperFromLead(l, employeeEmail, statusIdToUpdateOnConnex);
        
        Map<String, Object> wrapperMap = 
            (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(originalWrapper));
        
        
        Map<String, Object> leadGeneration = 
            (Map<String, Object>) wrapperMap.get('LeadGeneration');
        if (leadGeneration != null && leadGeneration.containsKey('LeadandOpportunityProcedure')) {
            Map<String, Object> lop = 
                (Map<String, Object>) leadGeneration.get('LeadandOpportunityProcedure');
            if (lop != null && !String.isNotBlank(statusIdToUpdateOnConnex)) {
                lop.remove('LeadStatus');
            }
        }
        
        wrapperMap = (Map<String, Object>) replaceNullStringsWithBlank(wrapperMap);
        
        List<Object> finalList = new List<Object>{ wrapperMap };
            
            return JSON.serializePretty(finalList);
    }
    
    
    /**
* @description Recursively replaces null values with blank ('') in a Map/List structure.
*              This ensures the JSON payload doesn't contain "null" for String fields.
*
* @param obj  
* @return Sanitized object with nulls replaced by ''
*/
    
    @TestVisible
    private static Object replaceNullStringsWithBlank(Object obj) {
        if (obj == null) {
            return '';
        }
        
        if (obj instanceof Map<String, Object>) {
            Map<String, Object> dataMap = (Map<String, Object>) obj;
            for (String key : dataMap.keySet()) {
                Object val = dataMap.get(key);
                
                if (val == null) {
                    dataMap.put(key, '');
                } else if (val instanceof Map<String, Object> || val instanceof List<Object>) {
                    dataMap.put(key, replaceNullStringsWithBlank(val));
                }
            }
            return dataMap;
        }
        
        if (obj instanceof List<Object>) {
            List<Object> dataList = (List<Object>) obj;
            for (Integer i = 0; i < dataList.size(); i++) {
                Object val = dataList[i];
                
                if (val == null) {
                    dataList[i] = '';
                } else if (val instanceof Map<String, Object> || val instanceof List<Object>) {
                    dataList[i] = replaceNullStringsWithBlank(val);
                }
            }
            return dataList;
        }
        
        return obj;
    }
}