public class CommonConstants {
    
    public static Set < String > approvalActions = New Set < String > {
        'Approved',
            'approved',
            'Approve',
            'approve',
            'Yes',
            'yes'
            };
                public static Set < String > rejectionActions = New Set < String > {
                    'Rejected',
                        'rejected',
                        'Reject',
                        'reject',
                        'No',
                        'No'
                        };
                            
                            public static Set< String > forwardAction = New Set < String >{
                                'Forward',
                                    'forward',
                                    'Reassign',
                                    'reassign'        
                                    };
                                        public static Map < String, String > mapUserRoleToField = New Map < String, String > {
                                            'RSM of AMERICAS - EASTERN' => 'RSM__c',
                                                'RSM of AMERICAS - WESTERN' => 'RSM__c',
                                                'RSM of APAC' => 'RSM__c',
                                                'RSM of EMEA' => 'RSM__c',
                                                'RSM of JAPAN' => 'RSM__c',
                                                'VP of AMERICAS - EASTERN' => 'VP__c',
                                                'VP of AMERICAS - WESTERN' => 'VP__c',
                                                'VP of APAC' => 'VP__c',
                                                'VP of EMEA' => 'VP__c',
                                                'VP of JAPAN' => 'VP__c',
                                                'EVP' => 'SVP__c',
                                                'TSS Admin' => 'SVP__c',
                                                'RSM of AMERICAS - EASTERN WSS' => 'RSM__c',
                                                'RSM of AMERICAS - WESTERN WSS' => 'RSM__c',
                                                'RSM of APAC WSS' => 'RSM__c',
                                                'RSM of EMEA WSS' => 'RSM__c',
                                                'RSM of JAPAN WSS' => 'RSM__c',
                                                'VP of AMERICAS - EASTERN WSS' => 'VP__c',
                                                'VP of AMERICAS - WESTERN WSS' => 'VP__c',
                                                'VP of APAC WSS' => 'VP__c',
                                                'VP of EMEA WSS' => 'VP__c',
                                                'VP of JAPAN WSS' => 'VP__c',
                                                'EVP WSS' => 'SVP__c',
                                                'TSS Admin WSS' => 'SVP__c'
                                                };
                                                    public static Set < String > approvalStatusSet = New Set < String > {
                                                        'Not Required',
                                                            'Pending',
                                                            'Approval Pending'
                                                            };
                                                                
                                                                // Roles
                                                                public static String RSM = 'RSM by Region';
    public static String VP = 'VP by Region';
    public static String SVP = 'EVP';
    public static String SalesRep = 'Sales Rep';
    
    public static Map < String,
        Set < String > >mapOfUserField = New Map < String, Set < String > >{
            'Quote' => New Set < String > {
                'RSM_Approver__c',
                    'PLM_Approver__c'
                    },
                        'Loaner__c' => New Set < String > {
                            'RSM__c',
                                'VP__c',
                                'SVP__c'
                                }
        };
            
