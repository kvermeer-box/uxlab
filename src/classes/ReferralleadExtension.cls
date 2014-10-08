public with sharing class ReferralleadExtension {
    
    private final Lead weblead;
    public string repName {get; set;}
    public User usr {get;set;}
    public boolean redirect{get;set;}
     
    public ReferralleadExtension(ApexPages.StandardController
                                stdController) {
       weblead = (Lead)stdController.getRecord();
       redirect=false;
        
    }

     public PageReference saveLead() {
        if(weblead.Previously_Worked_With__c != 'No' && String.isBlank(repName)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill Representative Name');
            ApexPages.addMessage(myMsg);
            return null;
        }
     usr = [select accountId, contactId, Id,TimeZoneSidKey from User where Id = : UserInfo.getUserId()];
       try {
        if(usr.AccountId != null){
       weblead.Referrer_Partner_ID__c=usr.AccountId;
        }
        weblead.Status='Mailman';
        weblead.Referrer_Partner_name__c=weblead.Referrer_First_Name__c+' '+weblead.Referrer_last_Name__c;
        Weblead.OwnerId=[select Id from Group where DeveloperName = 'Inbound' and Type = 'Queue'].id;
        weblead.Contact_Method__c='Partner Lead Submission';
        weblead.Contact_Method_Original__c='Partner Lead Submission';
        weblead.Lead_Notes__c='Deal Timing:'+weblead.Deal_Timing__c+'\n Why Box:'+weblead.Why_Box__c+'\n Worked With Sales Rep:'+weblead.Previously_Worked_With__c+
                                '\n Prior Sales Rep Name:'+repName+'\n Preference On Next Contact:'+weblead.Preference_on_Contact__c+'\n Referrer Partner Name:'+weblead.Referrer_First_Name__c+' '+weblead.Referrer_last_Name__c+
                                '\n Referrer Partner Phone:'+weblead.Referrer_Partner_Phone__c+'\n Referrer Partner Email:'+weblead.Referrer_Partner_Email__c;
       insert(weblead);
      
       }
       catch(System.DMLException e) {
           ApexPages.addMessages(e);
           return null;
       }
        //weblead.clear();
       //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Thanks for Submitting a Referral');
       //ApexPages.addMessage(myMsg);
       redirect=true;
       return null;
     }

}