/**
    * @description       : Selector Class for EmailTemplate Entity
    * @author            : Raja Arsalan
    * @last modified on  : 10-31-2023
   **/
   public inherited sharing class INS_SEL_EmailTemplate extends sbgplatform.fflib_SObjectSelector {
       private static Set<String> fields = new Set<String>{'Id', 
           'Subject',
           'Body',
           'HtmlValue'
       };
/**
    * @description       : Selector Class for EmailTemplate Entity
**/        
           public override Schema.SObjectType getSObjectType() {
               return EmailTemplate.sObjectType;
           }
       
           /**
           * @description Method to get list of fields to be part of response
           * @author Raja Arsalan | 05-31-2023 
           * @return List<Schema.SObjectField> 
           **/
           public override List<Schema.SObjectField> getSObjectFieldList() {
               return new List<Schema.SObjectField> {
                    EmailTemplate.Id, 
                    EmailTemplate.Subject,
                    EmailTemplate.Body,
                    EmailTemplate.HtmlValue
                     
                   };
           }
       
       
           /**
           * @description Method to fetch list of EmailTemplate based on Id
           * @param name
           * @return List<EmailTemplate> 
           **/
           public List<EmailTemplate> selectEmailTemplateByName(String name) {
               sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
               fieldQueryFactory.setCondition('DeveloperName =:name');
               fieldQueryFactory.selectFields(fields); 
               return Database.query(fieldQueryFactory.toSOQL());
           }
   
   
           
   }