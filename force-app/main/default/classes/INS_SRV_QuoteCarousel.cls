/**
 * @description Get qoutes for carousel component
 * @author Alexandr Goryachko
 * @date 2024/05/20
 */
public with sharing class INS_SRV_QuoteCarousel implements INS_IData {
    private final static String VEHICLE_TYPE = 'vehicle';
    /**
     * @description Get init data for the carousel component
     * @param params parameters
     * @return List of records
     */
    public DataResponse getData(Map<String, Object> params) {
        Id oppRecordId = (Id)params.get('recordId');
        Map<Id, DataQuoteLineItem> records = new Map<Id, DataQuoteLineItem>();
        List<QuoteLineItem> quoteItems = new SEL_QuoteLineItem().getQuoteLineItemsByOpportunityId(oppRecordId);
        List<OpportunityLineItem> opportunityItems = new SEL_OpportunityLineItem().getOpportunityLineItemsByOpportunityId(oppRecordId);
        Decimal min;
        Decimal max;
        String currencyCode;
        for (QuoteLineItem item : quoteItems) {
            min = min > item.Quote.GrandTotal || min == null ? item.Quote.GrandTotal : min;
            max = max < item.Quote.GrandTotal || max == null ? item.Quote.GrandTotal : max;
            currencyCode = item.CurrencyIsoCode;
            if (records.containsKey(item.Quote.Id)) {
                records.get(item.Quote.Id).addItem(item);
            } else {
                records.put(item.Quote.Id, new DataQuoteLineItem(item));
            }
        }
        Integer countVehicle = 0;
        for (OpportunityLineItem item : opportunityItems) {
            countVehicle += item.ProductCode == VEHICLE_TYPE ? 1 : 0;
        }
        DataHeader header = new DataHeader(oppRecordId, min, max, currencyCode);
        header.countVehicle = countVehicle;
        return new DataResponse(records.values(), header);
    }

    public class DataResponse {
        @AuraEnabled
        public List<DataQuoteLineItem> records;
        @AuraEnabled
        public DataHeader header;

        public DataResponse(List<DataQuoteLineItem> records, DataHeader header) {
            this.records = records;
            this.header = header;
        }
    }

    public class DataHeader {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String rangeMin;
        @AuraEnabled
        public String rangeMax;
        @AuraEnabled
        public Integer countVehicle = 1;
        @AuraEnabled
        public Integer countHome;
        @AuraEnabled
        public Integer countContent;

        public DataHeader(String recordId, Decimal min, Decimal max, String currencyCode) {
            this.rangeMin = min == null ? '' : currencyCode + ' ' + min.toPlainString();
            this.rangeMax = max == null ? '' : currencyCode + ' ' + max.toPlainString();
            this.id = recordId;
        }
    }

    public class DataQuoteLineItem {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String cssStyleParent;
        @AuraEnabled
        public String cssStyle;
        @AuraEnabled
        public String img;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String excess;
        @AuraEnabled
        public String totalPrice;
        @AuraEnabled
        public Decimal totalPriceDecimal;
        @AuraEnabled
        public String currencyCode;
        @AuraEnabled
        public List<DataQuoteLineItemAsset> assets;

        public DataQuoteLineItem(QuoteLineItem record) {
            record.Quote.Excess__c = record.Quote.Excess__c == null ? 0 : record.Quote.Excess__c;
            this.id = record.Quote.Id;
            this.title = record.Quote.Producer__r?.Account?.Name;
            this.img = record.Quote.Producer__r?.Account?.Image__c;
            this.cssStyleParent = record.Quote.Producer__r?.Account?.ColourHex__c == null 
                ? '' : 'border: 1px solid ' + record.Quote.Producer__r?.Account?.ColourHex__c + ';';
            this.cssStyle = record.Quote.Producer__r?.Account?.ColourHex__c == null 
                ? '' : 'background: ' + record.Quote.Producer__r?.Account?.ColourHex__c + ';';
            this.excess = record.CurrencyIsoCode + ' ' + record.Quote.Excess__c.toPlainString();
            this.totalPrice = record.CurrencyIsoCode + ' ' + record.Quote.GrandTotal.toPlainString();
            this.currencyCode = record.CurrencyIsoCode;
            this.assets = new List<DataQuoteLineItemAsset>{
                new DataQuoteLineItemAsset(record)
            };
        }

        public DataQuoteLineItem addItem(QuoteLineItem record) {
            this.assets.add(new DataQuoteLineItemAsset(record));
            return this;
        }
    }

    public class DataQuoteLineItemAsset {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String img;
        @AuraEnabled
        public Decimal unitPrice;

        public DataQuoteLineItemAsset(QuoteLineItem record) {
            this.id = record.Id;
            this.name = record.Description;
            this.img = record.Product2.Product_Image__c;
            this.unitPrice = record.unitPrice;
        }
    }
}