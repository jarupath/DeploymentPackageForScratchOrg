public with sharing class LOPAService {

	@TestVisible private static final Integer VERTICAL_SEARCH = 0;
	@TestVisible private static final Integer HORIZONTAL_SEARCH = 1;

	// Assigning the col number
	// L L LC LC C C C RC RC R R
	// L L LC LC C C RC RC R R
	// L L LC C C RC R R

	// For the x, I just cheated. The code will not detect that column and move the LC to the next one which should be the right one.
	// By observation, for 12 maxCol, there is nothing in that column.
	static Map<Integer, List<String>> rowStructureMap = new Map<Integer, List<String>> {
		12 => new List<String>{'L', 'L', 'L', 'x', 'LC', 'C', 'C', 'RC', 'x', 'R', 'R', 'R'},
		11 => new List<String>{'L', 'L', 'LC', 'LC', 'C', 'C', 'C', 'RC', 'RC', 'R', 'R'},
		10 => new List<String>{'L', 'L', 'LC', 'LC', 'C', 'C', 'RC', 'RC', 'R', 'R'},
		9 => new List<String>{'L', 'L', 'LC', 'LC', 'C', 'RC', 'RC', 'R', 'R'},
		8 => new List<String>{'L', 'L', 'LC', 'C', 'C', 'RC', 'R', 'R'},
		7 => new List<String>{'L', 'L', 'LC', 'C', 'RC', 'R', 'R'},
		6 => new List<String>{'L', 'LC', 'C', 'C', 'RC', 'R'},
		5 => new List<String>{'L', 'LC', 'C', 'RC', 'R'}
	};

	private class CabinZone {
		Integer lopaId;
		Integer cabinZoneNumber;
		TG_LOPA_Req.cabin_element cabin;
		List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> frontCabinFacilitySeatResponseModelList;
		Integer startingRowNumber;
		String travelClass;
		String floor;
		Integer startRange;
		Integer endRange;
		Map<String, Integer> columnNumberMap;
		Set<Integer> aisleSeatSet;
		Integer maxColumn;

		public CabinZone(Integer lopaId, Integer cabinZoneNumber, TG_LOPA_Req.cabin_element cabin) {
			this.lopaId = lopaId;
			this.cabinZoneNumber = cabinZoneNumber;
			this.cabin = cabin;
			travelClass = cabin.compartmentDetails.classDetails.classDesignator;
			floor = BE8_GlobalConstants.FLOOR_MAP.get(cabin.compartmentDetails.cabinZoneCode);
			startRange = Integer.valueOf(cabin.compartmentDetails.seatRowRange.number_x[0]);
			endRange = Integer.valueOf(cabin.compartmentDetails.seatRowRange.number_x[1]);
		}
	}

	public static String getMasterLOPAJSONString(Map<String, TG_LOPA_Req.GetSeatMapRes> lopaRawModelMap, Flight__c flight) {
		MB_RestResponseInfoModel.lopaInfo_model lopaResponseModel = getMasterLOPAModel(lopaRawModelMap, flight);
		if (lopaResponseModel != null && lopaResponseModel.lopaPos != null && lopaResponseModel.lopaPos.size() > 0 && lopaResponseModel.maxRow != '0') {
			return System.JSON.serialize(lopaResponseModel);
		} else {
			return null;
		}
	}

	public static MB_RestResponseInfoModel.lopaInfo_model getMasterLOPAModel(Map<String, TG_LOPA_Req.GetSeatMapRes> lopaRawModelMap, Flight__c flight) {
		flight = [SELECT Id, Cabin_Version__c FROM Flight__c WHERE Id =: flight.Id];
		System.debug('############flight.Cabin_Version__c ' + flight.Cabin_Version__c);
		LOPALabelRepository lopaLabelRepo = new LOPALabelRepository(flight.Cabin_Version__c);
		List<CabinZone> cabinZoneList = getCabinZoneList(lopaRawModelMap);
		//System.debug('lopaRawModelMap ' + lopaRawModelMap);

		MB_RestResponseInfoModel.lopaInfo_model lopaResponseModel = new MB_RestResponseInfoModel.lopaInfo_model();
		lopaResponseModel.lopaPos = new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>();

		for (TG_LOPA_Req.GetSeatMapRes rawModel : lopaRawModelMap.values()) {
			if (rawModel != null) {
				TG_LOPA_Req.seatmapInfo_element lopaModel = rawModel.seatmapInfo[0];
				List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> seatMatrix = getAllSeatResponseModelList(lopaModel.row, cabinZoneList);
				seatMatrix = consolidateSeat(seatMatrix);
				for (List<MB_RestResponseInfoModel.lopaInfo_lopaPos> eachRow : seatMatrix) {
					for(MB_RestResponseInfoModel.lopaInfo_lopaPos eachColumn : eachRow){
						String lopaLabel = lopaLabelRepo.getActualLabelFromTempLabel(eachColumn.pos);
						if(lopaLabel != null){
							System.debug('lopaLabel: ' + lopaLabel);
							eachColumn.pos = lopaLabel;
						}
					}
				}
				lopaResponseModel.lopaPos.addAll(removeFalseFlagLOPAPos(seatMatrix));
			}
		}
		lopaResponseModel.maxRow = '' + lopaResponseModel.lopaPos.size();
		return lopaResponseModel;
	}

	@TestVisible
	private static List<MB_RestResponseInfoModel.lopaInfo_lopaPos> removeFalseFlagLOPAPos(List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> seatMatrix) {
		List<MB_RestResponseInfoModel.lopaInfo_lopaPos> posList = new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>();
		for (List<MB_RestResponseInfoModel.lopaInfo_lopaPos> row : seatMatrix) {
			Integer colIndex = 0;
			for (Integer i = 0; i < row.size(); i++) {
				MB_RestResponseInfoModel.lopaInfo_lopaPos column = row[i];
				if (column.flag) {
					posList.add(column);
				}
			}
		}
		return posList;
	}

	private static List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> getAllSeatResponseModelList(List<TG_LOPA_Req.row_element> rowList, List<CabinZone> cabinZoneList) {
		Integer runningRowNumber = 0;
		Integer previousLOPAId = -1;

		List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> seatMatrix = new List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>>();
		Integer rowIndex = 0;
		for (TG_LOPA_Req.row_element row : rowList) {
			Boolean isLastRow = rowIndex == rowList.size() - 1;
			if (isRowExist(row, isLastRow)) {
				CabinZone cabinZone = getCabinZone(cabinZoneList, Integer.valueOf(row.rowDetails.seatRowNumber));
				Map<String, Integer> columnNumberMap = cabinZone.columnNumberMap;
				Integer maxColumn = (columnNumberMap.values()[columnNumberMap.values().size() - 1] + 1);
				List<String> columnAlphabetList = new List<String>(columnNumberMap.keySet());

				if (previousLOPAId != cabinZone.lopaId) {
					runningRowNumber = 0;
					previousLOPAId = cabinZone.lopaId;
				}

				if (cabinZone.frontCabinFacilitySeatResponseModelList.size() > 0 && cabinZone.startRange == Integer.valueOf(row.rowDetails.seatRowNumber)) {
					List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> frontCabinFacilityMatrix = cabinZone.frontCabinFacilitySeatResponseModelList;
					seatMatrix = mergeSeatMatrix(seatMatrix, frontCabinFacilityMatrix);
				}

				List<MB_RestResponseInfoModel.lopaInfo_lopaPos> seatList = new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>();
				seatMatrix.add(seatList);

				Integer seatRowNumber = runningRowNumber++;
				String floor = BE8_GlobalConstants.FLOOR_MAP.get(cabinZone.cabin.compartmentDetails.cabinZoneCode);

				Map<String, TG_LOPA_Req.SeatOccupationDetailsTypeI_250904CRES> rowMap = getLOPAPositionRowMap(row);

				// Seat
				for (Integer physicalColumnIndex = 0; physicalColumnIndex < columnAlphabetList.size(); physicalColumnIndex++) {
					String columnAlphabet = columnAlphabetList.get(physicalColumnIndex);

					if (rowMap.containsKey(columnAlphabet)) {
						TG_LOPA_Req.SeatOccupationDetailsTypeI_250904CRES column = rowMap.get(columnAlphabet);
						if (isSeatCharacteristic(column.seatCharacteristic, BE8_GlobalConstants.TYPE_LAVATORY)) {
							MB_RestResponseInfoModel.lopaInfo_lopaPos seatModel = getLOPAPosModel(column, cabinZone, seatRowNumber, columnNumberMap.get(column.seatColumn), maxColumn, cabinZone.lopaId, row.rowDetails.seatRowNumber + column.seatColumn, BE8_GlobalConstants.TYPE_LAVATORY, floor, cabinZone.cabinZoneNumber, true, row, column.seatColumn);
							seatList.add(seatModel);
						} else if (isSeatCharacteristic(column.seatCharacteristic, BE8_GlobalConstants.TYPE_GALLEY_IN_SEAT_ROW)) {
							MB_RestResponseInfoModel.lopaInfo_lopaPos seatModel = getLOPAPosModel(column, cabinZone, seatRowNumber, columnNumberMap.get(column.seatColumn), maxColumn, cabinZone.lopaId, row.rowDetails.seatRowNumber + column.seatColumn, BE8_GlobalConstants.TYPE_GALLEY_IN_SEAT_ROW, floor, cabinZone.cabinZoneNumber, true, row, column.seatColumn);
							//System.debug('TYPE_GALLEY_IN_SEAT_ROW: ' + seatModel);
							seatList.add(seatModel);
						} else if (isSeatInTheLocation(column.seatCharacteristic)) {
							MB_RestResponseInfoModel.lopaInfo_lopaPos seatModel = getLOPAPosModel(column, cabinZone, seatRowNumber, columnNumberMap.get(column.seatColumn), maxColumn, cabinZone.lopaId, row.rowDetails.seatRowNumber + column.seatColumn, BE8_GlobalConstants.TYPE_SEAT, floor, cabinZone.cabinZoneNumber, true, row, column.seatColumn);
							seatList.add(seatModel);
							//System.debug(seatModel.pos);

						}
					} else {
						MB_RestResponseInfoModel.lopaInfo_lopaPos seatModel = getLOPAPosModel(null, cabinZone, seatRowNumber, columnNumberMap.get(columnAlphabet), maxColumn, cabinZone.lopaId, row.rowDetails.seatRowNumber + columnAlphabet, BE8_GlobalConstants.TYPE_SEAT, floor, cabinZone.cabinZoneNumber, true, row, columnAlphabet);
						seatList.add(seatModel);
						//System.debug(seatModel.pos);
					}
				}

				// Galley and Lavatory
				List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> rearCabinFacilitySeatResponseModelList = getCabinFacilitySeatResponseModelList(row.cabinFacility, 0, cabinZone, maxColumn);
				//System.debug('rearCabinFacilitySeatResponseModelList ' + rearCabinFacilitySeatResponseModelList);
				if (rearCabinFacilitySeatResponseModelList != null && rearCabinFacilitySeatResponseModelList.size() > 0) {
					seatMatrix = mergeSeatMatrix(seatMatrix, rearCabinFacilitySeatResponseModelList);
					//System.debug('seatMatrix ' + JSON.serialize(seatMatrix));
				}
			}
			rowIndex++;
		}
		return seatMatrix;
	}

	private static List<CabinZone> getCabinZoneList(Map<String, TG_LOPA_Req.GetSeatMapRes> lopaRawModelMap) {
		List<TG_LOPA_Req.cabin_element> cabinElementList = new List<TG_LOPA_Req.cabin_element>();
		for (TG_LOPA_Req.GetSeatMapRes rawModel : lopaRawModelMap.values()) {
			//System.debug(rawModel);
			if (rawModel != null && rawModel.seatmapInfo != null && rawModel.seatmapInfo[0] != null && rawModel.seatmapInfo[0].cabin != null) {
				cabinElementList.addAll(rawModel.seatmapInfo[0].cabin);
			}
		}
		cabinElementList.sort();

		List<CabinZone> cabinZoneList = new List<CabinZone>();
		Integer lopaId = 1;
		Map<String, Integer> cabinZoneNumberMap = new Map<String, Integer>();
		for (TG_LOPA_Req.cabin_element cabinElement : cabinElementList) {
			String cabinZoneCode = cabinElement.compartmentDetails.cabinZoneCode;
			if (!cabinZoneNumberMap.containsKey(cabinZoneCode)) {
				cabinZoneNumberMap.put(cabinZoneCode, 0);
			}
			Integer cabinZoneNumber = cabinZoneNumberMap.get(cabinZoneCode);
			cabinZoneNumber++;
			cabinZoneNumberMap.put(cabinZoneCode, cabinZoneNumber);

			CabinZone cabinZone = new CabinZone(lopaId, cabinZoneNumber, cabinElement);
			cabinZone.columnNumberMap = getColumnNumberMap(cabinElement.compartmentDetails);
			cabinZone.maxColumn = (cabinZone.columnNumberMap.values()[cabinZone.columnNumberMap.values().size() - 1] + 1);
			cabinZone.frontCabinFacilitySeatResponseModelList = getCabinFacilitySeatResponseModelList(cabinZone.cabin.cabinFacilities, 0, cabinZone, cabinZone.maxColumn);

			cabinZone.aisleSeatSet = getAisleSeatSet(cabinZone.columnNumberMap);

			lopaId++;
			cabinZoneList.add(cabinZone);
		}
		return cabinZoneList;
	}

	@TestVisible
	private static Set<Integer> getAisleSeatSet(Map<String, Integer> columnNumberMap) {
		Set<Integer> aisleSeatSet = new Set<Integer>();
		Integer previousValue = -1;
		for (String seatColumn : columnNumberMap.keySet()) {
			Integer currentValue = columnNumberMap.get(seatColumn);
			Boolean isAisleSeat = currentValue - previousValue > 1;
			if (isAisleSeat) {
				aisleSeatSet.add(currentValue);
			}
			previousValue = currentValue;
		}
		return aisleSeatSet;
	}

	private static List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> getCabinFacilitySeatResponseModelList(List<TG_LOPA_Req.CabinFacilitiesTypeIRES> cabinFacilityList, Integer runningRowNumber, CabinZone cabinZone, Integer maxColumn) {
		List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> seatMatrix = new List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>>();

		List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> galleyOnlyMatrix = new List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>>();
		List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> lavatoryOnlyMatrix = new List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>>();

		String floor = BE8_GlobalConstants.FLOOR_MAP.get(cabinZone.cabin.compartmentDetails.cabinZoneCode);
		cabinZone.startingRowNumber = 0;
		if (cabinFacilityList != null) {
			Integer rowIndex = 0;
			List<MB_RestResponseInfoModel.lopaInfo_lopaPos> currentRow = new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>();
			for (TG_LOPA_Req.CabinFacilitiesTypeIRES eachCabinFacility : cabinFacilityList) {
				List<MB_RestResponseInfoModel.lopaInfo_lopaPos> galleySeatList = null;
				List<MB_RestResponseInfoModel.lopaInfo_lopaPos> lavatorySeatList = null;

				//Boolean foundLCLavatoryTheNextOneMustBeRC = false;
				List<TG_LOPA_Req.CabinFacilitiesDetailsTypeIRES> cabinFacilityDetailList = getCabinFacilityDetailList(eachCabinFacility);



				for (TG_LOPA_Req.CabinFacilitiesDetailsTypeIRES eachCabinFacilityDetail : cabinFacilityDetailList) {
					Boolean isLavatory = eachCabinFacilityDetail.type_x == BE8_GlobalConstants.TYPE_LAVATORY;
					Boolean isGalley = eachCabinFacilityDetail.type_x == BE8_GlobalConstants.TYPE_GALLEY;
					if (isLavatory || isGalley) {
						MB_RestResponseInfoModel.lopaInfo_lopaPos seatModel = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
						seatModel.lopaId = '' + cabinZone.lopaId;
						seatModel.type = '' + eachCabinFacilityDetail.type_x + eachCabinFacility.rowLocation;
						seatModel.floor = '' + floor;
						seatModel.flag = true;
						seatModel.zone = '' + cabinZone.cabinZoneNumber;
						seatModel.col = eachCabinFacilityDetail.location;
						//if (isLavatory && seatModel.col == 'C') {
						//	if (!foundLCLavatoryTheNextOneMustBeRC) {
						//		seatModel.col = 'LC';
						//		foundLCLavatoryTheNextOneMustBeRC = true;
						//	} else {
						//		seatModel.col = 'RC';
						//		foundLCLavatoryTheNextOneMustBeRC = false;
						//	}
						//}
						seatModel.row = '' + rowIndex;
						seatModel.pos = seatModel.lopaId + '_' + seatModel.row + '_' + eachCabinFacilityDetail.type_x + '_' + seatModel.col + '_' + eachCabinFacility.rowLocation;
						seatModel.maxCol = '' + maxColumn;
						seatModel.width = 1;
						seatModel.height = 1;

						if (isGalley) {
							if (galleySeatList == null) {
								galleyOnlyMatrix.add(new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>());
								galleySeatList = galleyOnlyMatrix.get(galleyOnlyMatrix.size() - 1);
							}
							galleySeatList.add(seatModel);
						} else if (isLavatory) {
							if (lavatorySeatList == null) {
								lavatoryOnlyMatrix.add(new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>());
								lavatorySeatList = lavatoryOnlyMatrix.get(lavatoryOnlyMatrix.size() - 1);
							}
							lavatorySeatList.add(seatModel);
						}
						//System.debug('*****' + seatModel.pos + ' ' + seatModel.col + ' ' + seatModel.row + ' ' + eachCabinFacilityDetail);
						currentRow.add(seatModel);
					}
				}
				rowIndex++;
			}

			// Consolidate All cabinFacilityNode into the same row
			// This is due to the fact that SOAP has the limit of repeating element, new cabinFacility node does not mean a new row occurs
			if (currentRow != null && currentRow.size() > 0) {
				List<String> rowStructure = rowStructureMap.get(Integer.valueOf(currentRow[0].maxCol));
				rowIndex = 0;
				seatMatrix.add(new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>());
				Integer colIndex = 0;
				for (Integer cabinFacilityIndex = 0; cabinFacilityIndex < currentRow.size(); cabinFacilityIndex++) {
					Boolean isFound = false;
					MB_RestResponseInfoModel.lopaInfo_lopaPos eachCabinFacility = currentRow[cabinFacilityIndex];
					//System.debug('pos: ' + eachCabinFacility.pos + ' colIndex: ' + colIndex);
					if (colIndex < rowStructure.size()) {
						for (Integer i = colIndex; i < rowStructure.size(); i++) {
							colIndex = i + 1;
							if (rowStructure.get(i) == eachCabinFacility.col) {
								eachCabinFacility.row = '' + rowIndex;
								seatMatrix.get(rowIndex).add(eachCabinFacility);
								//System.debug('pos: ' + eachCabinFacility.pos + ' i:' + i);
								isFound = true;
								break;
							}
						}
					}

					if(colIndex >= rowStructure.size()){
						//System.debug('start a new row');
						// There are still something left in currentRow list, we go to the new row
						colIndex = 0;
						rowIndex++;
						seatMatrix.add(new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>());
						if(!isFound){
							cabinFacilityIndex--; // Repeat the search with this one again
						}
					}
				}
				//seatMatrix.add(currentRow);
			}
		}
		//seatMatrix = mergeSeatMatrix(galleyOnlyMatrix, lavatoryOnlyMatrix);
		//System.debug('######seatMatrix: ' + JSON.serialize(seatMatrix));
		return seatMatrix;
	}

	//private static List<MB_RestResponseInfoModel.lopaInfo_lopaPos> consolidateCabinFacility(Map<String, List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>>> cabinFacilityMap) {
	//	List<MB_RestResponseInfoModel.lopaInfo_lopaPos> seatList = new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>();
	//	for (String key : cabinFacilityMap.keySet()) {
	//		List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> entity = cabinFacilityMap.get(key);
	//		MB_RestResponseInfoModel.lopaInfo_lopaPos model = null;
	//		Integer height = entity.size();
	//		Integer width = 0;
	//		for (Integer i = 0; i < entity.size(); i++) {
	//			if (entity.get(i).size() > 0) {
	//				width = entity.get(i).size();
	//				model = entity.get(i).get(0);
	//				break;
	//			}
	//		}

	//		if (height > 0 && width > 0 && model != null) {
	//			model.height = height;
	//			model.width = width;
	//			model.col = key;
	//			model.pos = model.type + model.col;
	//			seatList.add(model);
	//		}
	//	}
	//	return seatList;
	//}

	private static CabinZone getCabinZone(List<CabinZone> cabinZoneList, Integer row) {
		for (CabinZone cabin : cabinZoneList) {
			if (isInCabinZone(cabin, row)) {
				return cabin;
			}
		}
		return null;
	}

	//private static Map<String, Integer> getColumnNumberMap(TG_LOPA_Req.seatmapInfo_element lopaModel) {
	//	Map<String, Integer> columnNumberMap = new Map<String, Integer>();
	//	Integer columnNumber = 0;
	//	Boolean isPreviousColumnAisle = false;
	//	for (TG_LOPA_Req.CabinWidthAndColumnDetailsTypeIRES columnDetail : lopaModel.cabin[0].compartmentDetails.columnDetails) {
	//		if (columnDetail.seatColumn != null && columnDetail.desc_x != null) {
	//			columnNumberMap.put(columnDetail.seatColumn, columnNumber);

	//			String columnDescription = String.join(columnDetail.desc_x, '');
	//			if (columnDescription.contains(GlobalConstants.AISLE_SEAT)) {
	//				if (!isPreviousColumnAisle) {
	//					columnNumber++;
	//					isPreviousColumnAisle = true;
	//				} else {
	//					isPreviousColumnAisle = false;
	//				}
	//			}
	//			columnNumber++;
	//		}
	//	}
	//	return columnNumberMap;
	//}

	private static Map<String, Integer> getColumnNumberMap(TG_LOPA_Req.CabinDetailsTypeIRES compartmentDetails) {
		Map<String, Integer> columnNumberMap = new Map<String, Integer>();
		Integer columnNumber = 0;
		Boolean isPreviousColumnAisle = false;
		for (TG_LOPA_Req.CabinWidthAndColumnDetailsTypeIRES columnDetail : compartmentDetails.columnDetails) {
			if (columnDetail.seatColumn != null && columnDetail.desc_x != null) {
				columnNumberMap.put(columnDetail.seatColumn, columnNumber);

				String columnDescription = String.join(columnDetail.desc_x, '');
				if (columnDescription.contains(BE8_GlobalConstants.AISLE_SEAT)) {
					if (!isPreviousColumnAisle) {
						columnNumber++;
						isPreviousColumnAisle = true;
					} else {
						isPreviousColumnAisle = false;
					}
				}
				columnNumber++;
			}
		}
		return columnNumberMap;
	}

	private static List<TG_LOPA_Req.CabinFacilitiesDetailsTypeIRES> getCabinFacilityDetailList(TG_LOPA_Req.CabinFacilitiesTypeIRES cabinFacility) {
		List<TG_LOPA_Req.CabinFacilitiesDetailsTypeIRES> cabinFacilityDetailList = new List<TG_LOPA_Req.CabinFacilitiesDetailsTypeIRES>();
		if (cabinFacility.cabinFacilityDetails != null) {
			cabinFacilityDetailList.add(cabinFacility.cabinFacilityDetails);
		}
		if (cabinFacility.otherCabinFacilityDetails != null) {
			cabinFacilityDetailList.addAll(cabinFacility.otherCabinFacilityDetails);
		}
		return cabinFacilityDetailList;
	}

	private static Boolean isInCabinZone(CabinZone cabinZone, Integer row) {
		return row >= cabinZone.startRange && row <= cabinZone.endRange;
	}

	private static Boolean isSeatInTheLocation(List<String> seatCharacteristics) {
		if (seatCharacteristics != null) {
			for (String each : seatCharacteristics) {
				if (BE8_GlobalConstants.SEAT_CHARACTERISTICS_NO_SEAT.contains(each)) {
					return false;
				}
			}
		}
		return true;
	}

	private static Boolean isSeatCharacteristic(List<String> seatCharacteristics, String characteristic) {
		if (seatCharacteristics != null) {
			for (String each : seatCharacteristics) {
				if (each == characteristic) {
					return true;
				}
			}
		}
		return false;
	}

	private static Boolean isRowExist(TG_LOPA_Req.row_element row, Boolean isLastRow) {
		if (row != null && row.rowDetails != null && row.rowDetails.rowCharacteristicDetails != null && row.rowDetails.rowCharacteristicDetails.rowCharacteristic != null) {
			if (row.rowDetails.rowCharacteristicDetails.rowCharacteristic == BE8_GlobalConstants.NO_ROW) {
				return false;
			}
		}

		// Omitted this logic due to confusion with wrong LOPA data in PDT
		//if (isLastRow && row.rowDetails.seatOccupationDetails == null) {
		//	return false;
		//}
		return true;
	}

	private static Map<String, TG_LOPA_Req.SeatOccupationDetailsTypeI_250904CRES> getLOPAPositionRowMap(TG_LOPA_Req.row_element row) {
		Map<String, TG_LOPA_Req.SeatOccupationDetailsTypeI_250904CRES> rowMap = new Map<String, TG_LOPA_Req.SeatOccupationDetailsTypeI_250904CRES>();
		if (row.rowDetails.seatOccupationDetails != null) {
			for (TG_LOPA_Req.SeatOccupationDetailsTypeI_250904CRES column : row.rowDetails.seatOccupationDetails) {
				rowMap.put(column.seatColumn, column);
			}
		}
		return rowMap;
	}

	private static MB_RestResponseInfoModel.lopaInfo_lopaPos getLOPAPosModel(TG_LOPA_Req.SeatOccupationDetailsTypeI_250904CRES column, CabinZone cabinZone, Integer seatRowNumber, Integer columnNumber, Integer maxColumn, Integer lopaId, String position, String type, String floor, Integer cabinZoneNumber, Boolean flag, TG_LOPA_Req.row_element row, String seatColumn) {
		MB_RestResponseInfoModel.lopaInfo_lopaPos seatModel = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		seatModel.width = 1;
		seatModel.height = 1;
		seatModel.row = '' + seatRowNumber;
		seatModel.col = '' + columnNumber;
		seatModel.maxCol = '' + maxColumn;
		seatModel.lopaId = '' + lopaId;
		seatModel.pos = position;
		seatModel.type = type;
		seatModel.floor = '' + floor;
		seatModel.zone = '' + cabinZoneNumber;
		seatModel.flag = true;
		seatModel.tclass = cabinZone.travelClass;
		seatModel.rowL = row.rowDetails.seatRowNumber;
		seatModel.colL = seatColumn;
		if (column != null) {
			seatModel.sOcp = column.seatOccupation;
			seatModel.sCh = column.seatCharacteristic;
		}
		if (cabinZone.aisleSeatSet != null) {
			seatModel.setAisleSeatList(new List<Integer>(cabinZone.aisleSeatSet));
		}
		return seatModel;
	}

	private static List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> mergeSeatMatrix(List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> a, List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> b) {
		for (List<MB_RestResponseInfoModel.lopaInfo_lopaPos> eachB : b) {
			a.add(eachB);
		}
		return a;
	}

	@TestVisible
	private static List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> consolidateSeat(List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> seatMatrix) {
		//System.debug('seatMatrix: ' + JSON.serialize(seatMatrix));

		Integer rowSize = seatMatrix.size();
		for (Integer rowIndex = 0; rowIndex < rowSize; rowIndex++) {
			List<MB_RestResponseInfoModel.lopaInfo_lopaPos> row = seatMatrix.get(rowIndex);
			Integer columnSize = row.size();
			Integer colIndex = 0;
			for (Integer i = 0; i < columnSize; i++) {
				MB_RestResponseInfoModel.lopaInfo_lopaPos column = row.get(i);
				Integer maxCol = Integer.valueOf(column.maxCol);
				List<String> rowStructure = rowStructureMap.get(maxCol);
				//System.debug('row: ' + row);
				//System.debug('column: ' + column.pos + ' ' + column);
				//System.debug('rowStructure: ' + rowStructure);
				if (rowStructure != null) {
					for (Integer j = colIndex; j < rowStructure.size(); j++) {
						if (column.col == rowStructure.get(j)) {
							MB_RestResponseInfoModel.lopaInfo_lopaPos nextColumn = i + 1 < row.size() ? row[i + 1] : null;
							MB_RestResponseInfoModel.lopaInfo_lopaPos previousColumn = i - 1 > 0 ? row[i - 1] : null;
							Boolean hasNextColumn = nextColumn != null;
							Boolean hasPreviousColumn = previousColumn != null;
							Boolean notFirst = i != 0;
							Boolean isAdjacentColumn = hasPreviousColumn && (previousColumn.col == String.valueOf(j - 1));
							// LC C C RC case
							// We cannot rely on first LC in the row structure. It must be moved one position to the right.
							//System.debug('column.col: ' + column.col + ' j: ' + j + ' rowStructureSize: ' + rowStructure.size());
							//System.debug(previousColumn);
							//System.debug(nextColumn);

							Boolean colRWithPreviousRC = column.col == 'R' && (hasPreviousColumn && isAdjacentColumn);
							Boolean loneRWithNoPreviousRC = (column.col == 'R' && !(hasNextColumn && (nextColumn.col == 'R'))) && !colRWithPreviousRC;
							Boolean loneLWithFollowingLC = column.col == 'L' && !hasPreviousColumn && (hasNextColumn && nextColumn.col == 'LC'); // x L LC x x ...
							Boolean loneLC = column.col == 'LC' && !hasPreviousColumn && nextColumn.col != 'LC'; // x x LC C C RC ...
							Boolean loneRC = column.col == 'RC' && (!hasPreviousColumn || !isAdjacentColumn) && (hasNextColumn && nextColumn.col == 'R'); // L L LC x x RC R R
							//System.debug('loneRWithNoPreviousRC: ' + String.valueOf(loneRWithNoPreviousRC) + ' loneLWithFollowingLC:' + String.valueOf(loneLWithFollowingLC) + ' loneLC:' + String.valueOf(loneLC) + ' loneRC:' + String.valueOf(loneRC));
							if (loneRWithNoPreviousRC || loneLWithFollowingLC || loneLC || loneRC) {
								if (j + 1 < rowStructure.size() && rowStructure.get(j + 1) == column.col) {
									j++;
								} else {
									// j stays at the same value
								}
							}



							column.col = '' + j;
							if(column.pos != null){
								String[] posArray = column.pos.split('_');
								// Reference: seatModel.pos = seatModel.lopaId + '_' + seatModel.row + '_' + eachCabinFacilityDetail.type_x + '_' + seatModel.col + '_' + eachCabinFacility.rowLocation;
								if(posArray.size() == 5){
									column.pos = posArray[0] + '_' + posArray[1] + '_' + posArray[2] + '_' + j + '_' + posArray[4];
								}
							}
							colIndex = j + column.width;
							//System.debug(column.pos + ' ' + column.col);
							//System.debug(column);
							break;
						}
					}
				}
			}
		}

		for (Integer rowIndex = 0; rowIndex < rowSize; rowIndex++) {
			List<MB_RestResponseInfoModel.lopaInfo_lopaPos> row = seatMatrix.get(rowIndex);
			Integer columnSize = row.size();
			for (Integer columnIndex = 0; columnIndex < columnSize; columnIndex++) {
				MB_RestResponseInfoModel.lopaInfo_lopaPos position = row.get(columnIndex);
				Boolean isVisited = !position.flag;
				Set<String> cabinFacilityCodeSet = new Set<String> {'LAF', 'LAR', 'GF', 'GR', 'GN', 'LA'};
				//Set<String> cabinFacilityCodeSet = new Set<String> {'GF', 'GR', 'GN'};
				Boolean isCabinFacility = cabinFacilityCodeSet.contains(position.type);
				//System.debug(position.pos + ' isCabinFacility:' + isCabinFacility + ' isVisited:' + isVisited + ' flag:' + position.flag);
				if (isCabinFacility && !isVisited) {
					Integer width = 1;
					Integer height = 1;
					MB_RestResponseInfoModel.lopaInfo_lopaPos runningPosition = position;

					// Horizontal Search
					for (Integer horizontalIndex = columnIndex + 1; horizontalIndex < columnSize; horizontalIndex++) {
						//System.debug('HORIZONTAL_SEARCH ' + runningPosition);
						MB_RestResponseInfoModel.lopaInfo_lopaPos nextPosition = row.get(horizontalIndex);
						Boolean isTheSameEntity = isTheSameEntity(runningPosition, nextPosition, HORIZONTAL_SEARCH);
						//System.debug('Horizontal isTheSameEntity: ' + isTheSameEntity + ' ' + runningPosition.pos + ' ' + nextPosition.pos + ' ' + runningPosition.type);
						if (isTheSameEntity) {
							width++;
							nextPosition.flag = false; // visit
							runningPosition = nextPosition;
						} else {
							break;
						}
					}

					// Vertical Search
					runningPosition = position;
					Integer startingCol = Integer.valueOf(runningPosition.col);
					Integer endingCol = startingCol;
					for (Integer verticalIndex = rowIndex + 1; verticalIndex < rowSize; verticalIndex++) {
						List<MB_RestResponseInfoModel.lopaInfo_lopaPos> nextRow = seatMatrix.get(verticalIndex);
						Boolean isFoundAdjacentAtLeastOne = false;
						Integer firstFoundIndexOfThisRow = 0;
						for (Integer horizontalIndex = 0; horizontalIndex < nextRow.size(); horizontalIndex++) {
							MB_RestResponseInfoModel.lopaInfo_lopaPos nextPosition = nextRow[horizontalIndex];
							Boolean isTheSameEntity = isTheSameEntity(runningPosition, nextPosition, VERTICAL_SEARCH);
							Boolean isWithinWidth = Integer.valueOf(nextPosition.col) < (width + startingCol);
							//System.debug('Vertical isTheSameEntity: ' + isTheSameEntity + ' ' + runningPosition.pos + ' ' + runningPosition.col + ' ' + runningPosition.type + ' | ' + nextPosition.pos + ' ' + nextPosition.col  + ' ' + nextPosition.type);
							//System.debug('Integer.valueOf(nextPosition.col): ' + Integer.valueOf(nextPosition.col) + ' width: ' + width + ' startingCol: ' + startingCol);
							if (isTheSameEntity && !isFoundAdjacentAtLeastOne) {
								//System.debug('VERTICAL_SEARCH ' + runningPosition);
								height++;
								nextPosition.flag = false; // visit
								isFoundAdjacentAtLeastOne = true;
								runningPosition = nextPosition;
								firstFoundIndexOfThisRow = horizontalIndex;
								endingCol = Integer.valueOf(nextPosition.col);
							} else if (isFoundAdjacentAtLeastOne && isTheSameEntity(runningPosition, nextPosition, HORIZONTAL_SEARCH) && isWithinWidth) {
								//System.debug('HORIZONTAL_SEARCH ' + runningPosition);
								nextPosition.flag = false; // visit
								runningPosition = nextPosition;
								endingCol = Integer.valueOf(nextPosition.col);
							} else if (isFoundAdjacentAtLeastOne) {
								break;
							}
						}
						Integer widthOfThisRow = endingCol - startingCol + 1;
						if (!isFoundAdjacentAtLeastOne) {
							break;
						} else if (widthOfThisRow != width) {
							// Case:
							// C RC RC R R
							// C RC
							//undo the run of this row
							for (Integer horizontalIndex = 0; horizontalIndex < nextRow.size(); horizontalIndex++) {
								MB_RestResponseInfoModel.lopaInfo_lopaPos nextPosition = nextRow[horizontalIndex];
								nextPosition.flag = true;
							}
							break;
						} else {
							//System.debug('reset the running position: ' + firstFoundIndexOfThisRow);
							//System.debug(nextRow);
							runningPosition = nextRow[firstFoundIndexOfThisRow];
						}
					}

					position.width = width;
					position.height = height;
					position.flag = true;
					//position.col = position.col.contains('C') ? 'C' : position.col;
					//System.debug('position: ' + position.pos + ' width: ' + position.width + ' height:' + position.height);
				}
			}
		}
		return seatMatrix;
	}


	@TestVisible
	private static Boolean isTheSameEntity(MB_RestResponseInfoModel.lopaInfo_lopaPos position, MB_RestResponseInfoModel.lopaInfo_lopaPos nextPosition, Integer searchType) {
		//System.debug('position: ' + position);
		//System.debug('nextPosition: ' + nextPosition);
		Boolean isSameType = position.type == nextPosition.type || (position.type.contains('G') && nextPosition.type.contains('G'));
		//System.debug('isSameType ' + isSameType);
		Boolean isNextPositionVisited = !nextPosition.flag;
		Boolean isAdjacentRow = Integer.valueOf(nextPosition.row) - Integer.valueOf(position.row) == 1;
		Boolean isSpecialCaseAdjacentRowBetweenSeatRowAndRearCabinFacility = position.type == 'GN' && nextPosition.type == 'GR' || position.type == 'GF' && nextPosition.type == 'GN'; // GN | GR
		Boolean isNotLavatory = position.type != 'LA' && position.type != 'LAF' && position.type != 'LAR';
		//System.debug('isNextPositionVisited ' + isNextPositionVisited);
		if (searchType == HORIZONTAL_SEARCH && isSameType && !isNextPositionVisited) {
			//System.debug('isSameType && !isNextPositionVisited searchType:' + searchType + ' position.row == nextPosition.row:' + String.valueOf(position.row == nextPosition.row) + ' Integer.valueOf(nextPosition.col) - Integer.valueOf(position.col) == 1:' + String.valueOf(Integer.valueOf(nextPosition.col) - Integer.valueOf(position.col)));
			if (position.row == nextPosition.row && Integer.valueOf(nextPosition.col) - Integer.valueOf(position.col) == 1 && isNotLavatory) {
				return true;
			}
		}
		//if (searchType == VERTICAL_SEARCH) {
		//	System.debug('Vertical Search: ' + position.pos + ' ' + position.row + ' ' + nextPosition.pos + ' ' + nextPosition.row + ' ' + isAdjacentRow);
		//}
		if (searchType == VERTICAL_SEARCH && !isNextPositionVisited && (isAdjacentRow || isSpecialCaseAdjacentRowBetweenSeatRowAndRearCabinFacility) && isSameType && isNotLavatory) {
			//System.debug('searchType == VERTICAL_SEARCH && !isNextPositionVisited && isAdjacentRow && isSameType');
			if (position.col.isNumeric()) {
				return nextPosition.col == position.col;
			}
		}
		return false;
	}

	public static MB_RestResponseInfoModel.lopaInfo_model assignStatusToLOPA(MB_RestResponseInfoModel.lopaInfo_model lopaModel, Flight__c flight, Map<String, SObject> passengerMapByFlightIdAndSeatNumber, Map<String, List<SObject>> caseMapByAircraftIdAndPosition, LOPAStatusHandler lopaStatusHandler) {
		for (MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos : lopaModel.lopaPos) {
			Passenger__c matchedPassenger = null;
			List<Case_Group_Member__c> matchedCaseList = null;
			if (passengerMapByFlightIdAndSeatNumber.containsKey(flight.Id + lopaPos.pos)) {
				matchedPassenger = (Passenger__c) passengerMapByFlightIdAndSeatNumber.get(flight.Id + lopaPos.pos);
				if (matchedPassenger.Cabin_Code__c != null) {
					lopaPos.tclass = matchedPassenger.Cabin_Code__c;
				}
			}
			if (caseMapByAircraftIdAndPosition.containsKey(flight.AircraftId__c + lopaPos.pos)) {
				matchedCaseList = (List<Case_Group_Member__c>) caseMapByAircraftIdAndPosition.get(flight.AircraftId__c + lopaPos.pos);
			}
			lopaPos.sts = lopaStatusHandler.getLOPAPositionStatus(lopaPos.pos, lopaPos.type, matchedPassenger, matchedCaseList, lopaPos);
		}
		lopaModel.fltId = flight.Flight_External_ID__c;
		lopaModel.id = flight.Id;
		lopaModel.legId = '' + flight.Leg_Number__c;
		return lopaModel;
	}

	//@TestVisible
	//private static String getLOPAPositionStatus(String position, String positionType, Passenger__c matchedPassenger, List<Case_Group_Member__c> matchedCaseList, MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos) {
	//	Boolean isPassengerSeat = positionType == BE8_GlobalConstants.TYPE_SEAT;
	//	Boolean isPassengerSeatOccupied = isPassengerSeat && (matchedPassenger != null);
	//	Boolean isROP = isPassengerSeatOccupied && (matchedPassenger.FFP_Carrier__c == BE8_GlobalConstants.DEFAULT_TG_COMPANY);

	//	Boolean hasCase = matchedCaseList != null;
	//	Boolean isServiceable = !hasCase || matchedCaseList.size() == 0;

	//	Boolean isOccupied = isPassengerSeatOccupied;
	//	Boolean isBlock = false;
	//	Boolean isMalfunction = false;
	//	Boolean isGold = false;
	//	Boolean isPlatinum = false;

	//	Boolean isBlockedFromLOPA = lopaPos.sOcp != null && BE8_GlobalConstants.SEAT_OCCUPATION_BLOCKED_SEAT.contains(lopaPos.sOcp);

	//	String status = '';
	//	if (isPassengerSeat) {
	//		if (!isServiceable) {
	//			for (Case_Group_Member__c eachMember : matchedCaseList) {
	//				if (eachMember.Impact__c == BE8_GlobalConstants.IMPACT_BLOCK) {
	//					isBlock = true;
	//					break;
	//				}
	//				if (eachMember.Impact__c == BE8_GlobalConstants.IMPACT_MALFUNCTION) {
	//					isMalfunction = true;
	//					break;
	//				}
	//			}
	//		}
	//	}

	//	if (isROP) {
	//		isGold = matchedPassenger.FFP_Tier__c != null && matchedPassenger.FFP_Tier__c == BE8_GlobalConstants.FFP_TIER_GOLD;
	//		isPlatinum = matchedPassenger.FFP_Tier__c != null && matchedPassenger.FFP_Tier__c == BE8_GlobalConstants.FFP_TIER_PLATINUM;
	//	}


	//	if (isBlockedFromLOPA) {
	//		return BE8_GlobalConstants.LOPA_STATUS_BLOCKED_FROM_LOPA;
	//	}
	//	if (isMalfunction && isGold) {
	//		return BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_GOLD;
	//	}
	//	if (isMalfunction && isPlatinum) {
	//		return BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_PLATINUM;
	//	}
	//	if (isBlock && isGold) {
	//		return BE8_GlobalConstants.LOPA_STATUS_BLOCK_GOLD;
	//	}
	//	if (isBlock && isPlatinum) {
	//		return BE8_GlobalConstants.LOPA_STATUS_BLOCK_PLATINUM;
	//	}
	//	if (isOccupied && isGold) {
	//		return BE8_GlobalConstants.LOPA_STATUS_OCCUPIED_GOLD;
	//	}
	//	if (isOccupied && isPlatinum) {
	//		return BE8_GlobalConstants.LOPA_STATUS_OCCUPIED_PLATINUM;
	//	}
	//	if (isMalfunction && isOccupied) {
	//		return BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_OCCUPIED;
	//	}
	//	if (isBlock && isOccupied) {
	//		return BE8_GlobalConstants.LOPA_STATUS_BLOCK_OCCUPIED;
	//	}
	//	if (isMalfunction) {
	//		return BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION;
	//	}
	//	if (isBlock) {
	//		return BE8_GlobalConstants.LOPA_STATUS_BLOCK;
	//	}
	//	if (isOccupied) {
	//		return BE8_GlobalConstants.LOPA_STATUS_OCCUPIED;
	//	} else {
	//		return BE8_GlobalConstants.LOPA_STATUS_AVAILABLE;
	//	}
	//}

	//public static String convertInflightLOPAStatusToAircraftLOPAStatus(String status) {
	//	if (status == BE8_GlobalConstants.LOPA_STATUS_OCCUPIED) {
	//		return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_OCCUPIED;
	//	}
	//	if (status == BE8_GlobalConstants.LOPA_STATUS_AVAILABLE) {
	//		return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_AVAILABLE;
	//	}
	//	if (status == BE8_GlobalConstants.LOPA_STATUS_BLOCK) {
	//		return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_BLOCK;
	//	}
	//	if (status == BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION) {
	//		return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_MALFUNCTION;
	//	}
	//	Set<String> occupiedBlockStatusSet = new Set<String> {BE8_GlobalConstants.LOPA_STATUS_BLOCK_OCCUPIED, BE8_GlobalConstants.LOPA_STATUS_BLOCK_PLATINUM, BE8_GlobalConstants.LOPA_STATUS_BLOCK_GOLD};
	//	if (occupiedBlockStatusSet.contains(status)) {
	//		return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_BLOCK_OCCUPIED;
	//	}
	//	Set<String> occupiedMalfunctionStatusSet = new Set<String> {BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_OCCUPIED, BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_PLATINUM, BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_GOLD};
	//	if (occupiedMalfunctionStatusSet.contains(status)) {
	//		return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_MALFUNCTION_OCCUPIED;
	//	}
	//	if (status == BE8_GlobalConstants.LOPA_STATUS_BLOCKED_FROM_LOPA) {
	//		return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_BLOCKED_FROM_LOPA;
	//	}
	//	return null;
	//}

	public static List<Map<String, String>> getAllLOPAPositions(Id flightOrAircraftId) {
		return getLOPAPositionsByCabinCode(flightOrAircraftId, null);
	}

	public static List<Map<String, String>> getLOPAPositionsByCabinCode(Id flightOrAircraftId, String cabinCode) {
		Attachment lopaFile = [SELECT Id, Body, ParentId FROM Attachment WHERE Name = 'Master_LOPA.txt' AND ParentId = : flightOrAircraftId LIMIT 1];
		List<Map<String, String>> positionList = new List<Map<String, String>>();
		if (lopaFile != null) {
			MB_RestResponseInfoModel.lopaInfo_model lopaModel = (MB_RestResponseInfoModel.lopaInfo_model)System.JSON.deserialize(lopaFile.Body.toString(), MB_RestResponseInfoModel.lopaInfo_model.class);
			for (MB_RestResponseInfoModel.lopaInfo_lopaPos eachPos : lopaModel.lopaPos) {
				if(cabinCode == null || eachPos.tclass == cabinCode){
					positionList.add(new Map<String, String> {'position' => eachPos.pos, 'type' => eachPos.type});
				}
			}
		}
		return positionList;
	}

	public static Map<Id, Map<String, String>> getAllLOPAPositionsMapByEquipment(Set<Id> flightOrAircraftIdSet) {
		List<Attachment> lopaFiles = [SELECT Id, Body, ParentId FROM Attachment WHERE Name = 'Master_LOPA.txt' AND ParentId = : flightOrAircraftIdSet];
		Id seatEquipment;
		Id gEquipment;
		Id lEquipment;
		for (Master_Map__c equipment : [SELECT Id, Name FROM Master_Map__C WHERE Name IN ('PASSENGER SEAT', 'GALLEY AREA', 'LAVATORY (TOILET)')]) {
			if (equipment.Name == 'PASSENGER SEAT') {
				seatEquipment = equipment.Id;
			} else if (equipment.Name == 'GALLEY AREA') {
				gEquipment = equipment.Id;
			} else if (equipment.Name == 'LAVATORY (TOILET)') {
				lEquipment = equipment.Id;
			}
		}
		Map<Id, Map<String, String>> positionListMap = new Map<Id, Map<String, String>>();
		for (Attachment eachLopaFile : lopaFiles) {
			if (eachLopaFile != null) {
				Map<String, String> positionMap = new Map<String, String>();
				MB_RestResponseInfoModel.lopaInfo_model lopaModel = (MB_RestResponseInfoModel.lopaInfo_model)System.JSON.deserialize(eachLopaFile.Body.toString(), MB_RestResponseInfoModel.lopaInfo_model.class);
				for (MB_RestResponseInfoModel.lopaInfo_lopaPos eachPos : lopaModel.lopaPos) {
					Id equipmentId;
					if (eachPos.type.contains('G')) {
						equipmentId = gEquipment;
					} else if (eachPos.type.contains('L')) {
						equipmentId = lEquipment;
					} else if (eachPos.type.contains('seat')) {
						equipmentId = seatEquipment;
					}
					if (equipmentId != null) {
						positionMap.put(eachPos.pos, equipmentId);
					}
				}
				positionListMap.put(eachLopaFile.ParentId, positionMap);
			}
		}
		return positionListMap;
	}
}