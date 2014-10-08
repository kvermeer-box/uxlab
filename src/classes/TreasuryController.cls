/*
 * Box Treasury - Treasury Controller
 *
 * Add folders and context as entries in salesforce and easily provision them to Box accounts. 
 *
 * This controller pulls data from Treasury Entries and lets users select folders to transfer to their account.
 *
 * Makes callouts to Box API and displays data on Visual Force pages
 *
 * This controller also includes code for ASE Showcase
 * Version 9.0
 * 6/19/2014
 * @author Juihee Sharma <jsharma@box.com>
 * @author David Lasher <dlasher@box.com>
 *
 *
 * Table of Contents
 * 
 */
 
//formerly: Guggenheim1
public class TreasuryController{
  /**Global variables for Nugget Transfer **/
    public String FinalID { get; set; } //ID of staging folder
    public String quoteId { get; set; } // current product page name
    public String categoryId {get; set; }// current listing page name
    public String CollabID { get; set; }//ID of collaboration
    public String NEWCollabID { get; set;}//ID of collaboration after new owner    
    public String loginInvitee { get; set; }//email to invite
    public String loginInviteeConfirm { get; set; }//confirm email to invite
    public String nameInvitee { get; set;}//name (for treasury report)    
    //Box Treasury Box App info to get valid access/refresh token
    public String Token { get; set; }//store access token
    public String BoxJSON; //global variable save JSON of folder contents

    public Category__c demoCat { get; set; }//store details about current category 
    public Demo_Template__c demoTempASE { get; set; } //store details about current demo template ASE
    public Demo_Template__c demoTemp { get; set; } //store details about current demo template 
    public String videoLink { get; set; } 
    public String viewapiURL {get; set; }// View API Shared Link  

    /* Declare Lists */
     @TestVisible public List<cContact> usecaseList {get; set;}    
     public List<Related_Folder__c> selectedUseCases {get; set;}   
     public List<Related_Folder__c> unselectedUseCases {get; set;}
     List<Category__c> categories; //list of Categories
     List<Demo_Template__c> demoTemplates; //list of Treasury Entries
     List<Demo_Template__c> demoTemplatesASE; //list of Treasury Entries that builds the ASE Showcase
    /**/

  /** ./end Nugget Transfer global variables **/
   
  
/********************************************************************************** Visual Force Home Page **************************************************************/

/**
  *Build List of Categories for Visual Force Home Page  *
  */  
public List<Category__c> getCategories(){
    
        categories= [SELECT Name, Icon_Image_Location__c FROM Category__c ORDER BY Name];
       
       return categories;
    }
/********************************************************************************** END Visual Force Home Page **************************************************************/

/********************************************************************************** Visual Force Listings Page **************************************************************/
     
  /**
  *On page load, look up and store details about the current category*
  */  
   public PageReference doGetCatDetails() {
        this.demoCat = getCatDetails();
        return null;
    }  
  

  /**
  *Returns details of current Category, hence doGetCatDetails triggers this method for Visual Force Listings Page*
  */

