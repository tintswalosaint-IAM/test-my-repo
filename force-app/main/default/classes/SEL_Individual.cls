/**
 * @description       : Selector Class for Individual Object
 * @author            : Lokesh Bothsa
 * @last modified on  : 18-06-2024
 * @last modified by  : Derek Hughes
 * Last modified by Brian akankwasa, 19/11/2024
**/
public inherited sharing class SEL_Individual extends sbgplatform.fflib_SObjectSelector{
    private static Set<String> fields = new Set<String>{
        'Id', 
        'Name', 
        'CreatedDate', 
        'RecordTypeId',
        'AOB_Personal_Information_Consent__c',
        'AOB_Services_Special_Offers_Consent__c',
        'AOB_Market_Your_Product_Consent__c',
        'AOB_Research_Consent__c',
        'Data_Privacy_Consent__c',
        'AOB_Documents_Validation__c',
        'AOB_Declaration_of_Literacy__c',
        'CanStorePiiElsewhere',
        'HasOptedOutGeoTracking',
        'HasOptedOutProcessing',
        'HasOptedOutProfiling',
        'HasOptedOutSolicit',
        'HasOptedOutTracking',
        'IsHomeOwner',
        'SendIndividualData',
        'ShouldForget',
        'BirthDate',
        'DeathDate',
        'CreatedDate',
        'LastModifiedDate',
        'Salutation',
        'FirstName',
        'LastName',
        'MiddleName',
        'Suffix',
        'ChildrenCount',
        'ConsumerCreditScore',
        'ConvictionsCount',
        'InfluencerRating',
        'IndividualsAge',
        'MilitaryService',
        'Occupation',
        'ConsumerCreditScoreProviderName',
        'Website',
        'Application_Participant__c'
    };

    /**
    * @description Method to get list of fields to be part of response
    * @author Nagendraprasad Mylavarapu | 03-07-2023 
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Individual.Id, 
            Individual.Name,
            Individual.CreatedDate, 
            Individual.RecordTypeId, 
            Individual.AOB_Personal_Information_Consent__c, 
            Individual.AOB_Services_Special_Offers_Consent__c, 
            Individual.AOB_Market_Your_Product_Consent__c, 
            Individual.AOB_Research_Consent__c, 
            Individual.Data_Privacy_Consent__c, 
            Individual.AOB_Documents_Validation__c, 
            Individual.AOB_Declaration_of_Literacy__c, 
            Individual.CanStorePiiElsewhere, 
            Individual.HasOptedOutGeoTracking, 
            Individual.HasOptedOutProcessing, 
            Individual.HasOptedOutProfiling,
            Individual.HasOptedOutSolicit,
            Individual.HasOptedOutTracking,
            Individual.IsHomeOwner,
            Individual.SendIndividualData,
            Individual.ShouldForget,
            Individual.BirthDate, 
            Individual.DeathDate,
            Individual.CreatedDate,
            Individual.LastModifiedDate,
            Individual.Salutation,
            Individual.FirstName,
            Individual.LastName,
            Individual.MiddleName,
            Individual.Suffix,
            Individual.ChildrenCount,
            Individual.ConsumerCreditScore,
            Individual.ConvictionsCount,
            Individual.InfluencerRating,
            Individual.IndividualsAge,
            Individual.MilitaryService,
            Individual.Occupation,
            Individual.ConsumerCreditScoreProviderName,
            Individual.Website,
            Individual.Application_Participant__c,
            Individual.National_Identity_Number__c
        };
    }

    /**
* @description Implementation method for Application Participant Object as part of fflib framweork
* @author Nagendraprasad Mylavarapu | 03-07-2023 
* @return Schema.SObjectType 
**/
    public override Schema.SObjectType getSObjectType() {
        return Individual.sObjectType;
    }

       /**
* @description Method to fetch list of individuals based on Id
* @param participantId
* @return List<Individual>
*/
public List<Individual> selectByApplicationParticipant(String participantId) {

     if(!Schema.SobjectType.Application_Participant__c.isaccessible()){
            return null;
        }

    sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Application_Participant__c =:participantId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
}

     /**
 * @description Select Individuals for a set of Identity Numbers
 * @author Jaco de Lange
 * @param identityNumbers
 * @return List<Individual>
 **/
    public List<Individual> selectByNationalIdentityNumbers(Set<String> identityNumbers) {
        if (!Schema.SObjectType.Individual.isAccessible()) {
            return null; // Object-level FLS check
        }

        List<Individual> individuals = [
            SELECT Id, National_Identity_Number__c, External_Country_Code__c
            FROM Individual
            WHERE National_Identity_Number__c IN :identityNumbers
        ];

        return individuals; // Return the queried list instead of the class name
    }
     /**
 * @description Select Individuals for a set of Identity Numbers
 * @author Jaco de Lange
 * @param identityNumbers
 * @return List<Individual>
 **/
    public List<Individual> findParticipantById(String participantId) {

        if(!Schema.SobjectType.Application_Participant__c.isaccessible()){
               return null;
           }
       sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
       fieldQueryFactory.setCondition('Application_Participant__c =:participantId');
       fieldQueryFactory.selectFields(fields);
       return Database.query(fieldQueryFactory.toSOQL());
   }
}