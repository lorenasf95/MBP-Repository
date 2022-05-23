@IsTest
public class UtilidadesTest  {

	@TestSetup
	public static void init(){
		TestSetupClass.cargaInicial();
	}

	@IsTest
	public static void pruebaUtilidades(){
		//Creamos un WrDatosCorreo
		List<String> lCuerpos = new List<String>();
		lCuerpos.add('Correo de prueba para cubrir código');

		//Lista de Leads vacía para cubrir control de errores.
		List<Lead>lLeadsVacia= new List<Lead>();
		Utilidades.WrDatosCorreo correoSinCandidatos = new Utilidades.WrDatosCorreo(lLeadsVacia,'Prueba',lCuerpos);
		
		//Caso no válido para cubrir control de errores
		List<Lead>lLeadsSinEmail = [SELECT Id, Email, RecordType.DeveloperName FROM Lead WHERE Email = null AND Provincia__c = null LIMIT 1];
		Utilidades.WrDatosCorreo correoNoValido = new Utilidades.WrDatosCorreo(lLeadsSinEmail,'Prueba',lCuerpos);
		
		//Caso válido.
		List<Lead>lLeads = [SELECT Id, Email, RecordType.DeveloperName FROM Lead WHERE Email != null AND Provincia__c = null LIMIT 1];
		Utilidades.WrDatosCorreo correo = new Utilidades.WrDatosCorreo(lLeads,'Prueba',lCuerpos);
		
		Test.startTest();
			Utilidades.obtenerIdRecordId('Lead','Empresa');
			Utilidades.obtenerObjectNameFromRecordId(lLeads[0].id);
			System.debug('## Voy a cubrir enviarEmail');
			Utilidades.enviarEmail(correoSinCandidatos);
			Utilidades.enviarEmail(correoNoValido);
			Utilidades.enviarEmail(correo);
		Test.stopTest();
	}

}