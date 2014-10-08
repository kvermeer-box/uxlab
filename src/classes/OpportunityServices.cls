public class OpportunityServices {
    public static String opportunityStage {
        get {
            if(opportunityStage == null) {
                opportunityStage = Web_trial_Originating_Opp_Stage__c.getAll().values().isEmpty() ? '' : Web_trial_Originating_Opp_Stage__c.getAll().values()[0].Name;
            }
            return opportunityStage;
        }
        private set;
    }

    private static Map<String, List<Trial_Type_To_Account_Type_Sold__c>> trialTypeToAccountTypeSold {
        get {
            if(trialTypeToAccountTypeSold == null) {
                trialTypeToAccountTypeSold = GroupBy.strings('Trial_Type__c', Trial_Type_To_Account_Type_Sold__c.getAll().values());
            }
            return trialTypeToAccountTypeSold;
        }
        set;
    }
    @TestVisible
    private static Map<String, Decimal> currencyIsoCodeToConversionRate {
        get {
            if(currencyIsoCodeToConversionRate == null) {
                currencyIsoCodeToConversionRate = new Map<String, Decimal>();
                List<CurrencyType> currencyTypes = [SELECT ConversionRate, IsoCode FROM CurrencyType WHERE IsActive = true];
                for(CurrencyType currencyType : currencyTypes) {
                    currencyIsoCodeToConversionRate.put(currencyType.IsoCode, currencyType.ConversionRate);
                }
            }
            return currencyIsoCodeToConversionRate;
        }
        set;
    }

    /**
    * Returns a list of opportunities which changed to the Stage Name specified in the Web_trial_Originating_Opp_Stage__c custom setting.
    * @param opps new instances of the opportunities to filter
    * @param oldOpps map of Id to old instance of opportunities to filter
    */
    public static List<Opportunity> filterOpportunities(List<Opportunity> opps, Map<Id, Opportunity> oldOpps) {
        List<Opportunity> filteredOppties = Select.Field.hasChanged(Opportunity.StageName).
            andx(Select.Field.isEqual(Opportunity.StageName, opportunityStage)).
            andx(Select.Field.isEqual(Opportunity.Webtrial_Has_CW_Orig_Opp__c, true)).
            filter(opps, oldOpps);

        List<Opportunity> filteredOpptiesWithTrialEndDateAfterCloseDate = new List<Opportunity>();
        for(Opportunity filteredOppty : filteredOppties) {
            if(filteredOppty.Trial_End_Date__c > filteredOppty.CloseDate) {
                filteredOpptiesWithTrialEndDateAfterCloseDate.add(filteredOppty);
            }
        }
        return filteredOpptiesWithTrialEndDateAfterCloseDate;
    }


    public static List<Opportunity> getOriginatingOpportunities(Set<Id> originatingOppIds) {
        return [SELECT StageName FROM Opportunity WHERE Id IN :originatingOppIds];
    }

    /**
    * Copies Payment_Term__c and Fee_Frequency__c and Rep_Quota_Relief__c from Upsell opportunity onto Originating Opportunity
    * @param idToOriginatingOppty originating opportunity records to copy on to
    * @param upsells opportunity records to copy from
    * @revision Kyle Vermeer 4/14/2014 Added payment method and opportunity currency
    */
    public static void copyOpptyFieldsOntoOriginatingOppty( Map<Id,Opportunity> idToOriginatingOppty, List<Opportunity> opportunities )
    {
        for( Opportunity oppty : opportunities )
        {
            Opportunity originatingOppty = idToOriginatingOppty.get( oppty.Originating_Opportunity__c );
            if( originatingOppty != null )
            {
                Decimal conversionRate = currencyIsoCodeToConversionRate.get(oppty.CurrencyIsoCode);
                originatingOppty.Payment_Term__c = oppty.Payment_Term__c;
                originatingOppty.Fee_Frequency__c = oppty.Fee_Frequency__c;
                originatingOppty.Rep_Quota_Relief__c = oppty.Rep_Quota_Relief__c;
                originatingOppty.Account_Type_Sold__c = getCustomSettingWithPartialTrialType(oppty.Trial_Type__c).Account_Type_Sold__c;
                originatingOppty.Seats_Sold__c = Decimal.valueOf(oppty.Initial_Trial_Signup__c);
                originatingOppty.Amount = originatingOppty.Seats_Sold__c * (getCustomSettingWithPartialTrialType(oppty.Trial_Type__c).USD__c*conversionRate)*12;
                originatingOppty.Payment_Method__c = oppty.Payment_Method__c;
                originatingOppty.CurrencyIsoCode = oppty.Opportunity_Currency__c;
            }
        }
    }

    private static Trial_Type_To_Account_Type_Sold__c getCustomSettingWithPartialTrialType(String trialType) {
        Trial_Type_To_Account_Type_Sold__c customSetting;
        for(String key : trialTypeToAccountTypeSold.keySet()) {
            if(trialType.contains(key)) {
                customSetting = trialTypeToAccountTypeSold.get(key)[0];
                break;
            }
        }
        return customSetting;
    }

    /**
    * Updates Originating Opportunities if Stage Name is not the one specified in Web_trial_Originating_Opp_Stage__c custom setting
    * @param originatingOpportunities opportunity records which may need to be updated
    * @param originatingOpptyIdToOppties map of Id to originating opportunity records for use in safe update
    */
    public static void setOriginatingOpportunitiesStatus(List<Opportunity> originatingOpportunities, Map<Id, List<Opportunity>> originatingOpptyIdToOppties) {
        List<Opportunity> originatingOpportunitiesToUpdate = new List<Opportunity>();
        for(Opportunity originatingOpportunity : originatingOpportunities) {
                originatingOpportunity.StageName = opportunityStage;
                originatingOpportunitiesToUpdate.add(originatingOpportunity);
        }
        safeUpdate(originatingOpportunitiesToUpdate, originatingOpptyIdToOppties);
    }

    /**
    * Updates opportunities, catches dmlExceptions and adds errors to the related opportunity records
    * @param oppties Opportunity records to update
    * @param originatingOpptyIdToOppties grouping of originating opportunity Id to Opportunities related to it for use in adding errors
    */
    @TestVisible
    private static void safeUpdate(List<Opportunity> oppties, Map<Id, List<Opportunity>> originatingOpptyIdToOppties) {
        try {
            update oppties;
        }
        catch(DMLException dmx) {
            for(Integer i=0;i<dmx.getNumDml();i++) {
                Id failedOpptyId = dmx.getDmlId(i);
                List<Opportunity> opptiesToAddError = originatingOpptyIdToOppties.get(failedOpptyId);
                for(Opportunity oppty : opptiesToAddError) {
                    oppty.addError(dmx);
                }
            }
        }
    }
}