            public static Map < String, Map < String, Set < String >>> mapOfRolesReassignment = New Map < String, Map < String, Set < String >>> {
                'Quote' => New Map < String, Set < String >> {
                    'RSM of AMERICAS - EASTERN' => New Set < String > { 'RSM of AMERICAS - EASTERN', 'EVP' },
                        'RSM of AMERICAS - WESTERN' => New Set < String > { 'RSM of AMERICAS - WESTERN', 'EVP' },
                            'RSM of APAC' => New Set < String > { 'RSM of APAC', 'EVP' },
                                'RSM of EMEA' => New Set < String > { 'RSM of EMEA', 'EVP' },
                                    'RSM of JAPAN' => New Set < String > { 'RSM of JAPAN', 'EVP' },
                                        'PLM' => New Set < String > { 'PLM','PLD','Sales Admin'},
                                            'RSM of AMERICAS - EASTERN WSS' => New Set < String > { 'RSM of AMERICAS - EASTERN WSS', 'EVP WSSa' },
                                                'RSM of AMERICAS - WESTERN WSS' => New Set < String > { 'RSM of AMERICAS - WESTERN WSS', 'EVP WSS' },
                                                    'RSM of APAC WSS' => New Set < String > { 'RSM of APAC WSS', 'EVP WSS' },
                                                        'RSM of EMEA WSS' => New Set < String > { 'RSM of EMEA WSS', 'EVP WSS' },
                                                            'RSM of JAPAN WSS' => New Set < String > { 'RSM of JAPAN WSS', 'EVP WSS' },
                                                                'PLM WSS' => New Set < String > { 'PLM WSS','PLD WSS','Sales Admin WSS'}
                },
                    'Loaner__c' => New Map < String, Set < String >> {
                        'RSM of AMERICAS - EASTERN'  => 		New Set < String > { 'RSM of AMERICAS - EASTERN'},
                            'RSM of AMERICAS - WESTERN' => 		New Set < String > { 'RSM of AMERICAS - WESTERN'},
                                'RSM of APAC' 				=> 		New Set < String > { 'RSM of APAC'},
                                    'RSM of EMEA' 				=> 		New Set < String > { 'RSM of EMEA'},
                                        'RSM of JAPAN' 				=> 		New Set < String > { 'RSM of JAPAN'},
                                            'VP of AMERICAS - EASTERN' 	=> 		New Set < String > { 'VP of AMERICAS - EASTERN','VP of AMERICAS - WESTERN','VP of APAC','VP of JAPAN','VP of EMEA'},
                                                'VP of AMERICAS - WESTERN'  => 		New Set < String > { 'VP of AMERICAS - EASTERN','VP of AMERICAS - WESTERN','VP of APAC','VP of JAPAN','VP of EMEA'},
                                                    'VP of APAC' 				=> 		New Set < String > { 'VP of AMERICAS - EASTERN','VP of AMERICAS - WESTERN','VP of APAC','VP of JAPAN','VP of EMEA'},
                                                        'VP of EMEA' 				=> 		New Set < String > { 'VP of AMERICAS - EASTERN','VP of AMERICAS - WESTERN','VP of APAC','VP of JAPAN','VP of EMEA'},
                                                            'VP of JAPAN' 				=> 		New Set < String > { 'VP of AMERICAS - EASTERN','VP of AMERICAS - WESTERN','VP of APAC','VP of JAPAN','VP of EMEA'},
                                                                'EVP' 						=> 		New Set < String > { 'EVP' },
                                                                    'RSM of AMERICAS - EASTERN WSS'  => 		New Set < String > { 'RSM of AMERICAS - EASTERN WSS'},
                                                                        'RSM of AMERICAS - WESTERN WSS' => 		New Set < String > { 'RSM of AMERICAS - WESTERN WSS'},
                                                                            'RSM of APAC WSS' 				=> 		New Set < String > { 'RSM of APAC WSS'},
                                                                                'RSM of EMEA WSS' 				=> 		New Set < String > { 'RSM of EMEA WSS'},
                                                                                    'RSM of JAPAN WSS' 				=> 		New Set < String > { 'RSM of JAPAN WSS'},
                                                                                        'VP of AMERICAS - EASTERN WSS' 	=> 		New Set < String > { 'VP of AMERICAS - EASTERN WSS','VP of AMERICAS - WESTERN WSS','VP of APAC WSS','VP of JAPAN','VP of EMEA WSS'},
                                                                                            'VP of AMERICAS - WESTERN WSS'  => 		New Set < String > { 'VP of AMERICAS - EASTERN WSS','VP of AMERICAS - WESTERN WSS','VP of APAC WSS','VP of JAPAN WSS','VP of EMEA WSS'},
                                                                                                'VP of APAC WSS' 				=> 		New Set < String > { 'VP of AMERICAS - EASTERN WSS','VP of AMERICAS - WESTERN WSS','VP of APAC WSS','VP of JAPAN WSS','VP of EMEA WSS'},
                                                                                                    'VP of EMEA WSS' 				=> 		New Set < String > { 'VP of AMERICAS - EASTERN WSS','VP of AMERICAS - WESTERN WSS','VP of APAC WSS','VP of JAPAN WSS','VP of EMEA WSS'},
                                                                                                        'VP of JAPAN WSS' 				=> 		New Set < String > { 'VP of AMERICAS - EASTERN WSS','VP of AMERICAS - WESTERN WSS','VP of APAC WSS','VP of JAPAN WSS','VP of EMEA WSS'},
                                                                                                            'EVP WSS' 						=> 		New Set < String > { 'EVP WSS' }
                    }
            };
                
