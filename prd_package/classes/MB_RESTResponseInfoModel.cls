/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:  All Model to support Restful API to inquiry information from SFDC

History :
<Date>      <Authors Name>     <Brief Description of Change>
28/08/2016  Charnun.T           First Create
------------------------------------------------------------*/
global class MB_RESTResponseInfoModel {

    global virtual class BaseMobileResponse {
        public String statusCode;
        public String resultString;
    }

    /* Passenger Info Model */
    global class passengerInfo_model {
        public String id;
        public String fltId;
        public String legNo;
        public String pnrNo;
        public String bSeat;
        public String firstN;
        public String lastN;
        public String image;
        public String gender;
        public String birth;
        public String nat;
        public String phone;
        public String mobile;
        public String email1;
        public String email2;
        public String bClass;
        public passengerInfo_ssr[] ssr_spm;
        public passengerInfo_ssr[] ssr_sv;
        public passengerInfo_membership[] memberships;
        public passengerInfo_paxPsy psy;
        public String bag;
        public String conFlt;
        public String conDT;
        public String cabin;
        public String infName;
        public String infAge;
        public Integer hasInfant;
        public String boardPoint;
        public String offPoint;
        public Integer isStaff;
        public String accId;
        public String paxKey;
        public List<String> upgrade;
        public String connectingfltno;
        public String connectingfltdate;
        public String connectingfltsegment;
        public String connectingfltstd;
        public String changeSeat;
        public String changeClass;
        public Integer isExpired;
    }

    global class passengerInfo_membership {
        public String id;
        public String airline;
        public String tier;
        public String addr;
        public String hPhone;
        public String bPhone;
        public String mobile;
        public String email1;
        public String email2;
        public String mi;
        public String expMi;
        public String seatPre;
        public String favFood;
        public String occup;
        public String lang;
        public String food;
        public String drink;
    }
    global class passengerInfo_paxPsy {
        public String ifLike;
        public String ifDislike;
        public String ifOther;
        public String ground;
        public String sale;
    }

    global class passengerInfo_ssr {
        public String type;
        public String remark;
        public String status;
    }

    /////////////////////////////////////////////////////

    /* Incident Model */

    global class incident_model {
        public String sfdcId;
        public String id;
        public String fltId;
        public String fltNum;
        public String aircraftId;
        public String creBy;
        public String repBy;
        public String creDT;
        public String updDT;
        public String equipId;
        public String partId;
        public String seqNo;
        public String condi;
        public String subject;
        public String descr;
        public Integer logType;
        public incident_compensation[] compen;
        public String status; //Open, Closed, Resolved
        public Integer isLog;
        public Integer isMulti;
        public Integer isVoided;
        public String rptType;
        public Integer emerType;
        public Integer inCate; //Service, Passenger, Safety, Other, Emergency, Maintenance
        public Integer isSynced;
        public String safetyZone;
        public String acReg;
        public String action;
        public String phone;
        public String email;
        public String authName;
        public String authNumber;
        public String upChgType;
        public String acType;
        public String acMainType;
        public Integer isDup;
        public String depSt;
        public Integer lackOfPart;
        public Integer lackOfTime;
        public incident_posMem[] posMem;
        public incident_paxMem[] paxMem;
        public incident_crewMem[] crewMem;
        public incident_staffMem[] staffMem;
        public incident_changeSeatMem[] chSeat;
    }
    global class incident_staffMem {
        public String staffName;
        public String id;
        public String role;
        public String detail;
        public String sfdcId;
    }
    global class incident_crewMem {
        public String id;
        public String role;
        public String detail;
        public String sfdcId;
    }
    global class incident_compensation {
        public String id;
        public String detail;
        public String type;
        public String quantity;
        public String amount;
        public String paxId;
        public String incidentId;
        public String sfdcId;
        public String problem;
        public String currenc;
        public String upCer;
        public String iscFormNum;
        public String itemCodeNum;
        public String fromSeat;
        public String fromClass;
        public String toSeat;
        public String toClass;
        public String creDT;
    }

    global class incident_changeSeatMem {
        public String id;
        public String fromSeat;
        public String fromClass;
        public String toSeat;
        public String toClass;
        public String creDT;
    }

    global class incident_posMem {
        public String id;
        public String impact;
        public String sfdcId;
        public String acZone;
        public String equipId;
    }
    global class incident_paxMem {
        public String id;
        public String accId;
        public String paxKey;
        //public String newPos;
        //public String newClass;
        public String role;
        public String detail;
        public String sfdcId;
    }

    /////////////////////////////////////////////////////

    /* E-Document Info Model */
    global class eDocumentInfo_model extends BaseMobileResponse {
        public String id;
        public String fltId;
        public eDocumentInfo_routeInfo[] routeInfo;
        public eDocumentInfo_crewPro[] crewPro;
        public eDocumentInfo_FandB[] FandB;
        public eDocumentInfo_require[] require;
        public eDocumentInfo_manual[] manual;
        public String iCare;
    }
    global class eDocumentInfo_routeInfo {
        public String id;
        public String path;
    }
    global class eDocumentInfo_crewPro {
        public String id;
        public String path;
    }
    global class eDocumentInfo_FandB {
        public String id;
        public String path;
    }
    global class eDocumentInfo_require {
        public String id;
        public String path;
    }
    global class eDocumentInfo_manual {
        public String id;
        public String path;
    }

    /////////////////////////////////////////////////////

    /* LOPA Info Model */
    global class lopaInfo_model {
        public String id;
        public String acReg;
        public String fltId;
        public String legId;
        public String maxRow;
        public lopaInfo_lopaPos[] lopaPos;
    }
    global class lopaInfo_lopaPos implements Comparable {
        public String id;
        public String posId;
        public String lopaId;
        public String type;
        public String row;
        public string rowL;
        public String col;
        public String colL;
        public String maxCol;
        public String pos;
        public String tclass;
        public String floor;
        public String zone;
        public Boolean flag;
        public String sts;
        public String sOcp;
        public Integer width;
        public Integer height;
        public List<String> sCh;
        private List<Integer> aisleSeatList;
        public Double order;

        global Double getOrder(){
            String arrangement;
            if(this.type == 'GF' || this.type == 'LAF'){
                arrangement = '1';
            } else if(this.type == 'GR' || this.type == 'LAR'){
                arrangement = '3';
            } else {
                arrangement = '2';
            }

            String row = this.row.length() == 1 ? '0' + this.row : this.row;
            String col = this.col.length() == 1 ? '0' + this.col : this.col;

            this.order = Double.valueOf(this.zone + '0' + arrangement + '0' + row + '0' + col);
            return order;
        }

        global void setAisleSeatList(List<Integer> input) {
            aisleSeatList = input;
        }

        global List<Integer> getAisleSeatList() {
            return aisleSeatList;
        }

        global Integer compareTo(Object compareTo) {
            lopaInfo_lopaPos otherObj = (lopaInfo_lopaPos) compareTo;
            return Integer.valueOf((this.getOrder() - otherObj.getOrder()) * 100);
        }
    }

    /////////////////////////////////////////////////////

    /* Equipment and Emergency Info Model */
    global class equipmentAndEmergencyInfo_model extends BaseMobileResponse {
        public String id;
        public String fltId;
        public equipmentAndEmergencyInfo_equip[] equip;
        public equipmentAndEmergencyInfo_ataCh[] ataCh;
        public equipmentAndEmergencyInfo_condi[] condi;
        public equipmentAndEmergencyInfo_Emer[] Emer;
        public equipmentAndEmergencyInfo_CAC[] CAC;
    }
    global class equipmentAndEmergencyInfo_equip {
        public String id;
        public String equipNo;
        public String equipN;
        public String ataChId;
        public equipmentAndEmergencyInfo_part[] part;
    }
    global class equipmentAndEmergencyInfo_part {
        public String id;
        public String eqId;
        public String partNo;
    }
    global class equipmentAndEmergencyInfo_ataCh {
        public String id;
        public String ataChNo;
        public String ataChN;
    }
    global class equipmentAndEmergencyInfo_condi {
        public String id;
        public String CondiGp;
        public String item;
    }
    global class equipmentAndEmergencyInfo_Emer {
        public String id;
        public String type;
    }
    global class equipmentAndEmergencyInfo_CAC {
        public String id;
        public String cate;
        public equipmentAndEmergencyInfo_CAQ[] CAQ;
    }
    global class equipmentAndEmergencyInfo_CAQ {
        public String id;
        public String detail;
        public String sex;
        public equipmentAndEmergencyInfo_subQuest[] subQuest;
    }
    global class equipmentAndEmergencyInfo_subQuest {
        public String id;
        public String detail;
    }

    /////////////////////////////////////////////////////

    /* Flight Info Model */
    global class flightInfo_model {
        public String id {get; set;}
        public String fltExtId {get; set;}
        public String flightNo {get; set;}
        public String dateU {get; set;}
        public String dateL {get; set;}
        public String origin {get; set;}
        public String dest {get; set;}
        public String legNo {get; set;}
        public String acType {get; set;}
        public String acCon {get; set;}
        public String acReg {get; set;}
        public String model {get; set;}
        public String depSt {get; set;}
        public String depStF {get; set;}
        public String arrSt {get; set;}
        public String arrStF {get; set;}
        public String stdUTC {get; set;}
        public String stdLT {get; set;}
        public String etdUTC {get; set;}
        public String etdLT {get; set;}
        public String staUTC {get; set;}
        public String staLT {get; set;}
        public String etaUTC {get; set;}
        public String etaLT {get; set;}
        public String ft {get; set;}
        public String gate {get; set;}
        public String nFltNo {get; set;}
        public String nFltDTu {get; set;}
        public String depDl {get; set;}
        public String lastM {get; set;}
        public String lastS {get; set;}
        public String acName {get; set;}
        public String acNameTH {get; set;}
        public String codeShare {get; set;}
        public String bookingPax {get; set;}
        public String acceptedPax {get; set;}
        public crewL_model userId {get; set;}
        public List<String> condi {get; set;}
        public List<String> duty {get; set;}
        public String region {get; set;}
        public List<crewL_model> crewL {
            get
            {
                if (crewL == null)
                    crewL = new List<crewL_model>();
                return crewL;
            }
            set;
        }
        public List<sEquip_model> equip {
            get
            {
                if (equip == null)
                    equip = new List<sEquip_model>();
                return equip;
            }
            set;
        }
    }

    global class crewL_model {
        public String id {get; set;}
        public String fltId {get; set;}
        public String image {get; set;}
        public String title {get; set;}
        public String firstN {get; set;}
        public String lastN {get; set;}
        public String nickN {get; set;}
        public String type {get; set;}
        public String rank {get; set;}
        public String aRank {get; set;}
        public String spcSpl {get; set;}
        public String duty {get; set;}
        public String dutyC {get; set;}
        public String lang {get; set;}
        public String rtFltD {get; set;}
        public String rtFltNo {get; set;}
        public String posFly {get; set;}
        public String noOfEval {get; set;}
        public Decimal seqNo {get; set;}
        public String sfdcId {get; set;}
        public String gender {get; set;}
        public String lastEva {get; set;}
    }

    global class part_model {
        public String id;
        public String name;
        public String lcc;
    }

    global class sEquip_model {
        public String id {get; set;}
        public String type {get; set;}
        public String zone {get; set;}
        public String location {get; set;}
        public String name {get; set;}
        public String ataCh {get; set;}
        public String cCA {get; set;} //Check_by_CA_s_station__c
        public String cPro {get; set;} //Checked_Procedure__c
        public String descr {get; set;} //Description__c
        public Decimal qty {get; set;} //Quantity_to_be_checked__c
        public Decimal total {get; set;} //Total__c
        public String lcc {get; set;} //LOPA_Concern_Location__c
        public part_model[] part {get; set;}
    }

    /////////////////////////////////////////////////////

    global class att {
        public Blob body;
    }

    //////////////////////////////////////////////////

    global class flightSchedule_model {
        public String id;
        public String arrFltId;
        public String depFltId;
        public String arrFltConfig;
        public String depFltConfig;
        public String acReg;
        public String acType;
        public String arrFltFrom;
        public String depFltTo;
        public String staLT;
        public String staUTC;
        public String etaLT;
        public String etaUTC;
        public String stdLT;
        public String stdUTC;
        public String etdLT;
        public String etdUTC;
        public String bayArrDep;
        public Decimal serviceableCount;
        public Decimal blockCount;
        public Decimal malfunctionCount;
        public Decimal completedCount;
        public Decimal noActionCount;
        public String arrFltLastM;
        public String depFltLastM;
        public String arrFltName;
        public String depFltName;
        public String arrBookingPax;
        public String depBookingPax;
    }

    ////////////////////////////////////////////////////

    global class masterData_model {
        public Map<String, String> nation;
        public List<String> station;
        public String ropCond;
    }

    // ROP Enrollment

    global class ropEnrollment {
        public String ropNumber;
        public String paxKey;
        public String fltId;
        public String fltNum;
        public String accId;
        public String paxId;
        public String salut;
        public String firstN;
        public String lastN;
        public String phnType;
        public String cCode;
        public String aCode;
        public String phnNum;
        public String email;
        public String nation;
        public String enrollD;
        public String birth;
        public String gender;
        public String status;
        public String sfdcId;
        public String isSynced;
        public String reason;
        public String creBy;
        public String repBy;
    }

    global class userPrefs {
        public String station;
        public String acReg;
        public String acType;
        public String status;
    }

    global class upgradeSeat {
        public String id;
        public String ropNumber;
        public String toClass;
        public String toSeat;
        public String paxKey;
        public String fltId;
        public String paxId;
        public String upCode;
        public Integer isVoided;
        public String creDT;
    }
}