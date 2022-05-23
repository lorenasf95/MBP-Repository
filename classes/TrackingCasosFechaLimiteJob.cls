public class TrackingCasosFechaLimiteJob implements Schedulable {
    
	public void execute(SchedulableContext ctx) {
		//Buscamos los casos cuya fecha limite este superada.
		Datetime now = Datetime.now();
		List<Case> lCasesFechaSuperada = [Select Id From Case Where TiempoLimite__c < :now];
		System.debug('### lCase --> ' + JSON.serialize(lCasesFechaSuperada));
		if(lCasesFechaSuperada.isEmpty()){return;}

		for(Case c : lCasesFechaSuperada){
			c.Status = 'Desatendido';
		}

		try{
			update lCasesFechaSuperada;	
		}catch(Exception exc){
			System.debug('Ha dado el siguiente error ---> ' +  exc.getMessage());
		}
    }
}