  public Category__c getCatDetails() {
       
            
            //curName = value stored in url as name=_____        
            String curName = ApexPages.currentPage().getParameters().get('listing');
            //return this if sh*t doesn't work out
                       
            
            //if template exists, return it. 
            if (curName == null){
                return (null);
            }
            else{
              try{
               Category__c temp = [SELECT Name, Description__c, Icon_Image_Location__c FROM Category__c WHERE Name =: curName];
                if (temp == null){
                    return (null);
                }
                else{
                    return temp;
                }
              }
              
              catch (System.CalloutException e){
                  return null;
              }
            }
}  

/**
  *Build List of Demo Templates for Visual Force Listing Page, related to the current Category  *
  */ 
public List<Demo_Template__c> getDemoTemplates(){
    this.categoryId = ApexPages.currentPage().getParameters().get('listing');
 
       demoTemplates = [SELECT Name, Description__c, Description_Summary__c, Icon_Image_Location__c FROM Demo_Template__c WHERE Related_to_Category__r.Name =:categoryId AND Status__c = 'Published' AND Related_to_Category__r.Name !='ASE Showcase' ORDER BY Name];
       
     
   
       return demoTemplates;
    }

/** 
    * Build List of Demo Templates that pertain to the ASE Showcase, related to the ASE Showcase Category *
    */
    
public List<Demo_Template__c> getDemoTemplatesASE(){
    this.categoryId = ApexPages.currentPage().getParameters().get('listing');
   
   // breaking demoTemplates into two halves. One that pertain to ASE Showcase, and the other as they pertain tot he rest of the categories.
   //if condition for the break out
             
              demoTemplatesASE = [SELECT Name, Link_to_Demo_Script__c, Description_Summary__c, Icon_Image_Location__c FROM Demo_Template__c WHERE Related_to_Category__r.Name ='ASE Showcase' AND Status__c = 'Published' ORDER BY Name];
             
   
      return demoTemplatesASE; 
      }
    /**********************************************************************End Listing Page *******************************************************************/  
   
    /**********************************************************************Visual Force Product Page *******************************************************************/  

     /**
  *On page load, look up and store details about current Demo Template*
  */ 
   public PageReference doGetTemplateDetails() {
        this.demoTemp = getTemplateDetails();
        return null;
    }      
   
/**
  *Returns details of current Demo Template, hence doGetTemplateDetails triggers this method for Visual Force Product Page*
  */   
public Demo_Template__c getTemplateDetails() {
            /*** Return Demo_Template__c record for URL encoded name **/
            /* Error handling: create "error" record with data to display for each element */
            
            //curName = value stored in url as name=_____        
            String curName = ApexPages.currentPage().getParameters().get('product');
            //return this if sh*t doesn't work out
                       
            
            //if template exists, return it. 
            if (curName == null){
                return (null);
            }
            else{
              try{
               Demo_Template__c temp = [SELECT Name, Box_Owner__c, Description__c, Description_Summary__c, Icon_Image_Location__c, Link_to_Demo_Script__c, Link_to_Embed__c, Link_to_Video__c, Link_to_Resources__c, Related_to_Category__r.Name  FROM Demo_Template__c WHERE Name =: curName];
                
               // debugTxt = ' ' + temp.Link_to_Video__c; 
               // debugTxt += '... ' + temp;
                videoLink = temp.Link_to_Video__c;
                if (temp == null){
                    return (null);
                }
                else{
                    return temp;
                }
              }
              
              catch (Exception e){
                  return null;
              }
            }
}  

/**
  *New Method created to accomodate ASE Showcase. This method returns View API Session URL to the Visualforce page, making the page dynamic *
  */
public String getviewAPIURL(Demo_Template__c temp) {

    viewapiURL = temp.Link_to_Demo_Script__c; 
    system.debug(viewapiURL); 
return viewapiURL ; 


} 
/**
  *Build List of Demo Templates for Visual Force Product Page, related to the current Demo Template *
  */ 

    public List<cContact> getUseCases() {

        if(usecaseList == null) {
          usecaseList = new List<cContact>();
          //retrieve current product page name
          this.quoteId = ApexPages.currentPage().getParameters().get('product');
          //query published related folders related to product page name
          for ( Related_Folder__c c : [SELECT Name, FolderID__c, Description__c, Link_to_Resources__c, Related_to_Demo_Template__r.Name, Related_to_Demo_Template__r.FolderID__c FROM Related_Folder__c WHERE Related_to_Demo_Template__r.Name =: quoteId AND Status__c = 'Published' ORDER BY Name]){ 
            usecaseList.add(new cContact(c));
          }
        }

        return usecaseList;
    }
      
    /** CONTAINER CLASS FOR SELECTION BOX on Product Page
    **This is our wrapper/container class */