                public static Map < String, String > emailToCreator = New Map < String, String > {
                    'Quote' => 'Quote_Notification_To_Creator',
                        'Loaner__c' => 'Loaner_creator_Email'
                        };
                            public static Set < String > approvalPendingSet = New Set < String > {
                                'Draft',
                                    'Rejected',
                                    'Pending',
                                    'Approval Pending'
                                    };
                                        public static id LoanerRequestRecordtypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request').getRecordTypeId();
    public static id LoanerExtensiontypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Extension').getRecordTypeId();
    public static id LoanerRequestReadOnlyRecordtypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request Read Only').getRecordTypeId();
    public static id LoanerExtensionReadOnlytypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Extension Read Only').getRecordTypeId();
    public static id LoanerItemRecordtypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId();
    public static id LoanerExtensionRecordtypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Extension Item').getRecordTypeId();
    
    public static String vpEmptyreturnMessage = 'VP field can not be empty for Loaner Extension Approval';
    public static String vpInactivereturnMessage = 'VP is currently inactive.Please change VP field before Submitting for Approval';
    public static String VerifyWithBettyDeareturnMessage = 'Please confirm with Betty Dea and Check Verified with Betty Dea box';
    public static String loanerExtensionReturnDateEmpty = 'Loaner Extension Date cannot be empty';
    /*public static set < String > LoanerRequiredFields = New Set < String > {
'Opportunity_Type__c',
'RSM_PLM_Finisar__c',
'Inside_Sales_Finisar__c',
'Loaner_Ship_From_Finisar__c',
'Company_Name_End_Cust__c',
'Project_Engineer__c',
'Project_Name__c',
'Est_Production_Date__c',
'Address_ship_to__c',
'Company_Name_Ship_To__c',
'Loaner_Duration__c'
};*/
    
    public static set < String > LoanerRequiredFields = New Set < String > {
        'Opportunity_Type__c',
            'RSM_PLM_Finisar__c',
            'Inside_Sales_Finisar__c',
            'Loaner_Ship_From_Finisar__c',
            'Company_Name_End_Cust__c',
            'Project_Engineer__c',
            'Loaner_Category__c',
            'Project_Name__c',
            'Est_Production_Date__c',
            'Loaner_Duration__c',
            'Opportunity__c'
            };
                public static Map < String,String > LoanerRequiredFieldsLabel = New Map < String,String > {
                    'Opportunity_Type__c'=> 'Opportunity Type',
                        'RSM_PLM_Finisar__c' =>'RSM Finisar',
                        'Inside_Sales_Finisar__c' =>'Inside Sales-Finisar',
                        'Loaner_Ship_From_Finisar__c' =>'Loaner Ship From',
                        'Company_Name_End_Cust__c' =>'Company Name',
                        'Project_Engineer__c'=>'Project Engineer',
                        'Project_Name__c' =>'Project Name',
                        'Est_Production_Date__c' =>'Est Production Date',
                        'Opportunity__c'  => 'Opportunity #',
                        'Loaner_Duration__c'=>'Loaner Duration'
                        //'Address_ship_to__c'=>'Location',
                        //'Company_Name_Ship_To__c'=>'Company Name',
                        
                        };
                            
