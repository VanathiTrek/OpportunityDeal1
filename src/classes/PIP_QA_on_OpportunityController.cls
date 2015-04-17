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
	 	system.debug('=====strOpportunityIdd======'+strOpportunityIdd);
	}
	
	public void fetchClientQuestionsAnsAnswers() {
		
		system.debug('=====comes inside fetchClientQuestionsAnsAnswers======');
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
		//set<String> setPGName = new set<String>();
		//set<Id> setpgId = new set<Id>();
		
		list<Product2> lstProductObject = new list<Product2>();
		//list<String> lstQuest = new list<String>();
		lstQuestobject = new list<Question__c>();
		lstAnswerObject = new list<Answer__c>();
		lstQuestionAnswers = new List<QuestionAnswers>();
		
		map<Id,String> mapProductId_Products = new map<Id,String>();
		map<Id,String> mapOppId_OppName = new map<Id,String>();
		map<Id,String> mapPGid_PGname = new map<Id,String>();
		map<Id,String> mapProdId_PGname = new map<Id,String>();
		//map<Id,list<Question__c>> mapPGid_LstofQues = new map<Id,list<Question__c>>();
		map<Id,Question__c> mapPGid_LstofQues = new map<Id,Question__c>();
		map<Id,list<Product2>> mapPGid_LstofProd = new map<Id,list<Product2>>();
		map<String,QuestionAnswers> mapQAtoOLI = new map<String,QuestionAnswers>();
		map<set<Id>, Answer__c> mapAnswers = new map<set<Id>, Answer__c>();
		map<Id,Question__c> mapQuesId_QuesObj = new map<Id,Question__c>();
				
		for(Product_Group__c objPG : [	SELECT Id, Name, 
												(SELECT Id, Name, QuestionText__c, Question_Type__c, Question_Picklist_Options__c, Product_Group__c 
													FROM Questions__r),
												(SELECT Id, Name, Product_Group__c FROM Products__r)
										FROM Product_Group__c
										//WHERE Id IN : mapPGid_PGname.keyset()
									]) {
										
			system.debug('=====objPG====='+objPG);
			ProductGroupId = objPG.Id;
			lstQuestobject = objPG.Questions__r;
			system.debug('=====lstQuestobject====='+lstQuestobject);
			for(Question__c objQuestions : lstQuestobject) {
				
				system.debug('=====objQuestions====='+objQuestions);
				setQuestionId.add(objQuestions.Id);
				String Id = objQuestions.Id;
				String Name = objQuestions.Name;
				String QuestionText = objQuestions.QuestionText__c;
				String Question_Type = objQuestions.Question_Type__c;
				String Question_Picklist_Options = objQuestions.Question_Picklist_Options__c;
				mapQuesId_QuesObj.put(Id, objQuestions);
				system.debug('=====mapQuesId_QuesObj====='+mapQuesId_QuesObj);
			}
			//lstQuest.add(Question);
			
			lstProductObject = objPG.Products__r;
			for (Product2 objProdId : lstProductObject) {
				
				setProductId.add(objProdId.Id);
			}
			system.debug('=====lstProductObject====='+lstProductObject);
	
			/*if(mapPGid_LstofQues.containsKey(ProductGroupId)) {
				
				system.debug('=====containsKey=====');
				//mapPGid_LstofQues.get(ProductGroupId).add(lstQuestobject);
				system.debug('=====mapPGid_LstofQues12====='+mapPGid_LstofQues);	
			}
			else {*/
				//mapPGid_LstofQues.put(ProductGroupId, new list<Question__c>(lstQuestobject));
				mapPGid_LstofQues.put(ProductGroupId, mapQuesId_QuesObj.values());
				system.debug('=====mapPGid_LstofQues====='+mapPGid_LstofQues.values());	
				//mapPGid_LstofProd.put(ProductGroupId,lstProductObject);
				system.debug('=====mapPGid_LstofProd====='+mapPGid_LstofProd);		
			//}
							
		}
		system.debug('=====mapPGid_LstofQues====='+mapPGid_LstofQues);
		system.debug('=====mapPGid_LstofQues====='+mapPGid_LstofQues.values());
		system.debug('=====lstQuestobject====='+lstQuestobject);
		
		for(Answer__c objAnswer : [	SELECT Id, Question__r.Question_Picklist_Options__c, Question__r.Question_Type__c, Question__r.QuestionText__c, Question__r.Product_Group__c, Question__r.Id, Question__c,
									Product__r.Product_Group__c, Product__r.Name, Product__r.Id, Product__c,
									Opportunity__r.Id, Opportunity__c, Answer_TextType__c
									FROM Answer__c
									WHERE Opportunity__r.Id =: strOpportunityIdd
									AND Product__r.Id =: setProductId
									AND Question__r.Id =: setQuestionId
									]) {
										
			system.debug('=====objAnswer====='+objAnswer);
			
			//lstAnswerObject.add(objAnswer);
			mapAnswers.put(setQuestionId,objAnswer);
			system.debug('=====mapAnswers====='+mapAnswers);	
			
			system.debug('=====lstAnswerObject====='+lstAnswerObject);					
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
			system.debug('=====mapProductId_Products====='+mapProductId_Products);
			mapOppId_OppName.put(OppId, OppName);
			system.debug('=====mapOppId_OppName====='+mapOppId_OppName);
			system.debug('=====mapOppId_OppName====='+mapPGid_LstofQues.get(ProductGroupId));
			
			mapQAtoOLI.put(OLIname, new QuestionAnswers(String.valueOf(mapOppId_OppName.get(OppId)+' - '+mapProductId_Products.get(ProdId)), mapPGid_LstofQues.values(), mapAnswers.values()));
			system.debug('=====1====='+String.valueOf(mapOppId_OppName.get(OppId)+' - '+mapProductId_Products.get(ProdId)));			
		}
		
        for(QuestionAnswers objWrapper : mapQAtoOLI.values()) {
        	
        	lstQuestionAnswers.add(objWrapper);
        	//index++;
        	//objWrapper.index = index;
        } 
		
		//lstQuestionAnswers.add(new QuestionAnswers(String.valueOf(mapOppId_OppName.get(objOLI.OpportunityId))));
		//lstQuestionAnswers.add(new QuestionAnswers( String.valueOf(mapOppId_OppName.get(objOLI.OpportunityId)+' - '+mapProductId_Products.get(objOLI.Product2Id)), '', '' ));
	}
}