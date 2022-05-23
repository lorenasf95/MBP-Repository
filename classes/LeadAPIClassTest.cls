@IsTest
public class LeadAPIClassTest  {

	@TestSetup
	public static void init(){
		TestSetupClass.cargaInicial();
	}

	@IsTest
	public static void testLeadAPI(){
		//Buscamos un cliente y rellenamos el motivo de rechazo.
		List<Lead> lLeads = [SELECT Id FROM Lead LIMIT 1];
			
		Test.startTest();
			//Instanciamos una respuesta de la API.
			RestResponse res = new RestResponse();

			//Instanciamos la petición y rellenamos los datos necesarios.
			RestRequest req = new RestRequest();
			req.requestURI = '/nuevoCandidato';  //URL de la petición.
			req.httpMethod = 'POST';//HTTP tipo

			//Creamos un datosLead para hacer el test
			LeadAPIClass.WrDatosLead datosLead = new LeadAPIClass.WrDatosLead();
			
			//Con campos vacíos.
			String jsonEnvio = JSON.serialize(datosLead);
			req.requestBody = Blob.valueof(jsonEnvio);//body
			RestContext.request = req;
			RestContext.response = res;
			LeadAPIClass.newLead();
			
			//Válido con empresa
			datosLead.nombre = 'Mariano';
			datosLead.apellidos = 'López';
			datosLead.telefono = '456789456';
			datosLead.email = 'eqifgeuqigf@gmail.com';
			datosLead.provincia ='28';
			datosLead.origen = 'integracion';
			datosLead.numDocumento = '45645623M';
			datosLead.esEmpresa = true;
			jsonEnvio = JSON.serialize(datosLead);
			req.requestBody = Blob.valueof(jsonEnvio);//body
			RestContext.request = req;
			RestContext.response = res;
			LeadAPIClass.newLead();

			//Válido con persona física.
			datosLead.esEmpresa = false;
			jsonEnvio = JSON.serialize(datosLead);
			req.requestBody = Blob.valueof(jsonEnvio);//body
			RestContext.request = req;
			RestContext.response = res;
			LeadAPIClass.newLead();

		Test.stopTest();

	}
}