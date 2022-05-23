trigger LeadTrigger on Lead (before insert)  { 
	
	
	/****************/
	/*    BEFORE   */
	/****************/
	if(Trigger.isBefore){
		
		/****************/
		/*    INSERT    */
		/****************/
		if(Trigger.isInsert){
			LeadTriggerClass.asignarUsuario(Trigger.new);
		}

		if(Trigger.isUpdate){
			LeadTriggerClass.noConvertirLeadsRechazados(Trigger.new,Trigger.old);
		}
	}
	 
}