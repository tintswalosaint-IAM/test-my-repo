/**
 * @Name of the Class : ICS_DTO_RCVerifyAssessmentResponse
 * @description Contoller used for SBO UK GBG Feature  - SFP-37310  
 * @author IKYATHA NAIDU
 * @date 05/02/2024 
 * *****************************************************************
 * @last modified on  : 01/07/2024
 * @last modified by  : Ikyatha Naidu
 * @Modification Description : SFP-37310 changes done in token generation method for ICS_CTRL_GBG for SBO-UK
 */
global with sharing class ICS_DTO_RCVerifyAssessmentResponse {
    
    // Represents the main data structure.
    global Data data;
    
    /**
     * Represents a screening configuration.
     */
    public class ScreeningConfig {
        // The name of the screening configuration.
        public String name;
        
        // The type of screening.
        public String screeningType;
    }

    /**
     * Represents a customer.
     */
    public class Customer {
        // The customer's ID.
        public String id;
        
        // The customer's identifier.
        public String identifier;
        
        // The URL of the customer's page.
        public String pageUrl;
        
        // The customer's documents.
        public Document documents;
    }

    /**
     * Represents a document.
     */
    public class Document {
        // List of document edges.
        public List<Edge> edges;
    }

    /**
     * Represents a list of screenings.
     */
    public class Screenings {
        // List of screening edges.
        public List<Edge> edges;
    }

    /**
     * Represents the main data structure.
     */
    global class Data {
        // The assessments data.
        public Assessment assessments;
    }

    /**
     * Represents an assessment.
     */
    public class Assessment {
        // List of assessment edges.
        public List<Edge> edges;
    }

    /**
     * Represents an edge.
     */
    public class Edge {
        // The node of the edge.
        public NodeInfo node;
    }

    /**
     * Represents the configuration of an assessment.
     */
    public class AssessmentConfig {
        // The name of the assessment configuration.
        public String name;
        
        // The type of assessment.
        public String assessmentType;
    }

    /**
     * Represents an RC case.
     */
    public class RCCase {
        // List of RC case edges.
        public List<Edge> edges;
    }

    /**
     * Represents a node.
     */
    public class NodeInfo {
        // The ID of the node.
        public String id;
        
        // Indicates if the node is complete.
        public Boolean complete;
        
        // The status of the node.
        public String status;
        
        // The webhook URL of the node.
        public String webhookUrl;
        
        // The creation date of the node (string for easy conversion).
        public String created;
        
        // The last updated date of the node.
        public String updated;
        
        // The assessment configuration of the node.
        public AssessmentConfig assessmentConfig;
        
        // The customer associated with the node.
        public Customer customer;
        
        // The screenings associated with the node.
        public Screenings screenings;
        
        // The outcome of the node.
        public String outcome;
        
        // The result context of the node.
        public String resultContext;
        
        // The screening configuration of the node.
        public ScreeningConfig screeningConfig;
        
        // The RC cases associated with the node.
        public RCCase cases;
        
        // Indicates if the node is closed.
        public Boolean closed;
        
        // The state of the node.
        public String state;
        
        // The document type of the node.
        public DocumentType documentType;
        
        // The presigned URL of the node.
        public String presignedUrl;
    }

    /**
     * Represents the type of a document.
     */
    public class DocumentType {
        // The name of the document type.
        public String name;
    }

    /**
     * Parses the JSON string and returns an instance of RCVerifyAssessmentResponse.
     * @param json The JSON string to parse.
     * @return An instance of RCVerifyAssessmentResponse.
     */
    public static ICS_DTO_RCVerifyAssessmentResponse parse(String json) {
        // Parses the JSON string and returns an instance of RCVerifyAssessmentResponse.
        return (ICS_DTO_RCVerifyAssessmentResponse) System.JSON.deserialize(json, ICS_DTO_RCVerifyAssessmentResponse.class);
    }
}