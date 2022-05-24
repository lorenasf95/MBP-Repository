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

	//FUNCIÓN PARA VERIFICAR QUE SE HAN AGREGADO OPORTUNIDADES ANTES DE CERRAR LA TAREA.
	public static void verificarOportunidades (List<Task> lNew, List<Task> lOld){
		//Creamos una lista para almacenar las tareas cuyo estado haya cambiado a 'Completed'
		List<Task> lTaskToProcess = new List<Task>();
		for(Integer i=0; i<lNew.size();i++){
			if(lNew[i].Status != lOld[i].Status && lNew[i].Status == 'Completed'){
				lTaskToProcess.add(lNew[i]);
			}
		}

		//Comporbamos si está vacía.
		if(lTaskToProcess.isEmpty()){return;}

		//Guardamos cada id de oportunidad incluida en lTaskToProcess en un set para filtrar la query.
		Set<String> sOportunidadesIds = new Set<String>();
		for(Task tarea : lTaskToProcess){
			if(tarea.WhatId != null){
				sOportunidadesIds.add(tarea.WhatId);
			}
		}

		//Buscamos las oportunidades inlcuidas en el set.
		List<Opportunity> lOportunidades = [SELECT Id, HasOpportunityLineItem, (SELECT Quantity FROM OpportunityLineItems) FROM Opportunity WHERE Id in: sOportunidadesIds];
		
		if(lOportunidades.isEmpty()){return;}

		//Creamos una lista de id de oportunidades que no cumplen con los requisitos.
		List<String> lIdsOportunidadesSinProductos = new List<String>();

		//Por cada oportunidad relacionada con las tareas verificamos si cumple los requisitos.
		for(Opportunity oportunidad: lOportunidades){
			//Si no tiene un producto de oportunidad no dejaremos cambiar el estado de la tarea a completado y lo almacenaremos en la lista que no cumple los requisitos.
			if(oportunidad.HasOpportunityLineItem == false){
				lIdsOportunidadesSinProductos.add(oportunidad.Id);
				continue;
			}

			//Si tiene creado un producto de oportunidad pero su cantidad está a 0 también lo incluiremos en el listado que no cumple los requisitos.
			Decimal cantidad = 0;
			for(OpportunityLineItem oli : oportunidad.OpportunityLineItems){
				cantidad += oli.Quantity == null ? 0 : oli.Quantity;
			}

			if(cantidad == 0){
				lIdsOportunidadesSinProductos.add(oportunidad.Id);
			}
		}

		if(lIdsOportunidadesSinProductos.isEmpty()){return;}

		//Por cada tarea que hay que procesar, si está incluida en el listado de oportunidades sin productos lanzaremos un error, dado que no existen productos de oportunidad.
		for(Task tarea :lTaskToProcess){
			if(lIdsOportunidadesSinProductos.contains(tarea.WhatId)){
				tarea.addError(System.Label.ErrorNoTieneProdOportunidadCreado);
			}
		}
	}
}