/**
 * @description Boost Application API SharePoint PDF Callout Class
 * @author November Sizwe
 * @date September 2022
 */
public class ICS_API_BoostApplicationPDF {
    
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_BoostApplicationPDF');    
    
    
      /**
   * @description This method makes a callout to SharePoint to save PDF 
   * @param  opportunityID  				Opportunity ID from application
   * @param  applicationReferenceNumber  	Boost ID returned during Boost callout
   * @return String   						Response body from SharePoint
   */
    public static Integer savePDFSharePointCallout(Id opportunityID,  String applicationReferenceNumber){ 
        
		HttpRequest req = new HttpRequest();
		HTTPResponse res = new HTTPResponse();
        
        try{
            PageReference pdf = new pageReference('/apex/ICS_VF_BoostApplicationPDF');
            pdf.getParameters().put('generatepdf','true');
            pdf.getParameters().put('id',opportunityID);
            Blob blobFile;
            
            if(Test.isRunningTest()) { 
          		blobFile = blob.valueOf('Unit.Test');
            } 
            else {
             blobFile = pdf.getContentAsPDF();
            }
            String s = EncodingUtil.base64Encode(blobFile);
            
            CMN_WebserviceSetting__mdt webSettings = CMN_WebserviceSetting__mdt.getInstance('ICS_API_BoostApplicationPDF');
            NamedCredential credentials = CMN_DAL_NamedCredential.findByName(webSettings.CMN_NamedCredential__c);
            String endpointPDF = credentials.Endpoint;
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('PDF', s);
            gen.writeStringField('Filename','Salesforce - '+ applicationReferenceNumber+'.pdf');
            gen.writeEndObject();
            
            req.setEndpoint(endpointPDF);
            req.setBody(gen.getAsString()); 
            req.setHeader('Content-Type','application/json');
            req.setHeader('Accept','application/json');
            req.setHeader('Accept-Encoding','*');
            req.setHeader('Content-Length', String.valueOf(req.getBodyAsBlob().size()));
            req.setMethod('POST');  
            req.setTimeout(30000);
            req.setClientCertificateName('ICS_Azure_Certificate');
            
            Http http = new Http();
            res = http.send(req);
            
        }
        catch(Exception e){
            LOGGER.error('Error on savePDFSharePointCallout', e); 
            
        }
        return res.getStatusCode();
        
    }    


}