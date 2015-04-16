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
	
	public List<QuestionAnswers> lstQuestionAnswers {get;set;}
	
	//Inner Class
	public class QuestionAnswers {
		
		public Integer index			{get;set;}
		public String strOppProductName {get;set;} 
		public String strQuestions		{get;set;}
		public String strAnswers		{get;set;}
		
		//Inner Class Constructor
		public QuestionAnswers(Integer index, String strOppProductName, String strQuestions, String strAnswers) {
			
			this.index = index;
			this.strOppProductName = strOppProductName;
			this.strQuestions = strQuestions;
			this.strAnswers = strAnswers;
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
		
		set<Id> setProductId = new set<Id>();
		
		list<Product2> lstProd2 = new list<Product2>();
		lstQuestionAnswers = new List<QuestionAnswers>();
		
		map<Id,String> mapProductId_Products = new map<Id,String>();
		map<Id,String> mapOppId_OppName = new map<Id,String>();
		map<Id,String> mapPGid_PGname = new map<Id,String>();
		map<Id,String> mapProdId_PGname = new map<Id,String>();
		map<Id,list<Question__c>> mapPGid_LstofQues = new map<Id,list<Question__c>>();
		map<String,QuestionAnswers> mapQAtoOLI = new map<String,QuestionAnswers>();
		
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
		}
		
		for(AggregateResult objProd2 : [	SELECT count(Id) countId, Product_Group__c, Product_Group__r.Id PGid, Product_Group__r.Name PGname
											FROM Product2 
											WHERE Id IN : setProductId
											GROUP BY Product_Group__c, Product_Group__r.Id, Product_Group__r.Name
										]) {
									
			system.debug('=====objProd2====='+objProd2);
			String ProductName_Temp = String.valueOf(String.valueOf(objProd2.get('PGname')));
			String PgID_Temp = String.valueOf(String.valueOf(objProd2.get('PGid')));
			
			mapPGid_PGname.put(PgID_Temp,ProductName_Temp);
			mapProdId_PGname.put(objProd2.Id,ProductName_Temp);				
		}
		
		for(Product_Group__c objPG : [	SELECT Id, Name, (SELECT Id, Name, Question__c, Question_Type__c FROM Questions__r)
										FROM Product_Group__c
										WHERE Id IN : mapPGid_PGname.keyset()
										]) {
											
			list<Question__c> lstQuest = new list<Question__c>();
			lstQuest = objPG.Questions__r;
			mapPGid_LstofQues.put(objPG.Id,lstQuest);
			system.debug('=====mapPGid_LstofQues====='+mapPGid_LstofQues);							
		}
		
		mapQAtoOLI.put(OLIname, new QuestionAnswers(0, String.valueOf(mapOppId_OppName.get(OppId)+' - '+mapProductId_Products.get(ProdId)), '', ''));
		system.debug('=====1====='+String.valueOf(mapOppId_OppName.get(OppId)+' - '+mapProductId_Products.get(ProdId)));	
		
        for(QuestionAnswers objWrapper : mapQAtoOLI.values()) {
        	
        	lstQuestionAnswers.add(objWrapper);
        }  	
	}
}