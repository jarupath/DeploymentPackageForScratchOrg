public class genericMultiSelectPicklist {
    
    @AuraEnabled
    public static List<String> getPicklistvalues(String objectName, String field_apiname){
        List<String> optionlist = new List<String>();
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
        
         List<Schema.PicklistEntry> pick_list_values = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : pick_list_values) 
        {
            optionlist.add(a.getValue());
        }
        return optionlist;
    }
}