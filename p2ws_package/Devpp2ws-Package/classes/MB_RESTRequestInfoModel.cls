/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:  All Model to support Restful API to inquiry information from SFDC

History :
<Date>      <Authors Name>     <Brief Description of Change>
28/08/2016  Charnun.T           First Create
------------------------------------------------------------*/
global class MB_RESTRequestInfoModel {

    /* Crew Duty Assignment Model */

    global class updateCrewDutyAssignment_model {
        public List<crewDutyAssignment_model> returnResults {get{
                if (returnResults == null)
                    returnResults = new List<crewDutyAssignment_model>();
                return returnResults;
            } set;
        }
    }

    global class crewDutyAssignment_model {
        public String fltId;
        public String oldDuty;
        public String newDuty;
        public String sfdcId; //crew list id
        public String perno;
        public String updtstatus;
    }

    global class crewDutyAssignment_resp_model {
        public String staus;
        public Integer recNo;
    }

    /////////////////////////////////////////////////////

    /* Crew Apprraisal Answer Model */

    global class createUpdateCrewApprraisalAnswer_model {
        public List<crewAppraisalAnswer_model> returnResults {get{
                if (returnResults == null)
                    returnResults = new List<crewAppraisalAnswer_model>();
                return returnResults;
            } set;
        }
    }

    global class crewAppraisalAnswer_model {
        public String id;
        public String crewId;
        public String fltId;
        public String cateId;
        public crewAppraisalAnswer_CAAQ[] CAAQ;
        public String score;
        public String lastEva;
        public String evaNo;
        public String commt;
        public String sfdcId;
    }

    global class crewAppraisalAnswer_CAAQ {
        public String id;
        public String CAACId;
        public String CAQId;
        public String sex;
        public String score;
        public crewAppraisalAnswer_subQuest[] subQuest;
        public String sfdcId;
    }

    global class crewAppraisalAnswer_subQuest {
        public String id;
        public String CAAQId;
        public String CASQId;
        public String commt;
        public String sfdcId;
    }

    /////////////////////////////////////////////////////

    /* ROP Application Model */

    global class createROPApplication_model {
        public List<createROPApplication_model> returnResults {get{
                if (returnResults == null)
                    returnResults = new List<createROPApplication_model>();
                return returnResults;
            } set;
        }
    }

    global class ropApplication_model {
        public String id;
        public String ropNo;
        public String paxId;
        public String ropTier;
        public String loySts;
        public String addr;
        public String phone;
        public String mobile;
        public String email;
        public String ropMi;
        public String expMi;
        public String miExpD;
        public String seatPre;
        public String sfdcId;
        public String favFood;
        public String occup;
        public String lang;
    }

    /////////////////////////////////////////////////////

    /* Passenger Psychology Model */


    global class passengerPsychology_model {
        public String accId;
        public String paxKey;
        public String pLike;
        public String dislike;
        public String byOther;
        public String bySale;
        public String byGnd;
    }

    /////////////////////////////////////////////////////

    /* Incident Attachment Model */

    global class createUpdateAttachment_model {
        public List<createUpdateAttachment_model> returnResults {get{
                if (returnResults == null)
                    returnResults = new List<createUpdateAttachment_model>();
                return returnResults;
            } set;
        }
    }

    global class incidentAttachment_model {
        public String id;
        public String path;
        public String inId;
        public String sfdcId;
    }

    global class attachment {
        public String body;
        public String name;
        public String contenttype;
        public String parentId;
    }

    global class attachment_list {
        public List<String> body;
        public String name;
        public String contenttype;
        public String parentId;
        public String attachmentId;
        public String description;
    }

    global class attachment_response {
        public String attachmentId;
        public String parentId;
        public List<String> salesforceId;
    }

    /////////////////////////////////////////////////////

    /* Incident Model */

    global class incident_model {
        public String id;
        public String sfdcId;
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
        public String logType; //Incident Type: Cabin Log, Flight Log
        public incident_compensation[] compen;
        public Integer status; //Open, Closed, Resolved
        public Integer isLog;
        public Integer isMulti;
        public Integer isVoided;
        public String rptType;
        public Integer emerType;
        public String inCate; //Service, Passenger, Safety, Other, Emergency, Maintenance
        public String safetyZone;
        public String acReg;
        public String action;
        public String phone;
        public String email;
        public String authName;
        public String authNumber;
        public String upChgType;
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
        //public String newPos;
        //public String newClass;
        public String role;
        public String detail;
        public String accId;
        public String paxKey;
        public String sfdcId;
    }

    /////////////////////////////////////////////////////
    //Crew Image
    global class crewImage {
        public String image;
        public String name;
    }

    //E-Document
    global class allDoc {
        public String flightId;
        public String manual;
        public String functionInfo;
        public String safety;
        public String service;
        public List<dynamicLink> dynamicLinkList = new List<dynamicLink>();
    }

    global class dynamicLink {
        public String name;
        public String link;
        public Boolean multiFlag;
        public String startWith;
    }
    /////////////////////////////////////////////////////

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
        public String creBy;
        public String repBy;
    }

    global class crewAppraisalFormAnswer {
        public String sfdcId;
        public String appraisalId;
        public Integer isSynced;
        public String staffNum;
        public String formNum;
        public String evaStaffNum;
        public String evaFltSfdcId;
        public String evaFltExtId;
        public String evaArlnCd;
        public String evaFltNum;
        public String evaFltDt;
        public String comment;
        public String createdDate;
        public List<crewAppraisalSubjectAnswer> subjs;
    }

    global class crewAppraisalSubjectAnswer {
        public String subjNum;
        public String value;
        public List<crewAppraisalItemAnswer> items;
        public String comment;
    }

    global class crewAppraisalItemAnswer {
        public String itemNum;
        public String value;
        public String mdType;
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
        public String payType;
        public Decimal amount;
        public String currenc;
        public String detail;
        public Integer isVoided;
        public String creDT;
    }

    global class userPrefs {
        public String station;
        public String acReg;
        public String acType;
    }
}