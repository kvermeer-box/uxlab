global class QuoteMachine_UpsellCreatorController_v2 {

    // Controller fields
    public Apexpages.StandardController controller;
    public Quote q {get; set;}
    public Quote guessedQuote {get; set;}
    
    // Parent objects
    public String accountId {get; set;}
    public Opportunity opp {get; set;}

    public QuoteMachine_UpsellCreatorController_v2(ApexPages.StandardController controller) {
        // Initial stuff
        this.controller = controller;
        q = (Quote)controller.getRecord();
        
        // Get page parameters
        q.OpportunityId = System.currentPageReference().getParameters().get('oppid'); 
        accountId = System.currentPageReference().getParameters().get('accid'); 
        q.RecordTypeId = System.currentPageReference().getParameters().get('recordType'); 
        
        // Pre-populate payment info
        prepopulateGeneralInfo();
        
        // Get historical data
        getHistoricalContractData();
        
        // Copy historical data
        copyEstimatedValues();
    }
    
    public List<UpsellDataSource> getUpsellDataSources() {
        List<UpsellDataSource> dataSources = new List<UpsellDataSource>();
        if (q.Original_Data_Sources__c != null) {
            List<String> nameAndUrl = q.Original_Data_Sources__c.split('<id>');
            for (String s : nameAndUrl) {
                List<String> parsedNameAndUrl = s.split('<name>');
                dataSources.add(new UpsellDataSource(parsedNameAndUrl[0], parsedNameAndUrl[1]));
            }
        }
        return dataSources;
    }
    
    private void prepopulateGeneralInfo() {
        System.debug('Prepopulating general info...');
        
        q.Order_Start_Date__c = Date.today();
        
        if (q.OpportunityId != null) {
                opp = [SELECT Id, Name, Payment_Method__c, (SELECT Id, ContactId FROM OpportunityContactRoles WHERE IsPrimary = true) FROM Opportunity WHERE Id = :q.OpportunityId];
                
                if (opp != null) {
                        
                        // Prepopulate name
                        if (opp.Name != null) {
                                q.Name = opp.Name;
                        }
                        
                        // Prepopulate payment method
                        if (opp.Payment_Method__c != null) {
                                q.Payment_Method__c = mapPaymentMethodFromOppToQuote(opp.Payment_Method__c);
                        }
                        
                        // Prepopulate contact 
                        if (opp.OpportunityContactRoles != null && opp.OpportunityContactRoles.size() > 0) {
                                q.ContactId = opp.OpportunityContactRoles[0].ContactId;
                        }       
                }
        } 
    }
    
    private String mapPaymentMethodFromOppToQuote(String s) {
        System.debug('Mapping payment method from opp to quote...');
        
        String pmtMethod = '';
        if (s != null) {
                if (s.toUpperCase().equals('CREDIT CARD')) {
                        pmtMethod = 'Valid Credit Card Required';
                } else if (s.toUpperCase().equals('PAY BY CHECK')) {
                        pmtMethod = 'Check';
                } else if (s.toUpperCase().equals('WIRE TRANSFER')) {
                        pmtMethod = 'Wire Transfer';
                }
        }
        System.debug('Translated payment method: ' + pmtMethod);
        return pmtMethod;
    }
    
    private String mapPaymentFrequencyFromOppToQuote(String s) {
        System.debug('Mapping payment frequency from opp to quote...');
        
        String pmtFreq = '';
        if (s != null) {
                pmtFreq = s;
                if (s.toUpperCase().equals('SEMI-ANNUAL')) {
                        pmtFreq = 'Bi-Annual';
                } else if (s.toUpperCase().equals('TWO YEAR DEAL')) {
                        pmtFreq = '2-Years';
                } else if (s.toUpperCase().equals('THREE YEAR DEAL')) {
                        pmtFreq = '3-Years';
                }
        }
        System.debug('Translated payment frequency: ' + pmtFreq);
        return pmtFreq;
    }
    
    private void getHistoricalContractData() {
        System.debug('Controller is getting historical contract data...');
        guessedQuote = new Quote();
        QuoteMachine_UpsellIntegrator upsellIntegrator = new QuoteMachine_UpsellIntegrator(guessedQuote);  
        guessedQuote = upsellIntegrator.integrateQuoteData(accountId);
    }
    
    public void copyEstimatedValues() {
        System.debug('Copying estimated subscription terms...');
        
        q.Original_Product_Tier__c = guessedQuote.Original_Product_Tier__c;
        q.Original_Payment_Frequency__c = guessedQuote.Original_Payment_Frequency__c;
        q.Original_Contract_Renewal_Date__c = guessedQuote.Original_Contract_Renewal_Date__c;
        q.Confidence_Level__c = guessedQuote.Confidence_Level__c;
        q.Original_Data_Sources__c = guessedQuote.Original_Data_Sources__c;
    }
      
    public PageReference customSave() {
        System.debug('Saving w/custom logix...');
        
        stampQuoteFields(); 
        
        // Check req fields...
        Boolean doNotSave = missingRequiredFields();                   
        
        if (!doNotSave) {                           
            return controller.save();            
        } else {
            return null;
        }
    }    
    
    private void stampQuoteFields() {
        System.debug('Stamping quote fields...');
        q.Product_Tier__c = q.Original_Product_Tier__c;
        q.Payment_Frequency__c = q.Original_Payment_Frequency__c;
        q.Order_End_Date__c = q.Original_Contract_Renewal_Date__c;
    }
    
    private Boolean missingRequiredFields() {
        System.debug('Checking for required fields...');
        
        Boolean throwError = false;
        if (q.Order_Start_Date__c == null) {
            throwError = true;
        } else if (q.Payment_Method__c == null) {
           throwError = true;
        } else if (q.Payment_Terms__c == null) {
            throwError = true;
        } else if (q.Product_Tier__c == null) {
            throwError = true;
        } else if (q.Payment_Frequency__c == null) {
            throwError = true;
        } else if (q.Order_End_Date__c == null) {
            throwError = true;
        }
        
        if (throwError) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'All fields are required.'));
        } else {
            System.debug('All required fields are filled.');
        }
        
        return throwError;
    }
    
    public class UpsellDataSource {
        public String name;
        public String id;
        public String url;
        
        public UpsellDataSource(String n, String i) {
            this.name = n;
            this.id = i;
            this.url = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.id;
        }
        
        public String getName() {
            return this.name;
        }
        
        public String getUrl() {
            return this.url;
        }
    }
    
}