                            public static set < String > LoanerLineRequiredFields = New Set < String > {
                                'Product__c',
                                    'Loaner_Qty__c',
                                    'Est_Annual_Qty__c',
                                    'SOM__c',
                                    'Production_Price_ASP__c',
                                    'Loaner_Price_100_999_column_price__c'
                                    };
                                        public static Map < String,String > LoanerLineRequiredFieldsLable = New Map < String,String > {
                                            'Product__c' => 'Product',
                                                'Loaner_Qty__c' => 'Loaner Quantity',
                                                'Est_Annual_Qty__c' => 'EST ANNUAL QTY',
                                                'SOM__c' => 'SOM(%)',
                                                'Production_Price_ASP__c' =>'Production Price (ASP)',
                                                'Loaner_Price_100_999_column_price__c' =>'Loaner Price (100-999 column price)'    
                                                };
                                                    public static String pendingSalesorder = 'Please user Vaidate Loaner Button For Loaner Record with Status Pending Sales Order';
    public static String recordTypeError = 'Loaners can be of Loaner Item or Loaner Extension Type only';
    public static String invaliduserRole = 'Loaners can be submitted by Sales Reps,RSMs and VPs Only';
    public static set < String > QuoteRequiredFields = New Set < String > {
        'PrimarySalesperson__c',
            'Type_of_Pricing__c',
            'Account__c'
            };
                public static Map < String,String > QuoteRequiredFieldsLable = New Map < String,String > {
                    'PrimarySalesperson__c' => 'Primary Salesperson',
                        'Type_of_Pricing__c' => 'Type of Pricing',
                        'Account__c' => 'Account'
                        };
                            
                            public static set < String > QuoteLineRequiredFields = New Set < String > {
                                'Product__c',
                                    'Quantity__c',
                                    'Target_Price__c'
                                    };
                                        public static Map < String,String > QuoteLineRequiredFieldsLabel = New Map < String,String > {
                                            'Product__c' =>'Product',
                                                'Quantity__c' =>'Quantity',
                                                'Target_Price__c' =>'Target Price'
                                                };
                                                    
                                                    public static set < String > CommisionsAccountsFields = New set < String > {
                                                        'Salesrep_Name1__c',
                                                            'Salesrep_Name2__c',
                                                            'Salesrep_Name3__c',
                                                            'Salesrep_Name4__c',
                                                            'Salesrep_Name5__c',
                                                            'Salesrep_Name6__c',
                                                            'Salesrep_Name7__c',
                                                            'Salesrep_Name8__c',
                                                            'Salesrep_Name9__c',
                                                            'Salesrep_Name10__c'
                                                            };
                                                                /*
* Fields to be copied in Steps,FaultCodes,FA Analysis
* 
*/
                                                                public static List<String> FAAnalysisFields  =  new List<String>{
                                                                    'Id','Name','CA_Required__c','Comments__c','Completion_Date__c','Commit_Date__c','Complition_Date__c','Component_Description__c','Component_P_N__c',
                                                                        'Conclusion__c','Containment__c','Corrective_Action__c','Customer_Serial_Number__c','Date_Code__c','Disposition__c','Done_By__c','FA_Findings__c','RecordTypeId','RecordType.DeveloperName'
                                                                        ,'Failure_Description_at_the_Module_Level__c','Failure_Mechanism__c','Final_Function_Test__c','Final_Functional_Comments__c','Findings__c','FV_Findings__c','FV_Report_Status__c'
                                                                        ,'FA_FV_Status__c','FA_FV_Type__c','Order_Item_Id__c','Other_Description__c','Outcome__c','Primary_Failure__c','Problem_Statement__c','Quantity__c','RC_Analysis__c','Received_Date__c'
                                                                        ,'Risk_Assessment__c','Root_Cause_Statement__c','Secondary_Failure_Code__c','Site__c','Suppliers__c','Temp_BERT__c','Temp_Bert_Comments__c','Tertiary_Failure__c','Traceability_Information__c',
                                                                        'VMI__c','VMI_Comments__c','Statuspick__c'
                                                                        
                                                                        }; 
                                                                            public static List<String> StepFields  =  new List<String>{
                                                                                
                                                                                'Id','Name','Description__c','FA_Steps_Description_FA_Steps__c','FA_FV__c','Comments__c','FA_Findings__c'
                                                                                    
                                                                                    };
                                                                                        
                                                                                        public static List<String> FailureModes  =  new List<String>{
                                                                                            
                                                                                            'Id','Name','Component_Description__c','Fault_Specification__c','FAFV_Analysis__c','PDC_Level_1__c	','PDC_Level_2__c','PIC_Level_1__c','PIC_Level_2__c','Site__c','Traceability_Information__c'
                                                                                                
                                                                                                };
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    }