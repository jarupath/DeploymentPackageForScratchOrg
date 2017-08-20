public class TG_UsernameToken_element {        
	public String username;
    public String password;
  	public String nonce;
  	public String created;

    private String[] username_type_info = new String[]{'Username','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
    private String[] password_type_info = new String[]{'Password','http://www.w3.org/2001/XMLSchema','Password_element','1','1','false'};
	private String[] nonce_type_info = new String[]{'Nonce','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
	private String[] created_type_info = new String[]{'Created','http://www.w3.org/2001/XMLSchema','string','1','1','false'};    
    private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
    private String[] field_order_type_info = new String[]{'username','password','nonce','created'};

    public TG_UsernameToken_element(String username, String password) {        
        this.username = username;
        this.password = password;
        this.nonce = generateNounce();
        this.created = generateTimestamp();
    }
        
    // Generate Nounce, random number base64 encoded
    public String generateNounce(){
        Long randomLong = Crypto.getRandomLong();
        String nonce = EncodingUtil.base64Encode(Blob.valueOf(String.valueOf(randomLong)));
        if(nonce.length() > 28){
            nonce = nonce.substring(0, 28);
        }
        return nonce;
    }

    // Generate timestamp in GMT
    public String generateTimestamp(){
        return Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }       
}