/**
 * @description : wrapper class to store taxonomy record
 * @last modified on : 11-11-2024
 * @last modified by : Jaco de Lange
**/
public class INS_UTIL_Taxonomy {

    public String name {get;set;}
    public String entityType {get;set;}
    public String bpId {get;set;}
    public String documentTypeId {get;set;}

    public String excludeParams {get;set;}

    public INS_UTIL_Taxonomy(String name, String entityType, String bpId, String documentTypeId) {
        this.name = name;
        this.entityType = entityType;
        this.bpId = bpId;
        this.documentTypeId = documentTypeId;
    }

    public INS_UTIL_Taxonomy setParamsToExclude(String excludeParams) {
        this.excludeParams = excludeParams;
        return this;
    }

    public String getParamsToExclude() {
        return this.excludeParams;
    }
}