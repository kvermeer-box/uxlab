<fcrinitdata>
  <objecttype fieldtype="Lead">
    <field>
      <apiname>Company</apiname>
      <label>Company</label>
      <targetvalue>fcdpl_1</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>LastName</apiname>
      <label>LastName</label>
      <targetvalue>fcdpl_1</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>Contact_Method__c</apiname>
      <label>Contact Method - Most Recent</label>
      <targetvalue>Cold Call</targetvalue>
      <type>picklist</type>
    </field>
  </objecttype>
  <objecttype fieldtype="Contact">
    <field>
      <apiname>LastName</apiname>
      <label>LastName</label>
      <targetvalue>fcdpl_1</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>Contact_Method_Most_Recent__c</apiname>
      <label>Contact Method - Most Recent</label>
      <targetvalue>Cold Call</targetvalue>
      <type>picklist</type>
    </field>
  </objecttype>
  <objecttype fieldtype="Campaign">
    <field>
      <apiname>Name</apiname>
      <label>Name</label>
      <targetvalue>fcdpcp_1</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>IsActive</apiname>
      <label>IsActive</label>
      <targetvalue>true</targetvalue>
      <type>boolean</type>
    </field>
  </objecttype>
  <objecttype fieldtype="Opportunity">
    <field>
      <apiname>Name</apiname>
      <label>Name</label>
      <targetvalue>fcdpco_1</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>CloseDate</apiname>
      <label>CloseDate</label>
      <targetvalue>5</targetvalue>
      <type>date</type>
    </field>
    <field>
      <apiname>StageName</apiname>
      <label>StageName</label>
      <targetvalue>false</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>Contact_Method_Most_Recent__c</apiname>
      <label>Contact Method - Most Recent</label>
      <targetvalue>Business Web Trial</targetvalue>
      <type>picklist</type>
    </field>
  </objecttype>
  <objecttype fieldtype="Account">
    <field>
      <apiname>Name</apiname>
      <label>Name</label>
      <targetvalue>fcdpa_1</targetvalue>
      <type>string</type>
    </field>
  </objecttype>
  <objecttype fieldtype="CampaignMember" />
  <objecttype fieldtype="User">
    <field>
      <apiname>Alias</apiname>
      <label>Alias</label>
      <targetvalue>fcdpu_1</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>Email</apiname>
      <label>Email</label>
      <targetvalue>fcdpu_1@fullcirclecrm.com</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>FirstName</apiname>
      <label>FirstName</label>
      <targetvalue>fcdpu_2</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>LastName</apiname>
      <label>LastName</label>
      <targetvalue>fcdpu_3</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>TimeZoneSidKey</apiname>
      <label>TimeZoneSidKey</label>
      <targetvalue>America/Los_Angeles</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>UserName</apiname>
      <label>UserName</label>
      <targetvalue>fcdpu_3@fullcirclecrm.com</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>UserPermissionsMarketingUser</apiname>
      <label>UserPermissionsMarketingUser</label>
      <targetvalue>true</targetvalue>
      <type>boolean</type>
    </field>
    <field>
      <apiname>LocaleSidKey</apiname>
      <label>LocaleSidKey</label>
      <targetvalue>en_US</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>EmailEncodingKey</apiname>
      <label>EmailEncodingKey</label>
      <targetvalue>UTF-8</targetvalue>
      <type>string</type>
    </field>
    <field>
      <apiname>LanguageLocaleKey</apiname>
      <label>LanguageLocaleKey</label>
      <targetvalue>en_US</targetvalue>
      <type>string</type>
    </field>
  </objecttype>
  <objecttype fieldtype="OpportunityLineItem" />
  <disabletest block="disabledefaultcontactaccounts"></disabletest>
  <addproduct></addproduct>
  <testbypass>AE,AF,H,M-4,BD-3,AP-1,BC,M-5,BD-1</testbypass>
  <specialcodes></specialcodes>
</fcrinitdata>