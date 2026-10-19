/**
 * @description  : Central access point for INS_MemberRelation__mdt benefit mappings.
 *                 Provides lookups by public benefit id (API → local type) and by
 *                 member category + benefit type (local → API id).
 * @author       : Irshad Alam
 * @user story   : SFP-50909
 */
public with sharing class INS_DTO_BenefitMapping {

    private static Map<String, INS_MemberRelation__mdt> mappingByPublicId;
    private static Map<String, INS_MemberRelation__mdt> mappingByCategoryAndType;

    /**
     * @description Returns the mapping for a given public benefit id (as returned
     *              by the Mobi API), or null when no mapping exists.
     * @param publicBenefitId The API's benefitId value, e.g. '1', '7', '2'
     * @return                The matching metadata record, or null
     */
    public static INS_MemberRelation__mdt getByPublicBenefitId(String publicBenefitId) {
        if (String.isBlank(publicBenefitId)) {
            return null;
        }
        return getMappingByPublicId().get(publicBenefitId);
    }

    /**
     * @description Returns the public benefit id for a given member category and
     *              benefit type, or null when no mapping exists. Replaces the
     *              memberRelationToBenefitId map currently held in the LWCs.
     * @param memberCategory MAIN / SPOUSE / CHILD / PARENT / EXTENDEDFAMILY
     * @param benefitType    FUNERAL / CATERING / GROCERY / ADVERTISEMENT / AIRTIME / REPATRIATION
     * @return               The public benefit id, or null
     */
    public static String getPublicBenefitId(String memberCategory, String benefitType) {
        INS_MemberRelation__mdt mapping = getByCategoryAndType(memberCategory, benefitType);
        return mapping == null ? null : mapping.Public_Benefit_Id__c;
    }

    /**
     * @description Returns the mapping for a given member category and benefit type.
     * @param memberCategory MAIN / SPOUSE / CHILD / PARENT / EXTENDEDFAMILY
     * @param benefitType    FUNERAL / CATERING / GROCERY / etc.
     * @return               The matching metadata record, or null
     */
    public static INS_MemberRelation__mdt getByCategoryAndType(String memberCategory, String benefitType) {
        if (String.isBlank(memberCategory) || String.isBlank(benefitType)) {
            return null;
        }
        return getMappingByCategoryAndType().get(buildCategoryTypeKey(memberCategory, benefitType));
    }

    /**
     * @description Returns all mappings for a given member category, e.g. every
     *              benefit available to a SPOUSE.
     * @param memberCategory MAIN / SPOUSE / CHILD / PARENT / EXTENDEDFAMILY
     * @return               List of matching metadata records
     */
    public static List<INS_MemberRelation__mdt> getByMemberCategory(String memberCategory) {
        List<INS_MemberRelation__mdt> matches = new List<INS_MemberRelation__mdt>();
        if (String.isBlank(memberCategory)) {
            return matches;
        }

        for (INS_MemberRelation__mdt mapping : INS_MemberRelation__mdt.getAll().values()) {
            if (memberCategory.equalsIgnoreCase(mapping.Member_Category__c)) {
                matches.add(mapping);
            }
        }
        return matches;
    }

    /**
     * @description Lazily builds and caches the public-benefit-id lookup.
     */
    private static Map<String, INS_MemberRelation__mdt> getMappingByPublicId() {
        if (mappingByPublicId == null) {
            mappingByPublicId = new Map<String, INS_MemberRelation__mdt>();
            for (INS_MemberRelation__mdt mapping : INS_MemberRelation__mdt.getAll().values()) {
                if (String.isNotBlank(mapping.Public_Benefit_Id__c)) {
                    mappingByPublicId.put(mapping.Public_Benefit_Id__c, mapping);
                }
            }
        }
        return mappingByPublicId;
    }

    /**
     * @description Lazily builds and caches the category+type lookup.
     */
    private static Map<String, INS_MemberRelation__mdt> getMappingByCategoryAndType() {
        if (mappingByCategoryAndType == null) {
            mappingByCategoryAndType = new Map<String, INS_MemberRelation__mdt>();
            for (INS_MemberRelation__mdt mapping : INS_MemberRelation__mdt.getAll().values()) {
                if (String.isNotBlank(mapping.Member_Category__c) && String.isNotBlank(mapping.Benefit_Type__c)) {
                    mappingByCategoryAndType.put(
                        buildCategoryTypeKey(mapping.Member_Category__c, mapping.Benefit_Type__c),
                        mapping
                    );
                }
            }
        }
        return mappingByCategoryAndType;
    }

    private static String buildCategoryTypeKey(String memberCategory, String benefitType) {
        return memberCategory.toUpperCase() + '_' + benefitType.toUpperCase();
    }
}