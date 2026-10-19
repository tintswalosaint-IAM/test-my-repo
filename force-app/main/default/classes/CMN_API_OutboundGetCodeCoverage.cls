/**
 * @description This will retrieve the Code Coverage Details for a Salesforce Org, before calling API, make sure you
 * clear coverage results and run all tests again.
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_API_OutboundGetCodeCoverage extends CMN_API_RestBaseOutbound
{
	private static final String HTTP_HEADER_AUTH_BEARER = 'Bearer ';
	private static final String QUERY_PARAMETERS = 'q=SELECT+ApexClassOrTriggerId,ApexClassOrTrigger.Name,NumLinesCovered,NumLinesUncovered+FROM+ApexCodeCoverageAggregate';
	private static final String COMMA = ',';
	private static final String FMT_FILE_NAME = 'Code Coverage Report - {0}.csv';
	private static final String CSV_COLUMN_HEADERS = 'Class Name,Lines Covered,Lines Not Covered,Total Number of Lines, Percentage Code Coverage' + CMN_UTIL_String.CR + CMN_UTIL_String.LF;

	@TestVisible
	private static final String SERVICE_NAME = CMN_API_OutboundGetCodeCoverage.class.getName();
	public List<DTO_CoverageComparable> codeCoverages = new List<DTO_CoverageComparable>();

	/**
	 * @description A class to allow code coverages to be sorted based on coverage
	 */
	public class DTO_CoverageComparable implements Comparable
	{
		public String className;
		public Integer linesCovered;
		public Integer linesNotCovered;
		public Integer totalNumberOfLines;
		public Decimal percentCovered;

		public Integer compareTo(Object compareTo)
		{
			DTO_CoverageComparable codeCoverage = (DTO_CoverageComparable)compareTo;

			if(percentCovered == codeCoverage.percentCovered)
			{
				return 0;
			}
			else if(percentCovered > codeCoverage.percentCovered)
			{
				return 1;
			}
			else
			{
				return -1;
			}
		}
	}

	/**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return SERVICE_NAME
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Returns Mock API Client used during unit tests
	 *
	 * @return Mock Endpoint
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new CMN_API_OutboundGetCodeCoverageMock();
	}

	/**
	 * @description Ensure that we don't use base functionality as it's doing standard DTO deserialize which won't work for this JSON as it contains reserved words
	 */
	protected override void parseResponse()
	{
		DTO_Response dtoResponse = new DTO_Response(JSON.createParser(getResponseBody()));

		//Put response into a list that can be accessed outside class
		for(DTO_Coverage dtoCoverage : dtoResponse.coverages)
		{
			if(dtoCoverage.NumLinesCovered + dtoCoverage.NumLinesUncovered > 0)
			{
				DTO_CoverageComparable newCodeCoverage = new DTO_CoverageComparable();

				newCodeCoverage.className = dtoCoverage.ApexClassOrTrigger.Name;
				newCodeCoverage.linesCovered = dtoCoverage.NumLinesCovered;
				newCodeCoverage.linesNotCovered = dtoCoverage.NumLinesUncovered;
				newCodeCoverage.totalNumberOfLines = newCodeCoverage.linesCovered + newCodeCoverage.linesNotCovered;

				newCodeCoverage.percentCovered = newCodeCoverage.totalNumberOfLines <= 0 ? 0 : Decimal.valueOf(newCodeCoverage.linesCovered) / Decimal.valueOf(newCodeCoverage.totalNumberOfLines) * 100;
				newCodeCoverage.percentCovered = newCodeCoverage.percentCovered.setScale(2);

				codeCoverages.add(newCodeCoverage);
			}
		}
	}

	/**
	 * @description register all the object types we want to update
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType> {ContentVersion.SObjectType});
	}

	/**
	 * @description Ensure that we update the current user with a new file for the CSV file
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		//Sort from lowest coverage to highest.
		codeCoverages.sort();

		CMN_UTIL_StringBuffer csvFile = new CMN_UTIL_StringBuffer();

		csvFile.append(CSV_COLUMN_HEADERS);

		for(DTO_CoverageComparable codeCoverage : codeCoverages)
		{
			csvFile.append(codeCoverage.className);
			csvFile.append(COMMA);
			csvFile.append(codeCoverage.linesCovered);
			csvFile.append(COMMA);
			csvFile.append(codeCoverage.linesNotCovered);
			csvFile.append(COMMA);
			csvFile.append(codeCoverage.totalNumberOfLines);
			csvFile.append(COMMA);
			csvFile.append(codeCoverage.percentCovered);
			csvFile.append(CMN_UTIL_String.CR + CMN_UTIL_String.LF);
		}

		registerChange(CMN_DAL_DataFactory.newContentVersion(UserInfo.getUserId(), String.format(FMT_FILE_NAME, new List<String> {String.valueOf(Datetime.now())}), Blob.valueOf(csvFile.toStr())));
	}

	/**
	 * @description Will compose the relevant Query for retrieving code coverage
	 *
	 * @return The query string that will be appended to the URL
	 */
	protected override String getQueryParameters()
	{
		return QUERY_PARAMETERS;
	}

	/**
	 * @description Will return the current session Id as authorisation token
	 *
	 * @return Authorisation Header value
	 *
	 * @see UserInfo.getSessionId
	 */
	protected override String getAuthorisationToken()
	{
		//This is being called so that we can cover get an Auth String that is empty
		String authString = super.getAuthorisationToken();

		return String.isNotBlank(authString) ? authString : HTTP_HEADER_AUTH_BEARER + UserInfo.getSessionId();
	}

	/**
	 * @description determine whether call must be aborted if no TriggerObjectId is provided
	 *
	 * @return Indicates that TriggerObjectId is required or not
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description Returns the verb for the request
	 *
	 * @return Will return "GET"
	 */
	protected override String getVerb()
	{
		return HTTP_VERB_GET;
	}

	private static void consumeObject(JSONParser parser)
	{
		Integer depth = 0;
		do
		{
			System.JSONToken curr = parser.getCurrentToken();

			if(curr == System.JSONToken.START_OBJECT || curr == System.JSONToken.START_ARRAY)
			{
				depth++;
			}
			else if(curr == System.JSONToken.END_OBJECT || curr == System.JSONToken.END_ARRAY)
			{
				depth--;
			}
		}
		while(depth > 0 && parser.nextToken() != null);
	}

	private static List<DTO_Coverage> getCoverages(JSONParser parser)
	{
		List<DTO_Coverage> dtoRecords = new List<DTO_Coverage>();

		while(parser.nextToken() != System.JSONToken.END_ARRAY)
		{
			dtoRecords.add(new DTO_Coverage(parser));
		}

		return dtoRecords;
	}

	/**
	 * @description Generated by JSON2Apex http://json2apex.herokuapp.com/
	 * The supplied json has fields with names that are not valid in apex
	 * and so can only be parsed with explicitly generated code,
	 */
	private class DTO_Response
	{
		public List<DTO_Coverage> coverages;

		public DTO_Response(JSONParser parser)
		{
			while(parser.nextToken() != System.JSONToken.END_OBJECT)
			{
				if(parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
				{
					String text = parser.getText();
					if(parser.nextToken() != System.JSONToken.VALUE_NULL)
					{
						if(text == 'records')
						{
							coverages = getCoverages(parser);
						}
						else
						{
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	private class DTO_ApexClassOrTrigger
	{
		public String Name;

		public DTO_ApexClassOrTrigger(JSONParser parser)
		{
			while(parser.nextToken() != System.JSONToken.END_OBJECT)
			{
				if(parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
				{
					String text = parser.getText();
					if(parser.nextToken() != System.JSONToken.VALUE_NULL)
					{
						if(text == 'Name')
						{
							Name = parser.getText();
						}
						else
						{
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	private class DTO_Coverage
	{
		public DTO_ApexClassOrTrigger ApexClassOrTrigger;
		public Integer NumLinesCovered;
		public Integer NumLinesUncovered;

		public DTO_Coverage(JSONParser parser)
		{
			while(parser.nextToken() != System.JSONToken.END_OBJECT)
			{
				if(parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
				{
					String text = parser.getText();
					if(parser.nextToken() != System.JSONToken.VALUE_NULL)
					{
						if(text == 'ApexClassOrTrigger')
						{
							ApexClassOrTrigger = new DTO_ApexClassOrTrigger(parser);
						}
						else if(text == 'NumLinesCovered')
						{
							NumLinesCovered = parser.getIntegerValue();
						}
						else if(text == 'NumLinesUncovered')
						{
							NumLinesUncovered = parser.getIntegerValue();
						}
						else
						{
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	/**
	 * @description Class that will return a mock API response
	 */
	private class CMN_API_OutboundGetCodeCoverageMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String VALID_RESPONSE = '{"size":92,"totalSize":92,"done":true,"entityTypeName":"ApexCodeCoverageAggregate","Unknown":null,"UnknownArray":[1,2],"records":[{"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v50.0/tooling/sobjects/ApexCodeCoverageAggregate/7153I0000008h9cQAA","Unknown":true},"ApexClassOrTriggerId":"01p3I000000DUuzQAG","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v50.0/tooling/sobjects/ApexClass/01p3I000000DUuzQAG","Unknown":null},"Name":"ACC_CTRL_Intent","Unknown":true},"NumLinesCovered":20,"NumLinesUncovered":5,"Coverage":{"coveredLines":[83,85,87,88,89,90,91,93],"uncoveredLines":[10],"Unknown":true},"Unknown":true},{"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v50.0/tooling/sobjects/ApexCodeCoverageAggregate/7153I0000008lKRQAY"},"ApexClassOrTriggerId":"01p3I000000DjMEQA0","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v50.0/tooling/sobjects/ApexClass/01p3I000000DjMEQA0"},"Name":"CMN_EMAIL_Foobar"},"NumLinesCovered":10,"NumLinesUncovered":0},{"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v50.0/tooling/sobjects/ApexCodeCoverageAggregate/7153I0000008hBzQAI"},"ApexClassOrTriggerId":"01p3I000000DV0wQAG","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v50.0/tooling/sobjects/ApexClass/01p3I000000DV0wQAG"},"Name":"CMN_UTIL_SObjectDescribe"},"NumLinesCovered":128,"NumLinesUncovered":5},{"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v50.0/tooling/sobjects/ApexCodeCoverageAggregate/7153I0000008hC0QAI"},"ApexClassOrTriggerId":"01p3I000000DV0jQAG","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v50.0/tooling/sobjects/ApexClass/01p3I000000DV0jQAG"},"Name":"CMN_DAL_User"},"NumLinesCovered":128,"NumLinesUncovered":5}]}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}
}