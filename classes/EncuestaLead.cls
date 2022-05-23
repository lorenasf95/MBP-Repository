public class EncuestaLead  {

	@AuraEnabled
	public static Utilidades.InfoRespuesta gradoSatisfaccion (Decimal promedio, String idCandidato){
		System.debug('promedio es '+promedio+' e idCandidato es '+idCandidato);
		if(promedio == null || String.isEmpty(idCandidato)){ return new Utilidades.InfoRespuesta(false,'Ha surgido un error, vuelva a rellenar la encuesta');}

		Lead candidato = new Lead(Id = idCandidato);
		candidato.GradoSatisfaccion__c = promedio;
		
		try{update candidato;return new Utilidades.InfoRespuesta(true,'Se han guardado correctamente las respuestas de la encuesta');}catch(Exception exc){return new Utilidades.InfoRespuesta(false,'Ha ocurrido el siguiente error '+exc.getMessage());}

	}
}