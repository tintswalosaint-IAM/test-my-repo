/**
 * @description       : Selector Class for Quotes
 * @author            : Michal Orawiec
 * @created           : 14-10-2025
***************************************************
 * Last Modified By Alexandr Goryachko
 * Last Modified Date 10/03/2026
 * Last Modified Description: Added additional fields to query
 * User Story : SFP-54457
***************************************************
 * Last Modified By Shams
 * Last Modified Date 24/07/2026
 * Last Modified Description: Added additional method to query by OpportunityId
 * User Story : SFP-59435
**/

public inherited sharing class SEL_Quote extends sbgplatform.fflib_SObjectSelector{
    private static final String QUOTE_STATUS_IN_PROGRESS = 'Quote In-Progress';
    /**
    * @description Implementation method for Quote Object as part of fflib framework
    * @author Michal Orawiec | 14-10-2025
    * @return Schema.SObjectType
    **/
    public override Schema.SObjectType getSObjectType() {
        return Quote.getSObjectType();
    }

    /**
    * @description Method to get list of fields to be part of response
    * @author Michal Orawiec | 14-10-2025
    * @return List<Schema.SObjectField>
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Quote.Id,
                Quote.AccountId,
                Quote.OpportunityId,
                Quote.INS_PolicyDocumentLatestStatus__c,
                Quote.Name,
                Quote.QuoteNumber,
                Quote.Status,
                Quote.ExpirationDate,
                Quote.INS_MonthlyPremium__c,
                Quote.UnderwriterQuoteReferenceNumber__c,
                Quote.Opportunity.AccountId
        };
    }

    /**
     * Method to fetch list of QuoteSobject based on Quote ids
     * @author Michal Orawiec | 14-10-2025
     * @param quoteIds Listo of quote ids
     * @return List<Quote>
     */
    public List<Quote> selectByIds(List<Id> quoteIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        fieldQueryFactory.setCondition('Id in :quoteIds');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * Method to fetch list of QuoteSobject based on Quote names or ids
     * @author Michal Orawiec | 14-10-2025
     * @param quoteIds Listo of ids
     * @return List<Quote>
     */
    public List<Quote> selectByIdsOrNames(List<Id> quoteIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        fieldQueryFactory.setCondition('Id IN :quoteIds OR Name IN :quoteIds');
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Calls method selectByAccIds in without sharing context
     * 'WoSharing' stands for 'Without Sharing'
     * @author Moukeswar M  | 20-11-2025
     * @param accIds list of account ids
     *
     * @return list of quotes
     */
    public List<Quote> selectByIdsWoSharing(List<Id> quoteIds) {
        return new NoQuoteSharing().selectByIds(this, quoteIds);
    }


    /**
   * Method to fetch list of QuoteSobject based on Account ids
   * @author Michal Orawiec | 07-11-2025
   * @param accIds Listo of ids
   * @return List<Quote>
   */
    public List<Quote> selectByAccIds(List<Id> accIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AccountId IN :accIds');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Calls method selectByAccIds in without sharing context
     * 'WoSharing' stands for 'Without Sharing'
     * @author Moukeswar M  | 20-11-2025
     * @param accIds list of account ids
     *
     * @return list of quotes
     */
    public List<Quote> selectByAccIdsWoSharing(List<Id> accIds) {
        return new NoQuoteSharing().selectByAccIds(this, accIds);
    }


    /**
   * Method to fetch list of in-progress QuoteSobject based on Account ids
   * @param accIds List of account ids
   * @return List<Quote>
   */
    public List<Quote> selectInProgressByAccIds(List<Id> accIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        fieldQueryFactory.setCondition('AccountId IN :accIds AND Status = :QUOTE_STATUS_IN_PROGRESS');
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Calls method selectInProgressByAccIds in without sharing context
     * 'WoSharing' stands for 'Without Sharing'
     * @param accIds list of account ids
     *
     * @return list of in-progress quotes
     */
    public List<Quote> selectInProgressByAccIdsWoSharing(List<Id> accIds) {
        return new NoQuoteSharing().selectInProgressByAccIds(this, accIds);
    }

    /**
     * @description Select list of QuoteSobject based on Opportunity ids
     * @author Shams
     * @param opportunityIds List of opportunity ids
     * @return List<Quote>
     */
    public List<Quote> selectByOpportunityIds(List<Id> opportunityIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, true, true);
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return new List<Quote>();
        }
        fieldQueryFactory.setCondition('OpportunityId IN :opportunityIds');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Is used for omitting sharing setting, when needed
     */
    private without sharing class NoQuoteSharing {
        /**
        * @description Returns list of quotes by account ids without sharing
        *
        * @param selQuote SEL_Quote Quote selector instance
        * @param accIds List<Id> list of account ids
        *
        * @return list of selected quotes
        */
        public List<Quote> selectByAccIds(SEL_Quote selQuote, List<Id> accIds) {
            return selQuote.selectByAccIds(accIds);
        }

        /**
        * @description Returns list of in-progress quotes by account ids without sharing
        *
        * @param selQuote SEL_Quote Quote selector instance
        * @param accIds List<Id> list of account ids
        *
        * @return list of selected in-progress quotes
        */
        public List<Quote> selectInProgressByAccIds(SEL_Quote selQuote, List<Id> accIds) {
            return selQuote.selectInProgressByAccIds(accIds);
        }
        /**
        * @description Returns list of quotes by ids without sharing
        *
        * @param selQuote SEL_Quote Quote selector instance
        * @param ids List<Id> list of quote ids
        *
        * @return list of selected quotes
        */
        public List<Quote> selectByIds(SEL_Quote selQuote, List<Id> ids) {
            return selQuote.selectByIds(ids);
        }
    }
}