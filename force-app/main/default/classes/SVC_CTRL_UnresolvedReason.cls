/**
 * @description Controller for the svcLwcUnresolvedReasonSelector LWC.
 *              Decodes the field dependency between Case_Owner_Country__c and
 *              SVC_ReasonForUnresolved__c to return filtered picklist values.
 * @author Raymond Magezi
 * @date 15 June 2026
 * @user Story SFP-58600
 */
public with sharing class SVC_CTRL_UnresolvedReason {

	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_CTRL_UnresolvedReason');
	private static final String CLASS_NAME = 'SVC_CTRL_UnresolvedReason';

	/**
	 * @description Retrieves the filtered SVC_ReasonForUnresolved__c picklist values
	 *              based on the Case_Owner_Country__c field dependency for the given case.
	 * @param caseId The Id of the Case record to retrieve the country from
	 * @return List of PicklistOption wrappers containing label/value pairs
	 * @throws AuraHandledException if the case cannot be found or an error occurs
	 */
	@AuraEnabled(cacheable=true)
	public static List<PicklistOption> getFilteredReasons(Id caseId) {
		try {
			List<Case> cases = SEL_Case.newInstance().selectCountryById(caseId);
			if (cases.isEmpty() || String.isBlank(cases[0].Case_Owner_Country__c)) {
				return new List<PicklistOption>();
			}
			return getReasonsByCountry(cases[0].Case_Owner_Country__c);
		} catch (Exception e) {
			LOGGER.error(e.getMessage(), new String[]{CLASS_NAME, 'getFilteredReasons'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Decodes the validFor base64 bitfield on dependent picklist entries
	 *              to determine which SVC_ReasonForUnresolved__c values are valid for
	 *              the given controlling country value.
	 * @param country The Case_Owner_Country__c value to filter by
	 * @return List of PicklistOption wrappers for valid dependent values
	 */
	@TestVisible
	private static List<PicklistOption> getReasonsByCountry(String country) {
		Schema.DescribeFieldResult controllingField = Case.Case_Owner_Country__c.getDescribe();
		Schema.DescribeFieldResult dependentField = Case.SVC_ReasonForUnresolved__c.getDescribe();

		List<Schema.PicklistEntry> controllingEntries = controllingField.getPicklistValues();
		List<Schema.PicklistEntry> dependentEntries = dependentField.getPicklistValues();

		Integer controllingIdx = null;
		for (Integer i = 0; i < controllingEntries.size(); i++) {
			if (controllingEntries[i].getValue() == country) {
				controllingIdx = i;
				break;
			}
		}
		if (controllingIdx == null) {
			return new List<PicklistOption>();
		}

		Map<String, Integer> hexMap = new Map<String, Integer>{
			'0'=>0,'1'=>1,'2'=>2,'3'=>3,'4'=>4,'5'=>5,'6'=>6,'7'=>7,
			'8'=>8,'9'=>9,'a'=>10,'b'=>11,'c'=>12,'d'=>13,'e'=>14,'f'=>15
		};

		List<PicklistOption> options = new List<PicklistOption>();
		Integer byteIdx = controllingIdx / 8;
		Integer bitIdx = 7 - Math.mod(controllingIdx, 8);

		for (Schema.PicklistEntry depEntry : dependentEntries) {
			if (!depEntry.isActive()) {
				continue;
			}
			String jsonStr = JSON.serialize(depEntry);
			Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
			String validForBase64 = (String) jsonMap.get('validFor');
			if (String.isBlank(validForBase64)) {
				continue;
			}

			String hexStr = EncodingUtil.convertToHex(EncodingUtil.base64Decode(validForBase64)).toLowerCase();
			Integer hexPos = byteIdx * 2;
			if (hexPos + 1 < hexStr.length()) {
				Integer byteVal = hexMap.get(hexStr.substring(hexPos, hexPos + 1)) * 16
					+ hexMap.get(hexStr.substring(hexPos + 1, hexPos + 2));
				if (((byteVal >> bitIdx) & 1) == 1) {
					PicklistOption opt = new PicklistOption();
					opt.label = depEntry.getLabel();
					opt.value = depEntry.getValue();
					options.add(opt);
				}
			}
		}
		return options;
	}

	/**
	 * @description Wrapper class for picklist option label/value pairs
	 */
	public class PicklistOption {
		@AuraEnabled public String label;
		@AuraEnabled public String value;
	}
}