public with sharing class ExtraLOPAConfigService {
	public static List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> handleLongGalleyCase(Integer zoneWithLongGalley, Set<String> seatAdjacentToLongGalleySeatNumberSet, List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> seatMatrix) {
		List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> newSeatMatrix = new List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>>();
		for (List<MB_RestResponseInfoModel.lopaInfo_lopaPos> seatList : seatMatrix) {
			List<MB_RestResponseInfoModel.lopaInfo_lopaPos> newSeatList = new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>();
			for (MB_RestResponseInfoModel.lopaInfo_lopaPos eachSeat : seatList) {

				Boolean isSeatInZoneOfLongGalley = Integer.valueOf(eachSeat.zone) == zoneWithLongGalley;
				Boolean isSeatAdjacentToLongGalley = isSeatInZoneOfLongGalley && seatAdjacentToLongGalleySeatNumberSet.contains(eachSeat.pos);
				if (isSeatInZoneOfLongGalley) {
					eachSeat.maxCol = Integer.valueOf(eachSeat.maxCol) + 1 + '';
				}
				if (isSeatAdjacentToLongGalley) {
					newSeatList.add(eachSeat);
					MB_RestResponseInfoModel.lopaInfo_lopaPos longGalley = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
					longGalley.width = 1;
					longGalley.height = 1;
					longGalley.row = eachSeat.row;
					longGalley.col = Integer.valueOf(eachSeat.col) + 1 + '';
					longGalley.maxCol = eachSeat.maxCol;
					longGalley.lopaId = '' + eachSeat.lopaId;
					//String pos = eachSeat.pos.substring(0, eachSeat.pos.length()-1);
					longGalley.pos = 'longgalley_' + longGalley.row + '_' + longGalley.col;
					longGalley.posId = longGalley.pos;
					longGalley.type = BE8_GlobalConstants.TYPE_GALLEY_IN_SEAT_ROW;
					longGalley.floor = eachSeat.floor;
					longGalley.zone = eachSeat.zone;
					longGalley.flag = true;
					longGalley.tclass = eachSeat.tclass;
					longGalley.rowL = eachSeat.rowL;
					longGalley.colL = '';
					newSeatList.add(longGalley);
					System.debug('longGalley: ' + longGalley);
				} else {
					newSeatList.add(eachSeat);
				}
			}
			newSeatMatrix.add(newSeatList);
		}
		//System.debug('newSeatList: ' + JSON.serialize(newSeatList));
		return newSeatMatrix;
	}
}