   @TestVisible public class cContact {
        public Related_Folder__c con {get; set;}
        public Boolean selected {get; set;}

        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false

        public cContact(Related_Folder__c c) {
            con = c;
            selected = false;
        }
    }

    

/**
  * Main controller for Nugget Transfer
  * Provision selected scenarios, and redirict user to confirmation page 
  * Attached to submit button on Product VF Page
  *
  
  public PageReference runMain() {  
    processSelected(); //perform nugget transfer on selected folders
    PageReference pageRef = new PageReference('https://c.na15.visual.force.com/apex/confirm');
    pageRef.setRedirect(true);
        return pageRef;
       
    }

*/
   

    /********************************************************************** END Visual Force Product Page *******************************************************************/  

/************************************************************************** Nugget Transfer Logic ***************************************************************************/
/**
  *
  *Builds selection of folders to be transfered based on user selection
  *Sends folders to be processed in future class
  *Creates report of job completed
  *
  * V1.0 possible to combine with main method above 
  *
  */  
   public PageReference processSelected() {
      
     //code for no selection   
        Boolean noSelection = true;
        Boolean isSelectedFolderCountGT5 = false; 
        PageReference pageRef = new PageReference('https://box.my.salesforce.com/apex/confirm');
     // create string type list of selected Objs FIDs
        List<String> usecaseFIDlist = new List<String>();
        selectedUseCases = new List<Related_Folder__c>();
     //code for no selection
        unselectedUseCases = new List<Related_Folder__c>();
        for(cContact cCon: usecaseList) {
            if(cCon.selected == true) {
              selectedUseCases.add(Ccon.con);
              noSelection = false;  
                }
            else if (cCon.selected == false) {
                unselectedUseCases.add(Ccon.con); 
                }
            }
            
       
            // if no related folders are selected , return all related folders from the chosen Demo Template 
                  
                   if (noSelection == false && selectedUseCases.size()<=5 ) { 
                    for(Related_Folder__c fex : selectedUseCases) {
                     usecaseFIDlist.add(fex.FolderID__c);
                        }
                        
                       } // if selection is greater than 5 related folders copy the Entire Treasury Entry Folder     
            else if (noSelection == false && selectedUseCases.size()>5 ) {
                
                Related_Folder__c fex = selectedUseCases.get(0);
                isSelectedFolderCountGT5 = true; 
                usecaseFIDlist.add(fex.Related_to_Demo_Template__r.FolderID__c);           
            } 
                       else if (noSelection == true) {
                           Related_Folder__c fex = unselectedUseCases.get(0); 
                           isSelectedFolderCountGT5 = true; 
                           usecaseFIDlist.add(fex.Related_to_Demo_Template__r.FolderID__c);
                           
                          }
                 
       //****************************** calling Project G ******************************
       //update token, transfer content (sail away), create report
       String accessToken = newToken(); 
       if (loginInvitee == loginInviteeConfirm){
       // TEMPORARILY COMMENTING THIS OUT
       
      
           createReport(loginInvitee, nameInvitee, quoteId, usecaseFIDlist, isSelectedFolderCountGT5);
           sailAway(usecaseFIDlist, loginInvitee, nameInvitee, accessToken, quoteID);
           //note: after packaging, pull name from logged in user
           pageRef.setRedirect(true);
           
            return pageRef; 
      }
      
      else if (loginInvitee != loginInviteeConfirm){
            pageRef.setRedirect(false); 
            
            return null; 
             
          } 
            
   return null;
   
  } 

/**
  *Pull access token from Token__c object
  *
  * Relies on scheduled class that updates refresh/access tokens every 30 minutes
  *
  *
  */
    public String newToken(){
        //pull and return value of Access Token 
        Token__c myAccessToken = [SELECT Name, Value__c FROM Token__c WHERE Name='Access'];
        String accessToken = myAccessToken.Value__c;
        System.debug('Value of access token: ' + accessToken);
               
        return accessToken;

    } //./end newToken()

