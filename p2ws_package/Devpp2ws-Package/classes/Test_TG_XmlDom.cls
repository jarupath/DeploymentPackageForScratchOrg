@isTest
private class Test_TG_XmlDom {
                                    
    static testMethod void testCreateFromXml() {
        TG_XmlDom dom = TG_XmlDom.createFromXml('<price>29.99</price>');
        String asXml = dom.root.toXmlString();
        System.assertEquals('<price>29.99</price>', asXml);         
    }

    static testMethod void testCreateForRootElement() {
        TG_XmlDom dom = TG_XmlDom.createForRootElement('price');
        System.assertEquals('price', dom.root.nodeName);        
    }
    
    static testMethod void testCreateForRootElement2() {
        TG_XmlDom dom = TG_XmlDom.createForRootElement('price', null, null);
        System.assertEquals('price', dom.root.nodeName);        
    }
    
    static testMethod void testToXmlString() {
        TG_XmlDom dom = TG_XmlDom.createFromXml('<price>29.99</price>');
        System.assertEquals('<?xml version="1.0" encoding="UTF-8"?><price>29.99</price>', dom.toXmlString());       
    }
    
    static testMethod void testOwnerDocument() {
        TG_XmlDom dom = TG_XmlDom.createFromXml('<price>29.99</price>');
        System.assert(null != dom.ownerDocument);       
    }
    
}