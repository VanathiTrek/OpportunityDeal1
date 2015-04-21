/**
	* Name: PIP_QA_on_OpportunityController
    * Author: Vanathi.V
    * Reviewer: Vishnu
    * Description: PIP_QA_on_OpportunityController is to take a note of Questions and Answers to close a deal. 
    			   This contains the conversation between rep and Client
**/
public with sharing class PIP_QA_on_OpportunityController {
	
	public String strOpportunityIdd 						{get;set;}
	public String Idd										{get;set;}
	
	public Decimal TotalAnswer 								{get;set;}
	public Decimal TotalAnsweredField 						{get;set;}
	public Decimal TotalUnAnsweredField						{get;set;}
	
	public list<QuestionAnswers> lstQuestionAnswers 		{get;set;}
	public list<selectOption> lstSelectOptions 				{get;set;}
	public list<Answer__c> lstAnswers 						{get;set;}
	public list<Product2> lstProductObject;
	
	//public map<String,Answer__c> mapAnswers				{get;set;}
	public map<String,list<Answer__c>> mapAnswers			{get;set;}
	public map<string,list<selectOption>> mapSelectOptions 	{get;set;}
	public map<string,string> mapOptions 					{get;set;}
	public map<Id,List<Product2>> mapPGid_Prod;
	
	public Answer__c objAnswer								{get;set;}
	
	//Inner Class
	public class QuestionAnswers {
		
		public String strProductGroupName					{get;set;} 
		public String strProductName 						{get;set;} 
		public String strOpportunityIdd 					{get;set;}
		public list<Question__c> lstQuestobject				{get;set;}
		public list<Product2> lstProductObject;
		
		public map<string,string> mapOptions 				{get;set;}
		//public map<String,Answer__c> mapAnswers			{get;set;}
		public map<String,list<Answer__c>> mapAnswers		{get;set;}
		public map<string,list<selectOption>> mapSelectOptions {get;set;}
		
		public Answer__c ObjAnswer							{get;set;}
		
		//Inner Class Constructor
		public QuestionAnswers(String strOppId, list<Product2> lstProductObject, String strProductGroupName, String strProductName, list<Question__c> lstQuest, map<String,list<Answer__c>> mapAnswers, map<String,String>mapOptions, map<string,list<selectOption>>mapSelectOptions) {
			
			//this.index = index;
			this.strProductGroupName = strProductGroupName;
			this.strProductName = strProductName;
			this.lstQuestobject = lstQuest;
			this.mapAnswers = mapAnswers;
			this.mapOptions = mapOptions;
			this.mapSelectOptions = mapSelectOptions;
			this.strOpportunityIdd = strOppId;
			this.lstProductObject = lstProductObject;
		}
	}
	//Main Class Constructor
	public PIP_QA_on_OpportunityController (ApexPages.StandardController sc) {
		
	 	strOpportunityIdd = ApexPages.currentPage().getParameters().get('Idd');
	 	fetchClientQuestionsAnsAnswers();
	}
	
	public void fetchClientQuestionsAnsAnswers() {
		
		try {
			
		String ProductGroupId;
		String QuestionId;
		set<Id> setProductId = new set<Id>();
		
		//lstQuestobject = new list<Question__c>();
		lstAnswers = new list<Answer__c>();
		lstQuestionAnswers = new list<QuestionAnswers>();
		list<Product2> lstProductObject = new list<Product2>();
		
		mapPGid_Prod = new map<Id,list<Product2>>();
		//mapAnswers = new map<String,Answer__c>();
		mapAnswers = new map<String,list<Answer__c>>();
		mapSelectOptions  = new map<string,list<selectOption>>();
        mapOptions = new map<string,string >();
		map<Id,list<Question__c>> mapPGid_LstofQues = new map<Id,list<Question__c>>();
		
		for(OpportunityLineItem objOLI : [	SELECT Product2Id, OpportunityId
											FROM OpportunityLineItem 
											WHERE OpportunityId =: strOpportunityIdd]) {
										
			setProductId.add(objOLI.Product2Id);
			system.debug('=====setProductId0====='+setProductId);				
		}
		
		for(Opportunity objOpp : [	SELECT Id, Total_Answered_Fields__c, Total_UnAnswered_Fields__c
									FROM Opportunity
									WHERE Id =: strOpportunityIdd]) {
											
			TotalUnAnsweredField = objOpp.Total_UnAnswered_Fields__c;
			TotalAnsweredField = objOpp.Total_Answered_Fields__c; 
			TotalAnswer = TotalUnAnsweredField + TotalAnsweredField;								
		}
							
		for(Product_Group__c objPG : [	SELECT Id, Name, 
											(	SELECT Id, Name, Product_Group__c 
												FROM Products__r
												WHERE Id =: setProductId)
										FROM Product_Group__c
									]) {
			
			ProductGroupId = objPG.Id;							
			lstProductObject = objPG.Products__r;
			system.debug('=====lstProductObject====='+lstProductObject);	
			
			//mapPGid_Prod.put(ProductGroupId, lstProductObject);
			for(Question__c objQuestions : [SELECT Id, Name, QuestionText__c, Question_Type__c, Question_Picklist_Options__c, Product_Group__c,
												(SELECT Id, Answer_TextType__c, Product__r.Id, Product__c, Opportunity__r.Id, Opportunity__c
													FROM Answer__r
													WHERE Opportunity__c =: strOpportunityIdd
													AND Product__c =: setProductId) 
											FROM Question__c
											WHERE Product_Group__c =: ProductGroupId
											]) {
					
					/*Get list of questions respective to Product group*/	
					list<Question__c> lstQuest_temp = new list<Question__c>();
					QuestionId = objQuestions.Id;
					
					if(mapPGid_LstofQues.containsKey(ProductGroupId)) {
						
						lstQuest_temp = mapPGid_LstofQues.get(ProductGroupId);
					}	
										
					lstQuest_temp.add(objQuestions);
					mapPGid_LstofQues.put(ProductGroupId, lstQuest_temp);
					system.debug('===mapPGid_LstofQues===='+mapPGid_LstofQues);
					    
					    /*Get Picklist values*/
	                  	lstSelectOptions = new list<selectOption>();
	                  	list<string> lstPicklistOptions = new list<string>();
	                  	
	                  	if(objQuestions.Question_Picklist_Options__c != null) {
	                  		
	                  		system.debug('===COMES inside====');
	                      	lstPicklistOptions = objQuestions.Question_Picklist_Options__c.split(',');
	                      	system.debug('===COMES lstPicklistOptions===='+lstPicklistOptions);
	                      	for(string str : lstPicklistOptions ) {
	                      		
	                          	lstSelectOptions.add(new SelectOption(str ,str ));
	                          	system.debug('===lstSelectOptions===='+lstSelectOptions);
	                      	} 
	                  	}
	                  	mapSelectOptions.put(objQuestions.id, lstSelectOptions );
	                  	mapOptions.put(objQuestions.id, '' );
						
						/*Get Answers for the respective questions*/
						for(Product2 objprod : lstProductObject) {
							
							String ProductId = objprod.Id;
							
							list<Answer__c> lstAnswers_temp = new list<Answer__c>();
						
							if(objQuestions.Answer__r.size() <= 0) {
								
								system.debug('=====Answer__r====='+objQuestions.Answer__r);					
								objAnswer = new Answer__c();
		                      	objAnswer.Question__c = objQuestions.id; 
		                      	objAnswer.opportunity__c = strOpportunityIdd;
		                      	objAnswer.Product__c = ProductId;

		                      	if(mapAnswers.containsKey(objQuestions.id)) {
		                      		
		                      		lstAnswers_temp = mapAnswers.get(objQuestions.id);
		                      	}
		                      	
		                      	lstAnswers_temp.add(objAnswer);
		                      	//mapAnswers.put(objQuestions.id,objAnswer);
		                      	mapAnswers.put(objQuestions.id,lstAnswers_temp);
		                      	system.debug('=====objAnswer====='+objAnswer);
		                      	//system.debug('=====mapAnswers1====='+mapAnswers);
		                      	//lstAnswers.add(objAnswer); 
		                      	system.debug('=====lstAnswers====='+lstAnswers);      
		                  	}
		                  	else {
		                  		
		                      	mapAnswers.put(objQuestions.id,objQuestions.Answer__r);
		                      	system.debug('=====mapAnswers2====='+mapAnswers);
		                  	}
	                  }					
				}
				
				for(Product2 objProdId : lstProductObject) {
					
					system.debug('=====mapAnswers1====='+mapAnswers);
					system.debug('=====lstProductObject1====='+lstProductObject);
					system.debug('=====strOpportunityIdd2====='+strOpportunityIdd);
					
					lstQuestionAnswers.add(new QuestionAnswers(strOpportunityIdd, lstProductObject, objPG.Name, objProdId.Name, mapPGid_LstofQues.get(ProductGroupId), mapAnswers, mapOptions, mapSelectOptions));
				}
				
			}
		}
		catch(Exception e) {
			
			system.debug('====Exception ===='+e);
		}
	}
	
	/*public void populateAnswers() {
		 
          list<Answer__c> lstAnsToPopulate =  new List<Answer__c>();
          //if(lstQuestionAnswers != null) { 
          	
          	for(QuestionAnswers obj :lstQuestionAnswers) {
          		
          	   	//lstAnsToPopulate =  new List<Answer__c>();
              	for(Question__c objQues: obj.lstQuestobject) {
              	   
                  	if(objQues.Answer__r.size() <= 0)
                  	lstAnsToPopulate.add(obj.mapAnswers.get(objQues.id)); 
                  	system.debug('=====lstAnsToPopulate====='+lstAnsToPopulate);
              	}
          	}
           if(lstAnsToPopulate.size()>0)
           insert lstAnsToPopulate;
         // }
	}*/
	
	public void Submit() {
		
		try { 
			
			system.debug('=====comes inside submit=====');
			list<Answer__c> lstAnsToBeUpdated =  new List<Answer__c>();
			list<String> lstRetriveAnswers = new List<String>();
	        for(QuestionAnswers obj : lstQuestionAnswers) {
	        		
	        	system.debug('=====obj====='+obj);
	        	system.debug('=====obj.lstProductObject====='+obj.lstProductObject);
	        	for(Product2 objProd2 : obj.lstProductObject) {
	          	  		
	          		system.debug('=====obj.lstQuestobject====='+obj.lstQuestobject);
		        	for(Question__c objQues: obj.lstQuestobject) {
		              		
			            //lstRetriveAnswers.add(obj.mapOptions.get(objQues.id));
			            system.debug('=====lstRetriveAnswers====='+lstRetriveAnswers);
			            if(objQues.Question_Type__c == 'picklist') {
		                		
			                obj.mapAnswers.get(objQues.id)[0].Answer_TextType__c = obj.mapOptions.get(objQues.id);
			                system.debug('=====obj.mapOptions.get(objQues.id)====='+obj.mapOptions.get(objQues.id));	
		                }
		            	system.debug('=====obj.mapOptions.get(objQues.id)====='+obj.mapOptions.get(objQues.id));
		                system.debug('=====objQues.id====='+objQues.id);
		                //lstAnsToBeUpdated.add(obj.mapAnswers.get(objQues.Id)); 
		                lstAnsToBeUpdated.add(obj.mapAnswers.get(objQues.Id)[0]);
		                system.debug('=====lstAnsToBeUpdated====='+lstAnsToBeUpdated);
					}
	    		}		
	    	}
	       	upsert lstAnsToBeUpdated;
		}
		catch (Exception e) {
			
			system.debug('====Exception==='+e);
		}
	}
}