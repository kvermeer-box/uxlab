@isTest

private class TreasuryTest{

 
        static testMethod void testCategory () {

         Category__c category = new Category__c(Name = 'TestCategory', Icon_Image_Location__c = 'www.juihee.com'); 
                                                
        //Category__c.Demo_Templates__r.Name = ' Test Demo Temp')
        insert category;
        
        // creating Demo Temps
        
         Demo_Template__c testDemoTemplate = new Demo_Template__c(Name = 'Test Demo Temp', Description__c = ' Test Demo Descr',
                                                                 Description_Summary__c = 'Test Demo Descr Summary', 
                                                                 Icon_Image_Location__c= 'www.testdemotemp.com', Status__c = 'Published', 
                                                                 Related_to_Category__c = category.id); 
        insert testDemoTemplate;
        
        system.debug('obj value' + category); 
        
        category = [SELECT Name, Icon_Image_Location__c FROM Category__c]; 
        
        system.debug ( 'query value' + category); 
        //system.assertEquals ( 'SharmaName', category.Name, 'obb value:' + category);
        
        TreasuryController controller = new TreasuryController(); 
        
        List<Category__c> A = controller.getCategories(); 
        for ( integer i=0; i<1; i++){
        System.assertEquals(category.Name, A[i].Name); 
            }
        //Category__c AA = controller.getCatdetails(); 
        
        //System.assertEquals(category.Name, AA.Name); 
            
       
        
        //***************************** Testing Demo Templates ***************************************
        
       // static testMethod void testDemoTemplates () {

       
        
        
         testDemoTemplate = [SELECT Name, Description__c, 
                            Description_Summary__c, Icon_Image_Location__c 
                            FROM Demo_Template__c 
                            WHERE Related_to_Category__r.Name = 'TestCategory' AND Status__c = 'Published'];

        
        system.debug ( 'query value' + testDemoTemplate); 
        //system.assertEquals ( 'SharmaName', category.Name, 'obb value:' + category);
        
       
        // taking care of the pageReference Piece 
        
         //String Nextpage = ApexPages.currentPage().getParameters().put('qp', 'yyyy');
         PageReference pageRef = new PageReference('http://boxtreasury.force.com/Listing?listing=TestCategory');
        
        //Instantiate and construct the controller class.   
        TreasuryController controllerPageRef = new TreasuryController();

        // Set the current page
        System.Test.setCurrentPage(pageRef);
        
         System.assertNotEquals(null, pageRef); 
        List<Demo_Template__c> B = controller.getdemoTemplates(); 
        for ( integer i=0; i<1; i++){
        System.assertEquals(testdemoTemplate.Name, B[i].Name); 
            }
        //Demo_Template__c BB = controller.getTemplateDetails(); 
       
       // System.assertEquals(testdemoTemplate.Name, BB.Name); 
            
        }
        
     //****************************************************Test Do Get Cat Details ****************************************************
     
     static testMethod void testdoCatDetails(){
        Category__c category = new Category__c(Name = 'TestCategory', Icon_Image_Location__c = 'www.juihee.com'); 
                                                
        //Category__c.Demo_Templates__r.Name = ' Test Demo Temp')
        insert category;
        
        system.debug('obj value' + category); 
        
        PageReference pageRef = new PageReference('http://boxtreasury.force.com/Listing?listing=TestCategory');
        
        //Instantiate and construct the controller class.   
        TreasuryController controllerPageRef = new TreasuryController();
        
        System.Test.setCurrentPage(pageRef);
        System.assertNotEquals(null, pageRef); 
        category = [SELECT Name, Icon_Image_Location__c FROM Category__c WHERE Name = 'TestCategory']; 
        
        system.debug ( 'query value' + category); 
        //system.assertEquals ( 'SharmaName', category.Name, 'obb value:' + category);
        
        TreasuryController controller = new TreasuryController(); 
        
        controller.dogetCatDetails(); 
        //System.assertEquals(category.Name, A.Name); 
           
        //Category__c AA = controller.getCatdetails(); 
        
      }
      //*****************************************************Testing Demo Cat Details ****************************************************
        
