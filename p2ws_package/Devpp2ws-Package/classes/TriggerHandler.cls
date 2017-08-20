public virtual class TriggerHandler {
    public Map<Id, sObject> oldMap;
    public Boolean isInsert = false;
    public Boolean isUpdate = false;

    public void setup(Boolean isInsert, Boolean isUpdate, Boolean isDelete, Map<Id, sObject> oldMap) {
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.oldMap = oldMap;
    }
}