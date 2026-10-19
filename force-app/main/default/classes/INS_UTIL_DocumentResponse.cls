/**
 * @description : Wrapper class for Document Repository response
 * @author : Jaco de Lange
 *
 * @last modified on  : 11-11-2024
**/
public class INS_UTIL_DocumentResponse {

    public DocumentDirectoryResponse DocumentDirectoryResponse { get; set; }   
    public String moreInformation { get; set; }  

    public class DocumentDirectoryResponse {
        public String DocumentDirectoryId = '';
    }

    public String getDocumentId() {
        return this.DocumentDirectoryResponse?.DocumentDirectoryId;
    }

    public String getErrorInfo() {
        return this.moreInformation;
    }
}