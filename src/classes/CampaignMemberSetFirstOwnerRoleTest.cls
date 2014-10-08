/**
 * Test class for CampaignMemberSetFirstOwnerRole.
 *
 * @author Kyle Vermeer <kvermeer@box.com>
 * @author Full Circle <roan@fullcirclecrm.com>
 * @version 1.0
 *
 * @revision 1.0 Kyle Vermeer 2/27/2014 Intial Documentation + only query active users + removed SeeAllData
 */
@isTest
private class CampaignMemberSetFirstOwnerRoleTest {

    static testMethod void myUnitTest() {
    	
    	List<User> users = [Select Id From User Where UserRole.Name != null AND isActive = true Limit 2];
    	
        List<Contact> cts = initTestContacts('cts', 2);
        insert cts;
        
        List<Campaign> camps = initTestCampaigns('cmp', 1);
        insert camps;
        
        CampaignMember origCm1 = new CampaignMember(Status = 'Sent', FCRM__FCR_First_Owner_Worked__c=users[0].Id, FCRM__FCR_Response_Status__c = 'Open - Not Contacted', ContactID = cts[0].id, CampaignID = camps[0].id);
        CampaignMember origCm2 = new CampaignMember(Status= 'Sent', FCRM__FCR_First_Owner_Assigned__c=users[0].Id, FCRM__FCR_Response_Status__c = 'Open - Not Contacted', ContactID = cts[1].id, CampaignID = camps[0].id);        
        insert origCm1;               
        
        Test.startTest();
        origCm1.FCRM__FCR_First_Owner_Assigned__c = users[1].Id;
        origCm1.FCRM__FCR_First_Owner_Worked__c = users[1].Id;
        update origCm1;
        insert origCm2;
        Test.stopTest();
    }
    
    public static List<Contact> initTestContacts(String prefix, Integer count)  
    {    
        List<Contact>cts = new List<Contact>();    
        for(Integer x=1;x<count+1;x++)    
        {      
          cts.add(new Contact(LastName = prefix + '_' + String.valueOf(x)));
        }
        return cts;  
    }


    public static List<Campaign> initTestCampaigns(String prefix, Integer count)
    {
        List<Campaign> camps = new List<Campaign>();
        for(Integer x=1; x<count+1; x++)
        {
          camps.add(new Campaign(Name = prefix+'_'+ String.ValueOf(x), FCRM__FCR_Repeat_Responses_Allowed__c=true, FCRM__FCR_Bypass_Nurture_Timeout__c=true, IsActive = true));
        }
        return camps;
    }  
        
}