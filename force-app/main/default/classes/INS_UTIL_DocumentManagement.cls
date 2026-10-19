/**
 * @description: virtual class to be extended
 *
 * @author: Dhiraj Prajapti
 *
  _____   ____    _   _  ____ _______   ______ _____ _____ _______
 |  __ \ / __ \  | \ | |/ __ \__   __| |  ____|  __ \_   _|__   __|
 | |  | | |  | | |  \| | |  | | | |    | |__  | |  | || |    | |
 | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |
 | |__| | |__| | | |\  | |__| | | |    | |____| |__| || |_   | |
 |_____/ \____/  |_| \_|\____/  |_|    |______|_____/_____|  |_|

 THIS CODE IS CONTROLLED BY THE INSURANCE TEAM
 For any changes requied please contact the Insurance team.
**/
public virtual class INS_UTIL_DocumentManagement {

    @AuraEnabled public INS_UTIL_File file;

    public virtual INS_UTIL_DocumentManagement setFile(INS_UTIL_File file) {
        this.file = file;
        return this;
    }

    public virtual INS_UTIL_DocumentInfo send() {
        return null;
    }

    public virtual List<INS_UTIL_Taxonomy> getTaxonomies() {
        return new List<INS_UTIL_Taxonomy>();
    }
}