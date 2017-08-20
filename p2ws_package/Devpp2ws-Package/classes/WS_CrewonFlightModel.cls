public class WS_CrewonFlightModel {

    public CrewOnFlightQueryRes CrewOnFlightQueryRes {get; set;}

    public class Return_Z {
        public String actrank {get; set;}
        public String arrStation {get; set;}
        public String depStation {get; set;}
        public String dutyassign {get; set;}
        public String dutycode {get; set;}
        public String evaLastDate {get; set;}
        public String evaNum {get; set;}
        public String firstname {get; set;}
        public String fltDateUTC {get; set;}
        public String fltNo {get; set;}
        public String lastname {get; set;}
        public String posfly {get; set;}
        public String rank {get; set;}
        public String returnfltdate {get; set;}
        public String returnfltno {get; set;}
        public String seqNo {get; set;}
        public String staffno {get; set;}
        public String nickname {get; set;}
        public String thirdlang {get; set;}
        public String gender {get; set;}
        //public String crewimage {get;set;}
    }

    public class CrewOnFlightQueryRes {
        public String xmlns {get; set;}
        public String ns0 {get; set;}
        public String ns2 {get; set;}
        public String tns {get; set;}
        public String tns1 {get; set;}
        public List<Return_Z> return_Z {get; set;} // in json: return
    }
}