/**
 * @description Helper class for Mime type handling
 * @author Gnitsevich Anton
 * @date February 2023
 */
public with sharing class ICS_UTIL_DSXMimeType  {
    
      /**
 	* @description ICS_UTIL_DSXMimeType constructor
 	*/
     private ICS_UTIL_DSXMimeType() {

     }
    
 	/**
     * @description Map for file extension to mime type
     */
    public static Map<String, String> fileExtensionToMimeTypeMap = new Map<String, String> {
        'docx' => 'application/msword',
        'doc' => 'application/msword',
        'pdf' => 'application/pdf',
		'xlsx' => 'application/vnd.ms-excel',
        'xls' => 'application/vnd.ms-excel',
        'jpeg' => 'image/jpeg',
        'jpg' => 'image/jpeg',
        'jpe' => 'image/jpeg',
        'png' => 'image/png',
        'tiff' => 'image/tiff',
        'tif' => 'image/tiff',
        'txt' => 'text/plain',
        'text' => 'text/plain'
    };
        
    /**
     * @description This method return mime type for document download
     * @param fileExtension Document extension
     * @return String Mime type string for document download 
     */
    public static String getMimeType(String fileExtension) {
        
        String fileExtensionToMimeType = fileExtensionToMimeTypeMap.get(fileExtension);
		String mimeType;
        
        if (fileExtensionToMimeType.contains('application/pdf')||
            fileExtensionToMimeType.contains('text/plain')||
            fileExtensionToMimeType.contains('image/')){
            mimeType = fileExtensionToMimeType;
        }else{
			mimeType = 'application/octet-stream';
        }

        return mimeType;
        
    }
    
    
}