/**
 * @description
 * Handles and normalizes Dotsure API responses.
 *
 * Dotsure can return business errors (e.g. 400/401) inside a
 * successful HTTP response (200/201). Therefore, HTTP status and
 * Dotsure business status are handled independently.
 */
public with sharing class INS_SRV_DotsureLeadResponse {

    /**
     * @description Normalized response status.
     */
    public enum ResponseStatus {
        SUCCESS,
        CLIENT_ERROR,
        SERVER_ERROR,
        UNKNOWN
    }

    /**
     * @description
     * Normalized result consumed by the calling service.
     */
    public class ResponseResult {

        public ResponseStatus status;
        public Integer httpStatusCode;
        public Integer businessStatusCode;
        public String leadReferenceNumber;
        public String failureMessage;

        /**
         * @description
         * Determines whether the Dotsure response represents
         * a successfully created lead.
         */
        public Boolean isSuccess() {
            return status == ResponseStatus.SUCCESS;
        }
    }

    /**
     * @description
     * Parses and normalizes a Dotsure API response.
     *
     * HTTP 200/201 responses can still contain a business error
     * such as status_code 400 or 401 in the response body.
     *
     * Actual HTTP 5xx responses are treated as server errors.
     *
     * @param httpStatusCode HTTP status code returned by the API.
     * @param responseBody Raw response body returned by the API.
     * @return Normalized ResponseResult.
     */
    public static ResponseResult parse(
        Integer httpStatusCode,
        String responseBody
    ) {
        ResponseResult result = new ResponseResult();
        result.httpStatusCode = httpStatusCode;

        /*
         * Validate response body.
         */
        if (String.isBlank(responseBody)) {
            result.status = ResponseStatus.UNKNOWN;
            result.failureMessage =
                'Empty response received from Dotsure.';

            return result;
        }

        try {
            Map<String, Object> responseMap =
                (Map<String, Object>) JSON.deserializeUntyped(
                    responseBody
                );

            System.debug(
                LoggingLevel.DEBUG,
                'Dotsure response: ' + responseMap
            );

            /*
             * Actual HTTP server error.
             *
             * Example:
             * HTTP 502
             * {
             *     "status_code": 502,
             *     "message": "Bad Gateway"
             * }
             */
            if (httpStatusCode >= 500) {
                return handleServerError(
                    responseMap,
                    httpStatusCode,
                    result
                );
            }

            /*
             * Dotsure business/client error.
             *
             * Example:
             * HTTP 201
             * {
             *     "status_code": 400,
             *     "status": "Duplicate lead...",
             *     "message": "{...}"
             * }
             *
             * The business status is stored in the response body,
             * not necessarily in the HTTP status.
             */
            Integer businessStatusCode =
                extractBusinessStatusCode(responseMap);

            result.businessStatusCode = businessStatusCode;

            if (
                businessStatusCode == 400 ||
                businessStatusCode == 401
            ) {
                return handleClientError(
                    responseMap,
                    result
                );
            }

            /*
             * Successful lead creation response.
             *
             * Example:
             * {
             *     "LeadGenerationResponse": {
             *         "message": "{...statusCode:201...}"
             *     }
             * }
             */
            if (responseMap.containsKey('LeadGenerationResponse')) {
                return handleLeadGenerationResponse(
                    responseMap,
                    result
                );
            }

            /*
             * Unexpected response structure.
             */
            result.status = ResponseStatus.UNKNOWN;
            result.failureMessage =
                extractMessage(responseMap);

            return result;

        } catch (Exception ex) {

            System.debug(
                LoggingLevel.ERROR,
                'Error processing Dotsure response: ' +
                ex.getMessage()
            );

            result.status = ResponseStatus.UNKNOWN;
            result.failureMessage =
                'Unable to process Dotsure response: ' +
                ex.getMessage();

            return result;
        }
    }

    /**
     * @description
     * Handles actual HTTP 5xx errors.
     *
     * The HTTP status code is prefixed to the failure message.
     *
     * Example:
     * 502 - Bad Gateway
     *
     * @param responseMap Parsed response body.
     * @param httpStatusCode Actual HTTP status code.
     * @param result Response result.
     * @return Updated ResponseResult.
     */
    private static ResponseResult handleServerError(
        Map<String, Object> responseMap,
        Integer httpStatusCode,
        ResponseResult result
    ) {
        result.status = ResponseStatus.SERVER_ERROR;

        String message = extractMessage(responseMap);

        result.failureMessage =
            String.valueOf(httpStatusCode) +
            ' - ' +
            message;

        return result;
    }

    /**
     * @description
     * Handles Dotsure business/client errors such as 400 and 401.
     *
     * @param responseMap Parsed response body.
     * @param result Response result.
     * @return Updated ResponseResult.
     */
    private static ResponseResult handleClientError(
        Map<String, Object> responseMap,
        ResponseResult result
    ) {
        result.status = ResponseStatus.CLIENT_ERROR;

        result.failureMessage =
            extractMessage(responseMap);

        return result;
    }

    /**
     * @description
     * Handles successful LeadGenerationResponse.
     *
     * The nested message contains another JSON object which
     * contains the leadIds and business statusCode.
     *
     * @param responseMap Parsed response body.
     * @param result Response result.
     * @return Updated ResponseResult.
     */
    private static ResponseResult handleLeadGenerationResponse(
        Map<String, Object> responseMap,
        ResponseResult result
    ) {
        Object generationResponseObject =
            responseMap.get('LeadGenerationResponse');

        if (generationResponseObject == null) {
            result.status = ResponseStatus.UNKNOWN;
            result.failureMessage =
                'LeadGenerationResponse is missing from Dotsure response.';

            return result;
        }

        Map<String, Object> generationResponse =
            (Map<String, Object>) generationResponseObject;

        String innerJson =
            (String) generationResponse.get('message');

        if (String.isBlank(innerJson)) {
            result.status = ResponseStatus.UNKNOWN;
            result.failureMessage =
                'Message is missing from Dotsure response.';

            return result;
        }

        INS_DTO_DotsureLeadResponse.InnerResponse innerResponse =
            INS_DTO_DotsureLeadResponse.parseInnerResponse(innerJson);
        

        System.debug(
            LoggingLevel.DEBUG,
            'Dotsure inner response: ' + innerResponse
        );

        /*
         * Successful lead creation.
         */
        if (INS_DTO_DotsureLeadResponse.isInnerSuccess(innerResponse)) 
        {
            result.status = ResponseStatus.SUCCESS;

            result.businessStatusCode =
                innerResponse.statusCode;

            result.leadReferenceNumber = INS_DTO_DotsureLeadResponse.extractLeadId(innerResponse);

            return result;
        }

        /*
         * Business error returned inside LeadGenerationResponse.
         */
        result.businessStatusCode =
            innerResponse.statusCode;

        result.status =
            getResponseStatus(innerResponse.statusCode);

        result.failureMessage =
            innerResponse.message;

        return result;
    }

    /**
     * @description
     * Extracts the top-level Dotsure business status code.
     *
     * Example:
     * {
     *     "status_code": 400
     * }
     *
     * @param responseMap Parsed response body.
     * @return Business status code, or null if unavailable.
     */
    private static Integer extractBusinessStatusCode(
        Map<String, Object> responseMap
    ) {
        if (!responseMap.containsKey('status_code')) {
            return null;
        }

        Object statusCode = responseMap.get('status_code');

        if (statusCode == null) {
            return null;
        }

        return Integer.valueOf(
            String.valueOf(statusCode)
        );
    }

    /**
     * @description
     * Extracts the most relevant message from a Dotsure response.
     *
     * Supports both:
     * - Direct message
     * - JSON string stored inside message
     *
     * @param responseMap Parsed response body.
     * @return Error/success message.
     */
    private static String extractMessage(
        Map<String, Object> responseMap
    ) {
        Object messageObject =
            responseMap.get('message');

        if (messageObject == null) {
            return 'Unknown response received from Dotsure.';
        }

        String message =
            String.valueOf(messageObject);

        if (String.isBlank(message)) {
            return 'Unknown response received from Dotsure.';
        }

        /*
         * The message can itself contain JSON.
         *
         * Example:
         * "{\"leadIds\":[],\"statusCode\":400,...}"
         */
        try {
            Map<String, Object> innerResponse =
                (Map<String, Object>) JSON.deserializeUntyped(
                    message
                );

            Object innerMessage =
                innerResponse.get('message');

            if (innerMessage != null) {
                String extractedMessage =
                    String.valueOf(innerMessage);

                if (String.isNotBlank(extractedMessage)) {
                    return extractedMessage;
                }
            }

        } catch (Exception ex) {
            /*
             * Message is plain text rather than JSON.
             * Return the original message.
             */
        }

        return message;
    }

    /**
     * @description
     * Determines normalized response status from business status code.
     *
     * @param businessStatusCode Dotsure business status code.
     * @return Normalized ResponseStatus.
     */
    private static ResponseStatus getResponseStatus(
        Integer businessStatusCode
    ) {
        if (businessStatusCode == 201) {
            return ResponseStatus.SUCCESS;
        }

        if (
            businessStatusCode == 400 ||
            businessStatusCode == 401
        ) {
            return ResponseStatus.CLIENT_ERROR;
        }

        return ResponseStatus.UNKNOWN;
    }
}