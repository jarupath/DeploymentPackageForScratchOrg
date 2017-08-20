public class TG_Security_element {
	public TG_UsernameToken_element usernameToken;
    private String[] usernameToken_type_info = new String[]{'UsernameToken','http://www.w3.org/2001/XMLSchema','element','1','1','false'};
    private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
    private String[] field_order_type_info = new String[]{'usernameToken'};

	public TG_Security_element(String username, String password){   
        usernameToken = new TG_UsernameToken_element(username, password);
    }
}