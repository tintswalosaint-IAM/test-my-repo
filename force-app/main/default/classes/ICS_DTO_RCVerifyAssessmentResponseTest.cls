/**
* @description class Used as DTO class for sending POA request to Relycomply
*
* Story:SFP-36390 
*
* @author Ikyatha Naidu 
*
* @date  23/03/2024
*************************************************************************
* @last modified on  : 29-02-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description :SFP-36390, class Used to create Data, mostly for unit tests for SBO-UK
*/
@IsTest
public class ICS_DTO_RCVerifyAssessmentResponseTest {
    @IsTest
    public static void testICS_DTO_RCVerifyAssessmentResponse() {
        // Create and validate the DTO
        ICS_DTO_RCVerifyAssessmentResponse response = createTestResponse();
		Assert.isTrue(response.data.assessments.edges[0].node.complete, 'Node should be complete');
        Assert.areEqual('Completed', response.data.assessments.edges[0].node.status, 'Status should be Completed');
        // Test the parse method
        String jsonString = createTestJsonString();
        ICS_DTO_RCVerifyAssessmentResponse parsedResponse = ICS_DTO_RCVerifyAssessmentResponse.parse(jsonString);
        Assert.areEqual('Completed', parsedResponse.data.assessments.edges[0].node.status, 'Parsed status should be Completed');

    }

    private static ICS_DTO_RCVerifyAssessmentResponse createTestResponse() {
        ICS_DTO_RCVerifyAssessmentResponse response = new ICS_DTO_RCVerifyAssessmentResponse();
        response.data = new ICS_DTO_RCVerifyAssessmentResponse.Data();
        response.data.assessments = new ICS_DTO_RCVerifyAssessmentResponse.Assessment();
        response.data.assessments.edges = new List<ICS_DTO_RCVerifyAssessmentResponse.Edge>{createTestEdge()};
        return response;
    }

    private static ICS_DTO_RCVerifyAssessmentResponse.Edge createTestEdge() {
        ICS_DTO_RCVerifyAssessmentResponse.Edge edge = new ICS_DTO_RCVerifyAssessmentResponse.Edge();
        edge.node = createTestNode();
        return edge;
    }

    private static ICS_DTO_RCVerifyAssessmentResponse.NodeInfo createTestNode() {
        ICS_DTO_RCVerifyAssessmentResponse.NodeInfo node = new ICS_DTO_RCVerifyAssessmentResponse.NodeInfo();
        node.id = 'node1';
        node.complete = true;
        node.status = 'Completed';
        node.webhookUrl = 'http://example.com/webhook';
        node.created = '2023-01-01T00:00:00Z';
        node.updated = '2023-01-02T00:00:00Z';
        node.assessmentConfig = createTestAssessmentConfig();
        node.customer = createTestCustomer();
        node.screenings = createTestScreenings();
        node.outcome = 'Approved';
        node.resultContext = 'Context1';
        node.screeningConfig = createTestScreeningConfig();
        node.cases = createTestRCCase();
        node.closed = false;
        node.state = 'Open';
        node.documentType = createTestDocumentType();
        node.presignedUrl = 'http://example.com/presignedurl';
        return node;
    }

    private static ICS_DTO_RCVerifyAssessmentResponse.AssessmentConfig createTestAssessmentConfig() {
        ICS_DTO_RCVerifyAssessmentResponse.AssessmentConfig config = new ICS_DTO_RCVerifyAssessmentResponse.AssessmentConfig();
        config.name = 'Config1';
        config.assessmentType = 'Type1';
        return config;
    }

    private static ICS_DTO_RCVerifyAssessmentResponse.Customer createTestCustomer() {
        ICS_DTO_RCVerifyAssessmentResponse.Customer customer = new ICS_DTO_RCVerifyAssessmentResponse.Customer();
        customer.id = 'customer1';
        customer.identifier = 'identifier1';
        customer.pageUrl = 'http://example.com/customer';
        customer.documents = new ICS_DTO_RCVerifyAssessmentResponse.Document();
        customer.documents.edges = new List<ICS_DTO_RCVerifyAssessmentResponse.Edge>();
        return customer;
    }

    private static ICS_DTO_RCVerifyAssessmentResponse.Screenings createTestScreenings() {
        ICS_DTO_RCVerifyAssessmentResponse.Screenings screenings = new ICS_DTO_RCVerifyAssessmentResponse.Screenings();
        screenings.edges = new List<ICS_DTO_RCVerifyAssessmentResponse.Edge>();
        return screenings;
    }

    private static ICS_DTO_RCVerifyAssessmentResponse.ScreeningConfig createTestScreeningConfig() {
        ICS_DTO_RCVerifyAssessmentResponse.ScreeningConfig config = new ICS_DTO_RCVerifyAssessmentResponse.ScreeningConfig();
        config.name = 'Screening1';
        config.screeningType = 'Type1';
        return config;
    }

    private static ICS_DTO_RCVerifyAssessmentResponse.RCCase createTestRCCase() {
        ICS_DTO_RCVerifyAssessmentResponse.RCCase rcCase = new ICS_DTO_RCVerifyAssessmentResponse.RCCase();
        rcCase.edges = new List<ICS_DTO_RCVerifyAssessmentResponse.Edge>();
        return rcCase;
    }

    private static ICS_DTO_RCVerifyAssessmentResponse.DocumentType createTestDocumentType() {
        ICS_DTO_RCVerifyAssessmentResponse.DocumentType docType = new ICS_DTO_RCVerifyAssessmentResponse.DocumentType();
        docType.name = 'Type1';
        return docType;
    }

   

    private static String createTestJsonString() {
        return '{"data":{"assessments":{"edges":[{"node":{"id":"node1","complete":true,"status":"Completed","webhookUrl":"http://example.com/webhook","created":"2023-01-01T00:00:00Z","updated":"2023-01-02T00:00:00Z","assessmentConfig":{"name":"Config1","assessmentType":"Type1"},"customer":{"id":"customer1","identifier":"identifier1","pageUrl":"http://example.com/customer","documents":{"edges":[]}},"screenings":{"edges":[]},"outcome":"Approved","resultContext":"Context1","screeningConfig":{"name":"Screening1","screeningType":"Type1"},"cases":{"edges":[]},"closed":false,"state":"Open","documentType":{"name":"Type1"},"presignedUrl":"http://example.com/presignedurl"}}]}}}';
    }

    
}