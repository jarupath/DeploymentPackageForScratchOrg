@isTest
public class Mockup_DCS_Pax {

	public static Account getAccount(String sequence){
		Account acc = new Account();
		acc.First_Name__c = 'Account';
		acc.Last_Name__c = 'name' + sequence;
		acc.Name = acc.Last_Name__c + ' ' + acc.First_Name__c + ' ' + acc.Salutation__c;
		acc.Salutation__c = 'Mr';
		acc.Travel_Document__c = '1234' + sequence;
		acc.Date_of_Birth__c = Date.valueOf('1990-01-01');
		acc.Customer_External_Id__c = acc.First_Name__c + ' ' + acc.Salutation__c + '_' + acc.Last_Name__c + '_' + BE8_DateUtility.convertDateFormatToTraditionalFormat(String.valueOf(acc.Date_of_Birth__c).split('T').get(0)) + '_' + acc.Travel_Document__c;
		acc.Customer_External_Id_Trim__c = acc.Customer_External_Id__c.replaceAll(' ', '').toLowerCase();
		return acc;
	}

	public static Passenger__c getPassenger(String sequence){
		Passenger__c pax = new Passenger__c();
		pax.First_Name__c = 'Passenger';
		pax.Last_Name__c = 'name' + sequence;
		pax.Salutation__c = 'Mr';
		pax.Gender__c = 'M';
		pax.Email_1__c = 'email@gmail.com';
		pax.Mobile__c = '+66900909999';
		Pax.Nationality__c = 'THA';
		pax.Name = pax.Last_Name__c + ' ' + pax.First_Name__c + ' ' + pax.Salutation__c;
		pax.Date_of_Birth__c = '1990-01-01';
		pax.Travel_Document_Number__c = '1234' + sequence;
		pax.PNR__c = 'PNR1234' + sequence;
		pax.FFP_Number__c = 'RE12345';
		pax.FFP_Carrier__c = 'TG';
		pax.FFP_Tier__c = 'BASE';
		pax.WS_KEY__c = '';
		return pax;
	}
	
	public static WS_DCS_Pax_Model.cls_customerLevel getSingleDCSPax() {
		String customerLevelJson =  '' + 
							'       {  '  + 
							'         "uniqueCustomerId": {  '  + 
							'           "idSection": {  '  + 
							'             "referenceQualifier": "UCI",  '  + 
							'             "primeId": "200219770005BDB0"  '  + 
							'           }  '  + 
							'         },  '  + 
							'         "ssrDetails": null,  '  + 
							'         "secNumber": {  '  + 
							'           "referenceDetails": {  '  + 
							'             "value": "BKK-107",  '  + 
							'             "type_z": "4"  '  + 
							'           }  '  + 
							'         },  '  + 
							'         "seatInfo": {  '  + 
							'           "seatStatusInfo": {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "SS",  '  + 
							'               "action": "GUA"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           "seatNumberInfo": {  '  + 
							'             "seatDetails": {  '  + 
							'               "seatNumber": "053K"  '  + 
							'             }  '  + 
							'           }  '  + 
							'         },  '  + 
							'         "regulatoryInfo": [{ '  + 
							'           "travelerDocuments": {  '  + 
							'             "travelerDocumentDetails": {  '  + 
							'               "travelerDocumentId": "M10037216"  '  + 
							'             },  '  + 
							'             "issueDetails": {  '  + 
							'               "documentCode": "P"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           "regulatoryDataViewPermission": {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "VSP",  '  + 
							'               "action": "N"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           "PaxData": {  '  + 
							'             "paxDetails": {  '  + 
							'               "type_z": "FL",  '  + 
							'               "surname": "AHN",  '  + 
							'               "gender": null  '  + 
							'             },  '  + 
							'             "otherPaxDetails": {  '  + 
							'               "title": null,  '  + 
							'               "givenName": "BYUNGWOOK"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           "documentIssuingCountry": {  '  + 
							'             "LocnType": "180",  '  + 
							'             "LocnDesc": {  '  + 
							'               "code": "KOR"  '  + 
							'             }  '  + 
							'           }  '  + 
							'         }],  '  + 
							'         "productLevel": {  '  + 
							'           "TktInfo": null,  '  + 
							'           "sbrRecordLocator": {  '  + 
							'             "reservation": {  '  + 
							'               "controlNumber": "UI2BIW"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           "productID": {  '  + 
							'             "idSection": {  '  + 
							'               "referenceQualifier": "DID",  '  + 
							'               "primeId": "2002C9770039C7F2"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           "flightInfo": {  '  + 
							'             "offpointDetails": {  '  + 
							'               "trueLocnId": "ICN"  '  + 
							'             },  '  + 
							'             "flightIdentification": {  '  + 
							'               "flightNumber": "628",  '  + 
							'               "bookingClass": "K"  '  + 
							'             },  '  + 
							'             "flightDate": {  '  + 
							'               "departureDate": "2017-06-03"  '  + 
							'             },  '  + 
							'             "companyDetails": {  '  + 
							'               "operatingCompany": null,  '  + 
							'               "marketingCompany": "TG"  '  + 
							'             },  '  + 
							'             "boardPointDetails": {  '  + 
							'               "trueLocnId": "BKK"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           "bookingData": {  '  + 
							'             "statusCode": "HK"  '  + 
							'           }  '  + 
							'         },  '  + 
							'         "paxDateTime": {  '  + 
							'           "timeMode": "LD",  '  + 
							'           "dateTime_z": "1988-09-14T00:00:00",  '  + 
							'           "businessSemantic": "706"  '  + 
							'         },  '  + 
							'       "otherFlightInfo": [  '  + 
							'         {  '  + 
							'           "timeData": [  '  + 
							'             {  '  + 
							'               "timeMode": "LT",  '  + 
							'               "dateTime_z": "2017-07-05T20:45:00",  '  + 
							'               "businessSemantic": "STD"  '  + 
							'             },  '  + 
							'             {  '  + 
							'               "timeMode": "LT",  '  + 
							'               "dateTime_z": "2017-07-05T20:55:00",  '  + 
							'               "businessSemantic": "ATD"  '  + 
							'             },  '  + 
							'             {  '  + 
							'               "timeMode": "LT",  '  + 
							'               "dateTime_z": "2017-07-05T22:25:00",  '  + 
							'               "businessSemantic": "STA"  '  + 
							'             },  '  + 
							'             {  '  + 
							'               "timeMode": "LT",  '  + 
							'               "dateTime_z": "2017-07-05T23:03:00",  '  + 
							'               "businessSemantic": "ATA"  '  + 
							'             },  '  + 
							'             {  '  + 
							'               "timeMode": "LT",  '  + 
							'               "dateTime_z": "2017-07-05T22:54:00",  '  + 
							'               "businessSemantic": "ETA"  '  + 
							'             },  '  + 
							'             {  '  + 
							'               "timeMode": "LT",  '  + 
							'               "dateTime_z": "2017-07-05T20:05:00",  '  + 
							'               "businessSemantic": "BOT"  '  + 
							'             }  '  + 
							'           ],  '  + 
							'           "otherFlightData": {  '  + 
							'             "offpointDetails": {  '  + 
							'               "trueLocnId": "BKK"  '  + 
							'             },  '  + 
							'             "flightIdentification": {  '  + 
							'               "flightNumber": "607",  '  + 
							'               "bookingClass": "K"  '  + 
							'             },  '  + 
							'             "flightDate": {  '  + 
							'               "departureDate": "2017-07-05"  '  + 
							'             },  '  + 
							'             "companyDetails": {  '  + 
							'               "operatingCompany": null,  '  + 
							'               "marketingCompany": "TG"  '  + 
							'             },  '  + 
							'             "boardPointDetails": {  '  + 
							'               "trueLocnId": "HKG"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           "operatingDetails": {  '  + 
							'             "flightIdentification": {  '  + 
							'               "flightNumber": "607",  '  + 
							'               "bookingClass": null  '  + 
							'             },  '  + 
							'             "companyDetails": {  '  + 
							'               "operatingCompany": "TG",  '  + 
							'               "marketingCompany": null  '  + 
							'             }  '  + 
							'           },  '  + 
							'           "flightTypeIndicator": {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "FIT",  '  + 
							'               "action": "OFL"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           "cabinData": {  '  + 
							'             "cabinDetails": {  '  + 
							'               "classDesignator": "Y"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           "acceptanceStatus": {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "CAS",  '  + 
							'               "action": "CAC"  '  + 
							'             }  '  + 
							'           }  '  + 
							'         }  '  + 
							'      	],  ' +
							'         "nationality": {  '  + 
							'           "nationalityDetails": {  '  + 
							'             "nationalityCode": "KOR"  '  + 
							'           },  '  + 
							'           "codeQualifier": "2"  '  + 
							'         },  '  + 
							'         "legCabinCode": {  '  + 
							'           "cabinDetails": {  '  + 
							'             "classDesignator": "Y"  '  + 
							'           }  '  + 
							'         },  '  + 
							'         "groupName": null,  '  + 
							'       "fqtvDetails": [  '  + 
							'         {  '  + 
							'           "fqtvData": {  '  + 
							'             "frequentTravellerDetails": [  '  + 
							'               {  '  + 
							'                 "tierLevel": "BASE",  '  + 
							'                 "tierDesc": "BASE",  '  + 
							'                 "status": "A",  '  + 
							'                 "number_z": "GM44817",  '  + 
							'                 "carrier": "TG"  '  + 
							'               },  '  + 
							'               {  '  + 
							'                 "tierLevel": null,  '  + 
							'                 "tierDesc": null,  '  + 
							'                 "status": "A",  '  + 
							'                 "number_z": "GM44817",  '  + 
							'                 "carrier": "TG"  '  + 
							'               }  '  + 
							'             ]  '  + 
							'           }  '  + 
							'         }  '  + 
							'      ],  ' +
							'         "dummySTX": null,  '  + 
							'         "dummySegment": null,  '  + 
							'         "dummy3": null,  '  + 
							'         "dummy": null,  '  + 
							'         "customerStatus": [  '  + 
							'           {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "CAS",  '  + 
							'               "action": "CAC"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "AAC",  '  + 
							'               "action": "0"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "CBS",  '  + 
							'               "action": "BED"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "EST",  '  + 
							'               "action": "0"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "CBG",  '  + 
							'               "action": "0"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "IFT",  '  + 
							'               "action": "0"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "CHD",  '  + 
							'               "action": "0"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "UMN",  '  + 
							'               "action": "0"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "TST",  '  + 
							'               "action": "0"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "API",  '  + 
							'               "action": "1"  '  + 
							'             }  '  + 
							'           },  '  + 
							'           {  '  + 
							'             "statusInfo": {  '  + 
							'               "indicator": "ODP",  '  + 
							'               "action": "0"  '  + 
							'             }  '  + 
							'           }  '  + 
							'         ],  '  + 
							'         "customerStaffCategory": null,  '  + 
							'         "customerData": {  '  + 
							'           "paxDetails": {  '  + 
							'             "type_z": "A",  '  + 
							'             "surname": "AHN",  '  + 
							'             "gender": "M"  '  + 
							'           },  '  + 
							'           "otherPaxDetails": {  '  + 
							'             "title": "MR",  '  + 
							'             "givenName": "BYUNGWOOK"  '  + 
							'           }  '  + 
							'         },  '  + 
							'         "bookedCabinCode": {  '  + 
							'           "cabinDetails": {  '  + 
							'             "classDesignator": "Y"  '  + 
							'           }  '  + 
							'         },  '  + 
							'         "boardingLocn": {  '  + 
							'           "LocnType": "BRD",  '  + 
							'           "LocnDesc": {  '  + 
							'             "code": null  '  + 
							'           }  '  + 
							'         }  '  + 
							'       }  ';
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = (WS_DCS_Pax_Model.cls_customerLevel)JSON.deserialize(customerLevelJson, WS_DCS_Pax_Model.cls_customerLevel.class);
		System.debug('paxmodel: ' + JSON.serialize(paxmodel));
		return paxmodel;
	}
	
