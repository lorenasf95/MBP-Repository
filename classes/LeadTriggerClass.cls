public class LeadTriggerClass  {
	
	public static void asignarUsuario(List<Lead> lNew){
		List<Lead> lLeadstoProcess = new List<Lead>();

		//Filtramos los candidatos creados mediante API REST.
		for(lead leadIntegracion : lNew){
			if(leadIntegracion.LeadSource == 'integracion'){
				lLeadstoProcess.add(leadIntegracion);
			}
		}

		//Almacenamos los usuarios cuyo perfil sea comercial de ventas y sus ids.
		List<User> lUsers = [SELECT id, ProfileId, Profile.Name FROM user WHERE Profile.Name = 'Comercial de ventas'];
		Set<Id>sIdUsuarios = new Set<Id>();
		for(User u:lUsers){
			sIdUsuarios.add(u.id);
		}

		//Almacenamos los candidatos cuyo propietario coincida con el id de los usuarios.
		List<Lead> lLeadsAux = [SELECT Id,OwnerId FROM Lead WHERE OwnerId in: sIdUsuarios];
		Integer numCandidatos;
		Map<Id,Integer> mIdUsuarioNumeroCandidatos = new Map<Id,Integer>();

		for(Lead l : lLeadsAux){
			// Comprobamos cuál es el usuario con menor carga de trabajo.
			numCandidatos = mIdUsuarioNumeroCandidatos.containsKey(l.OwnerId) ? mIdUsuarioNumeroCandidatos.get(l.OwnerId)+1 : 1;
			mIdUsuarioNumeroCandidatos.put(l.OwnerId, numCandidatos);
		}

		//Comprobamos si el mapa contiene los usuarios que no tienen ningún candidato asignado y en caso de no contenerlo lo agregamos al mapa.
		for(id idUser:sIdUsuarios){
			if(!mIdUsuarioNumeroCandidatos.containsKey(idUser)){
				mIdUsuarioNumeroCandidatos.put(idUser, 0);
			}
		}

		List<Lead> lLeadsDefinitiva = new List<Lead>();
		//Por cada candidato vamos a asignarle el usuario con menor carga de trabajo.
		for (lead candidato : lLeadstoProcess){
			Integer menorCarga = 0;
			Integer iterador = 0;
			String idMenorCarga;
			for(id idUsuario : mIdUsuarioNumeroCandidatos.keySet()){
				//Si es la primera vez que entra, el primer candidato será el que menos carga tenga.
				if(iterador == 0){
					menorCarga = mIdUsuarioNumeroCandidatos.get(idUsuario);
					idMenorCarga = idUsuario;
				}
				//Si no, se sobrescribirá por el que menos carga tenga.
				else if(mIdUsuarioNumeroCandidatos.get(idUsuario) <= menorCarga){
					menorCarga = mIdUsuarioNumeroCandidatos.get(idUsuario);
					idMenorCarga = idUsuario;
				}
				iterador++;
			}

			//Agregamos el propietario con el id del usuario con menor carga a la lista definitiva.
			candidato.OwnerId = idMenorCarga;
			lLeadsDefinitiva.add(candidato);

			//agregamos un nuevo candidato al total de candidatos que tiene asignado el usuario.
			mIdUsuarioNumeroCandidatos.put(idMenorCarga, mIdUsuarioNumeroCandidatos.get(idMenorCarga) + 1);
		}
	}


	public static void noConvertirLeadsRechazados(List<Lead>lNew, List<Lead>lOld){

		for(integer i=0; i<lNew.size();i++){
			if(lOld[i].State == 'Rechazado' && lNew[i].State == 'Aceptado'){
				lNew[i].addError('No es posible cambiar de estado rechazado a aceptado');
			}

		}

	}

	public static void rellenarProvincia(List<Lead>lNew){
		List<Lead> lLeadsToProcess = new List<Lead>();
		Set<Id> sIdOwners = new Set<Id>();

		for(integer i=0; i<lNew.size();i++){
			if(lNew[i].PostalCode != null){
				lLeadsToProcess.add(lNew[i]);
				sIdOwners.add(lNew[i].OwnerId);
			}
		}
		
		List<User> lUsers = [Select Id,Sede__c From User Where id in: sIdOwners];
		Map<String,String> mIdOwnerProvincia = new Map<String,String>();
		for(User u : lUsers){
			mIdOwnerProvincia.put(u.Id,u.Sede__c);
		}

		for(Lead l: lLeadsToProcess){
			l.Provincia__c = l.PostalCode.substring(0,2);
			
			if(mIdOwnerProvincia.get(l.OwnerId) != l.Provincia__c){
				l.addError('No coinciden las provincias');
			}

		}
	}

	public static void validarDNI(List<Lead>lNew, List<Lead>lOld){
		List<Lead> lLeadsToProcess = new List<Lead>();
		String dniValido;
		
		Set<String> sProvincias = new Set<String>();
		//Comporbamos si se trata de una creación o actualización. Si se trata de una actualización:
		if(lOld != null){
			for(integer i=0; i<lNew.size();i++){
				if(lNew[i].numDocumento__c != lOld[i].numDocumento__c && lNew[i].numDocumento__c != null && lNew[i].Provincia__c!=null){
					lLeadsToProcess.add(lNew[i]);
					sProvincias.add(lNew[i].Provincia__c);
				}
			}
		}
		//Si se trata de una nueva creación.
		else{
			for(integer i=0; i<lNew.size();i++){
				if(lNew[i].numDocumento__c != null && lNew[i].Provincia__c!=null){
					lLeadsToProcess.add(lNew[i]);
					sProvincias.add(lNew[i].Provincia__c);
				}
			}
		}

		//Buscamos en los metadatos la sede y por cada una si tiene configurada la validación del dni. 
		List<ConfiguracionGeneral__mdt> lconfigDNI = [SELECT id, ValidarDNI__c, Sede__c  FROM ConfiguracionGeneral__mdt WHERE Sede__c in: sProvincias];
		
		//Construimos un mapa de la sede con su configuración de validación del dni.
		Map<String,ConfiguracionGeneral__mdt> mSedeValidarDNI = new Map<String,ConfiguracionGeneral__mdt>();
		for(ConfiguracionGeneral__mdt config : lconfigDNI ){
			mSedeValidarDNI.put(config.Sede__c,config);
		}
		
		//Si el lead tiene confirgurado para su provincia que hay que validarlo lo haremos.
		for(Lead l:lLeadsToProcess){
			if(mSedeValidarDNI.get(l.Provincia__c).ValidarDNI__c == true){
				//Si no cumple con las reglas de validación lanzaremos un error.
				if(reglasValidacion(l.numDocumento__c) == false){
					l.addError('No se ha podido validar porque no cumplía con las reglas de validación');
				}
			}
		}
	}

	public static Boolean reglasValidacion(String dni){
		Boolean letraCorrectaDNI;
		Boolean letraCorrectaNIE;
		Boolean numerosCorrectosDNI;
		Boolean numerosCorrectosNIE;
		Boolean primeraLetraNIE;
		
		//Comprobamos si es alfanúmerico. En caso contrario eliminamos los simbolos no válidos.
		dni = dni.trim();
		Boolean esAlfanumerico = dni.isAlphanumeric() ? true : false;
		if(esAlfanumerico == false){
			dni = dni.remove('-');
		}

		//Comprobamos que tenga tenga 9 dígitos después de quitar espacios y guiones.
		Boolean longitudCorrecta = dni.length() == 9 ? true : false;
		if(longitudCorrecta == false){
			return false;
		}

		//Comprobamos si se trata de un DNI o un NIE.
		//Si el primer dígito es un número será un DNI.
		if(dni.substring(0,1).isNumeric()){
			//Validamos que los 7 primeros dígitos sean números.
			numerosCorrectosDNI = dni.substring(0,8).isNumeric() ? true : false;

			//Validamos que el último dígito sea una letra
			letraCorrectaDNI = dni.substring(8,9).isAlpha() ? true : false;
			
			if(numerosCorrectosDNI == false || letraCorrectaDNI == false){
				return false;
			}
		}
		//Si el primer dígito no es un número será un NIE.
		else{
			//Validamos que la primera letra sea una Y/X/Z.
			if((dni.substring(0,1) == 'Y' || dni.substring(0,1) == 'X' || dni.substring(0,1) == 'Z') ){
				primeraLetraNIE = true;
			}

			//Validamos que los siguientes 7 dígitos sean números.
			numerosCorrectosNIE = dni.substring(1,8).isNumeric() ? true : false;

			//Validamos que el último dígito sea una letra.
			letraCorrectaNIE = dni.substring(8,9).isAlpha() ? true : false;

			if(numerosCorrectosNIE == false || letraCorrectaNIE == false || primeraLetraNIE == false){
				return false;
			}
		}

		return true;
	}

}