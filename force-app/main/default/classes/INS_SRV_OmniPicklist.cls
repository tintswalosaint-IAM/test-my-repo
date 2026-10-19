/**
 * @description Allows to get omni picklist dependent options
 * @author Alexandr Goryachko
 * @date 2025-02-03
 * SFP-55383
 */
public with sharing class INS_SRV_OmniPicklist {
    private static final List<Map<String, String>> sourceById = new List<Map<String, String>>{
        initOption('Salary', 'Salary / Employment Income'),
        initOption('Business Income', 'Business Income / Self-Employed'),
        initOption('Government Benefits', 'Investments (Stocks, Bonds, Dividends)'),
        initOption('Pension / Retirement Funds')
    };
    private static final List<Map<String, String>> empTypeById = new List<Map<String, String>>{
        initOption('Full Time', 'Full-time Permanent'),
        initOption('Part Time', 'Part-time Permanent'),
        initOption('Unemployed'),
        initOption('Retired'),
        initOption('Independent Contractor'),
        initOption('Student'),
        initOption('Self-Employed')
    };
    private static final List<Map<String, String>> occupationById = new List<Map<String, String>>{
        initOption('Employed Full Time - Bank'),
        initOption('Employed Full Time - Other'),
        initOption('Self Employed'),
        initOption('Student'),
        initOption('Retired/Pensioner'),
        initOption('Unemployed'),
        initOption('Other - Recurring'),
        initOption('Not Disclosed')
    };
    private static final Map<String, Map<String, List<Integer>>> controllingStatus = new Map<String, Map<String, List<Integer>>>{
        'source' => initDependency(new List<List<Integer>>{
            new List<Integer>{0, 1, 2},
            new List<Integer>{0, 1, 2, 3},
            new List<Integer>{0, 1, 2, 3},
            new List<Integer>{0, 1, 2},
            new List<Integer>{2, 3},
            new List<Integer>{1, 2},
            new List<Integer>{1, 2, 3}
        }),
        'emptype' => initDependency(new List<List<Integer>>{
            new List<Integer>{0, 6},
            new List<Integer>{1, 4, 5, 6},
            new List<Integer>{0, 3, 4, 6},
            new List<Integer>{0, 1, 4, 6},
            new List<Integer>{2, 3, 5},
            new List<Integer>{1, 2, 4, 5, 6},
            new List<Integer>{2, 3, 4, 6}
        }),
        'occupation' => initDependency(new List<List<Integer>>{
            new List<Integer>{0, 1, 2, 6, 7},
            new List<Integer>{2, 3, 4, 6, 7},
            new List<Integer>{1, 2, 3, 4, 6, 7},
            new List<Integer>{0, 1, 2, 6, 7},
            new List<Integer>{3, 4, 5, 6, 7},
            new List<Integer>{2, 3, 5, 6, 7},
            new List<Integer>{2, 4, 5, 6, 7}
        })
    };

    private INS_SRV_OmniPicklist() {}

    /**
     * @description call specific method to get picklist dependencies
     * @author Alexandr Goryachko
     * @param name class method name
     * @return `Map<String, List<Map<String, String>>>` dependent options
     */    
    public static Map<String, List<Map<String, String>>> callMethod(String name) {
        Map<String, List<Map<String, String>>> result;
        switch on name {
            when 'getOmniPicklistSource' {
                result = getOmniPicklist(sourceById, controllingStatus.get('source'));
            }
            when 'getOmniPicklistEmpType' {
                result = getOmniPicklist(empTypeById, controllingStatus.get('emptype'));
            }
            when 'getOmniPicklistOccupation' {
                result = getOmniPicklist(occupationById, controllingStatus.get('occupation'));
            }
            when else {
                throw new NoSuchElementException('The passed method name is not exist: ' + name);
            }
        }
        return result;
    }

    /**
     * @description generic method to generate option dependencies
     * @param optionsById options of dependent field
     * @param idsByValue controlling field dependencies
     * @return `Map<String, List<Map<String, String>>>` dependenct values
     */    
    private static Map<String, List<Map<String, String>>> getOmniPicklist(List<Map<String, String>> optionsById, Map<String, List<Integer>> idsByValue) {
        Map<String, List<Map<String, String>>> dependency = new Map<String, List<Map<String, String>>>();
        for (String optValue : idsByValue.keySet()) {
            List<Map<String, String>> options = new List<Map<String, String>>();
            for (Integer i = 0; i < idsByValue.get(optValue).size(); i++) {
                Integer id = idsByValue.get(optValue)[i];
                options.add(optionsById[id]);
            }
            dependency.put(optValue, options);
        }
        return dependency;
    }

    /**
     * @description init controlling field with dependencies
     * @param dependencies 
     * @return `Map<String, List<Integer>>` dependencies by controlling value
     */    
    private static Map<String, List<Integer>> initDependency(List<List<Integer>> dependencies) {
        Map<String, List<Integer>> result = new Map<String, List<Integer>>();
        List<String> controllingValues = new List<String>{'Employed-Full-time', 'Employed-Part-time', 'Self-employed',
            'Unemployed', 'Student', 'Retired', 'Employed'};
        for (Integer i = 0; i < controllingValues.size(); i++) {
            result.put(controllingValues[i], dependencies[i]);
        }
        return result;
    }

    /**
     * @description sugar for init dependent options method
     * @param name 
     * @return `Map<String, String>` dependent options
     */
    private static Map<String, String> initOption(String name) {
        return initOption(name, name);
    }

    /**
     * @description init dependent options
     * @param name 
     * @param value 
     * @return `Map<String, String>` dependent options
     */
    private static Map<String, String> initOption(String name, String value) {
        return new Map<String, String>{
            'name' => name,
            'value' => value
        };
    }
}