public class Utilidades  {
	
	@AuraEnabled
	public static String obtenerIdRecordId (String nombreObjeto, String nombreTipoRegistro){
		
		RecordType rT = [SELECT Id FROM RecordType WHERE SobjectType =: nombreObjeto AND DeveloperName =: nombreTipoRegistro];

		return rT.Id;
	}

	@AuraEnabled
	public static String obtenerObjectNameFromRecordId(String recordIdOrPrefix){
        //Nombre del objeto que vamos a devolver.
		String objectName = '';
        try{
			//Sacamos los 3 primeros dígitos del registro en el que estamos.
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Obtenemos la info del Schema.
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Iteramos cada objeto que devuelve el schema.
            for(Schema.SObjectType stype : gd.values()){

                Schema.DescribeSObjectResult r = stype.getDescribe();
                //Sacamos el prefijo del objeto.
				String prefix = r.getKeyPrefix();
                
				//Si el prefijo del objeto es igual que el del registro que estamos pasando, este será nuestro objeto.
				if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    break;
                }
            }
        }catch(Exception e){System.debug(e);}return objectName;}


	public static InfoRespuesta enviarEmail(WrDatosCorreo datosCorreo){
		System.debug('### Entramos en enviarEmail');
		//Instanciamos la variable de respuesta.
		InfoRespuesta respuesta = new InfoRespuesta();

		//Instanciamos el correo que vamos a enviar.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String subject = datosCorreo.Subject;
		String body;

		System.debug('### datosCorreo : ' + JSON.serialize(datosCorreo));
		//Control de errores del listado que nos pasan por parametro. 
		if(datosCorreo.lCandidatos.isEmpty()){
			respuesta.success = false;
			respuesta.mensaje = 'Ha ocurrido un error, el listado de clientes está vacío.';
			return respuesta;
		}
		
		for(Integer i = 0; i< datosCorreo.lCandidatos.size(); i++){
			//Por cada cliente se enviará un correo a su email, con un asunto y cuerpo. Rellenamos los datos.
			List<String> ltoAddresses = new List<String>();
			ltoAddresses.add('lorenasf.95@gmail.com');
			ltoAddresses.add(String.valueOf(datosCorreo.lCandidatos[i].Email));
			subject = datosCorreo.Subject;
			body = datosCorreo.lBodies[i];

			//Preparamos el email para enviar.
			mail.setSubject(subject);
			mail.setHtmlBody('<h1>'+ subject + '</h1> <p> ' + body + '</p>');
			mail.setToAddresses(ltoAddresses);

			//Enviamos el correo.
			try{
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}catch(Exception exc){
				respuesta.success = false;
				respuesta.mensaje = 'Ha ocurrido el siguiente error '+exc.getMessage();
				return respuesta;
			}
		}
		
		respuesta.success = true;
		respuesta.mensaje = 'Se han enviado los emails correctamente';
		
		return respuesta;
	}

	public static HttpResponse makeRequest(String endpoint, String metodo, String body){
        System.debug('### MakeRequest EndPoint ' + endpoint);
        System.debug('### MakeRequest Metodo ' + metodo);
        System.debug('### MakeRequest Body ' + body);
        String url = endpoint;
        Http http = new Http();
        HTTPRequest req = new HTTPRequest();
        req.setEndPoint(url);
        req.setBody(body);
        req.setMethod(metodo);
        HttpResponse response = http.send(req);
        return response;
    }



	public class InfoRespuesta{
		@AuraEnabled public Boolean success;
		@AuraEnabled public String mensaje;
		
		public InfoRespuesta(){}

		public InfoRespuesta(Boolean exito, String motivo){
			this.success = exito;
			this.mensaje = motivo;
		}
	}

	public class WrDatosCorreo{
		@AuraEnabled public List<Lead> lCandidatos;
		@AuraEnabled public String Subject;
		@AuraEnabled public List<String> lBodies;

		public WrDatosCorreo(){}

		public WrDatosCorreo (List<Lead> lLeads, String asunto, List<String>lCuerpos){
			this.lCandidatos = lLeads;
			this.Subject = asunto;
			this.lBodies = lCuerpos;
		}
	}

}