                    /***************************************************START SALI AWAY (Future Class)********************************************************/


 /**
  * Where the Magic Happens...
  *
  * Asynchronous method to call the Box api to preform necessary operations
  * 1. Create staging solder
  * 2. For each folder selected by user:
  *    - copy folder from the Treasury to staging folder
  * 3. Invite user to staging folder
  * 4. Transfer ownership of folder to user (requires accept custom TOS))
  * 5. Look up new collaboration id (under new folder owner)
  * 6. Remove the Treasury from the user's new folder
  *
  * @param {String[] useCases, String loginInvitee, String nameInvitee, String accessToken, String templateName}
  *   - User Name and Template Name for naming Staging Folder
  *   - List of use cases and access token for calling the Box API
  *   - Login for inviting Box user to new staging folder
  *
  *
  */  
  /* @future (callout=true)*/
    @future (callout=true)
    public static void sailAway(String[] useCases, String loginInvitee, String nameInvitee, String accessToken, String templateName) {
        //initialize auth header
         nameInvitee = UserInfo.getName(); 
        String authorizationHeader = 'Bearer ' + accessToken;
        String FinalID = ''; //where staging folder ID will be saved
        String BoxJSON = ''; //store http response
        
        /***********************STEP 1.0: CREATE STAGING FOlder **********************/
        /*
        * Request format: 
        * -H "Authorization: Bearer ACCESS_TOKEN" \
        * -d '{"name":"New Folder", "parent": {"id": "0"}}' \
        * -X POST
        *
        *
        * Response format:
        * - parse folder ID, save as FinalID
        *
        */
        HttpRequest reqCreate = new HttpRequest();
        reqCreate.setMethod('POST');
        String endpointCreate = 'https://api.box.com/2.0/folders/';
        reqCreate.setEndpoint(endpointCreate);
        reqCreate.setHeader('Authorization', authorizationHeader);
        System.debug('authorizationHeader: ' + authorizationHeader);
        String folderName = (templateName + ' Folder for ' + nameInvitee + ' created: ' + string.valueOf(System.now()));
        reqCreate.setBody('{"name": "' + folderName + '", "parent" : {"id":"0"}}');
        //reqCreate.setBody('{"name": "Demo Folder for ' + loginInvitee + ' ' + string.valueof(System.now())", "parent" : {"id":"0"}}');
        //Create Http, send request
        Http httpCreate = new Http();
        Boolean successCreate = false;
        System.debug('Create Request : ' + reqCreate); 
        System.debug('Create Request body: ' + reqCreate.getBody());
        //loop until request goes through
        while (successCreate == false){
            try{
                HTTPResponse resCreate = httpCreate.send(reqCreate);
                //save json response to BoxJSON, parse JSON
                BoxJSON = resCreate.getBody();
                System.debug('Create folder response: ' + BoxJSON);
                successCreate = true;
            }
            catch (System.Exception e){
                System.debug('Error creating folder: ' + string.valueof(e));
            }
    
        }
         
        //Parse JSON from createStagingFolder
        //save created folder ID as var FinalID
        Boolean firstIDCreate = false;
        //initialize parser
        JSONParser parserCreate = JSON.createParser(BoxJSON);
        //loop through tokens to be parsed
        while (parserCreate.nextToken() != null){
            //save values associated with id
            if (parserCreate.getCurrentToken() == JSONToken.FIELD_Name){
                String fieldName = parserCreate.getText();
                parserCreate.nextToken();
                //get first ID attribute and save as FinalID
                if (fieldName == 'id'){
                    if (firstIDCreate == false){
                    
                       FinalID = parserCreate.getText();
                       firstIDCreate = true;
                       
                    }
                       
                }
            }
        } 
     
        /************************* ./ END STEP 1: CREATE FOLDER ****************/      
        
        if (Test.isRunningTest()) {
            Test.setMock(HTTPCalloutMock.class, new TreasuryHTTPCopyTest());
        }

        /************************* STEP 2: COPY FOLDERS ************************/
        /*
        * Loop for each folder selected
        *
        * Request:
        * -Endpoint : https://api.box.com/2.0/folders/FOLDER_ID/copy \
        * -H "Authorization: Bearer ACCESS_TOKEN" \
        * -d '{"parent": {"id" : DESTINATION_FOLDER_ID}}' \
        * -X POST
        *
        * Response:
        * Don't parse response
        *
        */

        //create HTTP request outside of loop
        HttpRequest reqCopy = new HttpRequest();
        reqCopy.setMethod('POST');
        reqCopy.setHeader('Authorization', authorizationHeader);
        reqCopy.setBody('{"parent":{"id":' + FinalID + '}}');
        String endpointCopy = '';
        Http httpCopy = new Http();
        Boolean success = false;
        System.debug('Copy Request : ' + reqCopy); 
        System.debug('Copy Request body: ' + reqCopy.getBody());
        // loop to copy each selected useCase
        for (Integer i = 0; i < useCases.size(); i++){
            
            String tempID = useCases[i];
            endpointCopy = 'https://api.box.com/2.0/folders/' + tempID + '/copy';        
            reqCopy.setEndpoint(endpointCopy);
            success = false;
            while (success == false){
                try{
                    HTTPResponse resCopy = httpCopy.send(reqCopy);
                    //save json response to BoxJSON, parse JSON
                    BoxJSON = resCopy.getBody();
                    success = true;
                    System.debug('Copy Response: ' + BoxJSON);
                }
                catch (System.Exception e){
                    System.debug('Error Copying: ' + string.valueof(e));
                }    
            }        
        }
        /******************** ./ END STEP 2 *************************/

        if (Test.isRunningTest()) {
           Test.setMock(HTTPCalloutMock.class, new TreasuryHTTPCollabTest());
        }

        /********************** STEP 3: ADD COLLABORATOR ********************/
        /*
        * Add user email as collaborator to created folder
        *
        * Request: 
        * -Endpoint: https://api.box.com/2.0/collaborations \
        * -H "Authorization: Bearer ACCESS_TOKEN" \
        * -d '{"item": { "id": "FOLDER_ID", "type": "folder"}, "accessible_by": { "id": "USER_ID", "type": "user" }, "role": "editor"}' \
        * -X POST
        *
        * Response:
        * Parse collab ID for next step
        *
        *
        *
        */

        //INVITE COLLABORATOR TO FinalID FOLDER
        //create HTTP Request, set method
        HttpRequest reqCollab = new HttpRequest();
        reqCollab.setMethod('POST');
        //endpoint limit 5 responses
        String endpointCollab = 'https://api.box.com/2.0/collaborations';
        reqCollab.setEndpoint(endpointCollab);
        //authorization header
        reqCollab.setHeader('Authorization', authorizationHeader);
        reqCollab.setBody('{"item":{"id":"' + FinalID + '", "type":"folder"}, "accessible_by": {"login":"' + loginInvitee + '"}, "role":"editor"}');
        //Create Http, send request
        Http httpCollab = new Http();
        success = false;
        System.debug('Invite Request : ' + reqCollab); 
        System.debug('Invite Request body: ' + reqCollab.getBody());
        while (success == false){
            try{
                HTTPResponse resCollab = httpCollab.send(reqCollab);
                BoxJSON = resCollab.getBody();
                System.debug('Invite Collab Response: ' + BoxJSON);
                success = true;
                
            } 
            catch (System.Exception e){
                System.debug('Error Inviting: ' + string.valueof(e));
            }
       }

        //PARSE TO GET COLLAB ID
        String CollabID = '';
        Boolean isFirstCollab = false;
        //initialize parser
        JSONParser parserCollab = JSON.createParser(BoxJSON);
        //loop through tokens to be parsed
        while (parserCollab.nextToken() != null){
            //save values associated with id
            if (parserCollab.getCurrentToken() == JSONToken.FIELD_Name){
                String fieldNameCollab = parserCollab.getText();
                parserCollab.nextToken();
                //add file ids and file names to global variables
                if (fieldNameCollab == 'id'){
                    if (isFirstCollab == false){
                    
                       CollabID = parserCollab.getText();
                       isFirstCollab = true;
                    }
                       
                }
           }
       }

       /************** ./ END STEP 3 ***********************/
       
       if (Test.isRunningTest()) {
           Test.setMock(HTTPCalloutMock.class, new TreasuryHTTPEditCollabTest());
           }

       /************************ STEP 4: EDIT COLLABORATION *****************/
       /*
       * Make invited user owner of folder
       *
       * Request:
       * Endpoint: https://api.box.com/2.0/collaborations/COLLAB_ID \
       * -H "Authorization: Bearer ACCESS_TOKEN" \
       * -d '"role": "viewer" ' \
       * -X PUT
       *
       * 
       *
       */

       //MAKE USER OWNER OF FinalID FOLDER
       //create HTTP Request, set method
        HttpRequest reqOwner = new HttpRequest();
        reqOwner.setMethod('PUT');
        //endpoint limit 5 responses
        String endpointOwner = 'https://api.box.com/2.0/collaborations/' + CollabID;
        reqOwner.setEndpoint(endpointOwner);
        //authorization header
        reqOwner.setHeader('Authorization', authorizationHeader);
        reqOwner.setBody('{"role":"owner"}');
        //Create Http, send request
        Http httpOwner = new Http();
        Boolean successOwner = false;
        System.debug('Owner Request : ' + reqOwner); 
        System.debug('Owner Request body: ' + reqOwner.getBody());
        while (successOwner == false){
            try{
                HTTPResponse resOwner = httpOwner.send(reqOwner);
                //save json response to BoxJSON, parse JSON
                BoxJSON = resOwner.getBody();
                successOwner = true;
                System.debug('Owner Response: ' + BoxJSON);
            }
            catch (System.Exception e){
                System.debug('Error editing owner: ' + string.valueof(e));
            }
        
       }
       /******************** ./ END STEP 4 ********************/
        
         if (Test.isRunningTest()) {
           Test.setMock(HTTPCalloutMock.class, new TreasuryHTTPNewCollabTest());
         }
       /*********************** STEP 5: GET NEW COLLAB ID ******************/
       /*
       * Retrieve collaboration from folder ID
       *
       * Request: 
       * Endpoint: https://api.box.com/2.0/collaborations/COLLAB_ID \
       * -H "Authorization: Bearer ACCESS_TOKEN"        
       * -d folder_ID
       *
       * Response:
       * Parse new collaboration ID (Used in Step 6)
       *
       *
       */

        HttpRequest reqNewID = new HttpRequest();
        reqNewID.setMethod('GET');
        //endpoint limit 5 responses
        String endpointNewID = 'https://api.box.com/2.0/folders/' + FinalID + '/collaborations';
        reqNewID.setEndpoint(endpointNewID);
        reqNewID.setHeader('Authorization', authorizationHeader);
        Http httpNewID = new Http();
        Boolean successNewID = false;
        System.debug('New ID Request : ' + reqNewID); 
        System.debug('New ID Request body: ' + reqNewID.getBody());
        while (successNewID == false){
            try{
                HTTPResponse resNewID = httpNewID.send(reqNewID);
                //save json response to BoxJSON, parse JSON
                BoxJSON = resNewID.getBody();
                successNewID = true;
                System.debug('New ID Response: ' + BoxJSON);
            }
             catch (System.Exception e){
                System.debug('Error New ID: ' + string.valueof(e));
            }
        
       }

       //PARSE NEW COLLAB ID
       String NEWCollabID = '';
        Boolean isFirstNewID = false;
        //initialize parser
        JSONParser parserNewID = JSON.createParser(BoxJSON);
        //loop through tokens to be parsed
        while (parserNewID.nextToken() != null){
            //save values associated with id
            if (parserNewID.getCurrentToken() == JSONToken.FIELD_Name){
                String fieldNameNewID = parserNewID.getText();
                parserNewID.nextToken();
                //add file ids and file names to global variables
                if (fieldNameNewID == 'id'){
                    if (isFirstNewID == false){
                    
                       NEWCollabID = parserNewID.getText();
                       isFirstNewID = true;
                    }
                       
                }
           }
        }

        /********************** ./ END STEP 5 ***************************/
         if (Test.isRunningTest()) {
           Test.setMock(HTTPCalloutMock.class, new TreasuryHTTPRemoveTest());
          }
        /*************************** START STEP 6: REMOVE TREASURY *****************/
        /*
        * Remove Treasury from collaborated folder
        *
        * Request: 
        * Endpoint: https://api.box.com/2.0/collaborations/COLLAB_ID \
        * -H "Authorization: Bearer ACCESS_TOKEN" \
        * -X DELETE
        *
        *
        */

        //DELETE MASTER ORG
        HttpRequest reqDelete = new HttpRequest();
        reqDelete.setMethod('DELETE');
        //endpoint limit 5 responses
        String endpointDelete = 'https://api.box.com/2.0/collaborations/' + NEWCollabID;
        reqDelete.setEndpoint(endpointDelete);
        //authorization header
        reqDelete.setHeader('Authorization', authorizationHeader);
        Http httpDelete = new Http();
        Boolean successDelete = false;
        System.debug('Delete Request : ' + reqDelete); 
        System.debug('Delete Request body: ' + reqDelete.getBody());
        while (successDelete == false){
            try {
                HTTPResponse resDelete = httpDelete.send(reqDelete);
                //save json response to BoxJSON, parse JSON
                BoxJSON = resDelete.getBody();
                successDelete = true;
                System.debug('Delete Response: ' + BoxJSON);
            }
            catch (System.Exception e){
                System.debug('Error deleting: ' + string.valueof(e));
            }
        
        
       } 

       /********************** ./END STEP 6 **************************/
       /******************************************************************************** close sailAway *************************************************************/
    }    
                                                                            /************* REPORTING *************/
/*
  * Create Treasury Report object with info of job request
  *
  * @param {String email, String name, String templateName, String[] useCases, Boolean isSelectedFolderCountGT5}
  * name and email of user, name of treasury entry, array of selected folders
  *
  */  
    public void createReport(String email, String name, String templateName, String[] useCases, Boolean isSelectedFolderCountGT5){
         Treasury_Report__c newReport = new Treasury_Report__c();
         newReport.User_Name__c = UserInfo.getName();
         newReport.User_Email__c = email;
         Demo_Template__c curTemplate = [SELECT Name FROM Demo_Template__C WHERE Name =: templateName];
         newReport.Demo_Template__c = curTemplate.id;
         System.debug('Name: ' + newReport.User_Name__c);
         System.debug('Email: ' + newReport.User_Email__c);
         System.debug('Template: ' + curTemplate.Name);
         
         if ( isSelectedFolderCountGT5 == true){
             newReport.Transferred_Parent_Folder__c = true; 
             System.debug('Report - Transferred Parent Folder (gt5)');
            
         } else if ( isSelectedFolderCountGT5 == false){
             for (Integer i = 0; i < useCases.size(); i++){
            
                String tempID = useCases[i];
                String fieldName = 'Related_Folder_'+(i+1)+'__c';
                Related_Folder__c tempFolder = [SELECT Name, folderID__c FROM Related_Folder__c WHERE folderID__c =: tempID];
                System.debug('Field Name, folder: ' + fieldName + ' , ' + tempFolder.Name);
                newReport.put(fieldName, tempFolder.id); 
           
             }
         }
         
         
         insert newReport;
     
     }



    //close Apexclass
    
}