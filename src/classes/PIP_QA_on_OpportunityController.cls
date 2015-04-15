/**
	* Name: PIP_QA_on_OpportunityController
    * Author: Vanathi.V
    * Reviewer: Vishnu
    * Description: PIP_QA_on_OpportunityController is to take a note of Questions and Answers to close a deal. 
    			   This contains the conversation between rep and Client in the form of Questions and Answers.
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
	 	
	 	strOpportunityIdd = ApexPages.currentPage().getParameters().get('Idd');
	}
	
	public void fetchClientQuestionsAnsAnswers() {
		
		for(Opportunity objOpp : [	SELECT Id,(SELECT Id, Product2Id FROM OpportunityLineItems) 
									FROM Opportunity
									WHERE Id =: strOpportunityIdd
								]) {									
		}
	}
}