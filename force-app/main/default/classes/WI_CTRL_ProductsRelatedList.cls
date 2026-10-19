/**
 * @description Controller for the LWC wi_comp_productsRelatedList
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/02/13
 */
public with sharing class WI_CTRL_ProductsRelatedList {
    /**
     * @description Get related list records
     * @param recordId Id of the parent record
     * @param fields List api names of fields
     * @return Wrapper class with init data
     */
    @AuraEnabled(cacheable=false)
    public static DataResponse getRelatedListData(Id recordId) {
        DataResponse result;
        DataRelatedResponse obj = new DataRelatedResponse();
        try {
            obj.items = [
                SELECT Id, Opportunity.Pricebook2Id, Product2Id, Product2.Name, 
                    Product_Family__c, UnitPrice, TotalPrice, ServiceDate, 
                    Quantity, PricebookEntryId
                FROM OpportunityLineItem 
                WHERE OpportunityId = :recordId 
                ORDER BY CreatedDate DESC
            ];
            obj.record = [
                SELECT Id, Pricebook2Id, Pricebook2.Name, CurrencyIsoCode
                FROM Opportunity
                WHERE Id = :recordId 
                LIMIT 1
            ];
            result = new DataResponse(obj);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Get price books
     * @param recordId Id of the opportunity record
     * @return Wrapper class with price books data
     */
    @AuraEnabled(cacheable=false)
    public static DataResponse getPriceBooks(Id recordId) {
        DataResponse result;
        try {
            Opportunity opp = [
                SELECT Id, Pricebook2Id 
                FROM Opportunity 
                WHERE Id = :recordId 
                LIMIT 1
            ];
            Map<Id, Pricebook2> books = new Map<Id, Pricebook2>([
                SELECT Id, Name 
                FROM Pricebook2 
                WHERE IsActive = true 
                    AND IsStandard = false
            ]);
            List<UserRecordAccess> listUserRecordAccess = [
                SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess 
                FROM UserRecordAccess 
                WHERE UserId = :UserInfo.getUserId() 
                    AND RecordId IN :books.keySet()
            ];
            DataPriceBookObject obj = new DataPriceBookObject(opp.Pricebook2Id);
            for (UserRecordAccess item : listUserRecordAccess) {
                if (!item.HasReadAccess) continue;
                obj.options.add(new DataPriceBook(books.get(item.RecordId)));
            }
            result = new DataResponse(obj);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Remove opportunity line items
     * @param recordId Id of the opportunity record
     * @return Wrapper class with response
     */
    @AuraEnabled(cacheable=false)
    public static DataResponse removeLineItems(Id recordId) {
        DataResponse result;
        try {
            if (recordId.getSobjectType() == Schema.Opportunity.SObjectType) {
                delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :recordId];
            } else if (recordId.getSobjectType() == Schema.OpportunityLineItem.SObjectType) {
                delete [SELECT Id FROM OpportunityLineItem WHERE Id = :recordId];
            }
            result = new DataResponse(true);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Upsert opportunity line items
     * @param recordId Id of the opportunity record
     * @return Wrapper class with response
     */
    @AuraEnabled(cacheable=false)
    public static DataResponse upsertLineItems(List<OpportunityLineItem> records) {
        DataResponse result;
        try {
            for (OpportunityLineItem item : records) {
                if (item.Id == null) {
                    item.WI_Status__c = 'Setup';
                }
            }
            upsert records;
            result = new DataResponse(true);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Get products
     * @param priceBookId Id of the price book
     * @param oppCurrency Opportunity currency
     * @param search string with a part of the name
     * @param offset infinity offset
     * @return Wrapper class data
     */
    @AuraEnabled(cacheable=false)
    public static DataResponse getEntries(Id priceBookId, String oppCurrency, String search, Integer offset) {
        DataResponse result;
        try {
            String query = 'SELECT Id, Product2.Family, Product2Id, Product2.Name, UnitPrice' +
                ' FROM PricebookEntry' +
                ' WHERE Pricebook2Id = :priceBookId' +
                    ' AND IsActive = true' +
                    ' AND Product2.IsActive = true' +
                    ' AND CurrencyIsoCode = :oppCurrency';
            query += String.isNotBlank(search) 
                ? ' AND Product2.Name LIKE \'%' + String.escapeSingleQuotes(search) + '%\''
                : '';
            query += ' ORDER BY Product2.CreatedDate DESC LIMIT 30';
            query += ' OFFSET ' + String.escapeSingleQuotes(String.valueOf(offset));
            List<PricebookEntry> records = Database.query(query);
            result = new DataResponse(records);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Wrapper class with response to LWC component 
     */
    public class DataResponse {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String stack;
        @AuraEnabled
        public String result;

        /**
         * @description Wrapper constructor
         * @param ex exception record
         */
        public DataResponse(Exception ex) {
            this.isSuccess = false;
            this.message = ex.getMessage();
            this.stack = ex.getStackTraceString();
        }

        /**
         * @description Wrapper constructor
         * @param result output object
         */
        public DataResponse(Object result) {
            this.isSuccess = true;
            this.result = JSON.serialize(result);
        }
    }

    /**
     * @description Wrapper class with PriceBook Response data
     */
    public class DataPriceBookObject {
        public String selected;
        public List<DataPriceBook> options;

        /**
         * @description Wrapper constructor
         * @param oppPriceBookId Opportunity price book id
         */
        public DataPriceBookObject(Id oppPriceBookId) {
            this.selected = oppPriceBookId;
            this.options = new List<DataPriceBook>();
        }
    }

    /**
     * @description Wrapper class with Price Books options
     */
    public class DataPriceBook {
        public String label;
        public String value;

        /**
         * @description Wrapper constructor
         * @param Pricebook2 price book
         */
        public DataPriceBook(Pricebook2 book) {
            this.label = book.Name;
            this.value = book.Id;
        }
    }

    /**
     * @description Wrapper class with Related response
     */
    public class DataRelatedResponse {
        public Opportunity record;
        public List<OpportunityLineItem> items;
    }
}