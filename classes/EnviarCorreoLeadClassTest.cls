@IsTest
public class EnviarCorreoLeadClassTest  {
	

	@TestSetup
	public static void cargaInicial(){
		TestSetupClass.cargaInicial();
	}
	@isTest
	public static void testEnviarCorreo(){
		List<Lead>lLeads = [SELECT Id,Email FROM Lead LIMIT 1];

		//Creamos un documento adjunto
		ContentVersion contentVersion = new ContentVersion(
                Title          = 'TestFile',
                PathOnClient   = 'testFile.jpg',
                VersionData    = Blob.valueOf('Hola mundo!!'),
                IsMajorVersion = true);
				
        insert contentVersion;

		List<String>lTextos = new List<String>();
		lTextos.add(contentVersion.Id);

		Test.startTest();
			EnviarCorreoLeadClass.initLoad(lLeads[0].Id);
			EnviarCorreoLeadClass.initLoad('NOTIDVALID');
			EnviarCorreoLeadClass.sendEmailToController('Texto de prueba','lorenasf.95@gmail.com','prueba', lTextos);
		Test.stopTest();
	}
}