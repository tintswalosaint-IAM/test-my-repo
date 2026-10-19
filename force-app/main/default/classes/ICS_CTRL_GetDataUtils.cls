/**
 * @description                 : Class needed by Application flow stories
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 20-03-2024
 * @ last modified on           : 15-07-2025
 * @modification description    : Created
 * @last modified on            : 03-10-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Improved null handling
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity') //Make code manageable at one place
public without sharing class ICS_CTRL_GetDataUtils {
   
    static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_GetDataUtils');
    ICS_CTRL_GetData getData;

    /**
    * @description Initialize instance with reference to GetData class
    * @author Tushar Walse | 23-09-2024 
    * @param pGetData Reference to GetData class
    **/
    public ICS_CTRL_GetDataUtils(ICS_CTRL_GetData pGetData) {
            getData = pGetData;
    }

    /**
    * @description Function to throw exception when the condition is true
    * @author Tushar Walse | 23-09-2024 
    * @param condition Condition to be checked before throwing exception
    * @param errorMessage Exception message
    **/
    public void myThrow(Boolean condition, String errorMessage) {
        if(condition) {
            throw new IllegalArgumentException(errorMessage);
        }
    }

    /**
     * @description                 : Class to compare field values for sorting
     * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
     * @author                      : Tushar Walse
     * @date                        : 21-09-2024
     * @last modified on            : 03-10-2025
     * @last modified by            : Tushar Walse
     * @modification description    : Created
     */
    @SuppressWarnings('PMD.CyclomaticComplexity') //Make code manageable at one place
    public class SObjectComparator implements System.Comparator<sObject> {
            
        @SuppressWarnings('PMD.ImmutableField') //Unable to change this as causing errors
        Boolean order = false;
        @SuppressWarnings('PMD.ImmutableField') //Unable to change this as causing errors
        Schema.sObjectField sortField;
        @SuppressWarnings('PMD.ImmutableField') //Unable to change this as causing errors
        DescribeFieldResult describeResult;
        String[] orderValues;

        /**
         * @description Constructor to get sort field description
         * @param Sort Field to be used for sorting
         * @return void
         */
        public SObjectComparator(Schema.sObjectField compareField) {
            sortField = compareField;
            describeResult = sortField.getDescribe();
        }

        /**
        * @description Constructor with values to show first
        * @author Tushar Walse | 23-09-2024 
        * @param compareField Field used for sorting
        * @param pOrder JSON string containing values that should appear first
        **/
        public SObjectComparator(Schema.sObjectField compareField, String pOrder) {
            try {
                this(compareField);
                if(pOrder.contains('[')) {
                    orderValues = (String[])JSON.deserialize(pOrder, String[].Class);
                } else {
                    orderValues =  null;
                }
                order = pOrder == 'Descending';
            } catch (Exception e) {
                LOGGER.error('Error: {0}\nline: {1}\nexception type: {2}\nstack trace: {3}', new Object[]{e.getMessage(), e.getLineNumber(), e.getTypeName(), e.getStackTraceString()});
            }
        }

        /**
        * @description Compare the field values
        * @author Tushar Walse | 23-09-2024 
        * @param s1 First record for comparison
        * @param s2 Second record for comparison
        * @return Integer Outcome of comparison
        **/
        @testvisible
        Integer compareFields(SObject s1, SObject s2) {
            try {
                Integer compareResult;
                Object s1FieldValue = s1?.get(sortField);
                Object s2FieldValue = s2?.get(sortField);
                
                if(s1FieldValue == null && s2FieldValue == null) {
                    compareResult = 0;
                } else if (s1FieldValue == null) {
                    compareResult = 1;
                } else if (s2FieldValue == null) {
                    compareResult = -1;
                } else {
                    compareResult = compareFieldTypes(s1FieldValue, s2FieldValue);
                }
                return compareResult;
            } catch (Exception e) {
                LOGGER.error('Error in compareFields: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
                return null;
            }
        }

        /**
        * @description Compare the records
        * @author Tushar Walse | 23-09-2024 
        * @param s1 First record for comparison
        * @param s2 Second record for comparison
        * @return Integer Outcome of comparison
        **/
        public Integer compare(SObject s1, SObject s2) {
            try {
                
                Integer compareResult;
                
                if(s1 == null && s2 == null) {
                    compareResult = 0;
                } else if (s1 == null) {
                    compareResult = 1;
                } else if (s2 == null) {
                    compareResult = -1;
                } else {
                    compareResult = compareFields(s1, s2);
                }

                if(order) {
                    return compareResult * -1;
                }
                return compareResult;
            } catch (Exception e) {
                LOGGER.error('Error in compare: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
                return null;
            }
        }

        /**
        * @description Compare when order values aren't given
        * @author Tushar Walse | 17th Sep 2024 
        * @param s1FieldValue First field value
        * @param s2FieldValue Second field value
        * @return Integer Outcome of comparison
        **/
        @testvisible
        @SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount, PMD.UnusedLocalVariable') //Make code manageable at one place
        Integer compareWhenNull(Object s1FieldValue, Object s2FieldValue) {
            try {

                Boolean lessThan = false;
                Boolean moreThan = false;
                
                switch on (describeResult.getType()) {
                    when CURRENCY {
                        Decimal s1 = Decimal.valueOf('' + s1FieldValue);
                        Decimal s2 = Decimal.valueOf('' + s2FieldValue);
                        lessThan = s1 < s2;
                        moreThan = s1 > s2;   
                    } 
                    when String {
                        String s1 = (String)s1FieldValue;
                        String s2 = (String)s2FieldValue;
                        lessThan = s1 < s2;
                        moreThan = s1 > s2;   
                    } 
                    when DateTime {
                        DateTime s1 = (DateTime)s1FieldValue;
                        DateTime s2 = (DateTime)s2FieldValue;
                        lessThan = s1 < s2;
                        moreThan = s1 > s2;  
                    }
                    when Date {
                        Date s1 = (Date)s1FieldValue;
                        Date s2 = (Date)s2FieldValue;
                        lessThan = s1 < s2;
                        moreThan = s1 > s2;  
                    }
                    when Integer {
                        Integer s1 = (Integer)s1FieldValue;
                        Integer s2 = (Integer)s2FieldValue;
                        lessThan = s1 < s2;
                        moreThan = s1 > s2;  
                    }
                    when Double {
                        Double s1 = (Double)s1FieldValue;
                        Double s2 = (Double)s2FieldValue;
                        lessThan = s1 < s2;
                        moreThan = s1 > s2;  
                    }
                    when Id {
                        Id s1 = (Id)s1FieldValue;
                        Id s2 = (Id)s2FieldValue;
                        lessThan = s1 < s2;
                        moreThan = s1 > s2;  
                    }
                    when PICKLIST {
                        String s1 = (String)s1FieldValue;
                        String s2 = (String)s2FieldValue;
                        lessThan = s1 < s2;
                        moreThan = s1 > s2;   
                    }
                    when else {
                        throw new IllegalArgumentException('Unable to compare field type: ' + describeResult.getType());
                    }
                }
                return lessThan ? -1 : moreThan ? 1 : 0;
            } catch (Exception e) {
                LOGGER.error('Error in compareWhenNull: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
                return null;
            }
        }

        /**
        * @description Compare when order values are provided
        * @author Tushar Walse | 17th Sep 2024 
        * @param s1FieldValue First field value
        * @param s2FieldValue Second field value
        * @return Integer Outcome of comparison
        **/
        @testvisible
        @SuppressWarnings('PMD.CyclomaticComplexity') //Make code manageable at one place
        Integer compareWhenNotNull(Object s1FieldValue, Object s2FieldValue) {
            try {
                Integer s1 = orderValues.indexOf('' + s1FieldValue);
                Integer s2 = orderValues.indexOf('' + s2FieldValue);
                if(s1 == -1 && s2 == -1) {
                    String str1 = '' + s1FieldValue;
                    String str2 = '' + s2FieldValue;
                    return (str1 < str2) ? -1 : (str1 > str2) ? 1 : 0;
                } else if(s1 == -1) {
                    s1 = s2 + 1;
                } else if(s2 == -1) {
                    s2 = s1 + 1;
                }
                return (s1 < s2) ? -1 : (s1 > s2) ? 1 : 0;
            } catch (Exception e) {
                LOGGER.error('Error in compareWhenNotNull: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
                return null;
            }
        }

        /**
        * @description Check if order values are provided
        * @author Tushar Walse | 17th Sep 2024 
        * @param s1FieldValue First field value
        * @param s2FieldValue Second field value
        * @return Integer Outcome of comparison
        **/
        @testvisible
        Integer compareFieldTypes(Object s1FieldValue, Object s2FieldValue) {
            try {
                if(orderValues == null) {
                    return compareWhenNull(s1FieldValue, s2FieldValue);
                } else {
                    return compareWhenNotNull(s1FieldValue, s2FieldValue);
                }
            } catch (Exception e) {
                LOGGER.error('Error in compareFieldTypes: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
                return null;
            }
        }
    }

    /**
    * @description Convert object of strings list to string list
    * @author Tushar Walse | 17th Sep 2024 
    * @param iterableObject 
    * @return String[] List of strings
    **/
    public String[] objectToString(Object iterableObject) {
        try {
            String[] lsstr= new String[]{};
            for(Object a : (List<Object>)iterableObject){
                lsstr.add('' + a);
            }
            return(lsstr);
        } catch (Exception e) {
            LOGGER.error('Error in objectToString: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            return null;
        }
    }

    /**
    * @description Convert object of strings list to string list
    * @author Tushar Walse | 17th Sep 2024 
    * @param iterableObject 
    * @return String[] List of strings
    **/
    public String[] objectToString2(Object iterableObject) {
        try {
            String[] lsstr= new String[]{};
            for(Object a : (List<Object>)iterableObject){
                if(a == null) {
                    lsstr.add('');
                } else {
                    lsstr.add('' + a);
                }
            }
            return(lsstr);
        } catch (Exception e) {
            LOGGER.error('Error in objectToString2: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            return null;
        }
    }

    /**
    * @description Convert JSON to Map<String, String>
    * @author Tushar Walse | 17th Sep 2024 
    * @param jsonString JSON to be converted
    * @return Map<String, String> The converted map
    **/
    public Map<String, String> fromJSONtoMap(String jsonString) {
        try {
            return (Map<String, String>)JSON.deserialize(jsonString, Map<String, String>.class);
        } catch (Exception e) {
            LOGGER.error('Error in fromJSONtoMap: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            return null;
        }
    }

    /**
    * @description Get picklist value vs label map
    * @author Tushar Walse | 17th Sep 2024 
    * @param fullyQualName Fully qualified field name of the picklist field
    * @return Map<String, String> Value vs label map
    **/
    public Map<String, String> getPickListValueMap(String fullyQualName) {
        try {
            SObjectField picklistField = getField(fullyQualName);
            Map<String, String> valuesMap = new Map<String, String>();
            
            for(PicklistEntry value : picklistField.getDescribe().getPicklistValues()) {
                valuesMap.put(value.getValue(), value.getLabel());
            }

            return(valuesMap);
        } catch (Exception e) {
            LOGGER.error('Error in getPickListValueMap: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            return null;
        }
    }

    /**
    * @description Get field value
    * @author Tushar Walse | 17th Sep 2024 
    * @param field Fully qualified field name
    * @return SObjectField Value of the field
    **/
    public SObjectField getField(String field) {
        try {
            String[] splitString = field.split('\\.');
            String objectName = splitString[0];
            String fieldName = splitString[1];
                
            return getField(objectName, fieldName);
        } catch (Exception e) {
            LOGGER.error('Error in getField: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            return null;
        }
    }

    /**
    * @description Get value of field
    * @author Tushar Walse | 17th Sep 2024 
    * @param objectName Name of the object
    * @param fieldName Name of the field
    * @return SObjectField Value of the field
    **/
    public SObjectField getField(String objectName, String fieldName) {
        try {                
            SObjectType objectType = ((SObject)Type.forName(objectName).newInstance()).getSObjectType();
            return objectType.getDescribe().fields.getMap().get(fieldName);
        } catch (Exception e) {
            LOGGER.error('Error in getField: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            return null;
        }
    }

    /**
    * @description Convert to time a timezone and Format DateTime field
    * @author Tushar Walse | 23-09-2024 
    * @param inputs DateTime string value
    * @param allFieldValues String list that stores all outcomes
    * @param arg Semicolon seperated format and time zone
    **/
    @testvisible
    void applyFunctionFormat(String[] inputs, String[] allFieldValues, String arg) {
        try {
            for(String input : inputs) {
                if(input == 'null') {
                    allFieldValues.add(null);
                } else if(arg.substringAfter(';') != '') {
                    allFieldValues.add(DateTime.valueOfGMT(input).format(arg.substringBefore(';'), arg.substringAfter(';')));
                } else {
                    allFieldValues.add(DateTime.valueOfGMT(input).format(arg.substringBefore(';')));
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionFormat: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Split semicolon seperated string and retrieve specified value
    * @author Tushar Walse | 23-09-2024 
    * @param input Semicolon delimeted string
    * @param allFieldValues String list that stores all outcomes
    * @param arg Index of the value to be retrieved after splitting
    **/
    @testvisible
    void applyFunctionSplit(String input, String[] allFieldValues, String arg) {
        try {
            Integer i = Integer.valueOf(arg);
            if(input != null) {
                String[] strs = input.split(';');
                if(i < strs.size()) {
                    allFieldValues.add(strs[i]);
                } else {
                    allFieldValues.add(null);
                }    
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionSplit: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Display a constant string instead of field values
    * @author Tushar Walse | 23-09-2024 
    * @param inputs Field values to be processed
    * @param allFieldValues String list that stores all outcomes
    * @param arg The constant string to be displayed
    **/
    @testvisible
    void applyFunctionLiteral(String[] inputs, String[] allFieldValues, String arg) {
        try {
            for(Integer i = 0; i < inputs.size(); i++) {
                Object obj = JSON.deserializeUntyped(arg);
                if(obj instanceOf List<Object>) {
                    String[] args = objectToString(obj);
                    allFieldValues.add(String.join(args, ', '));    
                } else {
                    allFieldValues.add('' + obj);
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionLiteral: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Extract log i.e. reasons for entering the queue
    * @author Tushar Walse | 29-10-2024 
    * @param inputs Field value containing log
    * @param allFieldValues Output
    * @param arg 
    **/
    @testvisible
    void applyFunctionGetLog(String[] inputs, String[] allFieldValues) {
        try {
            for(String stringToUpdate : inputs) {
                String log = '';
                stringToUpdate = stringToUpdate == null ? '' : stringToUpdate;
                if(stringToUpdate.contains(ICS_CTRL_ApprovalFlow.STRING_START_LOG) &&
                    stringToUpdate.contains(ICS_CTRL_ApprovalFlow.STRING_END_LOG)) {
                        log = stringToUpdate.substringBetween(ICS_CTRL_ApprovalFlow.STRING_START_LOG, ICS_CTRL_ApprovalFlow.STRING_END_LOG);
                        stringToUpdate = stringToUpdate.remove(ICS_CTRL_ApprovalFlow.STRING_START_LOG + log + ICS_CTRL_ApprovalFlow.STRING_END_LOG);
                }        
                allFieldValues.add(log);
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionGetLog: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Replace two letter country codes with full names
    * @author Tushar Walse | 23-09-2024 
    * @param inputs Field values to be processed
    * @param allFieldValues String list that stores all outcomes
    **/
    @testvisible
    void applyFunctionCountryName(String[] inputs, String[] allFieldValues) {
        try {
            for(String input : inputs) {
                List<Map<String, Object>> country = getData.getFieldValue('AOB_ReferencedData__c(AOB_SAPField__c = :"ICS_Country" && AOB_Code__c = :"' + input.trim() + '").(Name)');
                if(country == null || country.isEmpty()) {
                    allFieldValues.add(input);
                } else {
                    allFieldValues.add('' + country[0].values()[0]);
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionCountryName: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    @testvisible
    void applyFunctionExpectedEndDateTime(String[] inputs, String[] allFieldValues, String arg) {
        try {
            String formatString = arg.substringAfter(';');
            arg = arg.substringBefore(';');
            for(String input : inputs) {
                List<Map<String, Object>> businessHoursRecord = getData.getFieldValue('BusinessHours(0).(Id)');
                if(businessHoursRecord == null || businessHoursRecord.isEmpty()) {
                    allFieldValues.add(null);
                } else if(formatString.substringAfter(';') != '') {
                    allFieldValues.add('' + BusinessHours.add((String)businessHoursRecord[0].values()[0], Datetime.valueOfGMT(input), Long.valueOf(arg)).format(formatString.substringBefore(';'), formatString.substringAfter(';')));
                } else {
                    allFieldValues.add('' + BusinessHours.add((String)businessHoursRecord[0].values()[0], Datetime.valueOfGMT(input), Long.valueOf(arg)).format(formatString.substringBefore(';')));
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionExpectedEndDateTime: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    
    /**
    * @description Split semicolon seperated country codes and replace with full names
    * @author Tushar Walse | 23-09-2024 
    * @param input Field value to be processed
    * @param allFieldValues String list that stores all outcomes
    **/
    @testvisible
    void applyFunctionCountryNames(String input, String[] allFieldValues) {
        try {
            String countries = '';
            for(String countryCode : input.split(';')) {
                List<Map<String, Object>> country = getData.getFieldValue('AOB_ReferencedData__c(AOB_SAPField__c = :"ICS_Country" && AOB_Code__c = :"' + countryCode.trim() + '").(Name)');
                if(country != null && country.size()>0) {
                    countries += country[0].values()[0] + ';';
                } else {
                    countries += countryCode + ';';
                }
            }
            countries = countries.removeEnd(';');
            if(countries == '') {
                allFieldValues.add(null);
            } else {
                allFieldValues.add(countries);
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionCountryNames: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Add all field values
    * @author Tushar Walse | 23-09-2024 
    * @param inputs Field values to be processed
    * @param allFieldValues String list that stores all outcomes
    **/
    @testvisible
    void applyFunctionSum(String[] inputs, String[] allFieldValues) {
        try {
            Decimal sum = 0;
            for(String input : inputs) {
                if(input != 'null') {
                    sum += Decimal.valueOf(input);
                }
            }
            allFieldValues.add(String.valueOf(Sum));
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionSum: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Add lengths of all field values
    * @author Tushar Walse | 23-09-2024 
    * @param inputs Field values to be processed
    * @param allFieldValues String list that stores all outcomes
    **/
    @testvisible
    void applyFunctionLength(String[] inputs, String[] allFieldValues) {
        try {
            Decimal sum = 0;
            for(String input : inputs) {
                if(input != null) {
                    sum += input.length();
                }
            }
            allFieldValues.add(String.valueOf(Sum));
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionLength: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Retrieve orders of all field values
    * @author Tushar Walse | 23-09-2024 
    * @param input Field value to be processed
    * @param args List of values to be considered to decide the higher one
    * @param index Stores orders of all field values
    **/
    @testvisible
    void applyFunctionHighestOf(String input, String[] args, Integer[] index) {
        try {
            for(Integer i = 0; i < args.size(); i++) {
                if(args[i] == input) {
                    index.add(-i);
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionHighestOf: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Retrieve highest of all field values
    * @author Tushar Walse | 23-09-2024 
    * @param inputs Field values to be processed
    * @param allFieldValues String list that stores all outcomes
    * @param arg JSON list of values in low to high order
    **/
    @testvisible
    void applyFunctionHighestOf(String[] inputs, String[] allFieldValues, String arg) {
        try {
            String[] args = objectToString(JSON.deserializeUntyped(arg));
            Integer[] index = new Integer[]{};
            for(String input : inputs) {
                applyFunctionHighestOf(input, args, index);
            }
            if(index.size() > 0) {
                index.sort();
                allFieldValues.add(args[-index[0]]);    
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionHighestOf: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Logically AND all field values
    * @author Tushar Walse | 23-09-2024 
    * @param inputs Field values to be processed
    * @param allFieldValues String list that stores all outcomes
    **/
    @testvisible
    void applyFunctionAndAll(String[] inputs, String[] allFieldValues) {
        try {
            Boolean result;
            if(inputs.size()>0) {
                result = true;
            }
            for(String input : inputs) {
                if(result == null || input == null) {
                    result = null;
                } else {
                    result = result && input == 'true';
                }
            }
            allFieldValues.add(String.valueOf(result));
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionAndAll: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Logically OR all field values
    * @author Tushar Walse | 14-02-2025 
    * @param inputs Field values to be processed
    * @param allFieldValues String list that stores all outcomes
    **/
    @testvisible
    void applyFunctionOrAll(String[] inputs, String[] allFieldValues, String arg) {
        try {
            Boolean result;
            String resultString;
            Map<String, String> args = new Map<String, String>();
            if(arg.startsWith('{')) {
                arg = arg.replaceAll('"; "', '", "');
                args = (Map<String, String>)JSON.deserialize(arg, Map<String, String>.class);
                arg = args.get('');
                args.remove('');
            }
            String considerNullAs = arg == 'null' ? null : arg;
            if(inputs.size()>0) {
                result = false;
            }
            for(String input : inputs) {
                input = input == null ? considerNullAs : input;
                if(result == null || input == null) {
                    result = null;
                } else {
                    result = result || input == 'true';
                }
            }
            result = result == null ? arg == 'null' ? null : Boolean.valueOf(arg) : result;
            resultString = String.valueOf(result);
            if(args.containsKey(resultString)) {
                resultString = args.get(resultString);
            }
            allFieldValues.add(resultString);
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionOrAll: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Retrieve a JSON field value from JSON string field value
    * @author Tushar Walse | 23-09-2024 
    * @param input Field value that happens to be a JSON string
    * @param allFieldValues String list that stores all outcomes
    * @param arg JSON field name whose value is to be retrieved
    **/
    @testvisible
    void applyFunctionJSONField(String input, String[] allFieldValues, String arg) {
        try {
            if(input == null) {
                allFieldValues.add(null);
            } else {
                Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(input.unescapeEcmaScript());
                if(params.get(arg) instanceOf List<Object>) {
                    String allValues = String.join(objectToString(params.get(arg)), ', ');
                    allFieldValues.add(allValues);
                } else {
                    allFieldValues.add('' + params.get(arg));
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionJSONField: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Prefix all field values with /
    * @author Tushar Walse | 23-09-2024 
    * @param inputs Field values to be processed
    * @param allFieldValues String list that stores all outcomes
    **/
    @testvisible
    void applyFunctionPrefixSlash(String[] inputs, String[] allFieldValues) {
        try {
            for(String input : inputs) {
                allFieldValues.add('/' + input);
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionPrefixSlash: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Replace values with strings provided as map
    * @author Tushar Walse | 23-09-2024 
    * @param inputs Field values to be processed
    * @param allFieldValues String list that stores all outcomes
    **/
    @testvisible
    void applyFunctionDecode(String[] inputs, String[] allFieldValues, String arg) {
        try {            
            Map<String, String> stringMap = (Map<String, String>)JSON.deserialize(arg, Map<String, String>.class);
            for(String input : inputs) {
                if(stringMap.containsKey(input)) {
                    allFieldValues.add(stringMap.get(input));
                } else {
                    allFieldValues.add(input);
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionDecode: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Replace values with strings provided as map
    * @author Tushar Walse | 23-09-2024 
    * @param inputs Field values to be processed
    * @param allFieldValues String list that stores all outcomes
    **/
    @testvisible
    void applyFunctionDecodeOnly(String[] inputs, String[] allFieldValues, String arg) {
        try {            
            Map<String, String> stringMap = (Map<String, String>)JSON.deserialize(arg, Map<String, String>.class);
            for(String input : inputs) {
                if(stringMap.containsKey(input)) {
                    allFieldValues.add(stringMap.get(input));
                } else {
                    allFieldValues.add('');
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error in applyFunctionDecodeOnly: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }

    /**
    * @description Apply specified function to all field values
    * @author Tushar Walse | 17th Sep 2024 
    * @param function Descriptive name of function to be applied
    * @param pInputs All field values
    * @param arg Argument to the function to be applied
    * @return String[] Resulting list of all processed field values
    **/
    @SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount') //Make code manageable at one place
    public String[] applyFunction(String function, Object[] pInputs, String arg) {
        try {
            String[] allFieldValues = new String[]{};
            String[] inputs = objectToString(pInputs);

            switch on function {
                when 'Format' {
                    applyFunctionFormat(inputs, allFieldValues, arg);
                }
                when 'Split' {
                    for(String input : inputs) {
                        applyFunctionSplit(input, allFieldValues, arg);
                    }
                }
                when 'Decode' {
                    applyFunctionDecode(inputs, allFieldValues, arg);
                }
                when 'DecodeOnly' {
                    applyFunctionDecodeOnly(inputs, allFieldValues, arg);
                }
                when 'Literal' {
                    applyFunctionLiteral(inputs, allFieldValues, arg);
                }
                when 'Getlog' {
                    applyFunctionGetLog(inputs, allFieldValues);
                }
                when 'prefixSlash' {
                    applyFunctionPrefixSlash(inputs, allFieldValues);
                }
                when 'Upper' {
                    for(String input : inputs) {
                        allFieldValues.add(input.toUpperCase());
                    }
                }
                when 'Capitalize' {
                    for(String input : inputs) {
                        allFieldValues.add(input.capitalize());
                    }
                }
                when 'Lower' {
                    for(String input : inputs) {
                        allFieldValues.add(input.toLowerCase());
                    }
                }
                when 'Center' {
                    for(String input : inputs) {
                        allFieldValues.add(input.center(Integer.valueOf(arg.substringBefore(';')), arg.substringAfter(';')));
                    }
                }
                when 'leftPad' {
                    for(String input : inputs) {
                        allFieldValues.add(input.leftPad(Integer.valueOf(arg.substringBefore(';')), arg.substringAfter(';')));
                    }
                }
                when 'rightPad' {
                    for(String input : inputs) {
                        allFieldValues.add(input.rightPad(Integer.valueOf(arg.substringBefore(';')), arg.substringAfter(';')));
                    }
                }
                when 'left' {
                    for(String input : inputs) {
                        allFieldValues.add(input.left(Integer.valueOf(arg)));
                    }
                }
                when 'right' {
                    for(String input : inputs) {
                        allFieldValues.add(input.right(Integer.valueOf(arg)));
                    }
                }
                when 'remove' {
                    for(String input : inputs) {
                        allFieldValues.add(input.remove(arg));
                    }
                }
                when 'getLevenshteinDistance' {
                    for(String input : inputs) {
                        allFieldValues.add('' + input.getLevenshteinDistance(arg));
                    }
                }
                when 'normalizeSpace' {
                    for(String input : inputs) {
                        allFieldValues.add(input.normalizeSpace());
                    }
                }
                when 'substringBetween' {
                    for(String input : inputs) {
                        allFieldValues.add(input.substringBetween(arg.substringBefore(';'), arg.substringAfter(';')));
                    }
                }
                when 'replaceAll' {
                    for(String input : inputs) {
                        allFieldValues.add(input.replaceAll(arg.substringBefore(';'), arg.substringAfter(';')));
                    }
                }
                when 'split' {
                    for(String input : inputs) {
                        allFieldValues.add(input.split(arg.substringBefore(';'))[Integer.valueOf(arg.substringAfter(';'))]);
                    }
                }
                when 'substring' {
                    for(String input : inputs) {
                        Integer startIndex = Integer.valueOf(arg.substringBefore(';'));
                        Integer endIndex = Integer.valueOf(arg.substringAfter(';'));
                        Integer endPos = input.length()-1;
                        if(startIndex > endPos) {
                            allFieldValues.add(null);
                        } else if(endIndex > endPos+1) {
                            allFieldValues.add(input.substring(startIndex, endPos+1));
                        } else {
                            allFieldValues.add(input.substring(startIndex, endIndex));
                        }
                    }
                }
                when 'Abbreviate' {
                    for(String input : inputs) {
                        allFieldValues.add(input.abbreviate(Integer.valueOf(arg)));
                    }
                }
                when 'substringBeforeLast' {
                    for(String input : inputs) {
                        allFieldValues.add(input.substringBeforeLast(arg));
                    }
                }
                when 'substringBefore' {
                    for(String input : inputs) {
                        allFieldValues.add(input.substringBefore(arg));
                    }
                }
                when 'substringAfterLast' {
                    for(String input : inputs) {
                        allFieldValues.add(input.substringAfterLast(arg));
                    }
                }
                when 'substringAfter' {
                    for(String input : inputs) {
                        allFieldValues.add(input.substringAfter(arg));
                    }
                }
                when 'stripHtmlTags' {
                    for(String input : inputs) {
                        allFieldValues.add(input.stripHtmlTags());
                    }
                }
                when 'AreaCode' {
                    for(String input : inputs) {
                        allFieldValues.add(input.substringBefore(' ').replaceAll('[+\']', ''));
                    }
                }
                when 'CountryName' {
                    applyFunctionCountryName(inputs, allFieldValues);
                }
                when 'ExpectedEndDateTime' {
                    applyFunctionExpectedEndDateTime(inputs, allFieldValues, arg);
                }
                when 'CountryNames' {
                    for(String input : inputs) {
                        applyFunctionCountryNames(input, allFieldValues);
                    }
                }
                when 'Count' {
                    allFieldValues.add(String.valueOf(inputs.size()));
                }
                when 'Sum' {
                    applyFunctionSum(inputs, allFieldValues);
                }
                when 'Length' {
                    applyFunctionLength(inputs, allFieldValues);
                }
                when 'HighestOf' {
                    applyFunctionHighestOf(inputs, allFieldValues, arg);
                }
                when 'AndAll' {
                    applyFunctionAndAll(inputs, allFieldValues);
                }
                when 'OrAll' {
                    applyFunctionOrAll(inputs, allFieldValues, arg);
                }
                when 'JSONField' {
                    for(String input : inputs) {
                        applyFunctionJSONField(input, allFieldValues, arg);
                    }
                }
                when 'JSONField3' {
                    String startString = '<start json string>';
                    String endString = '<end json string>';

                    for(String input : inputs) {
                        String jsonString = input;
                        if(jsonString == null || !jsonString.contains(startString) || !jsonString.contains(endString) || arg == null) {
                            jsonString = null;
                            allFieldValues.add(null);
                            continue;
                        }
                        if(arg == '') {
                            arg = jsonString.substringAfterLast(';');
                            arg = arg.substring(0, arg.lastIndexOf('.')+3);
                        }
                        applyFunctionJSONField(jsonString.substringBetween(startString, endString), allFieldValues, arg);
                    }
                }
                when 'JSONField2' {
                    String startString = '<start json string>';
                    String endString = '<end json string>';

                    for(String input : inputs) {
                        String jsonString = input;
                        if(jsonString == null || !jsonString.contains(startString) || !jsonString.contains(endString) || arg == null) {
                            jsonString = null;
                            allFieldValues.add('');
                            continue;
                        }
                        if(arg == '') {
                            arg = jsonString.substringAfterLast(';');
                            arg = arg.substring(0, arg.lastIndexOf('.')+3);
                        }
                        applyFunctionJSONField(jsonString.substringBetween(startString, endString), allFieldValues, arg);
                    }
                }
                when 'getPickListValue' {
                    Map<String, String> pickListValueMap = getPickListValueMap(arg);
                    for(String input : inputs) {
                        allFieldValues.add(pickListValueMap.get(input));
                    }
                }
                when else {
                    myThrow(true, function + ' function not found!');
                }
            }
            return(allFieldValues);
        } catch (Exception e) {
            LOGGER.error('Error in applyFunction: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            return null;
        }
    }

    /**
    * @description Get content between opening and last closing parentheses
    * @author Tushar Walse | 17th Sep 2024 
    * @param str String to process
    * @return String Content between parentheses
    **/
    public String getBracketContent(String str) {
        try {
            Integer openingIndex = str.indexOf('(');
            Integer closingIndex = str.lastIndexOf(')');
            if(openingIndex == -1 || closingIndex == -1) {
                return(null);
            } else {
                return(str.subString(openingIndex + 1, closingIndex));
            }
        } catch (Exception e) {
            LOGGER.error('Error in getBracketContent: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            return null;
        }
    }

    /**
     * @description                 : Class to carry inputs from flow to processFlowRequests method
     * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
     * @author                      : Tushar Walse
     * @date                        : 21-09-2024
     * @last modified on            : 03-10-2025
     * @last modified by            : Tushar Walse
     * @modification description    : Created
     */
    public class Input {
        @InvocableVariable
        public String firstValue;
        @InvocableVariable
        public String str;
        @InvocableVariable
        public String secondValue;
    }

    /**
    * @description Method called by ICS_Opportunity_After_Trigger flow to drive approval the process
    * @author Tushar Walse | 21-09-2024 
    * @param inputs .firstValue containing value related to the task to do
    * @param inputs .str containing the request string to be processed
    * @param inputs .secondValue containing additional info like index
    * @return List<String> containing the response to be sent back to the flow
    **/
    @InvocableMethod(
        label = 'Invoke GetDataUtilsMethod'
        description = 'Do according to toDo label'
        category = 'Approvals'
    )
    public static List<List<String>> processFlowRequests(List<Input> inputs) {
        List<List<String>> returnVe = new List<List<String>>();
        try {
            switch on inputs[0].str {
                when 'Delimited to Collection' {
                    returnVe.add(inputs[0]?.firstValue?.split(';'));
                }
            }    
        } catch(Exception e) {
            LOGGER.error('Error in processFlowRequests: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }

        return returnVe;
    }

}