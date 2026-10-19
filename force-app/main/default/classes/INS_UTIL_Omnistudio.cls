/**
 * @description Helper class to call methods from omniscript
 * @author Alexandr Goryachko
 * @date 2024/06/04
****************************************************************************************
* Last Modified By  Alexandr Goryachko
* Last Modified Date 18-12-2025
* Last Modified Description: Added getToken method
* User Story: SFP-54457
******************************************************************************************/

 global with sharing class INS_UTIL_Omnistudio implements omnistudio.VlocityOpenInterface2, System.Callable {
    /**
     * @description constructor to init request data
     * @param methodName
     * @param input map with input data
     * @param output map with output data
     * @param options map with options data
     */
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean isSuccess = true;
        if (methodName == 'logError') {
            try {
                logError(inputMap, options);
            } catch (Exception ex) {
                outMap.put('sucess', false);
                outMap.put('result', ex);
                isSuccess = false;
            }
        }
        try {
            if (methodName == 'getAddressPicklist') {
                outMap.put('options', getAddressPicklist());
            } else if (methodName == 'getProducers') {
                outMap.put('producersData', new SEL_Producer().getProducersByAccountNames(( 
                    (List<String>)JSON.deserialize(
                        JSON.serialize(inputMap.get('underwriters')), List<String>.class)
                )));
            } else if (methodName == 'convertExtras') {
                outMap.put('result', convertExtras(inputMap));
            } else if (methodName == 'mergeQuote') {
                outMap.put('result', mergeQuotes(inputMap, options));
            }
            else if('convertUnderwriterName'.equals(methodName)){
              outMap.put('underwriterName',((String)inputMap.get('underwriter')).replaceAll(' ','_'));
            } else if (methodName == 'getToken') {
                outMap.put('result', KYC_SRV_GenerateAccessToken.getAccessToken());
            }
            
        } catch (Exception ex) {
            String errorMessage = 'INS_UTIL_Omnistudio : Unhandled Exception '+ ex.getMessage() 
                +' Line Exception '+ ex.getLineNumber() + ' Stack trace: ' + ex.getStackTraceString();
            inputMap.put('Unhandled Exception',(object)errorMessage);
            logError(inputMap, options);
            outMap.put('sucess', false);
            outMap.put('result', ex);            
            isSuccess = false;
        }
        
        return isSuccess;
    }

    /**
     * @description construct the json extras object
     * @param inputMap
     */
     public static List<Object> convertExtras (Map<String, Object> inputMap){
         List<Object> records = (List<Object>)JSON.deserializeUntyped(JSON.serialize(inputMap.get('records')));
         for (Object item : records) {
             Map<String, Object> elem = (Map<String, Object>)item;
             String jsonExtra = ((String)elem.get('extrasJson')).replace(',]', ']');
             elem.put('extras', JSON.deserializeUntyped(jsonExtra));
         }
         return records;
     }

    /**
     * @description method to logging error in sbgplatform__rflib_Log__c
     * @param inputMap map with input data
     * @param options map with options data
     * @return output error
     */
    private void logError(Map<String, Object> inputMap, Map<String, Object> options) {
        List<String> argumentList = new List<String>{JSON.serialize(inputMap), JSON.serialize(options)};
        sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('INS_UTIL_Omnistudio');
        logger.error('Arguments: inputMap={0}; options={1}', argumentList);
    }

    /**
     * @description merge response with request data
     * @param inputMap map with input data
     * @param options map with options data
     * @return List with quotes
     */
    public List<Object> mergeQuotes(Map<String, Object> inputMap, Map<String, Object> options) {
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(inputMap.get('response')));

        List<Object> quotes = (List<Object>)response.get('quotes');

        String reference = (String)response.get('reference');
        String quoteId = (String)response.get('quoteId');

        Map<String, Object> request = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(options.get('request')));
        Map<String, Object> body = (Map<String, Object>)request.get('body');

        
        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName()
            .get('Insurance_Quote').getRecordTypeId();

        List<String> underwriters = buildUnderwriters(quotes);

        Map<String, Producer> producerByName = buildProducerByName(underwriters);

        List<Object> result = new List<Object>();
        for (Object quote : quotes) {
            Map<String, Object> elem = (Map<String, Object>)quote;
            List<Object> items = (List<Object>)elem.get('itemPremiums');
            if(items.isEmpty()){
                continue;
            }
            
            String underwriter = (String)elem.get('underwriter');
            elem.put('quoteReference', reference);
            elem.put('quoteReferenceId', reference + '#' + underwriter);
            elem.put('name', reference + ' - ' + underwriter);
            elem.put('quoteId', quoteId);
            elem.put('recordTypeId', recordTypeId);
            elem.put('producerId', producerByName.get(underwriter)?.Id);
            
            Map<String, Integer> indexMap = new Map<String, Integer>();
            Decimal totalExcess = 0;
            
            for (Object item : items) {
                Map<String, Object> itemElem = (Map<String, Object>)item;
                Map<String, Object> sfData = new Map<String, Object>();
                
                String itemType = (String)itemElem.get('itemType');
                
                if (indexMap.containsKey(itemType)) {
                    indexMap.put(itemType, indexMap.get(itemType) + 1);
                } else {
                    indexMap.put(itemType, 1);
                }
                sfData = buildsfData(itemElem,body,indexMap,itemtype);
                itemElem.put('sfData', sfData);
                
                if(itemElem.get('itemId') != null){
                	itemElem.put('uniqueId', (String)itemElem.get('itemId') + '#' + underwriter);
                }
                elem.put('sfOpportunityId', sfData.get('sfOpportunityId'));
                elem.put('sfProductId', sfData.get('sfProductId'));
                totalExcess += (Decimal)itemElem.get('basicExcess');
            }
            elem.put('totalExcess', totalExcess);
            result.add(quote);
        }
        return result;
    }

    /**
     * @description buildsfData structure sfdata whithin the json response.
     * @param itemElem
     * @param body 
     * @param indexMap
     * @param itemType 
     */

    public static  Map<String, Object> buildsfData( Map<String, Object> itemElem, Map<String, Object> body,Map<String, Integer> indexMap,String itemType){

        Map<String, Object> sfData = new Map<String, Object>();
        List<Object> vehicles = (List<Object>)body.get('vehicles');
        List<Object> buildings = (List<Object>)body.get('buildings');
        List<Object> allRisk = (List<Object>)body.get('allRisk');
        List<Object> caravanTrailer = (List<Object>)body.get('caravanTrailer');
        List<Object> homeContents = (List<Object>)body.get('homeContents');
        List<Object> motorCycle = (List<Object>)body.get('motorCycle');

        switch on (String)itemElem.get('itemType') {
            when 'CAR' {
                sfData = (Map<String, Object>)vehicles[indexMap.get(itemType) - 1];
            }
            when 'BUILDING' {
                sfData = (Map<String, Object>)buildings[indexMap.get(itemType) - 1];
            }
            when 'CARAVAN' {
                sfData = (Map<String, Object>)caravanTrailer[indexMap.get(itemType) - 1];
            }
            when 'ALLRISK' {
                sfData = (Map<String, Object>)allRisk[indexMap.get(itemType) - 1];
            }
            when 'CONTENT' {
                sfData = (Map<String, Object>)homeContents[indexMap.get(itemType) - 1];
            }
            when 'MOTORCYCLE' {
                sfData = (Map<String, Object>)motorCycle[indexMap.get(itemType) - 1];
            }
        }
        return sfData;

    }

    /**
     * @description build underwriters list
     * @param quotes
     */
    public static List<String> buildUnderwriters( List<Object> quotes){
        List<String> underwriters = new List<String>();
        for (Object quote : quotes) {
            Map<String, Object> elem = (Map<String, Object>)quote;
            underwriters.add((String)elem.get('underwriter'));
        }
        return underwriters;
    }

    /**
     * @description build producers list
     * @param underwriters
     */
    public static Map<String, Producer> buildProducerByName(List<String> underwriters) {
        Map<String, Producer> producerByName = new Map<String, Producer>();
        for (Producer item : new SEL_Producer().getProducersByAccountNames(underwriters)) {
            producerByName.put(item.Name, item);
        }
        return producerByName;
    }

    
    /**
     * @description get list of dependent countries and states
     * @return Map with countries and states
     */
    public List<Map<String, String>> getAddressPicklist() {
        List<Map<String, String>> result = new List<Map<String, String>>();
        Map<Object, List<Map<String, String>>> states = getDependentPicklistValues(
            Schema.CustomerProperty.Daytime_Address__StateCode__s
        );
        List<Schema.PicklistEntry> ple = CustomerProperty.Daytime_Address__CountryCode__s
            .getDescribe().getPicklistValues();
        for (Schema.PicklistEntry country : ple) {
            result.add(new Map<String, String>{
                'countryLabel' => country.getLabel(),
                'countryValue' => country.getValue()
            });
            if (!states.containsKey(country.getValue())) {
                continue;
            }
            for (Map<String, String> state : states.get(country.getValue())) {
                result.add(new Map<String, String>{
                    'countryLabel' => country.getLabel(),
                    'countryValue' => country.getValue(),
                    'stateLabel' => state.get('label'),
                    'stateValue' => state.get('value')
                });
            }
        }
        return result;
    }

    /**
     * @description System.Callable implementation for native OmniStudio Remote Action support
     * @param action method name
     * @param args map containing 'input', 'output', 'options'
     */
    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> inputMap = (Map<String, Object>) args.get('input');
        Map<String, Object> outMap = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        invokeMethod(action, inputMap, outMap, options);
        return null;
    }

    /**
     * @description Pass dependent field parameter e.g.: Account.YourDependentField__c
     * @param dependentField e.g.: Account.YourDependentField__c
     * @return Map with controlling-dependent values
     */
    private Map<Object, List<Map<String, String>>> getDependentPicklistValues(Schema.sObjectField dependentField) {
        Map<Object, List<Map<String, String>>> dependentPicklistValues = new Map<Object, List<Map<String, String>>>();
        //Get dependent field result
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        //Get dependent field controlling field 
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        //Check controlling field is not null
        if (controllerField == null) {
            return null;
        } 
        //Get controlling field result
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        //Get controlling field picklist values if controlling field is not a checkbox
        List<Schema.PicklistEntry> controllerValues = controllerFieldResult.getType() == Schema.DisplayType.Boolean 
            ? null : controllerFieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()) {
            if (!entry.isActive()) {
                continue;
            }
            //The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
            dependentPicklistValues = populateDependentPicklistValues(entry, controllerValues, dependentPicklistValues);
        }
        return dependentPicklistValues;
    }

    /**
     * @description helps to populate dependent picklist values
     * @param entry picklist entry
     * @param controllerValues controller values
     * @param result dependent picklist values
     * @return  `Map<Object, List<Map<String, String>>>`
     */
    private Map<Object, List<Map<String, String>>> populateDependentPicklistValues(Schema.PicklistEntry entry, List<Schema.PicklistEntry> controllerValues, Map<Object, List<Map<String, String>>> result) {
        //It is used to decode the characters of the validFor fields. 
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(
            JSON.serialize(entry))).get('validFor')).split('');
        for (Integer i = 0; i < controllerValues.size(); i++) {
            Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getValue() : null));
            Integer bitIndex = i / 6;
            Integer bitShift = 5 - Math.mod(i, 6 );
            if (controllerValue == null || bitIndex > base64chars.size() - 1 || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0) {
                continue;
            } 
            if (!result.containsKey(controllerValue)) {
                result.put(controllerValue, new List<Map<String, String>>());
            }
            result.get(controllerValue).add(
                new Map<String, String>{
                    'label' => entry.getLabel(),
                    'value' => entry.getValue()
                }
            );
        }
        return result;
    }
}