/**
* @description Bean Class for dealing with NIRA api and sending the result to the main container and storing the values in the wrapper
* @author Jagadish Thummala
* @date may 2022
*/

public  class BCB_NiraBean {
 

    /** @description Attribute */
    public String dateOfBirth;
    /** @description Attribute */
    public String documentIdentifier;
    /** @description Attribute */
    public String givenName;
    /** @description Attribute */
    public String nationalIdentifier;
    /** @description Attribute */
    public String surname;
    /** @description Attribute */
    public String otherNames;
    
    /** @description Attribute
     * @param dateOfBirth 
     * @param documentIdentifier 
     * @param givenName 
     * @param otherNames 
     * @param nationalIdentifier 
     * @param surname 
     * */
    public BCB_NiraBean(String dateOfBirth, String documentIdentifier, String givenName, String otherNames, String nationalIdentifier, String surname) {
        /** @description Attribute */
        this.dateOfBirth = dateOfBirth;
        /** @description Attribute */
        this.documentIdentifier = documentIdentifier;
        /** @description Attribute */
        this.givenName = givenName;
        /** @description Attribute */
        this.otherNames = otherNames;
        /** @description Attribute */
        this.nationalIdentifier = nationalIdentifier;
        /** @description Attribute */
        this.surname = surname;
    }

}