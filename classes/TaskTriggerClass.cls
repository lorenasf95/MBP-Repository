public class TaskTriggerClass  {

	/**
	* @description 

	* @param lNew 
	*/ 
	public static void enviarTareaPorCorreo(List<Task>lNew){
		System.debug('### Entramos en enviarTareaPorCorreo');

		String prefixContacto = Schema.SObjectType.Contact.getKeyPrefix();

		//Por cada tareas almacenamos las IdAccount.
		Set<Id>sIdContacts = new Set<Id>();
		for(Task t: lNew){
			//Si el WhoId es de un Contacto, lo agrego.
			if(t.WhoId != null && String.valueOf(t.WhoId).startsWith(prefixContacto)){
				sIdContacts.add(t.WhoId);
			}
		}

		//Filtramos los leads cuyas accounts estén incluidas en el set de id de las tareas.
		List<Lead>lLeads = [SELECT Id,Provincia__c, Owner.Name, Owner.Phone FROM Lead WHERE ConvertedContactId in: sIdContacts AND IsConverted = true];
		
		if(lLeads.isEmpty()){return;}

		//Almacenamos las provincias.
		Set<String> sProvincias = new Set<String>();
		for(Lead l: lLeads){
			sProvincias.add(l.Provincia__c);
		}

		//Construimos un mapa para saber qué leads requieren de enviar un email según la provincia.
		List<ConfiguracionGeneral__mdt> lConfig = [SELECT Id, Sede__c,EnviarEmail__c FROM ConfiguracionGeneral__mdt WHERE Sede__c in: sProvincias];
		Map<String,Boolean> mSedeEnviarEmail = new Map<String,Boolean>();
		for(ConfiguracionGeneral__mdt c: lConfig){
			mSedeEnviarEmail.put(c.Sede__c,c.EnviarEmail__c);
		}

		if(mSedeEnviarEmail.isEmpty()){ return; }  

		//Creamos una lista y almacenamos los leads a los que hay que enviar correo.
		Utilidades.WrDatosCorreo datosCorreo = new Utilidades.WrDatosCorreo();
		List<Lead> lLeadsEnviarCorreo = new List<Lead>();
		List<String> lCuerposCorreo = new List<String>();
		for(Lead candidato : lLeads){
			if(candidato.Provincia__c != null && mSedeEnviarEmail.get(candidato.Provincia__c) == true){
				String body = 'Su caso está siendo tratado por '+candidato.Owner.Name+', si tiene alguna duda puede contactarle en el siguiente número: '+candidato.Owner.Phone+'.';
				lLeadsEnviarCorreo.add(candidato);
				lCuerposCorreo.add(body);
			}
		}

		if(lLeadsEnviarCorreo.isEmpty()){return;}
		if(lCuerposCorreo.isEmpty()){return;}
		
		datosCorreo.lCandidatos = lLeadsEnviarCorreo;
		datosCorreo.lBodies = lCuerposCorreo;
		datosCorreo.Subject = 'Su caso se encuentra en proceso';

		try{
			Utilidades.enviarEmail(datosCorreo);
		}catch(Exception exc){
			return;
		}
	}
}