public with sharing class CaseEmailController {
    
    private ApexPages.StandardController stdController;
    public Case eachCase {get; set;}
    public List<EmailMessage> internalEmailList {get; set;}
    public List<EmailMessage> externalEmailList {get; set;}
    public List<EmailMessage> allInternalEmailList {get; set;}
    public List<EmailMessage> allExternalEmailList {get; set;}

    public Integer internalEmailPageSize {get; set;}
    public Integer externalEmailPageSize {get; set;}

    public String imageStringNext{get;set;}
    public String imageStringPrev{get;set;}

    public Boolean internalNextRender{get;set;}
    public Boolean internalPrevRender{get;set;}
    public String currentInternalPage{get;set;}
    public String internalPageIndex{get;set;}
    public Integer pageOfInternal;
    public Integer internalTotalPage;
    public Integer internalStartIndex;
    public Integer internalPointerIndex;
    public Integer internalEndIndex;

    public Boolean externalNextRender{get;set;}
    public Boolean externalPrevRender{get;set;}
    public String currentExternalPage{get;set;}
    public String externalPageIndex{get;set;}
    public Integer pageOfExternal;
    public Integer externalTotalPage;
    public Integer externalStartIndex;
    public Integer externalPointerIndex;
    public Integer externalEndIndex;

    public CaseEmailController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.eachCase = (Case) stdController.getRecord();
        refreshEmailList();
        resetPageHandler();
        pageHandler();
    }

    private void refreshEmailList() {
        this.internalEmailList = new List<EmailMessage>();
        this.externalEmailList = new List<EmailMessage>();
        this.allInternalEmailList = new List<EmailMessage>();
        this.allExternalEmailList = new List<EmailMessage>();

        List<EmailMessage> allEmailList = new List<EmailMessage>();
        allEmailList = [SELECT Id, Status, Subject, TextBody, FromAddress, ToAddress, MessageDate, Internal__c,Internal_Email__c FROM EmailMessage WHERE ParentId = :this.eachCase.Id ORDER BY MessageDate DESC];
        
        for(EmailMessage eachEmail : allEmailList) {
            if(eachEmail.Internal_Email__c) {
                this.allInternalEmailList.add(eachEmail);   
            } else {
                this.allExternalEmailList.add(eachEmail);
            }
        }
    }

    public void resetPageHandler() {
        imageStringNext = '/img/search_nextarrow.gif';
        imageStringPrev = '/img/search_prevarrow.gif';

        internalEmailPageSize = 5;
        externalEmailPageSize = 5;

        currentInternalPage = '';
        internalStartIndex = 0;
        internalPointerIndex = 0;
        internalTotalPage = 1;
        pageOfInternal = 1;
        internalEndIndex = internalEmailPageSize;

        currentExternalPage = '';
        externalStartIndex = 0;
        externalPointerIndex = 0;
        externalTotalPage = 1;
        pageOfExternal = 1;
        externalEndIndex = externalEmailPageSize;
    }

    public void pageHandler(){
        // Internal Handler Section
        currentInternalPage = '1'+'-'+internalEndIndex+' of '+this.allInternalEmailList.size();
        if(this.allInternalEmailList.size() <= internalEmailPageSize){
            internalNextRender = false;
            internalPrevRender = false;
            internalEndIndex = this.allInternalEmailList.size();
            currentInternalPage = '1'+'-'+internalEndIndex+' of '+this.allInternalEmailList.size();
        } else {
            internalNextRender = true;
            internalPrevRender = false;  
        }
        if(this.allInternalEmailList.size() == 0){
            currentInternalPage = '0 of 0';
        } else {
            for(Integer i = 0; i < internalEndIndex ; i++){
                this.internalEmailList.add(this.allInternalEmailList.get(i));
            }
            internalTotalPage = (this.allInternalEmailList.size()/internalEmailPageSize)+1;
        }
        internalPageIndex = 'Page ' + pageOfInternal + ' of ' + internalTotalPage;

        // External Handler Section
        currentExternalPage = '1'+'-'+externalEndIndex+' of '+this.allExternalEmailList.size();
        if(this.allExternalEmailList.size() <= externalEmailPageSize){
            externalNextRender = false;
            externalPrevRender = false;
            externalEndIndex = this.allExternalEmailList.size();
            currentExternalPage = '1'+'-'+externalEndIndex+' of '+this.allExternalEmailList.size();
        } else {
            externalNextRender = true;
            externalPrevRender = false;  
        }
        if(this.allExternalEmailList.size() == 0){
            currentExternalPage = '0 of 0';
        } else {
            for(Integer i = 0; i < externalEndIndex ; i++){
                this.externalEmailList.add(this.allExternalEmailList.get(i));
            }
            externalTotalPage = (this.allExternalEmailList.size()/externalEmailPageSize)+1;
        }
        externalPageIndex = 'Page ' + pageOfExternal + ' of ' + externalTotalPage;
    }
    public void NextInternalPage(){
        internalPointerIndex = internalPointerIndex + internalEmailPageSize;
        internalStartIndex = internalStartIndex + internalEmailPageSize;
        internalEndIndex = internalEndIndex + internalEmailPageSize;
        Integer startPage = internalStartIndex+1;
        currentInternalPage = startPage+'-'+internalEndIndex+' of '+this.allInternalEmailList.size();
        if(internalStartIndex < this.allInternalEmailList.size()){
            List<EmailMessage> tempList = new List<EmailMessage>();
            if(this.allInternalEmailList.size() <= internalEndIndex){
                internalEndIndex = this.allInternalEmailList.size();
                internalNextRender = false;
                currentInternalPage = startPage+'-'+internalEndIndex+' of '+internalEndIndex;
            }
            for(Integer i = internalStartIndex ; i < internalEndIndex ; i++){
                tempList.add(this.allInternalEmailList[i]);
            }
            internalPrevRender = true;        
            this.internalEmailList = tempList;
        }
        pageOfInternal++;
        internalPageIndex = 'Page '+pageOfInternal+' of '+internalTotalPage;
    }
    public void PrevInternalPage(){
        internalPointerIndex = internalPointerIndex - internalEmailPageSize;
        internalStartIndex = internalPointerIndex;
        internalEndIndex = internalStartIndex + internalEmailPageSize;
        Integer startPage = internalStartIndex+1;
        currentInternalPage = startPage+'-'+internalEndIndex+' of '+this.allInternalEmailList.size();
        List<EmailMessage> tempList = new List<EmailMessage>();
        if(internalStartIndex == 0){
            internalPrevRender = false;            
        }
        for(Integer i = internalStartIndex ; i < internalEndIndex ; i++){
            tempList.add(this.allInternalEmailList[i]);
        }
        internalNextRender = true;
        pageOfInternal--;
        internalPageIndex = 'Page '+pageOfInternal+' of '+internalTotalPage;
        this.internalEmailList = tempList;
    }
    public void NextExternalPage(){
        externalPointerIndex = externalPointerIndex + externalEmailPageSize;
        externalStartIndex = externalStartIndex + externalEmailPageSize;
        externalEndIndex = externalEndIndex + externalEmailPageSize;
        Integer startPage = externalStartIndex+1;
        currentExternalPage = startPage+'-'+externalEndIndex+' of '+this.allExternalEmailList.size();
        if(externalStartIndex < this.allExternalEmailList.size()){
            List<EmailMessage> tempList = new List<EmailMessage>();
            if(this.allExternalEmailList.size() <= externalEndIndex){
                externalEndIndex = this.allExternalEmailList.size();
                externalNextRender = false;
                currentExternalPage = startPage+'-'+externalEndIndex+' of '+externalEndIndex;
            }
            for(Integer i = externalStartIndex ; i < externalEndIndex ; i++){
                tempList.add(this.allExternalEmailList[i]);
            }
            externalPrevRender = true;        
            this.externalEmailList = tempList;
        }
        pageOfExternal++;
        externalPageIndex = 'Page '+pageOfExternal+' of '+externalTotalPage;
    }
    public void PrevExternalPage(){
        externalPointerIndex = externalPointerIndex - externalEmailPageSize;
        externalStartIndex = externalPointerIndex;
        externalEndIndex = externalStartIndex + externalEmailPageSize;
        Integer startPage = externalStartIndex+1;
        currentExternalPage = startPage+'-'+externalEndIndex+' of '+this.allExternalEmailList.size();
        List<EmailMessage> tempList = new List<EmailMessage>();
        if(externalStartIndex == 0){
            externalPrevRender = false;            
        }
        for(Integer i = externalStartIndex ; i < externalEndIndex ; i++){
            tempList.add(this.allExternalEmailList[i]);
        }
        externalNextRender = true;
        pageOfExternal--;
        externalPageIndex = 'Page '+pageOfExternal+' of '+externalTotalPage;
        this.externalEmailList = tempList;
    }
}