/**
 * The trigger for all account trigger functionality.  
 *
 * No other account triggers should be created, all needed functionality should be 
 * called in this trigger.
 * 
 * @author Kyle Vermeer <kvermeer@box.com>
 * @version 1.0
 * 
 * @revision 1.0 Kyle Vermeer 2/26/2014 Inital Creation
 */

trigger Account_trgr on Account (before insert, after insert, 
before update, after update, before delete, after delete, after undelete) {

  
    /* Before Insert */
    if (Trigger.isBefore && Trigger.isInsert)
    {
        AccountUpdateSalesDivision_trgr.updateSalesDivisionAndTheater(true,null,Trigger.new); 
        NAICSUpdater.updateNAICSFields(true, null, Trigger.new);
        AccountTriggerHelper.populateUserLookups(Trigger.new);
        CongaUtils.refreshCongaKeys();
    }
    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert)
    { 
        SubsidiaryAccountCounter.markParentAccountsForSubsidiaryRecount(Trigger.oldMap, Trigger.new, false);
    }
    /* Before Update */
    else if (Trigger.isBefore && Trigger.isUpdate)
    {

        AccountUpdateSalesDivision_trgr.updateSalesDivisionAndTheater(false,Trigger.oldMap,Trigger.new);
        SubsidiaryAccountCounter.recalculateSubsidiaryCount(Trigger.oldMap, Trigger.new);
        NAICSUpdater.updateNAICSFields(false, Trigger.oldMap, Trigger.new);
        CongaUtils.refreshCongaKeys(); 

    }
    /* After Update */
    else if (Trigger.isAfter && Trigger.isUpdate)
    {
 
        SubsidiaryAccountCounter.markParentAccountsForSubsidiaryRecount(Trigger.oldMap, Trigger.new, true);
        CSMEmailHelper.updateCSMEmailOfChildren(Trigger.oldMap, Trigger.new);

    }
    /* Before Delete */
    else if (Trigger.isBefore && Trigger.isDelete)
    {
    }
    /* After Delete */
    else if (Trigger.isAfter && Trigger.isDelete)
    {
        SubsidiaryAccountCounter.markParentAccountsForSubsidiaryRecount(Trigger.oldMap, Trigger.new, false);
    }
    /* After Undelete */
    else if (Trigger.isUnDelete)
    {
    }
}