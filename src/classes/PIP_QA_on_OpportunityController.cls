/**
	* Name: PIP_QA_on_OpportunityController
    * Author: Vanathi.V
    * Reviewer: Vishnu
    * Description: PIP_QA_on_OpportunityController is to take a note of Questions and Answers to close a deal. 
    			   This contains the conversation between rep and Client
**/
public with sharing class PIP_QA_on_OpportunityController {
	
	public String strOpportunityIdd 	{get;set;}
	public String Idd					{get;set;}
	private Integer index;
	public Integer TotalQuestioncount	{get;set;}
	public Integer TotalAnswersCount	{get;set;}
	
	public List<QuestionAnswers> lstQuestionAnswers 	{get;set;}
	public list<selectOption> lstSelectOptions 			{get;set;}
	//public List<Question__c> lstQuestobject			{get;set;}
	//public list<Answer__c> lstAnswerObject 			{get;set;}
	public map<String,Answer__c> mapAnswers				{get;set;}
	public map<string,list<selectOption>> mapSelectOptions {get;set;}
	public map<string,string> mapOptions 				{get;set;}
	public list<Answer__c> lstAnswers 					{get;set;}
	public Answer__c objAnswer							{get;set;}
	public list<Product2> lstProductObject;
	
	//Inner Class
	public class QuestionAnswers {
		
		public Integer index					{get;set;}
		public String strProductGroupName		{get;set;} 
		public String strProductName 			{get;set;} 
		public list<Question__c> lstQuestobject	{get;set;}
		public Answer__c ObjAnswer				{get;set;}
		public map<string,string> mapOptions 	{get;set;}
		public map<String,Answer__c> mapAnswers	{get;set;}
		public map<string,list<selectOption>> mapSelectOptions {get;set;}
		public String strOpportunityIdd 	{get;set;}
		public list<Product2> lstProductObject;
		
		//Inner Class Constructor
		public QuestionAnswers(String strOppId, list<Product2> lstProductObject, String strProductGroupName, String strProductName, list<Question__c> lstQuest, map<String,Answer__c> mapAnswers, map<String,String>mapOptions, map<string,list<selectOption>>mapSelectOptions) {
			
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
		
		Integer index = TotalQuestioncount = 0;
		//String OLIname = '';
		Integer TotalAnswersCount = 1;
	 	
	 	strOpportunityIdd = ApexPages.currentPage().getParameters().get('Idd');
	}
	
	public void fetchClientQuestionsAnsAnswers() {
		
		try {
			
		String ProductGroupId;
		String QuestionId;
		set<Id> setProductId = new set<Id>();
		
		//lstQuestobject = new list<Question__c>();
		lstAnswers = new list<Answer__c>();
		lstQuestionAnswers = new List<QuestionAnswers>();
		list<Product2> lstProductObject = new list<Product2>();
		
		mapAnswers = new map<String,Answer__c>();
		mapSelectOptions  = new map<string,list<selectOption>>();
        mapOptions = new map<string,string >();
		map<Id,list<Question__c>> mapPGid_LstofQues = new map<Id,list<Question__c>>();
		
		for(OpportunityLineItem objOLI : [	SELECT Product2Id, OpportunityId 
											FROM OpportunityLineItem 
											WHERE OpportunityId =: strOpportunityIdd]) {
										
			setProductId.add(objOLI.Product2Id);
			system.debug('=====setProductId0====='+setProductId);				
		}
								
		for(Product_Group__c objPG : [	SELECT Id, Name, 
											(SELECT Id, Name, Product_Group__c 
											FROM Products__r
											WHERE Id =: setProductId)
										FROM Product_Group__c
									]) {
			
			ProductGroupId = objPG.Id;							
			lstProductObject = objPG.Products__r;
			system.debug('=====lstProductObject====='+lstProductObject);	
			
			for(Question__c objQuestions : [SELECT Id, Name, QuestionText__c, Question_Type__c, Question_Picklist_Options__c, Product_Group__c,
												(SELECT Id, Answer_TextType__c, Product__r.Id, Product__c, Opportunity__r.Id, Opportunity__c
													FROM Answer__r
													WHERE Opportunity__c =: strOpportunityIdd
													AND Product__c =: setProductId) 
											FROM Question__c
											WHERE Product_Group__c =: ProductGroupId
											]) {
					
					system.debug('=====strOpportunityIdd====='+strOpportunityIdd);
					system.debug('=====objQuestions====='+objQuestions);	
					list<Question__c> lstQuest_temp = new list<Question__c>();
					QuestionId = objQuestions.Id;
					
					if(mapPGid_LstofQues.containsKey(ProductGroupId)) {
						
						lstQuest_temp = mapPGid_LstofQues.get(ProductGroupId);
					}	
										
					lstQuest_temp.add(objQuestions);
					//TotalQuestioncount = lstQuest_temp.size();
					//system.debug('=====TotalQuestioncount====='+TotalQuestioncount);	
					mapPGid_LstofQues.put(ProductGroupId, lstQuest_temp);
					//TotalQuestioncount = (mapPGid_LstofQues.values()).size();
					//system.debug('=====TotalQuestioncount====='+TotalQuestioncount);	
					    
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
						
						if(objQuestions.Answer__r.size() <= 0) {
						
							objAnswer = new Answer__c();
	                      	objAnswer.Question__c = objQuestions.id; 
	                      	objAnswer.opportunity__c = strOpportunityIdd;
	                      	//objAnswer.Product__c = objProduct.Id;
	                      	mapAnswers.put(objQuestions.id,objAnswer);
	                      	lstAnswers.add(objAnswer);        
	                  	}
	                  	else {
	                  		
	                      	mapAnswers.put(objQuestions.id,objQuestions.Answer__r[0]);
	                      	//TotalAnswersCount ++;
	                  	}							
				}
				
				for(Product2 objProdId : lstProductObject) {
					
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
	
	
	public void populateAnswers() {
		 
          list<Answer__c> lstAnsToPopulate =  new List<Answer__c>();
          //if(lstQuestionAnswers != null) { 
          	
          	for(QuestionAnswers obj :lstQuestionAnswers) {
          		
          	   	lstAnsToPopulate =  new List<Answer__c>();
              	for(Question__c objQues: obj.lstQuestobject) {
              	   
                  	if(objQues.Answer__r.size() <= 0)
                  	lstAnsToPopulate.add(obj.mapAnswers.get(objQues.id)); 
                  	system.debug('=====lstAnsToPopulate====='+lstAnsToPopulate);
              	}
          	}
           if(lstAnsToPopulate.size()>0)
           insert lstAnsToPopulate;
         // }
	}
	
	public void Submit() {
		
		try { 
			
				system.debug('=====comes inside submit=====');
				list<Answer__c> lstAnsToBeUpdated =  new List<Answer__c>();
	
	        	for(QuestionAnswers obj : lstQuestionAnswers) {
	        	
	          	  	system.debug('=====1for=====');
	          	  	//for(Product2 objProd2 : obj.lstProductObject) {
	          	  	
	          	  		//system.debug('=====2for=====');
		              	for(Question__c objQues: obj.lstQuestobject) {
		              		
		              		system.debug('=====3for=====');
		                  	if(objQues.Question_Type__c == 'picklist') {
		                
		                  		obj.mapAnswers.get(objQues.id).Answer_TextType__c = obj.mapOptions.get(objQues.id);
		                      	system.debug('=====obj.mapOptions.get(objQues.id)====='+obj.mapOptions.get(objQues.id));	
		                  	}
		                  	lstAnsToBeUpdated.add(obj.mapAnswers.get(objQues.Id)); 
		                  	system.debug('=====lstAnsToBeUpdated====='+lstAnsToBeUpdated);
		              	}
	          	 	//}		
	       		}
	          //upsert lstAnsToBeUpdated;
		}
		catch (Exception e) {
			
			system.debug('====Exception==='+e);
		}
	}
}