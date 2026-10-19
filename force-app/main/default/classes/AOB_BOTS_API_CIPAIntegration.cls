/**
* @description  class to make callout to CPIA 
* @author Dayakar
*/
public class AOB_BOTS_API_CIPAIntegration extends AOB_API_RestBaseOutboundPing{

    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
	public static final String SERVICE_NAME = AOB_BOTS_API_CIPAIntegration.class.getName();
	String CompanyUIN;

   /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param CIN
    */
    public AOB_BOTS_API_CIPAIntegration(String CIN)
    {
        CompanyUIN=CIN;
    }
    
    /**
    * @description The name of your service to be used when looking up custom settings for you service
    * @return String
    */
    protected virtual override String getServiceName()
    {
        return SERVICE_NAME;
    }

   /**
    * @description Override to set your request and response DTO types and any other globals you may have
    */
    protected override void initialise()
    {
        super.initialise();
        
    }
    
    private class DTO_Request extends CMN_DTO_JsonBase
    {
       /**
        * @description populates triggering object
		* @param triggeringObjectId
        */
        public override void populate(Id triggeringObjectId)
        {
            super.populate(triggeringObjectId);
        }
    }
    
   /**
    * @description Will serialize requestDTO after its been populated.
    * @return string
    */
    @TestVisible
    public virtual override String getBody()
    {
        super.getBody();
        populateRequestDTO();
        return jsonBody;
    }
    /**
    * @description Overriding parent class method to use the right API Method.
    * @return string
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_GET;
    }
    /**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 * @return endpoint
	 */
    public  virtual override void setHeaders() 
    {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_HEADER_AUTHORIZATION,'Bearer '+settings.AOB_ClientCertificate__c);
        
    }
    
    /**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 * @return String
	 */
   @TestVisible
   protected override String getWebServiceEndPoint() {
       String endPoint;
       String path;
		if (settings != null) {
			path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
			endPoint = path+CompanyUIN;
		}
       
       return endPoint;
	}
    
   /**
	 * @description Call the parent objects' method to ensure we get code coverage
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new AOB_BOTS_API_CIPAIntegration_Mock();
	}
    
   /**
    * @description Overriding parent class method to indicate that triggering object is not needed
    * @return Boolean
    */
    @TestVisible
    protected override virtual Boolean triggeringObjectRequired()
    {
        return false;
    }
    
    /**
    * @description DTO_Response
    */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<object> response;
         /**
         * @description recieving DTO_Response
         * @param file
         */
		public DTO_Response(List<object> file)
		{
			this.response = file;
		}
		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}
     /**
	 * @descriptio get response body
	 * @return String
	 */
    public override String getResponseBody()
    {
        return response.getBody();
    }
    
    
   /**
    * @description Mock class for Test classes 
    */
    public class AOB_BOTS_API_CIPAIntegration_Mock extends CMN_API_HttpBaseOutboundMock
    {
        
        public final String validResponse = '['+
		'    {'+
		'        "CompanyUIN": "BW00001881348",'+
		'        "businessName": "Raneems Proprietary Limited",'+
		'        "rootDomainName": "Company",'+
		'        "ghost": false,'+
		'        "domainTree": {'+
		'            "name": "Company",'+
		'            "attributes": {'+
		'                "OldCompanyNumber": "CO2000/3364",'+
		'                "Status": "removed",'+
		'                "Type": "PrivateCompany",'+
		'                "TotalShares": 100,'+
		'                "SuppressedFromPublicSearchYn": "N",'+
		'                "AuthorityManagementSuspendedYn": "N",'+
		'                "TransitionalYn": "N",'+
		'                "ShareAllocationType": "ind",'+
		'                "RegistrationDate": "2000-07-18",'+
		'                "AnnualReturnYear": 2021,'+
		'                "FilingMonth": 7'+
		'            },'+
		'            "names": ['+
		'                {'+
		'                    "_id": "30c7526c0879daeb",'+
		'                    "name": "Name",'+
		'                    "arrName": "names",'+
		'                    "attributes": {'+
		'                        "Name": "Raneems Proprietary Limited",'+
		'                        "StartDate": "2000-07-18"'+
		'                    }'+
		'                }'+
		'            ],'+
		'            "authority": {'+
		'                "attributes": {'+
		'                    "CreatedByUserName": "Gaborekwe Ikgopoleng",'+
		'                    "CreatedDate": "2020-05-29"'+
		'                },'+
		'                "authorities": ['+
		'                    {'+
		'                        "name": "Authority",'+
		'                        "attributes": {'+
		'                            "FirstName": "Gaborekwe",'+
		'                            "LastName": "Ikgopoleng",'+
		'                            "Type": "initiator",'+
		'                            "Status": "active",'+
		'                            "GrantedOn": "2020-05-29",'+
		'                            "OrganisationName": "Acme Services (Pty) Ltd",'+
		'                            "UserType": "organisation"'+
		'                        }'+
		'                    }'+
		'                ]'+
		'            },'+
		'            "registeredOfficeAddresses": ['+
		'                {'+
		'                    "name": "RegisteredOfficeAddress",'+
		'                    "attributes": {'+
		'                        "Country": "BW",'+
		'                        "Line1": "Plot 139",'+
		'                        "Line2": "Gaborone International Finance Park",'+
		'                        "RegionCode": "Gaborone"'+
		'                    }'+
		'                }'+
		'            ],'+
		'            "postalAddresses": ['+
		'                {'+
		'                    "name": "EntityPostalAddress",'+
		'                    "attributes": {'+
		'                        "Country": "BW",'+
		'                        "SameAs": "different",'+
		'                        "Line1": "P.O. Box 401805",'+
		'                        "RegionCode": "Gaborone"'+
		'                    }'+
		'                }'+
		'            ],'+
		'            "principalPlaceOfBusinessAddresses": ['+
		'                {'+
		'                    "name": "PrincipalPlaceOfBusinessAddress",'+
		'                    "attributes": {'+
		'                        "Country": "BW",'+
		'                        "SameAs": "different",'+
		'                        "Line1": "Plot 880",'+
		'                        "Line2": "Gaborone International Commerce Park",'+
		'                        "RegionCode": "Gaborone"'+
		'                    }'+
		'                }'+
		'            ],'+
		'            "telephones": ['+
		'                {'+
		'                    "attributes": {'+
		'                        "CountryCode": "+267"'+
		'                    }'+
		'                }'+
		'            ],'+
		'            "mobiles": ['+
		'                {'+
		'                    "name": "MobileAddress",'+
		'                    "attributes": {'+
		'                        "CountryCode": "+267",'+
		'                        "Number": "71322595"'+
		'                    }'+
		'                }'+
		'            ],'+
		'            "emails": ['+
		'                {'+
		'                    "attributes": {'+
		'                        "Email": "GBE.Secretarial@mazars.co.bw"'+
		'                    }'+
		'                }'+
		'            ],'+
		'            "directors": ['+
		'                {'+
		'                    "name": "IndividualDirector",'+
		'                    "attributes": {'+
		'                        "CitizenYn": "Y",'+
		'                        "Nationality": "BW",'+
		'                        "Gender": "M",'+
		'                        "IdentityNumber": "580112015"'+
		'                    },'+
		'                    "names": ['+
		'                        {'+
		'                            "name": "IndividualName",'+
		'                            "attributes": {'+
		'                                "FirstName": "Ramachandran",'+
		'                                "FullName": "Ramachandran Ottapathu",'+
		'                                "LastName": "Ottapathu"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "mobiles": ['+
		'                        {'+
		'                            "name": "MobileAddress",'+
		'                            "attributes": {'+
		'                                "CountryCode": "+267",'+
		'                                "Number": "71276507"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "emails": ['+
		'                        {'+
		'                            "name": "EmailAddress",'+
		'                            "attributes": {'+
		'                                "Email": "ram@choppiesbotswana.co.bw"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "residentialAddresses": ['+
		'                        {'+
		'                            "name": "ResidentialAddress",'+
		'                            "attributes": {'+
		'                                "Country": "BW",'+
		'                                "SameAs": "different",'+
		'                                "Line1": "Plot 523",'+
		'                                "Line2": "Ako",'+
		'                                "RegionCode": "Mokolodi"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "serviceAddresses": ['+
		'                        {'+
		'                            "name": "ServiceAddress",'+
		'                            "attributes": {'+
		'                                "Country": "BW",'+
		'                                "SameAs": "different",'+
		'                                "Line1": "Private Bag 278",'+
		'                                "RegionCode": "Gaborone"'+
		'                            }'+
		'                        }'+
		'                    ]'+
		'                },'+
		'                {'+
		'                    "name": "IndividualDirector",'+
		'                    "attributes": {'+
		'                        "CitizenYn": "Y",'+
		'                        "Nationality": "BW",'+
		'                        "Gender": "M",'+
		'                        "IdentityNumber": "605911103"'+
		'                    },'+
		'                    "names": ['+
		'                        {'+
		'                            "name": "IndividualName",'+
		'                            "attributes": {'+
		'                                "FirstName": "Farouk",'+
		'                                "FullName": "Farouk Ismail",'+
		'                                "LastName": "Ismail"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "mobiles": ['+
		'                        {'+
		'                            "name": "MobileAddress",'+
		'                            "attributes": {'+
		'                                "CountryCode": "+267",'+
		'                                "Number": "71302090"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "emails": ['+
		'                        {'+
		'                            "name": "EmailAddress",'+
		'                            "attributes": {'+
		'                                "Email": "farouk@choppiesbotswana.co.bw"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "residentialAddresses": ['+
		'                        {'+
		'                            "name": "ResidentialAddress",'+
		'                            "attributes": {'+
		'                                "Country": "BW",'+
		'                                "SameAs": "different",'+
		'                                "Line1": "Plot 4709",'+
		'                                "Line2": "Extension 11, Sebina Close",'+
		'                                "RegionCode": "Gaborone"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "serviceAddresses": ['+
		'                        {'+
		'                            "name": "ServiceAddress",'+
		'                            "attributes": {'+
		'                                "Country": "BW",'+
		'                                "SameAs": "different",'+
		'                                "Line1": "P.O. Box 80782",'+
		'                                "RegionCode": "Gaborone"'+
		'                            }'+
		'                        }'+
		'                    ]'+
		'                }'+
		'            ],'+
		'            "shareholders": ['+
		'                {'+
		'                    "name": "IndividualShareholder",'+
		'                    "attributes": {'+
		'                        "CitizenYn": "Y",'+
		'                        "Nationality": "BW",'+
		'                        "Gender": "M",'+
		'                        "IdentityNumber": "580112015",'+
		'                        "NomineeYn": "N",'+
		'                        "BeneficialOwnerYn": "Y",'+
		'                        "StartDate": "2012-06-06"'+
		'                    },'+
		'                    "names": ['+
		'                        {'+
		'                            "name": "IndividualName",'+
		'                            "attributes": {'+
		'                                "FirstName": "Ramachandran",'+
		'                                "FullName": "Ramachandran Ottapathu",'+
		'                                "LastName": "Ottapathu"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "mobiles": ['+
		'                        {'+
		'                            "name": "MobileAddress",'+
		'                            "attributes": {'+
		'                                "CountryCode": "+267",'+
		'                                "Number": "71276507"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "emails": ['+
		'                        {'+
		'                            "name": "EmailAddress",'+
		'                            "attributes": {'+
		'                                "Email": "ram@choppiesbotswana.co.bw"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "residentialAddresses": ['+
		'                        {'+
		'                            "name": "ResidentialAddress",'+
		'                            "attributes": {'+
		'                                "Country": "BW",'+
		'                                "SameAs": "different",'+
		'                                "Line1": "Plot 523",'+
		'                                "Line2": "Ako",'+
		'                                "RegionCode": "Mokolodi"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "serviceAddresses": ['+
		'                        {'+
		'                            "name": "ServiceAddress",'+
		'                            "attributes": {'+
		'                                "Country": "BW",'+
		'                                "SameAs": "different",'+
		'                                "Line1": "Private Bag 278",'+
		'                                "RegionCode": "Gaborone"'+
		'                            }'+
		'                        }'+
		'                    ]'+
		'                },'+
		'                {'+
		'                    "name": "IndividualShareholder",'+
		'                    "attributes": {'+
		'                        "CitizenYn": "Y",'+
		'                        "Nationality": "BW",'+
		'                        "Gender": "M",'+
		'                        "IdentityNumber": "605911103",'+
		'                        "NomineeYn": "N",'+
		'                        "BeneficialOwnerYn": "Y",'+
		'                        "StartDate": "2012-06-06"'+
		'                    },'+
		'                    "names": ['+
		'                        {'+
		'                            "name": "IndividualName",'+
		'                            "attributes": {'+
		'                                "FirstName": "Farouk",'+
		'                                "FullName": "Farouk Ismail",'+
		'                                "LastName": "Ismail"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "mobiles": ['+
		'                        {'+
		'                            "name": "MobileAddress",'+
		'                            "attributes": {'+
		'                                "CountryCode": "+267",'+
		'                                "Number": "71302090"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "emails": ['+
		'                        {'+
		'                            "name": "EmailAddress",'+
		'                            "attributes": {'+
		'                                "Email": "farouk@choppiesbotswana.co.bw"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "residentialAddresses": ['+
		'                        {'+
		'                            "name": "ResidentialAddress",'+
		'                            "attributes": {'+
		'                                "Country": "BW",'+
		'                                "SameAs": "different",'+
		'                                "Line1": "Plot 4709",'+
		'                                "Line2": "Extension 11, Sebina Close",'+
		'                                "RegionCode": "Gaborone"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "serviceAddresses": ['+
		'                        {'+
		'                            "name": "ServiceAddress",'+
		'                            "attributes": {'+
		'                                "Country": "BW",'+
		'                                "SameAs": "different",'+
		'                                "Line1": "P.O. Box 80782",'+
		'                                "RegionCode": "Gaborone"'+
		'                            }'+
		'                        }'+
		'                    ]'+
		'                }'+
		'            ],'+
		'            "ownershipBundles": ['+
		'                {'+
		'                    "attributes": {'+
		'                        "Type": "individual",'+
		'                        "NumShares": "50"'+
		'                    },'+
		'                    "owners": ['+
		'                        {'+
		'                            "name": "Owner",'+
		'                            "attributes": {'+
		'                                "ShareholderName": "Ramachandran Ottapathu "'+
		'                            }'+
		'                        }'+
		'                    ]'+
		'                },'+
		'                {'+
		'                    "attributes": {'+
		'                        "Type": "individual",'+
		'                        "NumShares": "50"'+
		'                    },'+
		'                    "owners": ['+
		'                        {'+
		'                            "name": "Owner",'+
		'                            "attributes": {'+
		'                                "ShareholderName": "Farouk Ismail "'+
		'                            }'+
		'                        }'+
		'                    ]'+
		'                }'+
		'            ],'+
		'            "secretaries": ['+
		'                {'+
		'                    "name": "EntitySecretary",'+
		'                    "attributes": {'+
		'                        "Name": "Acme Services Proprietary Limited",'+
		'                        "EntityNumber": "BW00000027737",'+
		'                        "StartDate": "2000-08-01"'+
		'                    },'+
		'                    "names": ['+
		'                        {'+
		'                            "name": "Name",'+
		'                            "attributes": {}'+
		'                        }'+
		'                    ],'+
		'                    "residentialAddresses": ['+
		'                        {'+
		'                            "name": "ResidentialAddress",'+
		'                            "attributes": {'+
		'                                "Country": "BW",'+
		'                                "Line1": "Plot 139",'+
		'                                "Line2": "Gaborone International Finance Park",'+
		'                                "RegionCode": "Gaborone"'+
		'                            }'+
		'                        }'+
		'                    ],'+
		'                    "representative": {'+
		'                        "name": "Representative",'+
		'                        "attributes": {'+
		'                            "Name": "Sindhu Sreedevi"'+
		'                        },'+
		'                        "telephone": {'+
		'                            "attributes": {'+
		'                                "CountryCode": "+267",'+
		'                                "Number": "3957466"'+
		'                            }'+
		'                        },'+
		'                        "email": {'+
		'                            "attributes": {'+
		'                                "Email": "GBE.Secretarial@mazars.co.bw"'+
		'                            }'+
		'                        },'+
		'                        "serviceAddress": {'+
		'                            "attributes": {'+
		'                                "Country": "BW",'+
		'                                "Line1": "P.O. Box 401805",'+
		'                                "RegionCode": "Gaborone",'+
		'                                "StartDate": "2000-07-18"'+
		'                            }'+
		'                        }'+
		'                    }'+
		'                }'+
		'            ]'+
		'        }'+
		'    }'+
		']';
       /*
        * @description creates a mock response for http calls
        * @param  request
        * @param response
        */
        protected override void setResponse(
            HttpRequest request,
            HttpResponse response
        )
        {
            super.setResponse(request, response);
            response.setBody(validResponse);
        }
    }
    
}