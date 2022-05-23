public class EnviarCorreoLeadClass  {

	//OPCIÓN 2.
	//public static Boolean showEmailDummy;
	@AuraEnabled
	public static WrapperRespuesta initLoad (String idCandidato){
		WrapperRespuesta respuesta = new WrapperRespuesta();
		
		//Comprobamos si hay que mostrar la opción para adjuntar o no.
		//OPCIÓN 1.
		List<ConfiguracionGeneral__mdt> lConfig;
		if(Test.isRunningTest()){
			lConfig = new List<ConfiguracionGeneral__mdt>{ new ConfiguracionGeneral__mdt(ShowEmailWithAttachments__c = true, Sede__c = 'Barcelona')};
		}else{
			lConfig =  [SELECT id, ShowEmailWithAttachments__c FROM ConfiguracionGeneral__mdt];
		}

		//OPCIÓN 2./
		/*
		if(showEmailDummy==null){
			lConfig =  [SELECT id, ShowEmailWithAttachments__c FROM ConfiguracionGeneral__mdt];
			showEmail = lConfig[0].ShowEmailWithAttachments__c ;
		}else{
			showEmail = showEmailDummy;
		} */

		if(lConfig.isEmpty()){return new WrapperRespuesta(false,'Ha ocurrido un error con la configuración');}

		//Buscamos el candidato para obtener su mail.
		List<Lead> lCandidatos = [SELECT Id, Email FROM Lead WHERE id =: idCandidato LIMIT 1];
		Lead candidato = new Lead();

		if(lCandidatos.isEmpty()){return null;}

		candidato = lCandidatos[0];

		respuesta.success = true;
		respuesta.mensaje = 'Se ha cargado con éxito';
		respuesta.mailCandidato = candidato.Email;
		respuesta.hayAdjunto = lConfig[0].ShowEmailWithAttachments__c ;
		return respuesta;
	}


    @AuraEnabled
    public static WrapperRespuesta sendEmailToController(String body, String toSend, String subject, List<String> lIdDocumentos){
		WrapperRespuesta respuesta = new WrapperRespuesta();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {toSend, 'lorenasf.95@gmail.com'};
		
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody('<h1>'+ subject + '</h1> <p> ' + body + '</p>');
		
		if(!lIdDocumentos.isEmpty()){
			List<ContentVersion> lContentVersion = [Select Id,Title,VersionData,FileExtension FROM ContentVersion Where Id in :lIdDocumentos];
			List<Messaging.Emailfileattachment> lAdjuntos = new List<Messaging.Emailfileattachment>();
			for(ContentVersion cv : lContentVersion){
				Messaging.EmailFileAttachment adjunto = new Messaging.EmailFileAttachment();
				adjunto.setFilename(cv.Title+'.'+cv.FileExtension);
				adjunto.setBody(cv.VersionData);
				lAdjuntos.add(adjunto);
			}
			mail.setFileAttachments(lAdjuntos);
		}

		//Enviamos el mail.
        try{Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });}catch(Exception exc){return new WrapperRespuesta(false,'Ha ocurrido el siguiente error '+exc.getMessage());}

		respuesta.success = true;
		respuesta.mensaje = 'Se ha enviado el email correctamente';
		
		return respuesta;
    }

	
	public class WrapperRespuesta{
		@AuraEnabled public Boolean success;
		@AuraEnabled public String mensaje;
		@AuraEnabled public Boolean hayAdjunto;
		@AuraEnabled public String mailCandidato;

		public WrapperRespuesta(){}

		public WrapperRespuesta(Boolean exito, String motivo){
			this.success = exito;
			this.mensaje = motivo;
		}

		
	}

}