trigger Lead_trgr on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

  /* Before Insert */
  if (Trigger.isBefore && Trigger.isInsert)
  {
    LeadAssignment_trgr.setRoutingCountry(Trigger.old, Trigger.new, 
                                          Trigger.oldMap, Trigger.newMap,
                                          Trigger.isInsert, Trigger.isUpdate);
  }
  /* After Insert */
  else if (Trigger.isAfter && Trigger.isInsert)
  {
    LeadAssignment_trgr.routeLeads(Trigger.old, Trigger.new, 
                                  Trigger.oldMap, Trigger.newMap,
                                  Trigger.isInsert, Trigger.isUpdate);
  }
  /* Before Update */
  else if (Trigger.isBefore && Trigger.isUpdate)
  {
    LeadAssignment_trgr.setRoutingCountry(Trigger.old, Trigger.new, 
                                          Trigger.oldMap, Trigger.newMap,
                                          Trigger.isInsert, Trigger.isUpdate);
  }
  /* After Update */
  else if (Trigger.isAfter && Trigger.isUpdate)
  {
    LeadAssignment_trgr.routeLeads(Trigger.old, Trigger.new, 
                                  Trigger.oldMap, Trigger.newMap,
                                  Trigger.isInsert, Trigger.isUpdate);
    LeadTriggerHandler.attachMarketingActivityFromConvertedLeads(Trigger.oldMap, Trigger.newMap);
  }
  /* Before Delete */
  else if (Trigger.isBefore && Trigger.isDelete)
  {}
  /* After Delete */
  else if (Trigger.isAfter && Trigger.isDelete)
  {}
  /* After Undelete */
  else if (Trigger.isUnDelete)
  {}
}