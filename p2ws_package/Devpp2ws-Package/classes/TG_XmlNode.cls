public virtual class TG_XmlNode {
    public static final Integer DEPTH_TILL_LEAF = -1;
    public static final Integer DEPTH_BASE = 0;
    public static final Integer MAX_ELEMENTS_TILL_LEAF = -1; 
    
    /*
       The Native Dom.XMLNode its made available if one wants to use the Spring 10 node at some point   
    */
    public Dom.XmlNode xmlNode {get;private set;}
    
    /*
        Returns the root element (document object) for a node   
    */
    public Dom.Document ownerDocument {get; private set;}
        
    public TG_XmlNode(Dom.XmlNode node, Dom.Document owner) {
        xmlNode = node;
        ownerDocument = owner;
    }

    /**
        Returns the name of a node  
    */
    public String nodeName {
        get{
            return xmlNode.getName();
        } protected set;}
    
    /**
        Sets or returns the value of a node
    */
    public String nodeValue {
        get{ 
            return xmlNode.getText();
        } 
        set{
            Dom.XmlNode[] existing  = xmlNode.getChildren();
            if (existing != null && !existing.isEmpty()) 
                for (Dom.XmlNode n : existing) 
                    if (n.getNodeType() == dom.XmlNodeType.TEXT) xmlNode.removeChild(n); 
            xmlNode.addTextNode(value); 
        }
    }
    
    /*
        Returns a NodeList of child nodes for a node
    */  
    public List<TG_XmlNode> childNodes {
        get {
            Dom.XmlNode[] kidNodes = this.xmlNode.getChildren();
            childNodes = new List<TG_XmlNode>();
            if (kidNodes != null && !kidNodes.isEmpty()) {
                for (Dom.XmlNode kid: kidNodes )
                    childNodes.add(new TG_XmlNode(kid, ownerDocument)); 
            } 
            return childNodes;
        } protected set;
    }   
    
    /*
        The firstChild property returns the first child node of this Dom Element.
    */
    public TG_XmlNode firstChild {
        get {
            Dom.XmlNode[] kids  = this.xmlNode.getChildren();
            return kids != null && !kids.isEmpty() ? new TG_XmlNode(kids[0], ownerDocument) : null;
        } protected set;
    }
    
    /*
        The lastChild property returns the last child node of this Dom Element.
    */
    public TG_XmlNode lastChild {
        get {
            Dom.XmlNode[] kids  = this.xmlNode.getChildren();
            return kids != null && !kids.isEmpty() ? new TG_XmlNode(kids[kids.size() - 1], ownerDocument) : null;
        } protected set;
    }
    
    /*
        The namespaceURI property sets or returns the namespace URI of this element.
    */
    public String namespaceURI {
        get {
            return xmlNode.getNamespace();
        } 
        set {
            xmlNode.setNamespace('', value);
        }
    }
    
    /*
        Returns the node immediately following a node   
    */
    public TG_XmlNode nextSibling {
        get {
            TG_XmlNode next = null;
            Dom.XmlNode parent = xmlNode.getParent();
            if (parent == null) return next;
            Dom.XmlNode[] kids = parent.getChildren();
            Integer thisNodeIdx = -1;
            if (kids != null && !kids.isEmpty()) {
                for (Integer idx = 0; idx < kids.size() ; idx++) {
                    Dom.XmlNode kid = kids[idx];
                    if (kid == this.xmlNode) {
                        thisNodeIdx = idx;
                        break;  
                    }
                }
                if (thisNodeIdx >= 0 && thisNodeIdx < (kids.size() -1)) {
                    next = new TG_XmlNode(kids [thisNodeIdx + 1], ownerDocument);       
                }   
            }
            return next;    
        } protected set;
    }
    
    /*
        Returns the root element for a node
    */
    public TG_XmlNode root {
        get {
            Dom.XmlNode ret = this.xmlNode; 
            while( ret.getParent() != null) { ret = ret.getParent(); }      
            // if one is at root return this otherwise create a new root element    
            return ret == this.xmlNode ? this : new TG_XmlNode(ret, ownerDocument) ;    
        } 
    } 

    /* 
        Returns the parent node of a node
    */
    public TG_XmlNode parentNode {
        get{
            Dom.XmlNode p = xmlNode.getParent();
            return p != null ? new TG_XmlNode(p, ownerDocument): null;
        } 
        protected set;
    }
    
    /*
        Returns the namespace prefix of a node
        LIMITATION: We are not allowing to change the prefix
    */  
    public String prefix {
        get {
            return xmlNode.getNamespace() != null ? xmlNode.getPrefixFor(xmlNode.getNamespace()) : null;
        } private set;
    }
    
    /*
        Returns the node immediately before a node
    */  
    public TG_XmlNode previousSibling   {
        get {
            TG_XmlNode prev = null;
            Dom.XmlNode parent = xmlNode.getParent();
            if (parent == null) return prev;
            Dom.XmlNode[] kids = parent.getChildren();
            Integer thisNodeIdx = -1;
            if (kids != null && !kids.isEmpty()) {
                Integer idx = kids.size() - 1;
                for (; idx > -1; idx--) {
                    Dom.XmlNode kid = kids[idx];
                    if (kid == this.xmlNode) {
                        thisNodeIdx = idx;
                        break;  
                    }
                }
                if (thisNodeIdx > 0) {
                    prev = new TG_XmlNode(kids [thisNodeIdx - 1], ownerDocument);       
                }   
            }
            
            return prev;    
        } protected set;
    }

    
    /*
        Returns the Node type out of all 12 nodetypes only 3 are supported
        • COMMENT
        • ELEMENT
        • TEXT
        
        ZERO (0) is returned on unsupported type
    */
    public Integer nodeType {
        get{
            if (nodeType == null) {
                dom.XmlNodeType nt = xmlNode.getNodeType();
                if (nt == dom.XmlNodeType.ELEMENT) 
                    nodeType = 1;
                else if (nt == dom.XmlNodeType.TEXT) 
                    nodeType = 3;   
                else if (nt == dom.XmlNodeType.COMMENT) 
                    nodeType = 8;
                else
                    nodeType = 0;
            }   
            return nodeType;  
        } protected set;
    }
    
    /*
        The textContent property sets or returns the textual content of a node and its descendants.
        On setting, any child nodes are removed and replaced by a single Text node containing the string this property is set to.
    */
    public String textContent{
        get {
            return getTextContents(xmlNode);
        }
        set {
            Dom.XmlNode[] existing  = xmlNode.getChildren();
            if (existing != null && !existing.isEmpty()) 
                for (Dom.XmlNode n : existing) 
                    xmlNode.removeChild(n); 
            xmlNode.addTextNode(value); 
        }
    }   
        
    protected Map<String,String> attributes {
        get {
            if (attributes != null) return attributes;
            attributes = new Map<String, String>();
            Integer attribCount = xmlNode.getAttributeCount();
            for (Integer idx = 0 ; idx < attribCount ; idx ++) {
                String aNs = xmlNode.getAttributeKeyNsAt(idx);
                String aKey = xmlNode.getAttributeKeyAt(idx);
                String aVal = xmlNode.getAttributeValue(aKey, aNs);
                attributes.put(aKey, aVal);
            }
            return attributes;
        } protected set;
    }
    
    /*
        Returns attribute value for the attribute name
    */  
    public virtual String getAttribute(string name) {
        return attributes.get(name); 
    }
    
    /*
        Returns all the Elements matching the specified tag name.
        Though its an advanced form of standard method "getElementsByTagName" for developers, 
        who want more control on depth and maximum number of elements to be returned.
    */
    public virtual List<TG_XmlNode> getElementsByTagName(String nam, Integer depth, Integer maxElements) {
        Integer colonIdx = nam.indexOf(':');
        String nameSpace = null;
        if (colonIdx > 0 ) {
            String nameSpacePrefix = nam.substring(0, colonIdx);
            nam = nam.substring(colonIdx + 1);
            System.debug(System.Logginglevel.Info, 'nameSpacePrefix:' +nameSpacePrefix);
            nameSpace = this.xmlNode.getNamespaceFor(nameSpacePrefix);  
        }
        
        return getElementsByTagName(nam, nameSpace, depth, maxElements);
    }   
    
    /*
        Returns all the Elements matching the specified tag name.
        Though its an advanced form of standard method "getElementsByTagName" for developers, 
        who want more control on namespace, depth and maximum number of elements to be returned.
        
        One can speed up the lookup, if he doesn't wants to 
        digg till leaf now. For ex. if one is at root node and wants to 
        get all matching child elements upto depth 2 only, then this param
        can be used for this. 
    */
    protected virtual List<TG_XmlNode> getElementsByTagName(String nam, String nameSpace, Integer depth, Integer maxElements) {
        // matching elements by tag name
        List<TG_XmlNode> ret = new List<TG_XmlNode>();
        
        // Check if this node is matching the mentioned tag name.
        if (xmlNode.getName().equalsIgnoreCase(nam) 
            // If namespace if there match that too, otherwise ignore.
                && (nameSpace == null || (nameSpace != null && nameSpace.equalsIgnoreCase(xmlNode.getNamespace())))) ret.add(this);
        
        //System.debug('>> NODE:' + xmlNode.getName() + ' depth : ' + depth + ' max : ' + maxElements);
        
        // If we have reached till required depth, then return
        if (depth == DEPTH_BASE) return ret;        

        // This flag will enforce return of limited no. of elements, instead of 
        // full fledged search inside DOM. Thi will speed up specially when one wants
        // just the first element for a tag name
        boolean limitReturnedElements = maxElements > 0;
        // If required number of elements are fetched then return
        if (limitReturnedElements && (ret.size() >= maxElements)) {
            return ret;
        }
            
                        
        // Add kids and their kids
        Dom.XmlNode [] kids = xmlNode.getChildElements();
        if (kids != null && !kids.isEmpty()) {
            // we are diving into kids so reduce the depth, if we don't need to dive till leaf
            depth = depth == DEPTH_TILL_LEAF ? DEPTH_TILL_LEAF : depth - 1;
            for (Dom.XmlNode kid: kids) {
                TG_XmlNode kidElement = new TG_XmlNode(kid, ownerDocument);
                Integer childMaxElements = limitReturnedElements ? (maxElements - ret.size()) : MAX_ELEMENTS_TILL_LEAF;
                //System.debug('>> KID-NODE:' + kidElement.xmlNode.getName() + ' depth : ' + depth + ' max : ' + childMaxElements);
                ret.addAll(kidElement.getElementsByTagName(nam, nameSpace, depth, childMaxElements));
                
                // if we have fetched the required number of elements that return
                if (limitReturnedElements && ret.size() >= maxElements) break;
            } 
        }  
        return ret;
    }
        
    /**
        Returns all the Elements matching the specified tag name.
    */
    public virtual List<TG_XmlNode> getElementsByTagName(String nam) {
        return getElementsByTagName(nam, DEPTH_TILL_LEAF, MAX_ELEMENTS_TILL_LEAF);
    }
    
    /*
        Returns the namespace URI matching a specified prefix
    */ 
    public virtual String lookupNamespaceURI(String prefix) {
        return xmlNode.getNamespaceFor(prefix);
    }
    
    /*
        Returns the prefix matching a specified namespace URI
    */ 
    public virtual String lookupPrefix(String nsURI) {
        return xmlNode.getPrefixFor(nsURI);
    }
                            
    /*
        Returns single Element matching the specified tag name.
    */   
    public virtual TG_XmlNode getElementByTagName(String nam) {
        List<TG_XmlNode> elem = getElementsByTagName(nam, DEPTH_TILL_LEAF, 1); 
        return elem != null && !elem.isEmpty() ? elem[0] : null;
    }
    
    /*
        Returns true if a node has any attributes, otherwise it returns false   
    */
    public virtual Boolean hasAttributes() {
        return xmlNode.getAttributeCount() > 0;
    }   
    
    /*
        Returns true if a node has any child nodes, otherwise it returns false
    */  
    public virtual Boolean hasChildNodes() {
        Dom.XmlNode [] nativeKids = xmlNode.getChildren();
        return nativeKids != null && !nativeKids.isEmpty();     
    }
    
    /*
        Returns whether the specified namespaceURI is the default   
    */
    public virtual Boolean isDefaultNamespace(String uri) {
        return uri == this.xmlNode.getNamespace();
    }
    
    /*
        Removes a child node
    */
    public virtual Boolean removeChild (TG_XmlNode child) {
        return this.xmlNode.removeChild(child.xmlNode);
    }

    /*
        Returns Xml Rep of this node
    */
    public String toXmlString() {
        String ns = xmlNode.getNamespace();
        String prefix = ns == null ? '' : xmlNode.getPrefixFor(ns);
        prefix = prefix == '' || prefix == null ? '' : prefix + ':';   
        String xmlrep = '<' +  prefix + xmlNode.getName() ;
        Integer attribCount = xmlNode.getAttributeCount();
        for (Integer idx = 0 ; idx < attribCount ; idx ++) {
            String aNs = xmlNode.getAttributeKeyNsAt(idx);
            String aKey = xmlNode.getAttributeKeyAt(idx);
            String aVal = xmlNode.getAttributeValue(aKey, aNs);
            String aPrefix = '';
            aPrefix = aNs == null ? '' : xmlNode.getPrefixFor(aNs);
            aPrefix = aPrefix == '' || aPrefix == null ? '' : aPrefix + ':';
            xmlrep += ' ' +aPrefix + aKey + '=\'' + aVal + '\'' ;
        }
        xmlrep += '>';
        
        Dom.XmlNode [] children = xmlNode.getChildren();
        if (children != null && !children.isEmpty()) {
            for (Dom.XmlNode child : children) {
                if (child.getNodeType() == dom.XmlNodeType.TEXT) {
                    xmlrep += child.getText();
                } else if (child.getNodeType() == dom.XmlNodeType.COMMENT) {
                    // do nothing ! 
                } else if (child.getNodeType() == dom.XmlNodeType.ELEMENT) {
                    xmlrep += new TG_XmlNode(child, ownerDocument).toXmlString();
                }
            }   
        } 
                    
        return xmlrep + '</' + prefix + xmlNode.getName() + '>';
    }
    
    private static String getTextContents(Dom.XmlNode node) {
        String textRep = '';
        Dom.XmlNode [] children = node.getChildren();
        if (children != null && !children.isEmpty()) {
            for (Dom.XmlNode child : children) {
                if (child.getNodeType() == dom.XmlNodeType.TEXT) {
                    textRep += ' ' + child.getText();
                } else if (child.getNodeType() == dom.XmlNodeType.ELEMENT) {
                    textRep += ' ' + getTextContents(child);
                }
            }   
        } 
        return textRep.trim() ;
    }
}