   static testMethod void testCatDetails(){
        Category__c category = new Category__c(Name = 'TestCategory', Icon_Image_Location__c = 'www.juihee.com'); 
                                                
        //Category__c.Demo_Templates__r.Name = ' Test Demo Temp')
        insert category;
        
        system.debug('obj value' + category); 
        
        PageReference pageRef = new PageReference('http://boxtreasury.force.com/Listing?listing=TestCategory');
        
        //Instantiate and construct the controller class.   
        TreasuryController controllerPageRef = new TreasuryController();
        
        System.Test.setCurrentPage(pageRef);
        System.assertNotEquals(null, pageRef); 
        category = [SELECT Name, Icon_Image_Location__c FROM Category__c WHERE Name = 'TestCategory']; 
        
        system.debug ( 'query value' + category); 
        //system.assertEquals ( 'SharmaName', category.Name, 'obb value:' + category);
        
        TreasuryController controller = new TreasuryController(); 
        
        Category__c A = controller.getCatDetails(); 
        System.assertEquals(category.Name, A.Name); 
           
        //Category__c AA = controller.getCatdetails(); 
        
      }
        //**************************************************** Test DO Demo Temp Details **************************************
        
      static testMethod void testdoDemoTemplates () {

           // create Demo  Template
        Demo_Template__c testDemoTemplate = new Demo_Template__c(Name = 'TestDemoTemp', Description__c = ' TestvDemo Descr',
                                                                 Description_Summary__c = 'Test Demo Descr Summary', 
                                                                 Icon_Image_Location__c= 'www.testdemotemp.com', Status__c = 'Published' 
                                                                 ); 
        insert testDemoTemplate;
        
        // initialize Demo Template
         testDemoTemplate = [SELECT Name, Description__c, 
                            Description_Summary__c, Icon_Image_Location__c 
                            FROM Demo_Template__c 
                            WHERE Name = 'TestDemoTemp' AND Status__c = 'Published'];

        
        system.debug ( 'query value' + testDemoTemplate); 
        //system.assertEquals ( 'SharmaName', category.Name, 'obb value:' + category);
        
       
        // taking care of the pageReference Piece 
        
         //String Nextpage = ApexPages.currentPage().getParameters().put('qp', 'yyyy');
         PageReference pageRef = new PageReference('http://boxtreasury.force.com/Product?product=TestDemoTemp');
        
        //Instantiate and construct the controller class.   
        TreasuryController controller = new TreasuryController();

        // Set the current page
        System.Test.setCurrentPage(pageRef);
        
         System.assertNotEquals(null, pageRef); 
           controller.dogetTemplateDetails(); 
        
        //System.assertEquals(testdemoTemplate.Name, B.Name); 
           
        //Demo_Template__c BB = controller.getTemplateDetails(); 
       
       // System.assertEquals(testdemoTemplate.Name, BB.Name); 
            
        }
        
        
        //*****************************************************Testing Demo Temp Details ****************************************************
        
  static testMethod void testDemoTemplates () {

           // create Demo  Template
        Demo_Template__c testDemoTemplate = new Demo_Template__c(Name = 'TestDemoTemp', Description__c = ' TestvDemo Descr',
                                                                 Description_Summary__c = 'Test Demo Descr Summary', 
                                                                 Icon_Image_Location__c= 'www.testdemotemp.com', Status__c = 'Published' 
                                                                 ); 
        insert testDemoTemplate;
        
        // initialize Demo Template
         testDemoTemplate = [SELECT Name, Description__c, 
                            Description_Summary__c, Icon_Image_Location__c 
                            FROM Demo_Template__c 
                            WHERE Name = 'TestDemoTemp' AND Status__c = 'Published'];

        
        system.debug ( 'query value' + testDemoTemplate); 
        //system.assertEquals ( 'SharmaName', category.Name, 'obb value:' + category);
        
       
        // taking care of the pageReference Piece 
        
         //String Nextpage = ApexPages.currentPage().getParameters().put('qp', 'yyyy');
         PageReference pageRef = new PageReference('http://boxtreasury.force.com/Product?product=TestDemoTemp');
        
        //Instantiate and construct the controller class.   
        TreasuryController controller = new TreasuryController();

        // Set the current page
        System.Test.setCurrentPage(pageRef);
        
         System.assertNotEquals(null, pageRef); 
           Demo_Template__c B = controller.getTemplateDetails(); 
        
        System.assertEquals(testdemoTemplate.Name, B.Name); 
           
        //Demo_Template__c BB = controller.getTemplateDetails(); 
       
       // System.assertEquals(testdemoTemplate.Name, BB.Name); 
            
        }
        
        
        
