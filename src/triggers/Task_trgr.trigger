trigger Task_trgr on Task (before insert, after insert, before update, after update, 
before delete, after delete, after undelete) {

  /* Before Insert */
  if (Trigger.isBefore && Trigger.isInsert)
  {
  }
  /* After Insert */
  else if (Trigger.isAfter && Trigger.isInsert)
  {
    TaskIncrementLeadTaskCounter_trgr.updateLeadTaskCounter(false, null, Trigger.new);
    TaskUpdateLastAccountActivity_trgr.updateLastActivity(false, null, Trigger.new);
  }
  /* Before Update */
  else if (Trigger.isBefore && Trigger.isUpdate)
  {
  }
  /* After Update */
  else if (Trigger.isAfter && Trigger.isUpdate)
  {
    TaskIncrementLeadTaskCounter_trgr.updateLeadTaskCounter(false, Trigger.old, Trigger.new);
    TaskUpdateLastAccountActivity_trgr.updateLastActivity(false, Trigger.old, Trigger.new);
  }
  /* Before Delete */
  else if (Trigger.isBefore && Trigger.isDelete)
  {
  }
  /* After Delete */
  else if (Trigger.isAfter && Trigger.isDelete)
  {
    TaskIncrementLeadTaskCounter_trgr.updateLeadTaskCounter(true, Trigger.old, Trigger.new);
    TaskUpdateLastAccountActivity_trgr.updateLastActivity(true, Trigger.old, Trigger.new);
  }
  /* After Undelete */
  else if (Trigger.isUnDelete)
  {
  }
}