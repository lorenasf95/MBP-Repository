trigger OpportunityTrigger on Opportunity (after update)  {

	if(Trigger.isAfter){
		if(Trigger.isUpdate){
			OpportunityTriggerClass.crearFactura(Trigger.new,Trigger.old);
		}

	}




}