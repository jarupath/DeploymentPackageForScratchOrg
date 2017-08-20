public class WS_CabinLogResponseModel {

    public Customercomplaintreply result;

    public class Customercomplaintreply {
        public String Responsetype;
        public String Responsetext;
    }

    
    public static WS_CabinLogResponseModel parse(String json) {
        return (WS_CabinLogResponseModel) System.JSON.deserialize(json, WS_CabinLogResponseModel.class);
    }
}