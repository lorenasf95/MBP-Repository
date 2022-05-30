public class EnviarFacturaQAClass  {
	
	public static String JSONDummy = '{"success":true,"lErrores":[],"idContratoSAP":"SAP0044456"}';

	@AuraEnabled
	public static Utilidades.InfoRespuesta enviarASAPMethod (String idFactura, Date fechaFactura){
		System.debug('### Que fecha llega -> ' + fechaFactura);
		String fechaFacturaDef = Datetime.newInstance(fechaFactura.year(),fechaFactura.month(),fechaFactura.day()).format('dd-MM-YY');
		System.debug('### Como queda la fecha tras transformarla --> ' + fechaFacturaDef);

		//Instanciamos la respuesta que devolverá el back.
		Utilidades.InfoRespuesta respuesta = new Utilidades.InfoRespuesta();

		//Buscamos la factura que se corresponda con la idFactura y el contacto que coincida con la cuenta de la factura.
		List<Factura__c> lFacturas = [SELECT Id,FechaFirmaContrato__c,Cuenta__c FROM Factura__c WHERE id =: idFactura LIMIT 1];
		List<Lead> lCandidatos = [SELECT Id, numDocumento__c, ConvertedAccountId, Email FROM Lead WHERE ConvertedAccountId =: lFacturas[0].Cuenta__c LIMIT 1];

		//Controlamos que no estén vacíos.
		if(lFacturas.isEmpty() || lCandidatos.isEmpty()){return new Utilidades.InfoRespuesta(false, 'El id de la factura no se ha encontrado');}

		//Obtenemos el EndPoint de la metadata.
		ConfiguracionEndPoints__mdt config = [Select Id, EndPointEnviarFactura__c From ConfiguracionEndPoints__mdt LIMIT 1];

		//Construimos el JSON que enviamos a SAP.
        WrEnvioSAP datosSAP = new WrEnvioSAP();
        datosSAP.idFactura = idFactura;
		datosSAP.idCliente = lFacturas[0].Cuenta__c;
		datosSAP.fechaFactura = fechaFacturaDef;
		datosSAP.DNICliente = lCandidatos[0].numDocumento__c;
        String jsonEnvio = JSON.serialize(datosSAP);
		System.debug('##Enviamos a SAP la siguiente información : '+jsonEnvio);
        
		//Vamos a mandarlo y almacenar la respuesta de SAP.
		RespuestaSAP respSap;
		HttpResponse response;

		//Si no es un test lanzamos la petición.
		if(JSONDummy == null ){
			response = Utilidades.makeRequest(config.EndPointEnviarFactura__c,'POST', jsonEnvio);
			
			//Controlamos que no haya habido ningún fallo del servidor o cliente.
			if(response.getStatusCode() != 200){ return new Utilidades.InfoRespuesta(false, 'Ha ocurrido un error al contactar con SAP, código del error: '+response.getStatusCode()); }
			
			//Deserealizamos el JSON.
			try{
				respSap = (RespuestaSAP) JSON.deserialize(response.getBody(),RespuestaSAP.class);
			}catch(Exception exc){
				respuesta.success = false;
				respuesta.mensaje = 'Se ha producido el siguiente error al deserealizar el JSON: '+exc.getMessage();
			}
		}
		//Si es un test mockeamos un JSON dummy.
		else{
			respSap = (RespuestaSAP) JSON.deserialize(JSONDummy,RespuestaSAP.class);
		}

		//SAP devuelve error.
		if(respSap.success == false){
			respuesta.success = false;
			respuesta.mensaje = 'Ha habido un error, por favor, inténtelo más tarde.';
		}
		//SAP devuelve éxito.
		else{
			lFacturas[0].FechaFirmaContrato__c = fechaFactura;
			lFacturas[0].IdContratoSAP__c = respSap.idContratoSAP;
			lFacturas[0].Estado__c = 'Enviado';
			respuesta.success = true;
			respuesta.mensaje = 'Se ha enviado correctamente';
		}

		//Intentamos actualizar la factura con los nuevos datos proporcionados por SAP y controlamos sus posibles errores.
		try{
			update lFacturas;
		}catch(Exception exc){
			respuesta.success = false;
			respuesta.mensaje = 'Ha habido un error al intentar actualizar los datos de la factura: '+exc.getMessage();
			return respuesta;
		}

		//Enviamos un correo al cliente indicando la fecha de citación para la firma.
		String cuerpo = 'Le recordamos que deberá acudir a nuestras oficinas sitas en la C/No existe s/n de Madrid, el próximo '+fechaFacturaDef+' para firmar el contrato';
		String asunto = 'Cita firma contrato';
		List<String> lCuerpos = new List<String> {cuerpo};
		Utilidades.WrDatosCorreo datosEmail= new Utilidades.WrDatosCorreo(lCandidatos, asunto, lCuerpos);
		Utilidades.enviarEmail(datosEmail);

		return respuesta;
	}

	public class WrEnvioSAP{
        public String idFactura;
		public String idCliente;
		public String DNICliente;
        public String fechaFactura;
    }

	public class RespuestaSAP{
        public Boolean success;
        public String idContratoSAP;
        public List<String> lErrores;
    }

}