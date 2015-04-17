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
	
	public List<QuestionAnswers> lstQuestionAnswers {get;set;}
	public List<Question__c> lstQuestobject			{get;set;}
	public list<Answer__c> lstAnswerObject 			{get;set;}
	
	//Inner Class
	public class QuestionAnswers {
		
		public Integer index					{get;set;}
		public String strOppProductName 		{get;set;} 
		//public String strQuestions			{get;set;}
		public list<Question__c> lstQuestobject	{get;set;}
		public list<Answer__c> lstAnswerObject 	{get;set;}
		public String strAnswers				{get;set;}
		
		//Inner Class Constructor
		public QuestionAnswers(String strOppProductName, list<Question__c> lstQuest, list<Answer__c> lstAnswerObject) {
			
			//this.index = index;
			this.strOppProductName = strOppProductName;
			this.lstQuestobject = lstQuest;
			this.lstAnswerObject = lstAnswerObject;
		}
	}
	//Main Class Constructor
	public PIP_QA_on_OpportunityController (ApexPages.StandardController sc) {
		
		Integer index = 0;
		String OLIname = '';
	 	
	 	strOpportunityIdd = ApexPages.currentPage().getParameters().get('Idd');
	}
	
	public void fetchClientQuestionsAnsAnswers() {
		
		String ProductName;
		String OpportunityName;
		String OLIname;
		String ProdName;	
		String OppName;
		String ProdId;
		String OppId;
		String ProductGroupId;
		
		set<Id> setProductId = new set<Id>();
		set<Id> setQuestionId = new set<Id>();
		
		list<Product2> lstProductObject = new list<Product2>();
		//list<String> lstQuest = new list<String>();
		
		lstQuestobject = new list<Question__c>();
		lstAnswerObject = new list<Answer__c>();
		lstQuestionAnswers = new List<QuestionAnswers>();
		
		map<Id,String> mapProductId_Products = new map<Id,String>();
		map<Id,String> mapOppId_OppName = new map<Id,String>();
		map<Id,String> mapPGid_PGname = new map<Id,String>();
		map<Id,String> mapProdId_PGname = new map<Id,String>();
		map<Id,list<Question__c>> mapPGid_LstofQues = new map<Id,list<Question__c>>();
		//map<Id,Question__c> mapPGid_LstofQues = new map<Id,Question__c>();
		map<Id,list<Product2>> mapPGid_LstofProd = new map<Id,list<Product2>>();
		map<String,QuestionAnswers> mapQAtoOLI = new map<String,QuestionAnswers>();
		map<set<Id>, Answer__c> mapAnswers = new map<set<Id>, Answer__c>();
				
		for(Product_Group__c objPG : [	SELECT Id, Name, 
												(SELECT Id, Name, QuestionText__c, Question_Type__c, Question_Picklist_Options__c, Product_Group__c 
													FROM Questions__r),
												(SELECT Id, Name, Product_Group__c FROM Products__r)
										FROM Product_Group__c
									]) {
										
			ProductGroupId = objPG.Id;
			lstQuestobject = objPG.Questions__r;
			
			lstProductObject = objPG.Products__r;
			
			for (Product2 objProdId : lstProductObject) {
				
				setProductId.add(objProdId.Id);
			}
			
			for(Question__c objQuestions : lstQuestobject) {
				
				system.debug('=====objQuestions====='+objQuestions);
				setQuestionId.add(objQuestions.Id);
				if(mapPGid_LstofQues.containsKey(ProductGroupId)) {
					
					system.debug('=====containsKey=====');
					//mapPGid_LstofQues.get(ProductGroupId).add(lstQuestobject);
					system.debug('=====mapPGid_LstofQues12====='+mapPGid_LstofQues);	
				}
				else {
					mapPGid_LstofQues.put(ProductGroupId, new list<Question__c>(lstQuestobject));
					//mapPGid_LstofQues.get(ProductGroupId).add(lstQuestobject);
					system.debug('=====mapPGid_LstofQues====='+mapPGid_LstofQues.values());	
					//mapPGid_LstofProd.put(ProductGroupId,lstProductObject);
					system.debug('=====mapPGid_LstofProd====='+mapPGid_LstofProd);		
				}
			}				
		}
		
		list<list<Question__c>> lstlstquest = new list<list<Question__c>>();
		list<Question__c> lstquest123 = new list<Question__c>();
		lstlstquest = mapPGid_LstofQues.values();
		lstquest123 = lstlstquest[0];
								
		for(Answer__c objAnswer : [	SELECT Id, Question__r.Question_Picklist_Options__c, Question__r.Question_Type__c, Question__r.QuestionText__c, Question__r.Product_Group__c, Question__r.Id, Question__c,
									Product__r.Product_Group__c, Product__r.Name, Product__r.Id, Product__c,
									Opportunity__r.Id, Opportunity__c, Answer_TextType__c
									FROM Answer__c
									WHERE Opportunity__r.Id =: strOpportunityIdd
									AND Product__r.Id =: setProductId
									AND Question__r.Id =: setQuestionId
								]) {
										
			mapAnswers.put(setQuestionId,objAnswer);	
								
		} 
		
		for(OpportunityLineItem objOLI : [	SELECT Id, Name, Product2Id, Product2.Name, OpportunityId, Opportunity.Name
											FROM OpportunityLineItem
											WHERE OpportunityId =: strOpportunityIdd
							   			]) {
											
			ProdName = objOLI.Product2.Name;	
			OppName = objOLI.Opportunity.Name;
			ProdId = objOLI.Product2Id;
			OppId = objOLI.OpportunityId;
			
			OLIname = OppName +' - '+ProdName;	
			setProductId.add(ProdId);	
			mapProductId_Products.put(ProdId, ProdName);
			mapOppId_OppName.put(OppId, OppName);
			mapQAtoOLI.put(OLIname, new QuestionAnswers(String.valueOf(mapOppId_OppName.get(OppId)+' - '+mapProductId_Products.get(ProdId)), lstQuestobject, mapAnswers.values()));
		}
		
        for(QuestionAnswers objWrapper : mapQAtoOLI.values()) {
        	
        	lstQuestionAnswers.add(objWrapper);
        } 
	}
	
	public List<SelectOption> getPicklist() {
		
	  List<SelectOption> options = new List<SelectOption>();
	        
	  Schema.DescribeFieldResult fieldResult = Question__c.Question_Picklist_Options__c.getDescribe();
	  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	  for( Schema.PicklistEntry f : ple) {
	  	
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	      system.debug('=====options====='+options);
	  }       
	  return options;
	}
}