	public static String getPSTDCSPaxResponse() {
		String response =  '' +
			 '   <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">  '  + 
			'       <SOAP-ENV:Header>  '  + 
			'           <ResHeader xmlns="http://xml.accenture.com/common/header" xmlns:ns="http://xml.thaiairways.com/dcs/listing/pax/getpaxlistbyflight/v1_0" xmlns:ns0="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns="http://ws.thaiairways.com/dcs/listing/pax/v1_0" xmlns:tns1="http://ws.thaiairways.com/dcs/listing/pax" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">  '  + 
			'               <ResDateTime>2017-07-07T10:58:19.88+07:00</ResDateTime>  '  + 
			'               <ReqTxnID>SFDC_SICSE20170707-105815</ReqTxnID>  '  + 
			'               <MWTxnID>SY_TGAIP_1499399895529</MWTxnID>  '  + 
			'               <AlteaSession>  '  + 
			'                   <SessionId>0VXCDGPCDB</SessionId>  '  + 
			'                   <SequenceNumber>2</SequenceNumber>  '  + 
			'                   <SecurityToken>1RCWGKEL52SKG8EDSPCM6BHMC</SecurityToken>  '  + 
			'               </AlteaSession>  '  + 
			'               <IsLastTxn>true</IsLastTxn>  '  + 
			'               <ResCode>SUCCESS</ResCode>  '  + 
			'           </ResHeader>  '  + 
			'       </SOAP-ENV:Header>  '  + 
			'       <SOAP-ENV:Body>  '  + 
			'           <ns0:GetPaxListByFlightRes xmlns="http://xml.thaiairways.com/dcs/listing/pax/getpaxlistbyflight/v1_0" xmlns:ns0="http://xml.thaiairways.com/dcs/listing/pax" xmlns:ns1="http://xml.accenture.com/common/header" xmlns:tns="http://ws.thaiairways.com/dcs/listing/pax/v1_0" xmlns:tns1="http://ws.thaiairways.com/dcs/listing/pax">  '  + 
			'               <orFiltersQuery xmlns="http://xml.thaiairways.com/dcs/listing/pax/getpaxlist/v1_0">  '  + 
			'                   <dummy/>  '  + 
			'                   <andFiltersQuery>  '  + 
			'                       <PaxListFilterName>  '  + 
			'                           <attributeDetails>  '  + 
			'                               <attributeType>GRP</attributeType>  '  + 
			'                           </attributeDetails>  '  + 
			'                       </PaxListFilterName>  '  + 
			'                   </andFiltersQuery>  '  + 
			'               </orFiltersQuery>  '  + 
			'               <orFiltersQuery xmlns="http://xml.thaiairways.com/dcs/listing/pax/getpaxlist/v1_0">  '  + 
			'                   <dummy/>  '  + 
			'                   <andFiltersQuery>  '  + 
			'                       <PaxListFilterName>  '  + 
			'                           <attributeDetails>  '  + 
			'                               <attributeType>PST</attributeType>  '  + 
			'                           </attributeDetails>  '  + 
			'                       </PaxListFilterName>  '  + 
			'                   </andFiltersQuery>  '  + 
			'                   <andFiltersQuery>  '  + 
			'                       <PaxListFilterName>  '  + 
			'                           <attributeDetails>  '  + 
			'                               <attributeType>NAT</attributeType>  '  + 
			'                           </attributeDetails>  '  + 
			'                       </PaxListFilterName>  '  + 
			'                   </andFiltersQuery>  '  + 
			'               </orFiltersQuery>  '  + 
			'               <flightDetailsGroup xmlns="http://xml.thaiairways.com/dcs/listing/pax/getpaxlist/v1_0">  '  + 
			'                   <legDetails>  '  + 
			'                       <carrierDetails>  '  + 
			'                           <marketingCarrier>TG</marketingCarrier>  '  + 
			'                       </carrierDetails>  '  + 
			'                       <flightDetails>  '  + 
			'                           <flightNumber>628</flightNumber>  '  + 
			'                       </flightDetails>  '  + 
			'                       <departureDate>2017-07-05</departureDate>  '  + 
			'                       <boardPoint>BKK</boardPoint>  '  + 
			'                   </legDetails>  '  + 
			'                   <aircraftInfo>  '  + 
			'                       <Equip>  '  + 
			'                           <meanTypeCode>74A</meanTypeCode>  '  + 
			'                           <characteristics>773</characteristics>  '  + 
			'                           <ID>HS-TKD</ID>  '  + 
			'                       </Equip>  '  + 
			'                   </aircraftInfo>  '  + 
			'                   <flightStatus>  '  + 
			'                       <statusInfo>  '  + 
			'                           <indicator>GN</indicator>  '  + 
			'                           <action>FD</action>  '  + 
			'                       </statusInfo>  '  + 
			'                   </flightStatus>  '  + 
			'                   <flightStatus>  '  + 
			'                       <statusInfo>  '  + 
			'                           <indicator>AC</indicator>  '  + 
			'                           <action>FI</action>  '  + 
			'                       </statusInfo>  '  + 
			'                   </flightStatus>  '  + 
			'                   <flightStatus>  '  + 
			'                       <statusInfo>  '  + 
			'                           <indicator>BO</indicator>  '  + 
			'                           <action>CL</action>  '  + 
			'                       </statusInfo>  '  + 
			'                   </flightStatus>  '  + 
			'                   <flightStatus>  '  + 
			'                       <statusInfo>  '  + 
			'                           <indicator>LC</indicator>  '  + 
			'                           <action>LSF</action>  '  + 
			'                       </statusInfo>  '  + 
			'                   </flightStatus>  '  + 
			'                   <flightStatus>  '  + 
			'                       <statusInfo>  '  + 
			'                           <indicator>BG</indicator>  '  + 
			'                           <action>IG</action>  '  + 
			'                       </statusInfo>  '  + 
			'                   </flightStatus>  '  + 
			'                   <flightStatus>  '  + 
			'                       <statusInfo>  '  + 
			'                           <indicator>SDE</indicator>  '  + 
			'                           <action>0</action>  '  + 
			'                       </statusInfo>  '  + 
			'                   </flightStatus>  '  + 
			'                   <flightStatus>  '  + 
			'                       <statusInfo>  '  + 
			'                           <indicator>BDE</indicator>  '  + 
			'                           <action>0</action>  '  + 
			'                       </statusInfo>  '  + 
			'                   </flightStatus>  '  + 
			'                   <flightStatus>  '  + 
			'                       <statusInfo>  '  + 
			'                           <indicator>BSR</indicator>  '  + 
			'                           <action>0</action>  '  + 
			'                       </statusInfo>  '  + 
			'                   </flightStatus>  '  + 
			'                   <flightStatus>  '  + 
			'                       <statusInfo>  '  + 
			'                           <indicator>DIS</indicator>  '  + 
			'                           <action>NDI</action>  '  + 
			'                       </statusInfo>  '  + 
			'                   </flightStatus>  '  + 
			'                   <timeData>  '  + 
			'                       <businessSemantic>STD</businessSemantic>  '  + 
			'                       <timeMode>LT</timeMode>  '  + 
			'                       <dateTime>2017-07-05T10:45:00</dateTime>  '  + 
			'                   </timeData>  '  + 
			'                   <timeData>  '  + 
			'                       <businessSemantic>ATD</businessSemantic>  '  + 
			'                       <timeMode>LT</timeMode>  '  + 
			'                       <dateTime>2017-07-05T10:48:00</dateTime>  '  + 
			'                   </timeData>  '  + 
			'                   <timeData>  '  + 
			'                       <businessSemantic>BOT</businessSemantic>  '  + 
			'                       <timeMode>LT</timeMode>  '  + 
			'                       <dateTime>2017-07-05T10:05:00</dateTime>  '  + 
			'                   </timeData>  '  + 
			'                   <timeData>  '  + 
			'                       <businessSemantic>STA</businessSemantic>  '  + 
			'                       <timeMode>LT</timeMode>  '  + 
			'                       <dateTime>2017-07-05T14:30:00</dateTime>  '  + 
			'                   </timeData>  '  + 
			'                   <terminalInfo>  '  + 
			'                       <airportCode>BKK</airportCode>  '  + 
			'                   </terminalInfo>  '  + 
			'                   <gate>  '  + 
			'                       <facilityDetails>  '  + 
			'                           <type>GTE</type>  '  + 
			'                           <ID>E1A</ID>  '  + 
			'                       </facilityDetails>  '  + 
			'                   </gate>  '  + 
			'                   <acLocnTerminalDetails>  '  + 
			'                       <arrivalDepartureOption>  '  + 
			'                           <actionRequestCode>DAL</actionRequestCode>  '  + 
			'                       </arrivalDepartureOption>  '  + 
			'                       <aircraftLocn>  '  + 
			'                           <facilityDetails>  '  + 
			'                               <type>BAY</type>  '  + 
			'                               <ID>306</ID>  '  + 
			'                           </facilityDetails>  '  + 
			'                       </aircraftLocn>  '  + 
			'                   </acLocnTerminalDetails>  '  + 
			'                   <flightRelatedComments>  '  + 
			'                       <freeTextDetails>  '  + 
			'                           <textSubjectQualifier>3</textSubjectQualifier>  '  + 
			'                           <source>M</source>  '  + 
			'                           <encoding>ZZZ</encoding>  '  + 
			'                       </freeTextDetails>  '  + 
			'                       <freeText>CRW 02/14/noge/PIC VUTHTHIBOON.M/IM LERTSAK.L</freeText>  '  + 
			'                   </flightRelatedComments>  '  + 
			'                   <flightRelatedComments>  '  + 
			'                       <freeTextDetails>  '  + 
			'                           <textSubjectQualifier>3</textSubjectQualifier>  '  + 
			'                           <source>M</source>  '  + 
			'                           <encoding>ZZZ</encoding>  '  + 
			'                       </freeTextDetails>  '  + 
			'                       <freeText>FLT AVBL X ID2 OK KA</freeText>  '  + 
			'                   </flightRelatedComments>  '  + 
			'                   <flightRelatedComments>  '  + 
			'                       <freeTextDetails>  '  + 
			'                           <textSubjectQualifier>3</textSubjectQualifier>  '  + 
			'                           <source>M</source>  '  + 
			'                           <encoding>ZZZ</encoding>  '  + 
			'                       </freeTextDetails>  '  + 
			'                       <freeText>KO-B C/SEKSUK PLS CTC 21319</freeText>  '  + 
			'                   </flightRelatedComments>  '  + 
			'                   <flightRelatedComments>  '  + 
			'                       <freeTextDetails>  '  + 
			'                           <textSubjectQualifier>3</textSubjectQualifier>  '  + 
			'                           <source>M</source>  '  + 
			'                           <encoding>ZZZ</encoding>  '  + 
			'                       </freeTextDetails>  '  + 
			'                       <freeText>KO-B F/SOMSAK NUTCHAPORN **LCC 71291 **</freeText>  '  + 
			'                   </flightRelatedComments>  '  + 
			'                   <flightRelatedComments>  '  + 
			'                       <freeTextDetails>  '  + 
			'                           <textSubjectQualifier>3</textSubjectQualifier>  '  + 
			'                           <source>M</source>  '  + 
			'                           <encoding>ZZZ</encoding>  '  + 
			'                       </freeTextDetails>  '  + 
			'                       <freeText>MOB: ADJ 27C 148Y 0915 SS</freeText>  '  + 
			'                   </flightRelatedComments>  '  + 
			'                   <flightRelatedComments>  '  + 
			'                       <freeTextDetails>  '  + 
			'                           <textSubjectQualifier>3</textSubjectQualifier>  '  + 
			'                           <source>M</source>  '  + 
			'                           <encoding>ZZZ</encoding>  '  + 
			'                       </freeTextDetails>  '  + 
			'                       <freeText>CSA-G: KHETAPAT PATTAMAPORN TASSAWAT 21320//TGD4BCC8</freeText>  '  + 
			'                   </flightRelatedComments>  '  + 
			'                   <flightRelatedComments>  '  + 
			'                       <freeTextDetails>  '  + 
			'                           <textSubjectQualifier>3</textSubjectQualifier>  '  + 
			'                           <source>M</source>  '  + 
			'                           <encoding>ZZZ</encoding>  '  + 
			'                       </freeTextDetails>  '  + 
			'                       <freeText>CSS-G: TATIRAT CHAWALRAS ST1910 CP1042 TTL145+23=168</freeText>  '  + 
			'                   </flightRelatedComments>  '  + 
			'                   <flightMode>  '  + 
			'                       <attributeFunction>BPW</attributeFunction>  '  + 
			'                       <attributeDetails>  '  + 
			'                           <attributeType>PW</attributeType>  '  + 
			'                       </attributeDetails>  '  + 
			'                   </flightMode>  '  + 
			'                   <totalByCabin>  '  + 
			'                       <cabin>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>C</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </cabin>  '  + 
			'                       <total>  '  + 
			'                           <quantityDetails>  '  + 
			'                               <numberOfUnit>27</numberOfUnit>  '  + 
			'                               <unitQualifier>CUS</unitQualifier>  '  + 
			'                           </quantityDetails>  '  + 
			'                       </total>  '  + 
			'                       <cabinIndicators>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>FSI</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </cabinIndicators>  '  + 
			'                       <cabinIndicators>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CGI</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </cabinIndicators>  '  + 
			'                   </totalByCabin>  '  + 
			'                   <totalByCabin>  '  + 
			'                       <cabin>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>Y</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </cabin>  '  + 
			'                       <total>  '  + 
			'                           <quantityDetails>  '  + 
			'                               <numberOfUnit>145</numberOfUnit>  '  + 
			'                               <unitQualifier>CUS</unitQualifier>  '  + 
			'                           </quantityDetails>  '  + 
			'                       </total>  '  + 
			'                       <cabinIndicators>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>FSI</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </cabinIndicators>  '  + 
			'                       <cabinIndicators>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CGI</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </cabinIndicators>  '  + 
			'                   </totalByCabin>  '  + 
			'                   <customerLevel>  '  + 
			'                       <customerData>  '  + 
			'                           <paxDetails>  '  + 
			'                               <surname>SONGSAMPHAN</surname>  '  + 
			'                               <type>A</type>  '  + 
			'                               <gender>F</gender>  '  + 
			'                           </paxDetails>  '  + 
			'                           <otherPaxDetails>  '  + 
			'                               <givenName>CHALIDAPORN</givenName>  '  + 
			'                               <title>MS</title>  '  + 
			'                           </otherPaxDetails>  '  + 
			'                       </customerData>  '  + 
			'                       <uniqueCustomerId>  '  + 
			'                           <idSection>  '  + 
			'                               <referenceQualifier>UCI</referenceQualifier>  '  + 
			'                               <primeId>2002898500007BA9</primeId>  '  + 
			'                           </idSection>  '  + 
			'                       </uniqueCustomerId>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CAS</indicator>  '  + 
			'                               <action>CAC</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>AAC</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CBS</indicator>  '  + 
			'                               <action>BED</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>EST</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CBG</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>IFT</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CHD</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>UMN</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>TST</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>API</indicator>  '  + 
			'                               <action>1</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>ODP</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <boardingLocn>  '  + 
			'                           <LocnType>BRD</LocnType>  '  + 
			'                           <LocnDesc>  '  + 
			'                               <name>A/BKK/T//GTE/E1A</name>  '  + 
			'                           </LocnDesc>  '  + 
			'                       </boardingLocn>  '  + 
			'                       <paxDateTime>  '  + 
			'                           <businessSemantic>706</businessSemantic>  '  + 
			'                           <timeMode>LD</timeMode>  '  + 
			'                           <dateTime>1962-07-15T00:00:00</dateTime>  '  + 
			'                       </paxDateTime>  '  + 
			'                       <regulatoryInfo>  '  + 
			'                           <travelerDocuments>  '  + 
			'                               <issueDetails>  '  + 
			'                                   <documentCode>P</documentCode>  '  + 
			'                               </issueDetails>  '  + 
			'                               <travelerDocumentDetails>  '  + 
			'                                   <travelerDocumentId>AA5028566</travelerDocumentId>  '  + 
			'                               </travelerDocumentDetails>  '  + 
			'                           </travelerDocuments>  '  + 
			'                           <documentIssuingCountry>  '  + 
			'                               <LocnType>180</LocnType>  '  + 
			'                               <LocnDesc><code>THA</code></LocnDesc>  '  + 
			'                           </documentIssuingCountry>  '  + 
			'                           <regulatoryDataViewPermission>  '  + 
			'                               <statusInfo>  '  + 
			'                                   <indicator>VSP</indicator>  '  + 
			'                                   <action>N</action>  '  + 
			'                               </statusInfo>  '  + 
			'                           </regulatoryDataViewPermission>  '  + 
			'                           <PaxData>  '  + 
			'                               <paxDetails>  '  + 
			'                                   <surname>SONGSAMPHAN</surname>  '  + 
			'                                   <type>FL</type>  '  + 
			'                               </paxDetails>  '  + 
			'                               <otherPaxDetails>  '  + 
			'                                   <givenName>CHALIDAPORN</givenName>  '  + 
			'                               </otherPaxDetails>  '  + 
			'                           </PaxData>  '  + 
			'                       </regulatoryInfo>  '  + 
			'                       <nationality>  '  + 
			'                           <codeQualifier>2</codeQualifier>  '  + 
			'                           <nationalityDetails>  '  + 
			'                               <nationalityCode>THA</nationalityCode>  '  + 
			'                           </nationalityDetails>  '  + 
			'                       </nationality>  '  + 
			'                       <productLevel>  '  + 
			'                           <bookingData>  '  + 
			'                               <statusCode>HK</statusCode>  '  + 
			'                           </bookingData>  '  + 
			'                           <productID>  '  + 
			'                               <idSection>  '  + 
			'                                   <referenceQualifier>DID</referenceQualifier>  '  + 
			'                                   <primeId>2002E9850001E8AC</primeId>  '  + 
			'                               </idSection>  '  + 
			'                           </productID>  '  + 
			'                           <sbrRecordLocator>  '  + 
			'                               <reservation>  '  + 
			'                                   <controlNumber>TTS26I</controlNumber>  '  + 
			'                               </reservation>  '  + 
			'                           </sbrRecordLocator>  '  + 
			'                           <flightInfo>  '  + 
			'                               <flightDate>  '  + 
			'                                   <departureDate>2017-07-05</departureDate>  '  + 
			'                               </flightDate>  '  + 
			'                               <boardPointDetails>  '  + 
			'                                   <trueLocnId>BKK</trueLocnId>  '  + 
			'                               </boardPointDetails>  '  + 
			'                               <offpointDetails>  '  + 
			'                                   <trueLocnId>HKG</trueLocnId>  '  + 
			'                               </offpointDetails>  '  + 
			'                               <companyDetails>  '  + 
			'                                   <marketingCompany>TG</marketingCompany>  '  + 
			'                               </companyDetails>  '  + 
			'                               <flightIdentification>  '  + 
			'                                   <flightNumber>628</flightNumber>  '  + 
			'                                   <bookingClass>X</bookingClass>  '  + 
			'                               </flightIdentification>  '  + 
			'                           </flightInfo>  '  + 
			'                       </productLevel>  '  + 
			'                       <secNumber>  '  + 
			'                           <referenceDetails>  '  + 
			'                               <type>4</type>  '  + 
			'                               <value>BKK-021</value>  '  + 
			'                           </referenceDetails>  '  + 
			'                       </secNumber>  '  + 
			'                       <legCabinCode>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>Y</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </legCabinCode>  '  + 
			'                       <dummy/>  '  + 
			'                       <bookedCabinCode>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>Y</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </bookedCabinCode>  '  + 
			'                       <ssrDetails>  '  + 
			'                           <specialRequirementsInfo>  '  + 
			'                               <ssrCode>SFML</ssrCode>  '  + 
			'                               <actionCode>HK</actionCode>  '  + 
			'                               <serviceType>S</serviceType>  '  + 
			'                           </specialRequirementsInfo>  '  + 
			'                       </ssrDetails>  '  + 
			'                       <seatInfo>  '  + 
			'                           <seatStatusInfo>  '  + 
			'                               <statusInfo>  '  + 
			'                                   <indicator>SS</indicator>  '  + 
			'                                   <action>GUA</action>  '  + 
			'                               </statusInfo>  '  + 
			'                           </seatStatusInfo>  '  + 
			'                           <seatNumberInfo>  '  + 
			'                               <seatDetails>  '  + 
			'                                   <seatNumber>041A</seatNumber>  '  + 
			'                               </seatDetails>  '  + 
			'                           </seatNumberInfo>  '  + 
			'                       </seatInfo>  '  + 
			'                       <fqtvDetails>  '  + 
			'                           <fqtvData>  '  + 
			'                               <frequentTravellerDetails>  '  + 
			'                                   <carrier>TG</carrier>  '  + 
			'                                   <number>ZD14713</number>  '  + 
			'                                   <status>A</status>  '  + 
			'                                   <tierLevel>SILV</tierLevel>  '  + 
			'                                   <tierDesc>SILVER</tierDesc>  '  + 
			'                               </frequentTravellerDetails>  '  + 
			'                               <frequentTravellerDetails>  '  + 
			'                                   <carrier>TG</carrier>  '  + 
			'                                   <number>ZD14713</number>  '  + 
			'                                   <status>A</status>  '  + 
			'                                   <tierLevel>S</tierLevel>  '  + 
			'                                   <tierDesc>S</tierDesc>  '  + 
			'                               </frequentTravellerDetails>  '  + 
			'                           </fqtvData>  '  + 
			'                       </fqtvDetails>  '  + 
			'                       <fqtvDetails>  '  + 
			'                           <fqtvData>  '  + 
			'                               <frequentTravellerDetails>  '  + 
			'                                   <carrier>TG</carrier>  '  + 
			'                                   <number>ZD14713</number>  '  + 
			'                                   <status>R</status>  '  + 
			'                                   <tierLevel>SILV</tierLevel>  '  + 
			'                                   <tierDesc>SILVER</tierDesc>  '  + 
			'                               </frequentTravellerDetails>  '  + 
			'                               <frequentTravellerDetails>  '  + 
			'                                   <carrier>TG</carrier>  '  + 
			'                                   <number>ZD14713</number>  '  + 
			'                                   <status>R</status>  '  + 
			'                                   <tierLevel>S</tierLevel>  '  + 
			'                                   <tierDesc>S</tierDesc>  '  + 
			'                               </frequentTravellerDetails>  '  + 
			'                           </fqtvData>  '  + 
			'                       </fqtvDetails>  '  + 
			'                       <dummySTX/>  '  + 
			'                       <dummySegment/>  '  + 
			'                       <dummy3/>  '  + 
			'                   </customerLevel>  '  + 
			'                   <customerLevel>  '  + 
			'                       <customerData>  '  + 
			'                           <paxDetails>  '  + 
			'                               <surname>GU</surname>  '  + 
			'                               <type>A</type>  '  + 
			'                               <gender>M</gender>  '  + 
			'                           </paxDetails>  '  + 
			'                           <otherPaxDetails>  '  + 
			'                               <givenName>YANMING</givenName>  '  + 
			'                               <title>MR</title>  '  + 
			'                           </otherPaxDetails>  '  + 
			'                       </customerData>  '  + 
			'                       <groupName>  '  + 
			'                           <freeTextQualification>  '  + 
			'                               <textSubjectQualifier>3</textSubjectQualifier>  '  + 
			'                               <language>EN</language>  '  + 
			'                           </freeTextQualification>  '  + 
			'                           <freeText>SUNPAC/TOURS</freeText>  '  + 
			'                       </groupName>  '  + 
			'                       <uniqueCustomerId>  '  + 
			'                           <idSection>  '  + 
			'                               <referenceQualifier>UCI</referenceQualifier>  '  + 
			'                               <primeId>3003493E000033A6</primeId>  '  + 
			'                           </idSection>  '  + 
			'                       </uniqueCustomerId>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CAS</indicator>  '  + 
			'                               <action>CAC</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>AAC</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CBS</indicator>  '  + 
			'                               <action>BED</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>EST</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CBG</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>IFT</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CHD</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>UMN</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>TST</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>API</indicator>  '  + 
			'                               <action>1</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>ODP</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>IFA</indicator>  '  + 
			'                               <action>1</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <boardingLocn>  '  + 
			'                           <LocnType>BRD</LocnType>  '  + 
			'                           <LocnDesc>  '  + 
			'                               <name>A/BKK/T//GTE/E1A</name>  '  + 
			'                           </LocnDesc>  '  + 
			'                       </boardingLocn>  '  + 
			'                       <paxDateTime>  '  + 
			'                           <businessSemantic>706</businessSemantic>  '  + 
			'                           <timeMode>LD</timeMode>  '  + 
			'                           <dateTime>1983-02-28T00:00:00</dateTime>  '  + 
			'                       </paxDateTime>  '  + 
			'                       <regulatoryInfo>  '  + 
			'                           <travelerDocuments>  '  + 
			'                               <issueDetails>  '  + 
			'                                   <documentCode>P</documentCode>  '  + 
			'                               </issueDetails>  '  + 
			'                               <travelerDocumentDetails>  '  + 
			'                                   <travelerDocumentId>G61153993</travelerDocumentId>  '  + 
			'                               </travelerDocumentDetails>  '  + 
			'                           </travelerDocuments>  '  + 
			'                           <documentIssuingCountry>  '  + 
			'                               <LocnType>180</LocnType>  '  + 
			'                               <LocnDesc><code>CHN</code></LocnDesc>  '  + 
			'                           </documentIssuingCountry>  '  + 
			'                           <regulatoryDataViewPermission>  '  + 
			'                               <statusInfo>  '  + 
			'                                   <indicator>VSP</indicator>  '  + 
			'                                   <action>N</action>  '  + 
			'                               </statusInfo>  '  + 
			'                           </regulatoryDataViewPermission>  '  + 
			'                           <PaxData>  '  + 
			'                               <paxDetails>  '  + 
			'                                   <surname>GU</surname>  '  + 
			'                                   <type>FL</type>  '  + 
			'                               </paxDetails>  '  + 
			'                               <otherPaxDetails>  '  + 
			'                                   <givenName>YANMING</givenName>  '  + 
			'                               </otherPaxDetails>  '  + 
			'                           </PaxData>  '  + 
			'                       </regulatoryInfo>  '  + 
			'                       <nationality>  '  + 
			'                           <codeQualifier>2</codeQualifier>  '  + 
			'                           <nationalityDetails>  '  + 
			'                               <nationalityCode>CHN</nationalityCode>  '  + 
			'                           </nationalityDetails>  '  + 
			'                       </nationality>  '  + 
			'                       <productLevel>  '  + 
			'                           <bookingData>  '  + 
			'                               <statusCode>HK</statusCode>  '  + 
			'                           </bookingData>  '  + 
			'                           <productID>  '  + 
			'                               <idSection>  '  + 
			'                                   <referenceQualifier>DID</referenceQualifier>  '  + 
			'                                   <primeId>2000993F000739A7</primeId>  '  + 
			'                               </idSection>  '  + 
			'                           </productID>  '  + 
			'                           <sbrRecordLocator>  '  + 
			'                               <reservation>  '  + 
			'                                   <controlNumber>6VFG8G</controlNumber>  '  + 
			'                               </reservation>  '  + 
			'                           </sbrRecordLocator>  '  + 
			'                           <flightInfo>  '  + 
			'                               <flightDate>  '  + 
			'                                   <departureDate>2017-07-05</departureDate>  '  + 
			'                               </flightDate>  '  + 
			'                               <boardPointDetails>  '  + 
			'                                   <trueLocnId>BKK</trueLocnId>  '  + 
			'                               </boardPointDetails>  '  + 
			'                               <offpointDetails>  '  + 
			'                                   <trueLocnId>HKG</trueLocnId>  '  + 
			'                               </offpointDetails>  '  + 
			'                               <companyDetails>  '  + 
			'                                   <marketingCompany>TG</marketingCompany>  '  + 
			'                               </companyDetails>  '  + 
			'                               <flightIdentification>  '  + 
			'                                   <flightNumber>628</flightNumber>  '  + 
			'                                   <bookingClass>G</bookingClass>  '  + 
			'                               </flightIdentification>  '  + 
			'                           </flightInfo>  '  + 
			'                       </productLevel>  '  + 
			'                       <secNumber>  '  + 
			'                           <referenceDetails>  '  + 
			'                               <type>4</type>  '  + 
			'                               <value>BKK-090</value>  '  + 
			'                           </referenceDetails>  '  + 
			'                       </secNumber>  '  + 
			'                       <legCabinCode>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>Y</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </legCabinCode>  '  + 
			'                       <dummy/>  '  + 
			'                       <bookedCabinCode>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>Y</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </bookedCabinCode>  '  + 
			'                       <ssrDetails>  '  + 
			'                           <specialRequirementsInfo>  '  + 
			'                               <ssrCode>CKIN</ssrCode>  '  + 
			'                               <serviceType>S</serviceType>  '  + 
			'                               <serviceFreeText>INFT ETKNO 217-5604791523</serviceFreeText>  '  + 
			'                           </specialRequirementsInfo>  '  + 
			'                       </ssrDetails>  '  + 
			'                       <ssrDetails>  '  + 
			'                           <specialRequirementsInfo>  '  + 
			'                               <ssrCode>INFT</ssrCode>  '  + 
			'                               <actionCode>HK</actionCode>  '  + 
			'                               <serviceType>S</serviceType>  '  + 
			'                               <serviceFreeText>1GU/ZHENYU MSTR/17AUG15</serviceFreeText>  '  + 
			'                           </specialRequirementsInfo>  '  + 
			'                       </ssrDetails>  '  + 
			'                       <seatInfo>  '  + 
			'                           <seatStatusInfo>  '  + 
			'                               <statusInfo>  '  + 
			'                                   <indicator>SS</indicator>  '  + 
			'                                   <action>GUA</action>  '  + 
			'                               </statusInfo>  '  + 
			'                           </seatStatusInfo>  '  + 
			'                           <seatNumberInfo>  '  + 
			'                               <seatDetails>  '  + 
			'                                   <seatNumber>061D</seatNumber>  '  + 
			'                               </seatDetails>  '  + 
			'                           </seatNumberInfo>  '  + 
			'                       </seatInfo>  '  + 
			'                       <dummySTX/>  '  + 
			'                       <dummySegment/>  '  + 
			'                       <dummy3/>  '  + 
			'                   </customerLevel>  '  + 
			'   				<customerLevel>  '  + 
			'                       <customerData>  '  + 
			'                           <paxDetails>  '  + 
			'                               <surname>GU</surname>  '  + 
			'                               <type>IN</type>  '  + 
			'                               <gender>M</gender>  '  + 
			'                           </paxDetails>  '  + 
			'                           <otherPaxDetails>  '  + 
			'                               <givenName>ZHENYU</givenName>  '  + 
			'                               <title>MSTR</title>  '  + 
			'                           </otherPaxDetails>  '  + 
			'                       </customerData>  '  + 
			'                       <groupName>  '  + 
			'                           <freeTextQualification>  '  + 
			'                               <textSubjectQualifier>3</textSubjectQualifier>  '  + 
			'                               <language>EN</language>  '  + 
			'                           </freeTextQualification>  '  + 
			'                           <freeText>SUNPAC/TOURS</freeText>  '  + 
			'                       </groupName>  '  + 
			'                       <uniqueCustomerId>  '  + 
			'                           <idSection>  '  + 
			'                               <referenceQualifier>UCI</referenceQualifier>  '  + 
			'                               <primeId>10D2E20000F8B704</primeId>  '  + 
			'                           </idSection>  '  + 
			'                       </uniqueCustomerId>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CAS</indicator>  '  + 
			'                               <action>CAC</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>AAC</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CBS</indicator>  '  + 
			'                               <action>BED</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  ';
		response += '' + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>EST</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CBG</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>IFT</indicator>  '  + 
			'                               <action>1</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CHD</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>UMN</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>TST</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>API</indicator>  '  + 
			'                               <action>1</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>ODP</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <boardingLocn>  '  + 
			'                           <LocnType>BRD</LocnType>  '  + 
			'                           <LocnDesc>  '  + 
			'                               <name>A/BKK/T//GTE/E1A</name>  '  + 
			'                           </LocnDesc>  '  + 
			'                       </boardingLocn>  '  + 
			'                       <paxDateTime>  '  + 
			'                           <businessSemantic>706</businessSemantic>  '  + 
			'                           <timeMode>LD</timeMode>  '  + 
			'                           <dateTime>2015-08-17T00:00:00</dateTime>  '  + 
			'                       </paxDateTime>  '  + 
			'                       <regulatoryInfo>  '  + 
			'                           <travelerDocuments>  '  + 
			'                               <issueDetails>  '  + 
			'                                   <documentCode>P</documentCode>  '  + 
			'                               </issueDetails>  '  + 
			'                               <travelerDocumentDetails>  '  + 
			'                                   <travelerDocumentId>E84690906</travelerDocumentId>  '  + 
			'                               </travelerDocumentDetails>  '  + 
			'                           </travelerDocuments>  '  + 
			'                           <documentIssuingCountry>  '  + 
			'                               <LocnType>180</LocnType>  '  + 
			'                               <LocnDesc><code>CHN</code></LocnDesc>  '  + 
			'                           </documentIssuingCountry>  '  + 
			'                           <regulatoryDataViewPermission>  '  + 
			'                               <statusInfo>  '  + 
			'                                   <indicator>VSP</indicator>  '  + 
			'                                   <action>N</action>  '  + 
			'                               </statusInfo>  '  + 
			'                           </regulatoryDataViewPermission>  '  + 
			'                           <PaxData>  '  + 
			'                               <paxDetails>  '  + 
			'                                   <surname>GU</surname>  '  + 
			'                                   <type>FL</type>  '  + 
			'                               </paxDetails>  '  + 
			'                               <otherPaxDetails>  '  + 
			'                                   <givenName>ZHENYU</givenName>  '  + 
			'                               </otherPaxDetails>  '  + 
			'                           </PaxData>  '  + 
			'                       </regulatoryInfo>  '  + 
			'                       <nationality>  '  + 
			'                           <codeQualifier>2</codeQualifier>  '  + 
			'                           <nationalityDetails>  '  + 
			'                               <nationalityCode>CHN</nationalityCode>  '  + 
			'                           </nationalityDetails>  '  + 
			'                       </nationality>  '  + 
			'                       <productLevel>  '  + 
			'                           <bookingData>  '  + 
			'                               <statusCode>HK</statusCode>  '  + 
			'                           </bookingData>  '  + 
			'                           <productID>  '  + 
			'                               <idSection>  '  + 
			'                                   <referenceQualifier>DID</referenceQualifier>  '  + 
			'                                   <primeId>10D2E200011E7A98</primeId>  '  + 
			'                               </idSection>  '  + 
			'                           </productID>  '  + 
			'                           <sbrRecordLocator>  '  + 
			'                               <reservation>  '  + 
			'                                   <controlNumber>6VFG8G</controlNumber>  '  + 
			'                               </reservation>  '  + 
			'                           </sbrRecordLocator>  '  + 
			'                           <flightInfo>  '  + 
			'                               <flightDate>  '  + 
			'                                   <departureDate>2017-07-05</departureDate>  '  + 
			'                               </flightDate>  '  + 
			'                               <boardPointDetails>  '  + 
			'                                   <trueLocnId>BKK</trueLocnId>  '  + 
			'                               </boardPointDetails>  '  + 
			'                               <offpointDetails>  '  + 
			'                                   <trueLocnId>HKG</trueLocnId>  '  + 
			'                               </offpointDetails>  '  + 
			'                               <companyDetails>  '  + 
			'                                   <marketingCompany>TG</marketingCompany>  '  + 
			'                               </companyDetails>  '  + 
			'                               <flightIdentification>  '  + 
			'                                   <flightNumber>628</flightNumber>  '  + 
			'                                   <bookingClass>G</bookingClass>  '  + 
			'                               </flightIdentification>  '  + 
			'                           </flightInfo>  '  + 
			'                       </productLevel>  '  + 
			'                       <secNumber>  '  + 
			'                           <referenceDetails>  '  + 
			'                               <type>4</type>  '  + 
			'                               <value>BKK-091</value>  '  + 
			'                           </referenceDetails>  '  + 
			'                       </secNumber>  '  + 
			'                       <legCabinCode>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>Y</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </legCabinCode>  '  + 
			'                       <dummy/>  '  + 
			'                       <bookedCabinCode>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>Y</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </bookedCabinCode>  '  + 
			'                       <dummySTX/>  '  + 
			'                       <dummySegment/>  '  + 
			'                       <dummy3/>  '  + 
			'                  </customerLevel>  ' +
			'                   <customerLevel>  '  + 
			'                       <customerData>  '  + 
			'                           <paxDetails>  '  + 
			'                               <surname>DUMKHUNTOD</surname>  '  + 
			'                               <type>A</type>  '  + 
			'                               <gender>F</gender>  '  + 
			'                           </paxDetails>  '  + 
			'                           <otherPaxDetails>  '  + 
			'                               <givenName>KANCHANA</givenName>  '  + 
			'                               <title>MRS</title>  '  + 
			'                           </otherPaxDetails>  '  + 
			'                       </customerData>  '  + 
			'                       <uniqueCustomerId>  '  + 
			'                           <idSection>  '  + 
			'                               <referenceQualifier>UCI</referenceQualifier>  '  + 
			'                               <primeId>2002399B00033B3C</primeId>  '  + 
			'                           </idSection>  '  + 
			'                       </uniqueCustomerId>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CAS</indicator>  '  + 
			'                               <action>CAC</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>AAC</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CBS</indicator>  '  + 
			'                               <action>BED</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>EST</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CBG</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>IFT</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CHD</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>UMN</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>TST</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>API</indicator>  '  + 
			'                               <action>1</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>ODP</indicator>  '  + 
			'                               <action>1</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <boardingLocn>  '  + 
			'                           <LocnType>BRD</LocnType>  '  + 
			'                           <LocnDesc>  '  + 
			'                               <name>A/BKK/T//GTE/E1A</name>  '  + 
			'                           </LocnDesc>  '  + 
			'                       </boardingLocn>  '  + 
			'                       <paxDateTime>  '  + 
			'                           <businessSemantic>706</businessSemantic>  '  + 
			'                           <timeMode>LD</timeMode>  '  + 
			'                           <dateTime>1977-10-07T00:00:00</dateTime>  '  + 
			'                       </paxDateTime>  '  + 
			'                       <regulatoryInfo>  '  + 
			'                           <travelerDocuments>  '  + 
			'                               <issueDetails>  '  + 
			'                                   <documentCode>P</documentCode>  '  + 
			'                               </issueDetails>  '  + 
			'                               <travelerDocumentDetails>  '  + 
			'                                   <travelerDocumentId>AA7241832</travelerDocumentId>  '  + 
			'                               </travelerDocumentDetails>  '  + 
			'                           </travelerDocuments>  '  + 
			'                           <documentIssuingCountry>  '  + 
			'                               <LocnType>180</LocnType>  '  + 
			'                               <LocnDesc><code>THA</code></LocnDesc>  '  + 
			'                           </documentIssuingCountry>  '  + 
			'                           <regulatoryDataViewPermission>  '  + 
			'                               <statusInfo>  '  + 
			'                                   <indicator>VSP</indicator>  '  + 
			'                                   <action>N</action>  '  + 
			'                               </statusInfo>  '  + 
			'                           </regulatoryDataViewPermission>  '  + 
			'                           <PaxData>  '  + 
			'                               <paxDetails>  '  + 
			'                                   <surname>DUMKHUNTOD</surname>  '  + 
			'                                   <type>FL</type>  '  + 
			'                               </paxDetails>  '  + 
			'                               <otherPaxDetails>  '  + 
			'                                   <givenName>KANCHANA</givenName>  '  + 
			'                               </otherPaxDetails>  '  + 
			'                           </PaxData>  '  + 
			'                       </regulatoryInfo>  '  + 
			'                       <nationality>  '  + 
			'                           <codeQualifier>2</codeQualifier>  '  + 
			'                           <nationalityDetails>  '  + 
			'                               <nationalityCode>THA</nationalityCode>  '  + 
			'                           </nationalityDetails>  '  + 
			'                       </nationality>  '  + 
			'                       <productLevel>  '  + 
			'                           <bookingData>  '  + 
			'                               <statusCode>HK</statusCode>  '  + 
			'                           </bookingData>  '  + 
			'                           <productID>  '  + 
			'                               <idSection>  '  + 
			'                                   <referenceQualifier>DID</referenceQualifier>  '  + 
			'                                   <primeId>2000699B001F7107</primeId>  '  + 
			'                               </idSection>  '  + 
			'                           </productID>  '  + 
			'                           <sbrRecordLocator>  '  + 
			'                               <reservation>  '  + 
			'                                   <controlNumber>WADATV</controlNumber>  '  + 
			'                               </reservation>  '  + 
			'                           </sbrRecordLocator>  '  + 
			'                           <flightInfo>  '  + 
			'                               <flightDate>  '  + 
			'                                   <departureDate>2017-07-05</departureDate>  '  + 
			'                               </flightDate>  '  + 
			'                               <boardPointDetails>  '  + 
			'                                   <trueLocnId>BKK</trueLocnId>  '  + 
			'                               </boardPointDetails>  '  + 
			'                               <offpointDetails>  '  + 
			'                                   <trueLocnId>HKG</trueLocnId>  '  + 
			'                               </offpointDetails>  '  + 
			'                               <companyDetails>  '  + 
			'                                   <marketingCompany>TG</marketingCompany>  '  + 
			'                               </companyDetails>  '  + 
			'                               <flightIdentification>  '  + 
			'                                   <flightNumber>628</flightNumber>  '  + 
			'                                   <bookingClass>K</bookingClass>  '  + 
			'                               </flightIdentification>  '  + 
			'                           </flightInfo>  '  + 
			'                       </productLevel>  '  + 
			'                       <secNumber>  '  + 
			'                           <referenceDetails>  '  + 
			'                               <type>4</type>  '  + 
			'                               <value>BKK-169</value>  '  + 
			'                           </referenceDetails>  '  + 
			'                       </secNumber>  '  + 
			'                       <otherFlightInfo>  '  + 
			'                           <otherFlightData>  '  + 
			'                               <flightDate>  '  + 
			'                                   <departureDate>2017-07-05</departureDate>  '  + 
			'                               </flightDate>  '  + 
			'                               <boardPointDetails>  '  + 
			'                                   <trueLocnId>HKG</trueLocnId>  '  + 
			'                               </boardPointDetails>  '  + 
			'                               <offpointDetails>  '  + 
			'                                   <trueLocnId>BKK</trueLocnId>  '  + 
			'                               </offpointDetails>  '  + 
			'                               <companyDetails>  '  + 
			'                                   <marketingCompany>TG</marketingCompany>  '  + 
			'                               </companyDetails>  '  + 
			'                               <flightIdentification>  '  + 
			'                                   <flightNumber>607</flightNumber>  '  + 
			'                                   <bookingClass>K</bookingClass>  '  + 
			'                               </flightIdentification>  '  + 
			'                           </otherFlightData>  '  + 
			'                           <flightTypeIndicator>  '  + 
			'                               <statusInfo>  '  + 
			'                                   <indicator>FIT</indicator>  '  + 
			'                                   <action>OFL</action>  '  + 
			'                               </statusInfo>  '  + 
			'                           </flightTypeIndicator>  '  + 
			'                           <acceptanceStatus>  '  + 
			'                               <statusInfo>  '  + 
			'                                   <indicator>CAS</indicator>  '  + 
			'                                   <action>CAC</action>  '  + 
			'                               </statusInfo>  '  + 
			'                           </acceptanceStatus>  '  + 
			'                           <operatingDetails>  '  + 
			'                               <companyDetails>  '  + 
			'                                   <operatingCompany>TG</operatingCompany>  '  + 
			'                               </companyDetails>  '  + 
			'                               <flightIdentification>  '  + 
			'                                   <flightNumber>607</flightNumber>  '  + 
			'                               </flightIdentification>  '  + 
			'                           </operatingDetails>  '  + 
			'                           <cabinData>  '  + 
			'                               <cabinDetails>  '  + 
			'                                   <classDesignator>Y</classDesignator>  '  + 
			'                               </cabinDetails>  '  + 
			'                           </cabinData>  '  + 
			'                           <timeData>  '  + 
			'                               <businessSemantic>STD</businessSemantic>  '  + 
			'                               <timeMode>LT</timeMode>  '  + 
			'                               <dateTime>2017-07-05T20:45:00</dateTime>  '  + 
			'                           </timeData>  '  + 
			'                           <timeData>  '  + 
			'                               <businessSemantic>ATD</businessSemantic>  '  + 
			'                               <timeMode>LT</timeMode>  '  + 
			'                               <dateTime>2017-07-05T20:55:00</dateTime>  '  + 
			'                           </timeData>  '  + 
			'                           <timeData>  '  + 
			'                               <businessSemantic>STA</businessSemantic>  '  + 
			'                               <timeMode>LT</timeMode>  '  + 
			'                               <dateTime>2017-07-05T22:25:00</dateTime>  '  + 
			'                           </timeData>  '  + 
			'                           <timeData>  '  + 
			'                               <businessSemantic>ATA</businessSemantic>  '  + 
			'                               <timeMode>LT</timeMode>  '  + 
			'                               <dateTime>2017-07-05T23:03:00</dateTime>  '  + 
			'                           </timeData>  '  + 
			'                           <timeData>  '  + 
			'                               <businessSemantic>ETA</businessSemantic>  '  + 
			'                               <timeMode>LT</timeMode>  '  + 
			'                               <dateTime>2017-07-05T22:54:00</dateTime>  '  + 
			'                           </timeData>  '  + 
			'                           <timeData>  '  + 
			'                               <businessSemantic>BOT</businessSemantic>  '  + 
			'                               <timeMode>LT</timeMode>  '  + 
			'                               <dateTime>2017-07-05T20:05:00</dateTime>  '  + 
			'                           </timeData>  '  + 
			'                       </otherFlightInfo>  '  + 
			'                       <legCabinCode>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>Y</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </legCabinCode>  '  + 
			'                       <dummy/>  '  + 
			'                       <bookedCabinCode>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>Y</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </bookedCabinCode>  '  + 
			'                       <seatInfo>  '  + 
			'                           <seatStatusInfo>  '  + 
			'                               <statusInfo>  '  + 
			'                                   <indicator>SS</indicator>  '  + 
			'                                   <action>GUA</action>  '  + 
			'                               </statusInfo>  '  + 
			'                           </seatStatusInfo>  '  + 
			'                           <seatNumberInfo>  '  + 
			'                               <seatDetails>  '  + 
			'                                   <seatNumber>039K</seatNumber>  '  + 
			'                               </seatDetails>  '  + 
			'                           </seatNumberInfo>  '  + 
			'                       </seatInfo>  '  + 
			'                       <fqtvDetails>  '  + 
			'                           <fqtvData>  '  + 
			'                               <frequentTravellerDetails>  '  + 
			'                                   <carrier>TG</carrier>  '  + 
			'                                   <number>GM44817</number>  '  + 
			'                                   <status>A</status>  '  + 
			'                                   <tierLevel>BASE</tierLevel>  '  + 
			'                                   <tierDesc>BASE</tierDesc>  '  + 
			'                               </frequentTravellerDetails>  '  + 
			'                               <frequentTravellerDetails>  '  + 
			'                                   <carrier>TG</carrier>  '  + 
			'                                   <number>GM44817</number>  '  + 
			'                                   <status>A</status>  '  + 
			'                               </frequentTravellerDetails>  '  + 
			'                           </fqtvData>  '  + 
			'                       </fqtvDetails>  '  + 
			'                       <dummySTX/>  '  + 
			'                       <dummySegment/>  '  + 
			'                       <dummy3/>  '  + 
			'                   </customerLevel>  '  + 
			'                   <customerLevel>  '  + 
			'                       <customerData>  '  + 
			'                           <paxDetails>  '  + 
			'                               <surname>DAORUANG</surname>  '  + 
			'                               <type>A</type>  '  + 
			'                               <gender>M</gender>  '  + 
			'                           </paxDetails>  '  + 
			'                           <otherPaxDetails>  '  + 
			'                               <givenName>EKKATHAT</givenName>  '  + 
			'                               <title>MR</title>  '  + 
			'                           </otherPaxDetails>  '  + 
			'                       </customerData>  '  + 
			'                       <uniqueCustomerId>  '  + 
			'                           <idSection>  '  + 
			'                               <referenceQualifier>UCI</referenceQualifier>  '  + 
			'                               <primeId>20021997000234FA</primeId>  '  + 
			'                           </idSection>  '  + 
			'                       </uniqueCustomerId>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CAS</indicator>  '  + 
			'                               <action>CAC</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>AAC</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CBS</indicator>  '  + 
			'                               <action>BED</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>EST</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CBG</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>IFT</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>CHD</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>UMN</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>TST</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>API</indicator>  '  + 
			'                               <action>1</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <customerStatus>  '  + 
			'                           <statusInfo>  '  + 
			'                               <indicator>ODP</indicator>  '  + 
			'                               <action>0</action>  '  + 
			'                           </statusInfo>  '  + 
			'                       </customerStatus>  '  + 
			'                       <boardingLocn>  '  + 
			'                           <LocnType>BRD</LocnType>  '  + 
			'                           <LocnDesc>  '  + 
			'                               <name>A/BKK/T//GTE/E1A</name>  '  + 
			'                           </LocnDesc>  '  + 
			'                       </boardingLocn>  '  + 
			'                       <paxDateTime>  '  + 
			'                           <businessSemantic>706</businessSemantic>  '  + 
			'                           <timeMode>LD</timeMode>  '  + 
			'                           <dateTime>1978-10-13T00:00:00</dateTime>  '  + 
			'                       </paxDateTime>  '  + 
			'                       <regulatoryInfo>  '  + 
			'                           <travelerDocuments>  '  + 
			'                               <issueDetails>  '  + 
			'                                   <documentCode>P</documentCode>  '  + 
			'                               </issueDetails>  '  + 
			'                               <travelerDocumentDetails>  '  + 
			'                                   <travelerDocumentId>AA5533669</travelerDocumentId>  '  + 
			'                               </travelerDocumentDetails>  '  + 
			'                           </travelerDocuments>  '  + 
			'                           <documentIssuingCountry>  '  + 
			'                               <LocnType>180</LocnType>  '  + 
			'                               <LocnDesc><code>THA</code></LocnDesc>  '  + 
			'                           </documentIssuingCountry>  '  + 
			'                           <regulatoryDataViewPermission>  '  + 
			'                               <statusInfo>  '  + 
			'                                   <indicator>VSP</indicator>  '  + 
			'                                   <action>N</action>  '  + 
			'                               </statusInfo>  '  + 
			'                           </regulatoryDataViewPermission>  '  + 
			'                           <PaxData>  '  + 
			'                               <paxDetails>  '  + 
			'                                   <surname>DAORUANG</surname>  '  + 
			'                                   <type>FL</type>  '  + 
			'                               </paxDetails>  '  + 
			'                               <otherPaxDetails>  '  + 
			'                                   <givenName>EKKATHAT</givenName>  '  + 
			'                               </otherPaxDetails>  '  + 
			'                           </PaxData>  '  + 
			'                       </regulatoryInfo>  '  + 
			'                       <nationality>  '  + 
			'                           <codeQualifier>2</codeQualifier>  '  + 
			'                           <nationalityDetails>  '  + 
			'                               <nationalityCode>THA</nationalityCode>  '  + 
			'                           </nationalityDetails>  '  + 
			'                       </nationality>  '  + 
			'                       <productLevel>  '  + 
			'                           <bookingData>  '  + 
			'                               <statusCode>HK</statusCode>  '  + 
			'                           </bookingData>  '  + 
			'                           <productID>  '  + 
			'                               <idSection>  '  + 
			'                                   <referenceQualifier>DID</referenceQualifier>  '  + 
			'                                   <primeId>2002F9970015483F</primeId>  '  + 
			'                               </idSection>  '  + 
			'                           </productID>  '  + 
			'                           <sbrRecordLocator>  '  + 
			'                               <reservation>  '  + 
			'                                   <controlNumber>OEFICL</controlNumber>  '  + 
			'                               </reservation>  '  + 
			'                           </sbrRecordLocator>  '  + 
			'                           <flightInfo>  '  + 
			'                               <flightDate>  '  + 
			'                                   <departureDate>2017-07-05</departureDate>  '  + 
			'                               </flightDate>  '  + 
			'                               <boardPointDetails>  '  + 
			'                                   <trueLocnId>BKK</trueLocnId>  '  + 
			'                               </boardPointDetails>  '  + 
			'                               <offpointDetails>  '  + 
			'                                   <trueLocnId>HKG</trueLocnId>  '  + 
			'                               </offpointDetails>  '  + 
			'                               <companyDetails>  '  + 
			'                                   <marketingCompany>TG</marketingCompany>  '  + 
			'                               </companyDetails>  '  + 
			'                               <flightIdentification>  '  + 
			'                                   <flightNumber>628</flightNumber>  '  + 
			'                                   <bookingClass>X</bookingClass>  '  + 
			'                               </flightIdentification>  '  + 
			'                           </flightInfo>  '  + 
			'                       </productLevel>  '  + 
			'                       <secNumber>  '  + 
			'                           <referenceDetails>  '  + 
			'                               <type>4</type>  '  + 
			'                               <value>BKK-133</value>  '  + 
			'                           </referenceDetails>  '  + 
			'                       </secNumber>  '  + 
			'                       <legCabinCode>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>Y</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </legCabinCode>  '  + 
			'                       <dummy/>  '  + 
			'                       <bookedCabinCode>  '  + 
			'                           <cabinDetails>  '  + 
			'                               <classDesignator>Y</classDesignator>  '  + 
			'                           </cabinDetails>  '  + 
			'                       </bookedCabinCode>  '  + 
			'                       <ssrDetails>  '  + 
			'                           <specialRequirementsInfo>  '  + 
			'                               <ssrCode>SPML</ssrCode>  '  + 
			'                               <actionCode>HK</actionCode>  '  + 
			'                               <serviceType>S</serviceType>  '  + 
			'                               <serviceFreeText>ALLERGY TO SEAFOOD</serviceFreeText>  '  + 
			'                           </specialRequirementsInfo>  '  + 
			'                       </ssrDetails>  '  + 
			'                       <seatInfo>  '  + 
			'                           <seatStatusInfo>  '  + 
			'                               <statusInfo>  '  + 
			'                                   <indicator>SS</indicator>  '  + 
			'                                   <action>GUA</action>  '  + 
			'                               </statusInfo>  '  + 
			'                           </seatStatusInfo>  '  + 
			'                           <seatNumberInfo>  '  + 
			'                               <seatDetails>  '  + 
			'                                   <seatNumber>033J</seatNumber>  '  + 
			'                               </seatDetails>  '  + 
			'                           </seatNumberInfo>  '  + 
			'                       </seatInfo>  '  + 
			'                       <fqtvDetails>  '  + 
			'                           <fqtvData>  '  + 
			'                               <frequentTravellerDetails>  '  + 
			'                                   <carrier>TG</carrier>  '  + 
			'                                   <number>QB08413</number>  '  + 
			'                                   <status>R</status>  '  + 
			'                               </frequentTravellerDetails>  '  + 
			'                               <frequentTravellerDetails>  '  + 
			'                                   <carrier>TG</carrier>  '  + 
			'                                   <number>QB08413</number>  '  + 
			'                                   <status>R</status>  '  + 
			'                               </frequentTravellerDetails>  '  + 
			'                           </fqtvData>  '  + 
			'                       </fqtvDetails>  '  + 
			'                       <dummySTX/>  '  + 
			'                       <dummySegment/>  '  + 
			'                       <dummy3/>  '  + 
			'                   </customerLevel>  '  + 
			'               </flightDetailsGroup>  '  + 
			'           </ns0:GetPaxListByFlightRes>  '  + 
			'       </SOAP-ENV:Body>  '  + 
			'   </SOAP-ENV:Envelope>  '  + 
			'    ' ; 
		 return response;
	}