        //*****************************************************Testing Related Folder*********************************************************
         static testMethod void testUseCases () {

         Category__c category = new Category__c(Name = 'TestCategory', Icon_Image_Location__c = 'www.juihee.com'); 
                                                
        //Category__c.Demo_Templates__r.Name = ' Test Demo Temp')
        insert category;
        
        // creating Demo Temps
        
         Demo_Template__c testDemoTemplate = new Demo_Template__c(Name = 'TestDemoTemp', Description__c = ' Test Demo Descr',
                                                                 Description_Summary__c = 'Test Demo Descr Summary', 
                                                                 Icon_Image_Location__c= 'www.testdemotemp.com', Status__c = 'Published' 
                                                                 ); 
        insert testDemoTemplate;
        
        Related_Folder__c testRelatedFolder = new Related_Folder__c(Name = 'TestRelatedFolder', Description__c = ' Test RelatedFolder Descr',
                                                                  Status__c = 'Published', 
                                                                 Related_to_Demo_Template__c = testDemoTemplate.id); 
        
        insert testRelatedFolder;
        system.debug('obj value' + testRelatedFolder); 
        
        category = [SELECT Name, Icon_Image_Location__c FROM Category__c]; 
        
        system.debug ( 'query value' + category); 
        //system.assertEquals ( 'SharmaName', category.Name, 'obb value:' + category);
        
        
        
         testDemoTemplate = [SELECT Name, Description__c, 
                            Description_Summary__c, Icon_Image_Location__c 
                            FROM Demo_Template__c];

        
        system.debug ( 'query value' + testDemoTemplate); 
        //system.assertEquals ( 'SharmaName', category.Name, 'obb value:' + category);
        
       testRelatedFolder = [SELECT Name, Description__c 
                           
                            FROM Related_Folder__c 
                            WHERE Related_to_Demo_Template__r.Name = 'TestDemoTemp' AND Status__c = 'Published'];
         system.debug ( 'query value' + testRelatedFolder); 
        // taking care of the pageReference Piece 
        
         
         PageReference pageRef = new PageReference('http://boxtreasury.force.com/Product?listing=TestCategory&Product=TestDemoTemp');
        
        //Instantiate and construct the controller class.   
        TreasuryController controllerPageRef = new TreasuryController();
        
        // Set the current page
        System.Test.setCurrentPage(pageRef);
        
        System.assertNotEquals(null, pageRef); 
        List<TreasuryController.cContact> C = controllerPageRef.getuseCases(); 
        for ( integer i=0; i<1; i++){
        System.assertEquals(testRelatedFolder.Name, C[i].con.Name); 
            }
        }
        
        //******************************************Test for Process Selected*************************************************
  
