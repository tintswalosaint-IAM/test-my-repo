@isTest
public class AOB_BOTS_WRP_CIPAResponse_Test {
@isTest
static  void testPublicName() {
    
    try{
    String json=		'{'+
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
        '}';
		AOB_BOTS_WRP_CIPAResponse.parse(json);
    }Catch(exception e){
        
        assert.areNotEqual(null, e.getMessage());
    }
  }
}