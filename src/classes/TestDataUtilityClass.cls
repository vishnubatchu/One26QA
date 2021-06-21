@isTest
public class TestDataUtilityClass {
    public static void preparetestData(){
        createUsers();
        List<Account> acclist=  createAccounts();
        User rsmuser =[select id From User where Name like '%RSM User 1%'];
        createOpportunity();
        Loaner__c loaner = createLoanersandLoanerLines(rsmuser);
        createReturnDetail(loaner);
        createRMAorCases(acclist);
        createFAFVData();
    }
    public static void createUsers()
    {
        Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Profile' LIMIT 1];
        Profile PLMUserProfile = [SELECT Id FROM Profile WHERE Name = 'Marketing/PLM Profile' LIMIT 1];
        Profile qualityUserProfile = [SELECT Id FROM Profile WHERE Name = 'Quality Profile' LIMIT 1];
        Profile distributorUserProfile = [SELECT Id FROM Profile WHERE Name = 'Finisar Partner Community User (Disti Users)' LIMIT 1];
        Profile qualityAdminProfile = [SELECT Id FROM Profile WHERE Name = 'Quality Admin Profile' LIMIT 1];
        
        String rsmrole =[select Id from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
        String vprole =[select Id from UserRole where Name='VP of AMERICAS - WESTERN' LIMIT 1].Id;
        String evprole =[select Id from UserRole where Name='EVP' LIMIT 1].Id;
        String FAManagerrole = [select Id,Name  from UserRole where Name like 'FA M%'  Limit 1].Id;
        String FAEEngineersrole = [select Id,Name  from UserRole where Name like 'FA E%'  Limit 1].Id;
        
        UserRole insdieuserrole = [Select Id from UserRole Where DeveloperName ='Inside_Sales_FAE'];
        Profile usrProfile = [SELECT Id from Profile where Name ='System Administrator'];
        
        createTestUser(rsmrole,salesUserProfile.Id,'RSM User 1','RSM User 1');
        createTestUser(vprole,salesUserProfile.Id,'VP User 1','VP User 1'); 
        createTestUser(evprole,salesUserProfile.Id,'EVP User 1','EVP User 1'); 
        createTestUser(FAEEngineersrole,qualityUserProfile.Id,'FAEUser 1','FAEUser 1'); 
        createTestUser(FAManagerrole,qualityAdminProfile.Id,'FA Manager User 1','FA Manager User 1'); 
        createTestUser(insdieuserrole.Id,usrProfile.Id, 'Inside User','Inside User');
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            User salesAdmin=[select Id From User where Name like 'RSM User 1%' Limit 1];
            PermissionSet permissionset = [select Id From PermissionSet where Label like 'Sales Admin Profile Permission Set%' limit 1 ];
            PermissionSetAssignment permset=new PermissionSetAssignment(AssigneeId = salesAdmin.Id,PermissionSetId = permissionset.Id); 
            insert permset;
        }
        
    }
    public static void createPartnerUsers(){
        
    }
    public static void createTestUser(Id roleId, Id profID, String fName, String lName) {
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                              lastName = lName,
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profId,
                              isActive = True,
                              UserRoleId = roleId);
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert tuser;
        }
        
        //  return tuser;
    }
    public static List<Account> createAccounts()
    {
        Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId()	);
        insert globalParentAcc;
        List<Account> accountsList = new List<Account>();
        Account acc1 = new Account(name='AccountTopLevelTest', Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                   Status__c='Active',Type='Customer',ShippingCity = 'New York', ShippingCountry ='US',ParentId = globalParentAcc.Id,RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        accountsList.add(acc1);
        Account acc2 = new Account(name='AccountCustomer1 ', Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                   ParentId=globalParentAcc.Id,Status__c='Active',ShippingCity = 'New York', ShippingCountry ='US',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId());
        accountsList.add(acc2);
        Account siteacc = new Account(name='AccountSite ', Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                      shippingcity='New York',Site_Use_Code__c='SHIP_TO',Site_Use_Status__c='Active',parentId=globalParentAcc.id, shippingcountry='US',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId(),
                                      Org_ID__c= '2');
        accountsList.add(siteacc);
        insert accountsList;
        return accountsList;
        
    }
    public static string createOpportunity()
    {
        UserRole rsmrole = [select Id From UserRole where Name like 'RSM%' Limit 1];
        User RSMUser = [select Id From User where UserRoleId =:rsmrole.Id Limit 1];
        Opportunity opty= new Opportunity(Name='Test Oppty 1');
        Account accounttest =[select Id From Account where Name ='AccountTopLevelTest'];
        opty.AccountId = accounttest.Id;
        opty.Project_Name__c ='test project';
        opty.StageName ='Open - Discussion';
        opty.Next_Action_Due_Date__c = Date.Today();
        opty.NextStep = 'Test';
        opty.CloseDate = System.today() + 60 ;
        opty.RSM__c =RSMUser.Id;
        insert opty;
        Opportunity opty2= new Opportunity();
        Account accounttest2 =[select Id From Account where Name ='AccountTopLevelTest'];
        opty2.name = 'TestOppty2';
        opty2.AccountId = accounttest2.Id;
        opty2.Project_Name__c ='test project';
        opty2.StageName ='Open - Discussion';
        opty2.CloseDate = System.today() + 60 ;
        opty2.Next_Action_Due_Date__c = Date.Today();
        opty2.NextStep = 'Test';
        opty2.RSM__c =RSMUser.Id;
        insert opty2;
        return '';  
    }
    public static Loaner__c createLoanersandLoanerLines(User rsmuser)
    {
        Loaner__c loaner = new Loaner__c();
        list<Loaner__c> loanerList = new list<Loaner__c>();
        list<Loaner_Line__c> lianerLineList = new list<Loaner_Line__c>();
        //UserRole insdieuserrole = [Select Id from UserRole Where DeveloperName ='Inside_Sales_FAE'];
        //Profile usrProfile = [SELECT Id from Profile where Name ='System Administrator'];
        User insideUser = [Select Id from user where Name Like '%Inside User%' limit 1];
        Product2 prod = new Product2(IsActive = true,Status__c = 'Active',Name = 'Test Product',ExternalId__c = '12534', ProductCode = 'Test Product Code',Marketing_P_N__c = 'Test PN');
        insert prod;
        Account acctop =[select Id From Account where Name ='AccountTopLevelTest'];
        Account acc =[select Id From Account where Name ='AccountCustomer1'];
        Account Site =[select Id From Account where Name='AccountSite'];
        system.debug('opp@@@ '+ [select Id From Opportunity limit 1 ]);
        Opportunity Opp =[select Id From Opportunity limit 1 ];
        Loaner_Line__c loanerLine = new Loaner_Line__c();
        loaner = new Loaner__c(RecordTypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request').getRecordTypeId(),Company_Name_End_Cust__c = acctop.Id,Project_Engineer__c='Test',Project_Name__c = 'Test',Est_Production_Date__c = Date.Today(),
                               RSM_PLM_Finisar__c=rsmuser.Id,Address_ship_to__c=Site.Id, Opportunity_Type__c='New Opportunity', Loaner_Duration__c='180',Loaner_Ship_From_Finisar__c = 'Factory Stock', Status_Approval__c ='Pending Sales Order',Inside_Sales_Sales_rep__c = UserInfo.getUserId(),Opportunity__c=Opp.Id,Inside_Sales_Finisar__c = insideUser.Id);
        loanerList.add(loaner);
        Loaner__c loaner2 = new Loaner__c(RecordTypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request').getRecordTypeId(),Company_Name_End_Cust__c = acctop.Id,Project_Engineer__c='Test',Project_Name__c = 'Test2Invaliddata',Opportunity__c =Opp.Id
                                          ,RSM_PLM_Finisar__c=rsmuser.Id,Address_ship_to__c=Site.Id, Opportunity_Type__c='New Opportunity', Loaner_Duration__c='180',Loaner_Ship_From_Finisar__c = 'Factory Stock', Status_Approval__c ='Draft',Inside_Sales_Sales_rep__c = UserInfo.getUserId(),Inside_Sales_Finisar__c = insideUser.Id);
        loanerList.add(loaner2);
        Loaner__c loaner3 = new Loaner__c(RecordTypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request').getRecordTypeId(),Company_Name_End_Cust__c = acctop.Id,Project_Engineer__c='Test',Project_Name__c = 'Test2OpportunityTest',Est_Production_Date__c =Date.today(),
                                          RSM_PLM_Finisar__c=rsmuser.Id,Address_ship_to__c=Site.Id, Opportunity_Type__c='New Opportunity', Loaner_Duration__c='180',Loaner_Ship_From_Finisar__c = 'Factory Stock', Status_Approval__c ='Draft',Inside_Sales_Sales_rep__c = UserInfo.getUserId(),Inside_Sales_Finisar__c = insideUser.Id);
        loanerList.add(loaner3);           
        Loaner__c loanerrecord = new Loaner__c(RecordTypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request').getRecordTypeId(),Company_Name_End_Cust__c = acctop.Id,Project_Engineer__c='Test',Project_Name__c = 'Test',Est_Production_Date__c = Date.Today(),
                                               RSM_PLM_Finisar__c =rsmuser.Id ,RSM_PLM_Approval__c=rsmuser.Id,Address_ship_to__c=Site.Id, Opportunity_Type__c='New Opportunity - < 100K SAM', Loaner_Duration__c='180',Loaner_Ship_From_Finisar__c = 'Factory Stock', Status_Approval__c ='Draft',Inside_Sales_Sales_rep__c = UserInfo.getUserId(),Inside_Sales_Finisar__c = insideUser.Id);
        loanerList.add(loanerrecord);  
        insert loanerList;
        Loaner_Line__c loanerLine2= new Loaner_Line__c(Loaner__c = loanerList[0].Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c =10,
                                                       Manual_Update__c=true,Manual_Shipped_Date__c=System.today(),     Loaner_Qty__c=5, Line_Status__c='Approved',Product__c=prod.Id,Est_Annual_Qty__c = 5,SOM__c = 5);
        lianerLineList.add(loanerLine2);
        loanerLine= new Loaner_Line__c(Loaner__c = loanerList[0].Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c=10,
                                       Manual_Update__c=true,Manual_Shipped_Date__c=System.today(),Loaner_Qty__c=5,   Line_Status__c='Approved',Product__c=prod.Id,Est_Annual_Qty__c = 5,SOM__c = 5);
        lianerLineList.add(loanerLine);
        Loaner_Line__c loanerLine1= new Loaner_Line__c(Loaner__c = loanerList[1].Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c=10,
                                                       Line_Status__c='Draft',Product__c=prod.Id,Loaner_Qty__c =null,Est_Annual_Qty__c=null);
        lianerLineList.add(loanerLine1);
        Loaner_Line__c loaner3line1= new Loaner_Line__c(Loaner__c = loanerList[2].Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c=10,
                                                        Line_Status__c='Draft',Product__c=prod.Id,Loaner_Qty__c =null,Est_Annual_Qty__c=null);
        lianerLineList.add(loaner3line1);
        Loaner_Line__c loanerrecordLine= new Loaner_Line__c(Loaner__c = loanerList[3].Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c=10,
                                                            Line_Status__c='Draft',Product__c=prod.Id,Loaner_Qty__c =2,Est_Annual_Qty__c=null);
        lianerLineList.add(loanerrecordLine);
        insert lianerLineList;
        return loaner;
    }
    public static void createRMAorCases(List<Account> accountlist)
    {
        String FAErole = [select Id From UserRole where Name like 'FA E%' Limit 1].Id;
        User FAEUser = [select Id  From User where Name like '%FAEUser 1%'];
        Account acc =[select Id From Account where Name ='AccountCustomer1'];
        Account Site =[select Id From Account where Name='AccountSite'];
        Case caserec = new Case();
        caserec.AccountId =accountlist.get(0).Id;
        caserec.Found_By__c = 'Customer';
        caserec.Part_Numbers_s__c ='12344565';
        caserec.FAE__c = FAEUser.Id;
        caserec.Ship_To_Customer__c = acc.Id;
        caserec.Ship_To_Address__c=Site.Id;
        insert caserec;
        Case RMArequest = new Case();
    }
    public static void createReturnDetail(Loaner__c loaner)
        
    {
        Return_Detail__c rd = new Return_Detail__c();
        rd.Return_Date__c =System.today() +2;
        Loaner_Line__c loanerline = [select Id From Loaner_Line__c where Loaner__c =:loaner.Id and Line_Status__c ='Approved' Limit 1];
        rd.Loaner_Line__c  =loanerline.Id;
        rd.Return_Quantity__c=5;
        insert rd;
        Disposition_Transfer_Details__c dtransferdetails = new Disposition_Transfer_Details__c();
        dtransferdetails.Close_Date__c=System.today() + 2;
        dtransferdetails.Quantity__c = 5;
        dtransferdetails.Return_Detail__c =rd.Id;
        insert dtransferdetails;
        
        
        
    }
    public static void createFAFVData()
    {
        FA_FV_Analysis__c FAFvFinalRecord = new FA_FV_Analysis__c(Name= 'updateInprogress',FA_FV_Status__c='Finalized',RecordTypeId = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FA Analysis').getRecordTypeId()); 
        insert FAFvFinalRecord;
        
        Failure_Modes__c fmode1= new Failure_Modes__c(FAFV_Analysis__c =FAFvFinalRecord.id,Fault_Specification__c='Defective',PDC_Level_2__c='Crack',PIC_Level_1__c =
                                                      'Component',PDC_Level_1__c='Flex',PIC_Level_2__c='Adhesive/Epoxy',Site__c='IPH' );
        insert fmode1;   
        Steps__c  step = new Steps__c(Name='testupdateInprogress',FA_FV__c=FAFvFinalRecord.id,FA_Findings__c='testtt',Comments__c='test',FA_Steps_Description_FA_Steps__c='testt');
        insert step;
        
        
    }
    
}