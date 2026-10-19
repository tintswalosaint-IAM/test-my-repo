/**
 * @description API and DTO to facilitate retrieval of a list of Branches
 *
 * @see SVC_API_GetBranches_TEST
 *
 * @author Accenture
 *
 * @date January 2021
 */
public inherited sharing class SVC_API_GetBranches extends SVC_API_ReferenceDataBase
{
	private static final String COLUMN_BRANCH_CODE = 'BRANCH_CODE';
	private static final String COLUMN_BRANCH_NAME = 'BRANCH_DESCRIPTION';
	private static final String TABLE_NAME = 'APIGATEWAY_DELIVERY_BRANCHES';

	@TestVisible
	private static final String SERVICE_NAME = SVC_API_GetBranches.class.getName();
	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();

		baseTableDTOType = DTO_Table.class;
	}

	/**
	 * @description Name of your service to be used when looking up custom settings for you service
	 *
	 * @return the service name
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Returns the mock endpoint for testing purposes
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SVC_API_GetBranchesMock();
	}

	/**
	 * @description Will set the tableName so relevant reference type is queried
	 *
	 * @return tableName to query
	 */
	protected override String getTableName()
	{
		return String.isBlank(super.getTableName()) ? TABLE_NAME : super.getTableName();
	}
	/**
	 * @description DTO_Table
	 */
	public class DTO_Table extends SVC_API_ReferenceDataBase.DTO_BaseReferenceDataTable
	{
		/**
		 * @description Will transform the DTO provided into the current dto, its up to the class to check the type being passed an transform appropriately
		 *
		 * @param dtoBase Input dto for transformation
		 */
		public override virtual void transform(CMN_DTO_Base dtoBase)
		{
			super.transform(dtoBase);

			addColumn('Name', 'name', 'text');
			addColumn('Code', 'code', 'text');

			for(Map<String, String> rowMap : rowList)
			{
				DTO_Row dtoRow = new DTO_Row();

				dtoRow.name = rowMap.get(COLUMN_BRANCH_NAME);
				dtoRow.code = rowMap.get(COLUMN_BRANCH_CODE);

				rows.add(dtoRow);
			}
		}
	}

	/**
	 * @description Represents an individual branch row in the response table
	 */
	private class DTO_Row
	{
		public String name;
		public String code;
	}

	/**
	 * @description Mock class for returning test data
	 */
	private class SVC_API_GetBranchesMock extends SVC_API_OAuthOutboundBase.SVC_API_OAuthOutboundBaseMock
	{
		private final String validResponse = '{"total":704,"currentPage":1,"pageSize":300,"rows":[{"columns":[{"column":"BRANCH_CODE","value":"50535"},{"column":"BRANCH_DESCRIPTION","value":"ALEX MALL"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"50716"},{"column":"BRANCH_DESCRIPTION","value":"MAAKE PLAZA SERVICE CENTRE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"50761"},{"column":"BRANCH_DESCRIPTION","value":"GIYANI"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"50906"},{"column":"BRANCH_DESCRIPTION","value":"ONLINE BANKING"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"51790"},{"column":"BRANCH_DESCRIPTION","value":"FOURWAYS MALL SERVICE CENTRE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"51833"},{"column":"BRANCH_DESCRIPTION","value":"SAM NTULI MALL"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"51904"},{"column":"BRANCH_DESCRIPTION","value":"KOPANO MOBILE SERVICE CENTRE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"51916"},{"column":"BRANCH_DESCRIPTION","value":"DAVEYTON"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"51925"},{"column":"BRANCH_DESCRIPTION","value":"CAPE TOWN STATION SC"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52010"},{"column":"BRANCH_DESCRIPTION","value":"RANDFONTEIN SC 5841-6"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52012"},{"column":"BRANCH_DESCRIPTION","value":"MELROSE ARCH SC 4305-3"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52083"},{"column":"BRANCH_DESCRIPTION","value":"NORTHGATE SC 1106-4"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52232"},{"column":"BRANCH_DESCRIPTION","value":"DWARSLOOP SERVICE CENTRE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52411"},{"column":"BRANCH_DESCRIPTION","value":"LEPHALALE CBD SERVICE CENTRE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52414"},{"column":"BRANCH_DESCRIPTION","value":"SESHEGO TACTICAL SC"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52416"},{"column":"BRANCH_DESCRIPTION","value":"NORWOOD"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52427"},{"column":"BRANCH_DESCRIPTION","value":"EASTERN CAPE MOBILE SC"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52473"},{"column":"BRANCH_DESCRIPTION","value":"NORTH WEST MOBILE SC"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52477"},{"column":"BRANCH_DESCRIPTION","value":"RUSTENBURG MALL"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52492"},{"column":"BRANCH_DESCRIPTION","value":"MAKHAZA SC 0911-3"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52532"},{"column":"BRANCH_DESCRIPTION","value":"WESTERN CAPE MOBILE SC 1"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52583"},{"column":"BRANCH_DESCRIPTION","value":"CORKWOOD SERVICE CENTRE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52633"},{"column":"BRANCH_DESCRIPTION","value":"RANDBURG SQUARE SERVICE CENTRE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"52694"},{"column":"BRANCH_DESCRIPTION","value":"RUSTENBURG MOBILE SC"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"60667"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK CITY"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"60767"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK M/HOEK"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"60867"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK LERIBE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"60967"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK MAFETE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"61067"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK MAPUTSO"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"61167"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK BATHA"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"62067"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK TOWER"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"62167"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK TEYATE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"62367"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK INDUST"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"62467"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK QUTHING"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"62567"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK MOKHOTL"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"62667"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK AQCHA\'S"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"62767"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK THABA T"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"62867"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK ROMA"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"62967"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK PIONEER"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"63167"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD LESOTHO BANK MASERU"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"660464"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD BANK BIG BEND"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"660564"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD BANK MANZINI MAIN"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"660864"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD BANK TSHANENI"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"660964"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD BANK NHLANGANO"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"661164"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD BANK PIGGS PEAK"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"661264"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD BANK SIMUNYE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"663064"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD BANK HEAD OFFICE SWA"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"663164"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD BANK MBABANE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"663464"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD BANK MATSAPHA"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"663964"},{"column":"BRANCH_DESCRIPTION","value":"STANDARD BANK OPERATIONS PROCS"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800001"},{"column":"BRANCH_DESCRIPTION","value":"CARD DIVISION FACE TO FACE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800002"},{"column":"BRANCH_DESCRIPTION","value":"CARD DIVISION FACE TO FACE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800009"},{"column":"BRANCH_DESCRIPTION","value":"CARD DIVISION FACE TO FACE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800017"},{"column":"BRANCH_DESCRIPTION","value":"PRIVATE BANKING BOKSBURG"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800018"},{"column":"BRANCH_DESCRIPTION","value":"PRIVATE BANKING EASTGATE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800019"},{"column":"BRANCH_DESCRIPTION","value":"PVT BLOEMFONTEIN"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800020"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK PORT ELIZABETH"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800021"},{"column":"BRANCH_DESCRIPTION","value":"PVT BETHLEHEM"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800022"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK HEAD OFFICE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800023"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK KLERKSDORP"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800024"},{"column":"BRANCH_DESCRIPTION","value":"PRIVATE BANKING DURBAN SUITE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800025"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK NELSPRUIT"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800026"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK POLOKWANE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800027"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK MEYERSDAL"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800028"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK POTCHEFSTROOM"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800029"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK PRETORIA"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800030"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK RUSTENBURG"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800031"},{"column":"BRANCH_DESCRIPTION","value":"PRIVATE BANKING SANDTON SUITE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800032"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK HYDE PARK"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800033"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK SECUNDA"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800034"},{"column":"BRANCH_DESCRIPTION","value":"PRIVATE BANKING WESTERN CAPE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800035"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK WITBANK"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800037"},{"column":"BRANCH_DESCRIPTION","value":"PRIVATE BANKING KINGSMEAD SUIT"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800038"},{"column":"BRANCH_DESCRIPTION","value":"PVT CLIENTS HYDE PARK"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800039"},{"column":"BRANCH_DESCRIPTION","value":"PRIVATE BANKING FOURWAYS"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800040"},{"column":"BRANCH_DESCRIPTION","value":"PRIVATE BANKING WATERFALL"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800041"},{"column":"BRANCH_DESCRIPTION","value":"EMPLOYER VALUE BANKING"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800279"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK LOUIS TRICHARDT"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800477"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK NYLSTROOM"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800478"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK PIETERMARITZBURG"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800479"},{"column":"BRANCH_DESCRIPTION","value":"PVT CENTURION"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800480"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK RICHARDS BAY"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800481"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK VEREENIGING"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800482"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK HILLCREST"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800483"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK WELKOM"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800484"},{"column":"BRANCH_DESCRIPTION","value":"PVT CLIENTS PORT ELIZABETH"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800485"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK EAST LONDON"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800486"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK TZANEEN"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800487"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK MTHATHA"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800488"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK KIMBERLEY"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800489"},{"column":"BRANCH_DESCRIPTION","value":"PVT BRITS"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800490"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK LIBERTY"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800491"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK JOHANNESBURG"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800492"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK HELDERBERG"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800493"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK TYGERBERG"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800494"},{"column":"BRANCH_DESCRIPTION","value":"PRIVATE CLIENTS DURBAN"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800495"},{"column":"BRANCH_DESCRIPTION","value":"MOGALE PRIVATE BANKING SUITE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800496"},{"column":"BRANCH_DESCRIPTION","value":"PVT CLIENTS PRETORIA"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800497"},{"column":"BRANCH_DESCRIPTION","value":"PVT CLIENTS CLAREMONT"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800499"},{"column":"BRANCH_DESCRIPTION","value":"PRIVATE BANKING KURUMAN SUITE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800500"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK MAFIKENG"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800501"},{"column":"BRANCH_DESCRIPTION","value":"STD PVT BANK GEORGE"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800590"},{"column":"BRANCH_DESCRIPTION","value":"PVT ATLANTIC SEABOARD"}],"active":true},{"columns":[{"column":"BRANCH_CODE","value":"800602"},{"column":"BRANCH_DESCRIPTION","value":"STELLENBOSCH PC"}],"active":true}]}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);

			response.setBody(validResponse);

		}
	}
}