	public static String getDCSPaxErrorResponse(){
		String response = '' +
			'   <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">  '  + 
			'       <SOAP-ENV:Body>  '  + 
			'           <SOAP-ENV:Fault>  '  + 
			'               <faultcode>SOAP-ENV:Server</faultcode>  '  + 
			'               <faultstring>Internal Error</faultstring>  '  + 
			'               <faultactor>PROVIDER</faultactor>  '  + 
			'               <detail>  '  + 
			'                   <mwerror:ErrList xmlns:mwerror="http://xml.accenture.com/common/fault" xmlns:tns="http://ws.thaiairways.com/dcs/listing/pax">  '  + 
			'                       <mwerror:Err>  '  + 
			'                           <mwerror:ErrCat>40</mwerror:ErrCat>  '  + 
			'                           <mwerror:ErrCatDesc>Application Errors</mwerror:ErrCatDesc>  '  + 
			'                           <mwerror:ErrCode>14000</mwerror:ErrCode>  '  + 
			'                           <mwerror:ErrDesc>Invalid flight details.</mwerror:ErrDesc>  '  + 
			'                           <mwerror:ErrSev>Severity-3</mwerror:ErrSev>  '  + 
			'                           <mwerror:ErrSrc>FB_SICSE_DCS</mwerror:ErrSrc>  '  + 
			'                           <mwerror:ErrTgt>Altea</mwerror:ErrTgt>  '  + 
			'                           <mwerror:ErrDateTime>2017-06-07T17:25:31.267+07:00</mwerror:ErrDateTime>  '  + 
			'                           <mwerror:ErrDetail/>  '  + 
			'                           <mwerror:MWErrDetails>  '  + 
			'                               <mwerror:ErrHeader>  '  + 
			'                                   <mwerror:ServiceProvider>Altea</mwerror:ServiceProvider>  '  + 
			'                                   <mwerror:MWTxnID>SY_TGAIP_1496831130607</mwerror:MWTxnID>  '  + 
			'                                   <mwerror:ReqTxnID>SFDC_SICSE20170607-172529</mwerror:ReqTxnID>  '  + 
			'                                   <mwerror:ReqID>FB_SICSE_DCS</mwerror:ReqID>  '  + 
			'                                   <mwerror:MWProcess>ServiceImplementation/ws.thaiairways.com/DCS/Listing/Pax/Operations/GetPaxListByFlight.process</mwerror:MWProcess>  '  + 
			'                                   <mwerror:MWActivity>AppError - Fault</mwerror:MWActivity>  '  + 
			'                               </mwerror:ErrHeader>  '  + 
			'                           </mwerror:MWErrDetails>  '  + 
			'                       </mwerror:Err>  '  + 
			'                   </mwerror:ErrList>  '  + 
			'               </detail>  '  + 
			'           </SOAP-ENV:Fault>  '  + 
			'       </SOAP-ENV:Body>  '  + 
			'   </SOAP-ENV:Envelope>  '  + 
			'    ';
		return response;
	}
	
}