public  class PricebookSettings_cs {

  public static final String CURRENT_PRICEBOOK_ID = '01s60000000APgk';
  public static final String CURRENT_PRICEBOOK_NAME = 'Current';
  public static final String LEGACY_PRICEBOOK_ID = '01s60000000ALfM';
  
  public static Pricebook_Setting__c getInstance(String instance_name)
  {
    if (!Test.isRunningTest())
    {
      return Pricebook_Setting__c.getInstance(instance_name);
    }
    else
    {
      Pricebook_Setting__c setting = Pricebook_Setting__c.getInstance(instance_name);
      if (setting == null) 
      {
        setting = new Pricebook_Setting__c(Name=instance_name);
        if (instance_name == CURRENT_PRICEBOOK_NAME)
          setting.Id__c = CURRENT_PRICEBOOK_ID;
        else setting.Id__c = LEGACY_PRICEBOOK_ID;
        insert setting;
      }
      return setting;
    }
  }
}