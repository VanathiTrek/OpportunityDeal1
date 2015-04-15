/**
	* Name: PIP_QA_on_OpportunityController
    * Author: Vanathi.V
    * Reviewer: Vishnu
    * Description: 
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
		system.debug('=====strOpportunityIdd======'+strOpportunityIdd);
	}
	
	public void fetchClientQuestionsAnsAnswers() {
		
		system.debug('=====comes inside fetchClientQuestionsAnsAnswers======');
	}
}