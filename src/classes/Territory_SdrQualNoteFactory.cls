public class Territory_SdrQualNoteFactory {

	public static SDR_Qualification_Notes__c createSdrQualNote(Lead l, String ownerId, String accId) { 
        System.debug(System.LoggingLevel.ERROR, 'Territory_SdrQualNoteFactory: Creating qual note...');
        
        SDR_Qualification_Notes__c sdrQualNote = new SDR_Qualification_Notes__c();
        if (l.Company != null && l.Company.length() <= 68) {
            sdrQualNote.Name = l.Company + ' Qual Notes';
        } else {
            sdrQualNote.Name = 'Qual Notes';
        }
          
        sdrQualNote.About_the_Company__c       = l.About_the_Company__c;
        sdrQualNote.Business_Objective__c      = l.Business_Objective__c;
        sdrQualNote.Competition__c             = l.Competition__c;
        sdrQualNote.Decision_Makers__c         = l.Decision_Makers__c;
        sdrQualNote.How_They_Found_Box__c      = l.How_They_Found_Box__c;
        sdrQualNote.Next_Steps__c              = l.Next_Steps__c; 
        sdrQualNote.Pain__c                    = l.Pain__c;
        sdrQualNote.Number_of_Users__c         = l.Number_of_Users__c;      
        sdrQualNote.Employees_User_Defined__c  = l.Employees__c;
        sdrQualNote.NumberOfEmployees__c       = l.NumberOfEmployees;
        sdrQualNote.Scope_of_Deployment__c     = l.Scope_of_Deployment__c;
        sdrQualNote.Number_of_Upsell_Users__c  = l.Number_of_Upsell_Users__c; 
        sdrQualNote.Budget__c                  = l.Budget__c; 
        sdrQualNote.CurrencyIsoCode            = l.CurrencyIsoCode;
        sdrQualNote.OwnerId                    = ownerId;
        
        if (accId != null) {
            sdrQualNote.Account__c = accId;
        }
        
        // Don't make empty qual notes
        if (l.About_the_Company__c != null || 
        	l.Business_Objective__c != null || 
        	l.Competition__c != null || 
            l.Decision_Makers__c != null || 
            l.How_They_Found_Box__c != null || 
            l.Next_Steps__c != null ||
            l.Pain__c != null || 
            l.Scope_of_Deployment__c != null || 
            l.Budget__c != null) {          
            	System.debug('Territory_SdrQualNoteFactory: Sdr qual note will be created');       
        } else {
        	sdrQualNote = null;
        } 
        return sdrQualNote;
    }   

}