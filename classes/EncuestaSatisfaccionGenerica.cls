public class EncuestaSatisfaccionGenerica  {
	
	/*
	*
	*
	*/
	@AuraEnabled
	public static WrapperRespuestaEncuesta initLWCMetadata (String recordId){

		//Inicializamos la respuesta.
		WrapperRespuestaEncuesta respuesta = new WrapperRespuestaEncuesta();

		//Sacamos los 3 primeros digitos del registro para sacar que tipo de objeto es
		String myIdPrefix = String.valueOf(recordId).substring(0,3); //00Q
		String nombreObjeto = Utilidades.obtenerObjectNameFromRecordId(myIdPrefix); // Lead

		//Hacemos una query dinámica para obtener el RecordTypeId
		String queryRT = 'SELECT Id,RecordTypeId FROM ' + nombreObjeto + ' WHERE Id = \''+recordId+'\'';
		
		//Lanzamos la query.
		List<SObject> lObj =  Database.query(queryRT);

		//Cogemos el primer elemento de la query (Solo habrá 1 pues estamos filtrando por ID).
		SObject obj = lObj[0];

		//Sacamos el campo RecordTypeId y hacemos query para obtener su DeveloperName
		String idRT = String.valueOf(obj.get('RecordTypeId'));
		RecordType RT = [Select DeveloperName FROM RecordType Where Id =:idRT LIMIT 1];

		//Obtenemos el NOMBRE del tipo de registro.
		String devNameRT = RT.DeveloperName;

		List<ConfigEncuestasSatisfaccion__mdt> lConfig = [Select Id,Cabecera__c,ListadoPreguntas__c FROM ConfigEncuestasSatisfaccion__mdt WHERE RecTypeDevName__c =:devNameRT AND ObjectType__c =:nombreObjeto ];

		if(lConfig.isEmpty()){
			respuesta.success = false;
			respuesta.mensaje = 'Ha ocurrido un error de configuración';
			return respuesta;
		}	

		Map<String,String> mStepPregunta = new Map<String,String>();
		List<WrapperProgressIndicator> lItemProgreso = new List<WrapperProgressIndicator>();
		WrapperProgressIndicator itemProgreso;
		for(Integer i = 0; i < lConfig[0].ListadoPreguntas__c.split(';').size();i++){
			itemProgreso = new WrapperProgressIndicator();
			itemProgreso.value = String.valueOf(i+1);
			itemProgreso.label = 'Pregunta ' + itemProgreso.value;
			lItemProgreso.add(itemProgreso);

			mStepPregunta.put(String.valueOf(i+1),lConfig[0].ListadoPreguntas__c.split(';')[i]);
		}



		respuesta.success = true;
		respuesta.cabecera = lConfig[0].Cabecera__c;
		respuesta.lPreguntas = lConfig[0].ListadoPreguntas__c.split(';');
		respuesta.lProgreso = lItemProgreso;
		respuesta.mPasoPregunta = mStepPregunta;
		return respuesta;
	}

	public class WrapperRespuestaEncuesta{
		@AuraEnabled Public Boolean success;
		@AuraEnabled Public String mensaje;
		@AuraEnabled Public String cabecera;
		@AuraEnabled Public List<String> lPreguntas; 
		@AuraEnabled public List<WrapperProgressIndicator> lProgreso;
		@AuraEnabled public Map<String,String> mPasoPregunta;
	}



	public class WrapperProgressIndicator{
		@AuraEnabled public String label;
		@AuraEnabled public String value;
	}
}