  // @isTest

//private class processSelectedTestClass{
static testMethod void testPS () {
             
             // Instantiating Controller
             
          
             
             
             Demo_Template__c testDemoTemplate = new Demo_Template__c(Name = 'TestDemoTemp', Description__c = ' Test Demo Descr', FolderID__C ='8910',
                                                                 Description_Summary__c = 'Test Demo Descr Summary', 
                                                                 Icon_Image_Location__c= 'www.testdemotemp.com', Status__c = 'Published' 
                                                                 ); 
                 insert testDemoTemplate;
        
        
        
             Related_Folder__C testSelectedUseCase = new Related_Folder__c(Name = 'TestSelectedUseCase1', FolderID__c = '12345', Status__C = 'published',  Related_to_Demo_Template__c = testDemoTemplate.id); 
               insert testSelectedUseCase; 
               
           //  Related_Folder__C testUnselectedUseCase = new Related_Folder__c( Name = 'TestUnSelectedUseCase1', FolderID__c = '12345', Status__C = 'published',  Related_to_Demo_Template__c = testDemoTemplate.id);      
             //   insert testUnselectedUseCase; 
               // System.debug ( 'unselected_Use_Case:' + testUnselectedUseCase); 
              
              
              // Query Template Values 
              
             testDemoTemplate = [SELECT Name, Description__c, 
                            Description_Summary__c, Icon_Image_Location__c 
                            FROM Demo_Template__c];
                system.debug ( 'query value' + testDemoTemplate);   
             
            // Query Selected Use Cases
            
             testSelectedUseCase = [SELECT Name, Description__c 
                                    FROM Related_Folder__c 
                                    WHERE Related_to_Demo_Template__r.Name = 'TestDemoTemp' AND FolderID__c = '12345'];
                  system.debug ( 'query value' + testSelectedUseCase); 
             
            // Query Unselected Use Case       
            // testUnselectedUseCase = [SELECT Name, Description__c 
                           
               //             FROM Related_Folder__c 
               //             WHERE FolderID__c = '12345'];
        // system.debug ( 'query value' + testUnselectedUseCase);           
         
         
           PageReference pageRef = new PageReference('http://boxtreasury.force.com/Product?listing=TestCategory&Product=TestDemoTemp');
                TreasuryController controller = new TreasuryController(); 
             System.Test.setCurrentPage(pageRef);
         
             List<TreasuryController.cContact> C = controller.getuseCases(); 
             
                for ( integer i=0; i<1; i++){
                C[i].selected = true; 
                //System.assertEquals(testSelectedUseCase.Name, C[i].con.Name); 
            }
            
            //set mock callout class
    Test.setMock(HTTPCalloutMock.class, new TreasuryHTTPCreateTest());
    
    //declare variables
    // new token 
     
        Token__c t = new Token__c();
        t.Name = 'Access';
        t.Value__c = '12345';
        insert t;
        
        //sailaway
    String[] useCases = new String[]{'12345'};
    String email = 'test@test.com';
    String name = 'test';
    String token = 'testToken';
    String template = 'testTemplate';
    
            test.startTest(); 
            controller.processSelected();
            test.stopTest(); 
}


      
    
    /******************************************* Testing New Token *******************************************/
    
    static testMethod void testNewToken(){
        
        
        
        Token__c t = new Token__c();
        t.Name = 'Access';
        t.Value__c = '12345';
        insert t;
        
        TreasuryController tc = new TreasuryController();
        test.startTest();        
        String testToken = tc.newToken();
        test.stopTest();
        System.assertEquals(t.Value__c, testToken);
    
    }
    
    
    
     /****************************************** Testing HTTP Callouts ***************************************/
static testMethod void testHTTPCreate(){
    //set mock callout class
    Test.setMock(HTTPCalloutMock.class, new TreasuryHTTPCreateTest());
    
    //declare variables
    String[] useCases = new String[]{'12345'};
    String email = 'test@test.com';
    String name = 'test';
    String token = 'testToken';
    String template = 'testTemplate';
    
    test.startTest();
    TreasuryController.sailAway(useCases, email, name, token, template);
    test.stopTest();
    
    
}
    /******************************************* Testing Reporting ***************************************/
static testMethod void testCreateReport(){
 
    TreasuryController controller = new TreasuryController();
    
    String email = 'testEmail';
    String name = Userinfo.getUserId();
    String[] useCases = new String[]{'12345'};
    
    
    //create the template and folder to report on
    Demo_Template__c t = new Demo_Template__c ();
    t.Name = 'TestTemplate';
    t.FolderID__c = '12345';
    String testID = t.ID;
    insert t;
    
    Related_Folder__c rf = new Related_Folder__c();
    rf.Name = 'TestFolder';
    rf.FolderID__c = '12345';
    rf.Related_to_Demo_Template__c = t.id;
    insert rf;
    
    
    
    test.startTest();
    controller.createReport(email, name, 'TestTemplate', useCases, false);
    test.stopTest();
    
    Treasury_Report__c tr = [SELECT User_Name__c, User_Email__c FROM Treasury_Report__c WHERE User_Email__c=:'testEmail'];
    
    //System.assertEquals(name, tr.User_Name__c);
    System.assertEquals(email, tr.User_Email__c);
    //System.assertEquals(t.ID, r.Demo_Template__c);
    //System.assertEquals(gt5, r.Transferred_Parent_Folder__c);
    
    //Related_Folder__c tRF = [SELECT folderID__c FROM Related_Folder__c WHERE folderID__c =:'12345'];
    //System.assertEquals(rf.ID, r.Related_Folder_1__c.ID);
   
   }
   
        
        
 
}