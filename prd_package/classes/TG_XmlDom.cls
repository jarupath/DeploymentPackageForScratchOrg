public class TG_XmlDom {
    
    private Dom.Document domDoc = new Dom.Document();
    // everything in the dom is found as childNodes under this root element
    public TG_XmlNode root {get; private set;}
    
    // utility dom functions
    public Dom.Document ownerDocument { get {return domDoc;} private set; }

    // dump out the element tree
    public String toXmlString() { return domDoc.toXmlString(); }
    
    // Constructor
    public TG_XmlDom(String xml) {
        domDoc.load(xml);
        Dom.XmlNode rootXmlNode = domDoc.getRootElement();
        root = new TG_XmlNode(rootXmlNode, ownerDocument); 
    }
    
    public TG_XmlDom(String rootElementName, String rootElementNamespace, String rootElementPrefix) { 
        Dom.XmlNode rootXmlNode  = domDoc.createRootElement(rootElementName, rootElementNamespace, rootElementPrefix);
        root = new TG_XmlNode(rootXmlNode, ownerDocument);
    }
    
     
    // FACTORY METHODS //
    public static TG_XmlDom createForRootElement(String rootElementName) {
        return new TG_XmlDom(rootElementName, null, null);  
    }   
    
    public static TG_XmlDom createForRootElement(String rootElementName, String rootElementNamespace, String rootElementPrefix) {
        return new TG_XmlDom(rootElementName, rootElementNamespace, rootElementPrefix);
    }       
    
    public static TG_XmlDom createFromXml(String xml) {
        return new TG_XmlDom(xml);
    }
}