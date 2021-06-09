package src_Cabeza_Martin_Angel;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

import java.util.*;

public class Agent extends AbstractPlayer{
	
	static final int ID_GEMA = 6;	// Es el ID que le da el juego a una gema
	Stack<Types.ACTIONS> plan;		// En esta variable vamos a guardar el plan a seguir para ir a un punto
	Vector2d portal;				// Aqui guardaremos la posicion del portal
	Vector2d fescala;				// Factor para convertir de coordenadas de pixeles a coordenadas de grid
	int gemasConseguidas;			// Variabale para almacenar las gemas que tenemos
	int gemasAObtener;				// Variable para almacenar las gemas que tenemos que obtener para poder salir por el portal
	ArrayList<Observation> gemas;	// Variable donde vamos a almacenar las mejores gemas que quedan en el mapa
	boolean puedoAcabar;			// Variable que controla si estoy en el nivel 1 o en el nivel 2/5
	boolean reactivo;				// Variable que conrola si estoy en el nivel 3 4
	Double[][] riesgoMuros;			// Matriz de riesgo con el riesgo de los muros
	Double[][] riesgoMundo;			// Matriz de riesgo con el riesgo del mundo (muros+enemigos)
	
	
	public Agent(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
		
		// Inicializo algunas variables que nos ayudarán para controlar el nivel
		// en el que estamos 
		gemasAObtener = 9;
		gemasConseguidas = 0;
		puedoAcabar = false;
		reactivo = false;
		
		// Gemas es un array que contiene las mejores gemas a las que el avatar puede ir
		// Plan es una pila que almacenará los movimientos que tiene que realizar el avatar
		// para ir a un sitio en concreto
		gemas = new ArrayList<>();
		plan = new Stack<>();
		
		// Calculo el factor para transformar las coordenadas pixel en coordenadas del grid
		fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length,
								stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);
		
		//Recupero la lista de posiciones de portales ordenadas por cercanía al avatar
		ArrayList<Observation>[] posiciones = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
		
		// Este if no debería accionarse nunca, lo he puesto por precaución
		// Comprueba que hay portales,, si no hay portal se quda a null
		if (posiciones == null) {
			portal = null;
		}
		else {
			// Me quedo con el portal más cercano al avatar
			portal = posiciones[0].get(0).position;
			portal = calcularPosGrid(portal);
			
			// Recupero la lista de diamantes ordenados por cercanía al avatar
			ArrayList<Observation>[] mejoresGemas = stateObs.getResourcesPositions(stateObs.getAvatarPosition());
			
			// Si hay gemas en el mapa significa que estoy en el nivel 2 o 5 y no puedo
			// acabar sin recoger las gemas
			if (mejoresGemas != null) {
				puedoAcabar = false;
			}
			// Si no hay gemas
			else {
				// Y hay enemigos estoy en los niveles 3 o 4 con lo que el comportamiento
				// es puramente reactivo
				if (stateObs.getNPCPositions() != null) {
					reactivo = true;
				}
				
				// Si no hay enemigos estoy en el nivel 1 y puedo acabar sin coger ninguna gema
				puedoAcabar = true;
			}
		}
		
		// Calculamos las dimensiones del mapa para crear nuestras dos matrices de riesgo
		Vector2d dimensionesMundo = new Vector2d(stateObs.getWorldDimension().width,stateObs.getWorldDimension().height);
		dimensionesMundo = calcularPosGrid(dimensionesMundo);
		
		// Creamo las matrices al tamaño del mundo
		riesgoMuros = new Double[(int)dimensionesMundo.x][(int)dimensionesMundo.y];
		riesgoMundo = new Double[(int)dimensionesMundo.x][(int)dimensionesMundo.y];
		
		// Inicializamos la matriz con el riesgo de los muros aquí ya que 
		// este riesgo no va a cambiar nunca (los muros no se mueven)
		inicializarRiesgoMuros(stateObs);
	}
	
	@Override
	public Types.ACTIONS act (StateObservation stateObs, ElapsedCpuTimer elapsedTimer){

		// Inicializo la acción a no hacer nada por si algo pasara
		Types.ACTIONS accion = Types.ACTIONS.ACTION_NIL;
		
		// Compruebo si estoy en riesgo
		boolean estoyEnRiesgo = calcularRiesgoMundo(stateObs);
		
		// Si estoy en riesgo (Nivel 5) o estoy en el comportamiento reactivo o reactivo compuesto
		// Entro en el comportamiento reactivo y voy a hacer una acción para escapar del peligro
		if (estoyEnRiesgo || reactivo) {
			accion = calcularAccionReactiva(stateObs);
			
			//Tengo que eliminar el plan existente si es que lo había
			// Para recalcular otro
			plan.clear();
		}
		// Si no estoy en peligro
		else {
			// Este if debería sobrar porque siempre hay portal
			// pero lo he puesto por precaución
			if (portal != null) {
				
				// En cada paso del avatar actualizo las gemas que tengo por si
				// al intentar conseguir una gema recojo otra por suerte
				if (stateObs.getAvatarResources().get(ID_GEMA) != null) {
					gemasConseguidas = stateObs.getAvatarResources().get(ID_GEMA);
				}
				
				// Si ya he conseguido las 9 gemas puedo acabar
				if (gemasConseguidas >= gemasAObtener) {
					puedoAcabar = true;
				}
				
				// Si puedo acabar calculo un plan para ir al portal
				if (plan.empty() && puedoAcabar) {
					sacarPlanNodo(Astar(stateObs,calcularPosGrid(stateObs.getAvatarPosition()),portal));
					
				}
				// Si no puedo acabar y no tengo ningún plan para ir a por alguna gema
				else if (plan.empty()){
					
					// Saco las mejores gemas por posición
					ArrayList<Observation>[] mejoresGemas = stateObs.getResourcesPositions(stateObs.getAvatarPosition());
					gemas = mejoresGemas[0];
					
					// Si hay más de 9 gemas corto el array a 9 gemas para no perder
					// tiempo de cómputo
					if (gemas.size() > 9) {
						List<Observation> mejores9Gemas = gemas.subList(0,9);
						gemas = new ArrayList<>(mejores9Gemas);
					}
					
					// Calculo la mejor gema según la distanciaManhattan
					Vector2d mejorGema = calcularMejorGema(stateObs,gemas);
					
					// Y calculo un plan para ir a esa gema
					sacarPlanNodo(Astar(stateObs,calcularPosGrid(stateObs.getAvatarPosition()),calcularPosGrid(mejorGema)));
				}
				
				// Si tengo un plan para ir hacia algún sitio y me queda tiempo
				// saco del plan la acción a realizar y devuelvo esa acción
				if (!plan.empty() && elapsedTimer.remainingTimeMillis() > 0) {
					accion = plan.peek();
					plan.pop();
				}
			}
		}
 		
		return accion;
	}
	
	private Node Astar (StateObservation stateObs, Vector2d ini, Vector2d dest) {
		
		//Creo dos nodos iguales a los que nos pasan para modificarlos tranquilamente
		Node inicio = new Node(ini);
		
		// traducirOrientacion lo que hace es cambiar la representación de la orientaciñon
		// que GVGAI implementó a una con la que yo me siento más cómodo ya que la usé
		// en otra asignatura (Inteligencia Artificial)
		inicio.orientation = traducirOrientacion(stateObs.getAvatarOrientation());
		
		System.out.println("La orientación del avatar en el primer tick es: " + traducirOrientacion(stateObs.getAvatarOrientation()));
		Node destino = new Node(dest);
		
		// Creo las listas de abiertos y cerrados como colas con prioridad
		// de esta manera se ordenan de manera automática
		PriorityQueue<Node> abiertos = new PriorityQueue<>();
		PriorityQueue<Node> cerrados = new PriorityQueue<>();
		
		// Inicializo los costes del nodo inicio
		inicio.totalCost = 0;
		inicio.estimatedCost = distanciaManhattan(inicio,destino);
		
		// Lo añado a abiertos
		abiertos.add(inicio);
		
		// Estos dos nodos son auxiliar
		// el primero (solucion) es el que usaremos para guardar el nodo cuando lleguemos al destino
		// y el segundo es el que usaremos para almacenar el mejor nodo posible que esté en abieretos
		Node solucion = null;
		Node mejorAbiertos = inicio;
		
		// Este vector lo usaré para expandir el nodo
		ArrayList<Types.ACTIONS> acciones = new ArrayList<>();
		acciones.add(Types.ACTIONS.ACTION_DOWN);
		acciones.add(Types.ACTIONS.ACTION_LEFT);
		acciones.add(Types.ACTIONS.ACTION_RIGHT);
		acciones.add(Types.ACTIONS.ACTION_UP);
		
		// Bool para controlar cuando salirme del bucle
		boolean tengoSolucion = false;
		
		// Empieza el bucle
		while(!abiertos.isEmpty() && !tengoSolucion) {
			
			// Cogemos el primer elemento de la cola y lo sacamos de ella.
			// Cogemos el primero ya que al ser una cola de prioridad
			// están ordenados y el primero es el mejor
			mejorAbiertos = abiertos.poll();
			
			// Lo añado a ceerrados para marcarlo como ya visitado
			cerrados.add(mejorAbiertos);
			
			// Le cambio la orientación para poder ejecutar el
			// método equals y que si estoy en el destino 
			// sepa identificarlo. Al fin y al cabo la orientación
			// que tenga el avatar una vez llega al destino nos da igual
			destino.orientation = mejorAbiertos.orientation;
			
			
			// Compruebo si estoy en el nodo destino
			if (mejorAbiertos.equals(destino)) {
				tengoSolucion = true;
			}
			
			
			// Si no he llegado a la solución expando el nodo
			if(!tengoSolucion) {
				
				for (Types.ACTIONS accion : acciones) {
					Node hijo = new Node(mejorAbiertos);
					
					// Por cada acción posible creo un nodo hijo con una nueva posición (según la acción),
					// orientación y guardo la acción que me ha llevado hasta él
					if (accion.equals(Types.ACTIONS.ACTION_LEFT)) {
						hijo.position.x = hijo.position.x -1;
						hijo.orientation = 3;
						hijo.accion = Types.ACTIONS.ACTION_LEFT;
					}
					else if (accion.equals(Types.ACTIONS.ACTION_RIGHT)){
						hijo.position.x = hijo.position.x +1;
						hijo.orientation = 1;
						hijo.accion = Types.ACTIONS.ACTION_RIGHT;
					}
					else if (accion.equals(Types.ACTIONS.ACTION_UP)){
						hijo.position.y = hijo.position.y -1;
						hijo.orientation = 0;
						hijo.accion = Types.ACTIONS.ACTION_UP;
					}
					else if (accion.equals(Types.ACTIONS.ACTION_DOWN)){
						hijo.position.y = hijo.position.y +1;
						hijo.orientation = 2;
						hijo.accion = Types.ACTIONS.ACTION_DOWN;
					}
					
					// Si ese hijo no es un obstáculo (un muro)
					if (!esObstaculo(stateObs, hijo)) {
						// Inicializo su padre al nodo que hemos sacado de abiertos
						hijo.parent = mejorAbiertos;
						
						// Y cambio sus costes
						hijo.totalCost = mejorAbiertos.totalCost +1;
						hijo.estimatedCost = distanciaManhattan(hijo,destino);
						
						// Si las orientaciones han cambiado eso significa que 
						// he gastado algún tick para orientarme con lo cual
						// tengo que aumentar el coste (cada giro para orientarse tenía 1 de coste adicional)
						if (hijo.orientation != mejorAbiertos.orientation) {
							hijo.totalCost = hijo.totalCost + 1;
						}
						
						// Si abiertos no tiene este hijo ni cerrados lo tiene lo agrego
						if (!abiertos.contains(hijo) && !cerrados.contains(hijo)) {
							abiertos.add(hijo);
						}
						else {
							// Si este hijo está en abiertos miro cual tiene el menor coste entre el que está en abieertos y el que acabo de expandir
							//y es el que se quedará en abiertos
							if (abiertos.contains(hijo)) {
								ArrayList<Node> abiertosEnArrayList = new ArrayList <Node>(Arrays.asList(abiertos.toArray(new Node[abiertos.size()])));
								Node actualAbiertos = abiertosEnArrayList.get(abiertosEnArrayList.indexOf(hijo));
								
								if (actualAbiertos.totalCost > hijo.totalCost) {
									abiertos.remove(actualAbiertos);
									abiertos.add(hijo);
								}
							}
						}
						
						// MUY IMPORTANTE!!
						// NO TENGO QUE MIRAR SI EL HIJO ESTÁ EN CERRADOS PORQUE LA HEURÍSTICA (DISTANCIA MANHATTAN)
						// ES UNA HEURÍSTICA MONÓTONA Y POR TANTO NO HAY QUE COMPROBAR SI ESTÁ EN CERRADOS 
						// (VISTO Y DEMOSTRADO EN TEORÍA)
					}
					
				}
			}
			// Si es solución la guardo en el nodo solución
			else {
				solucion = mejorAbiertos;
			}
			
			
		}
		
		// Si la solución no es nula la devuelvo
		if (solucion != null) {
			return solucion;
		}
		// Si no he encontrado solución devuelvo el nodo donde estaba
		// con un coste negativo. (Esto no debería pasar en ningún mapa pero lo hago por precaución)
		else {
			Node error = new Node(ini);
			error.totalCost = -1;
			return error;
		}
	}

	private double distanciaManhattan(Node inicio, Node destino) {
		double distancia;
		
		// Simplemente implementamos la fórmula de la distancia Manhattan
		// distMan = abs(P1.x - P2.x) + abs(P1.y - P2.y 
		distancia = Math.abs(inicio.position.x - destino.position.x) + Math.abs(inicio.position.y - destino.position.y);
		
		return distancia;
	}
	
	private boolean esObstaculo(StateObservation stateObs, Node nodo) {
		
		// Saco todas las observaciones del nivel
		ArrayList<Observation>[][] grid = stateObs.getObservationGrid();
		
		// Recorro las observaciones de cada pixel en la posición del nodo que se le pasa por
		// parámetro. Si alguna es un muro (itype = 0) devuelo true y si no false
		for (Observation obs : grid[(int)nodo.position.x][(int)nodo.position.y]) {
			if (obs.itype == 0)
				return true;
		}
		
		return false;
	}
	
	
	// Con este método traducimos la orientación de GVGAI a una orientación que entiendo mejor.
	private int traducirOrientacion(Vector2d orientacion) {
		
		int orient = -1;
		
		// Si estamos mirando hacia arriba o hacia abajo
		if (orientacion.x == 0) {
			// Si miramos hacia arriba la orientación es 0. (0 == NORTE)
			if (orientacion.y == -1)
				orient = 0;
			else
				// Si miramos hacia abajo la orientación es 2 (2 == SUR)
				orient = 2;
		}
		// Si estamos mirando hacia los lados
		else {
			// Si miramos a la izquierda la orientacion es 3 (3 == OESTE)
			if (orientacion.x == -1)
				orient = 3;
			else
				//Si miramos hacia la dereha la orientación es 1 (1 == ESTE)
				orient = 1;
		}
		
		return orient;
	}
	
	// Método que saca el plan a partir de un nodo
	private void sacarPlanNodo(Node nodo) {
		// Vacío el plan anterior
		plan = new Stack<>();
		
		// Mientras el nodo no sea nulo
		while (nodo != null) {
			// Y si el nodo tiene padre
			if (nodo.parent != null) {
				// Meto la acción almacenada en el nodo
				plan.push(nodo.accion);
				
				// Y si no tiene la misma orientación que el nodo padre
				// eso quiere decir que hemos usado algún tick para cambiar
				// de orientación por lo que tneemos que meterla acción anterior
				// dos veces
				if (nodo.orientation != nodo.parent.orientation)
					plan.push(plan.peek());
			}
			
			// Me paso al padre del nodo
			nodo = nodo.parent;
		}
	}
	
	// Este método pasa de coordeandas de pixeles a coordenadas en una matriz 2D con la
	// que nosotros trabajaremos (he implementado esta operación como un método porque se
	// repetía muchas veces)
	private Vector2d calcularPosGrid (Vector2d posObjeto) {
		Vector2d posicion = new Vector2d(posObjeto.x / fescala.x, posObjeto.y / fescala.y);
		
		//posicion.x = Math.floor(posicion.x);
		//posicion.y = Math.floor(posicion.y);
		
		return posicion;
	}
	
	// Método para inicializar una matriz de riesgo teniendo solo en cuenta los muros
	// (Esto lo hago para que el avatar intente evitar estar cerca de un muro pero
	// por ahora le esta dando un poco igual y adora los muros)
	private void inicializarRiesgoMuros(StateObservation stateObs) {
		
		// Lo primero que hago es inicializar toda la matriz a 0
		for (int i = 0; i < riesgoMuros.length; i++) {
			for (int j = 0; j < riesgoMuros[i].length; j++) {
				riesgoMuros[i][j] = 0.0;
			}
		}
		
		// Saco una lista con todos los objetos inmoviles (en general muros)
		ArrayList<Observation>[] objetosInmoviles = stateObs.getImmovablePositions();
		
		//Si hay objetos inmoviles
		if (objetosInmoviles != null) {
			// Me saco los muros en un array
			ArrayList<Observation> muros = objetosInmoviles[0];
			
			// Y recorro los muros
			for (Observation muro : muros) {
				// A cada muro le calculo su posición
				Vector2d posMuro = new Vector2d(calcularPosGrid(muro.position));
				
				// miro el cuadrado de 5x5 alrededor del muro
				// miro las 2 casillas a la derecha del muro, las dos casillas arriba a la derecha y las dos casillas abajo a la derecha
				// y lo mismo pero a la izquierda del muro
				for (int i = 2; i >= -2; i--) {
					for(int j = 2; j >= -2; j--) {
						// Saco las coordenadas de la casilla que estoy mirando
						int x = (int)posMuro.x - i;
						int y = (int)posMuro.y - j;
						
						//Si no excede los límites del mapa
						if (0 <= x && x < riesgoMuros.length && 0 <= y && y < riesgoMuros[x].length) {
							
							// Y no es un obstaculo
							if (!esObstaculo(stateObs,new Node(new Vector2d(x,y)))) {
								
								// Le añado uno de peligro a la casilla si está muy cerca del muro
								// y 0.5 si está alejada
								if (Math.abs(j) < 2 && Math.abs(i) < 2) {
									riesgoMuros[x][y] += 1.0;
								}
								else {
									riesgoMuros[x][y] += 0.5;
								}
							}
						}
					}
				}
				
				// A la propia casilla del muro le pongo un valor de riesgo infinito
				riesgoMuros[(int)posMuro.x][(int)posMuro.y] = Double.MAX_VALUE;
			}
		}
		
		// Este trozo de código solo se activa cuando estamos 
		// en los niveles reactivo simple o compuesto y lo he impleementado
		// para intentar que el avatar se quede en el centro del mapa y no vaya
		// a las esquinas pero no me hace caso :(
		if (reactivo) {
			// Calculo el centro del mapa
			int xCentro = riesgoMuros.length/2;
			int yCentro = riesgoMuros[0].length/2;
			
			// Para el cuadrado de lado centro
			for (int i = -xCentro; i < xCentro - 2; i++) {
				for (int j = -yCentro; j < yCentro - 2; j++) {
					
					// Saco las coordenadas de la casilla que estamos evaluando
					int x = xCentro + i;
					int y = yCentro +j;
					
					// SI no excede los limites del mapa y no es un muro
					if (0 <= x && x < riesgoMuros.length && 0 <= y && y < riesgoMuros[x].length) {
						if ( !esObstaculo(stateObs,new Node( new Vector2d(x,y)))) {
							
							// Le quito un riesgo proporcional a la distancia al centro
							int distancia = Math.max(Math.abs(i), Math.abs(j));
							riesgoMuros[x][y] -= 5.0/distancia;
						}
					}
				}
			}
		}
	}
	
	// Este es el método que calcula el mapa de potencial real que es usado en los
	// momentos de peligro, devuelve true si está bajo una amenaza real y false si no
	private boolean calcularRiesgoMundo(StateObservation stateObs) {
		
		// Sacamos todas las posiciones de los npcs del mundo
		ArrayList<Observation>[] NPC = stateObs.getNPCPositions();
		
		// Inicializamos el riesgo del mundo al mismo que la matriz de riesgo de los muros
		for (int i = 0; i < riesgoMuros.length;i++) {
			for (int j = 0; j < riesgoMuros[i].length; j++) {
				riesgoMundo[i][j] = riesgoMuros[i][j];
			}
		}
		
		// Si hay npcs en el mundo
		if (NPC != null) {
			// Sacamos todos los enemigos del mundo
			ArrayList<Observation> enemigos = NPC[0];
			
			// Y los recorremos
			for (Observation enemigo : enemigos) {
				
				// Calculo su posicion
				Vector2d posNPC = new Vector2d(calcularPosGrid(enemigo.position));
				
				// Y hago lo mismo que para los muros, veo todas
				// las casillas en un cuadrado de 4x4
				for (int i = 5; i >= -5; i--) {
					for (int j = 5; j >= -5; j--) {
						// Calculo la posicion de la casilla que estamos visitando
						int x = (int)posNPC.x + i;
						int y = (int)posNPC.y + j;
						
						// Si la casilla  no excede los limites del mundo y no es un muro
						if (0 <= x && x < riesgoMundo.length && 0 <= y && y < riesgoMundo[x].length) {
							if (!riesgoMundo[x][y].equals(Double.MAX_VALUE) && !esObstaculo(stateObs, new Node(new Vector2d(x,y)))) {
								// Asigno valores de  riesgo según la proximidad
								// de la casilla al enemigo, no sumo a los que ya 
								// tenga para que si se juntan dos enemigos
								// no se sumen las amenazas de los dos enemigos
								
								// He ido asignando valores decrementales de 5 en 5 porque he querido
								// podría haber escogido otro criterio.
								if ( Math.abs(j) < 2 && Math.abs(i) <= 2) {
									if (riesgoMundo[x][y] < 35.0)
										riesgoMundo[x][y] = 35.0;
								}
								else if ( Math.abs(j) < 3 && Math.abs(i) < 3){
									if (riesgoMundo[x][y] < 30.0)
										riesgoMundo[x][y] = 30.0;
								}
								else if (Math.abs(j) < 4 && Math.abs(i) < 4){
									if (riesgoMundo[x][y] < 25.0) {
										riesgoMundo[x][y] = 25.0;
									}
								}
								// Le asigno 20 porque es mayor que 17 que es el que le asigno
								// a las casillas más alejadas del escorpión, podría haberle asignado
								// cualquier otro mientras sea mayor que 17 y menor que los anteriores.
								else if ( Math.abs(j) < 5 && Math.abs(i) < 5){
									if (riesgoMundo[x][y] < 20.0)
										riesgoMundo[x][y] = 20.0;
								}
								else {
									// 17 es 1 más que el máximo riesgo generado por los muros
									if (riesgoMundo[x][y] < 17.0)
										riesgoMundo[x][y] = 17.0;
								}
							}
						}
					}
				}
				// A la casilla en la que está el enemigo le doy un valor infinito de riesgo
				riesgoMundo[(int)posNPC.x][(int)posNPC.y] = Double.MAX_VALUE;
			}
		}
		Vector2d posAvatar = new Vector2d(calcularPosGrid(stateObs.getAvatarPosition()));
		
		// Si estoy probando los comportamientos reactivos siempre estoy en riesgo
		// por lo que siempre devuelvo true
		if (reactivo)
			return true;
		// Si no estoy en los comportamientos reactivo, estoy en el comportamiento reactivo-deliberativo
		// con lo que estoy en peligro siempre y cuando exceda un límite marcado en 16 porque
		// es el máximo que los muros pueden generar si estoy en una esquina
		else
			return riesgoMundo[(int)posAvatar.x][(int)posAvatar.y] > 16;
	}
	
	// Este método devuelve la mejor acción de manera reactiva teniendo en cuenta el riesgo
	// es decir devuelve la acción que menos riesgo provoca.
	private Types.ACTIONS calcularAccionReactiva(StateObservation stateObs){
		// Inicializamos la acción a no hacer nada por si algo pudiera pasar
		// y porque si estamos en el centro en los niveles 3 y 4 y el escorpion está lejos del centro
		// ningun otro nodo mejorará al centro.
		Types.ACTIONS accion = Types.ACTIONS.ACTION_NIL;
		
		// Sacamos la posicion del avatar.
		Node posAvatar = new Node(calcularPosGrid(stateObs.getAvatarPosition()));
		posAvatar.orientation = traducirOrientacion(stateObs.getAvatarOrientation());
		
		// Miramos el riesgo actual
		Double riesgoActual = riesgoMundo[(int)posAvatar.position.x][(int)posAvatar.position.y];
		
		// Y comprobamos si para cada acción posible disminuye el riesgo, si lo disminuye o lo iguala
		// la acción a realizar será esa y modificamos el riesgoActual al que tendría el avatar
		// si estuviese en esa posición
		if (riesgoMundo[(int)posAvatar.position.x +1][(int)posAvatar.position.y] <= riesgoActual) {
			accion = Types.ACTIONS.ACTION_RIGHT;
			riesgoActual = riesgoMundo[(int)posAvatar.position.x +1][(int)posAvatar.position.y];
		}
		
		if (riesgoMundo[(int)posAvatar.position.x - 1][(int)posAvatar.position.y] <= riesgoActual) {
			accion = Types.ACTIONS.ACTION_LEFT;
			riesgoActual = riesgoMundo[(int)posAvatar.position.x - 1][(int)posAvatar.position.y];
		}
		
		if (riesgoMundo[(int)posAvatar.position.x][(int)posAvatar.position.y -1] <= riesgoActual) {
			accion = Types.ACTIONS.ACTION_UP;
			riesgoActual = riesgoMundo[(int)posAvatar.position.x][(int)posAvatar.position.y -1];
		}
		
		if (riesgoMundo[(int)posAvatar.position.x][(int)posAvatar.position.y + 1] <= riesgoActual) {
			accion = Types.ACTIONS.ACTION_DOWN;
			riesgoActual = riesgoMundo[(int)posAvatar.position.x +1][(int)posAvatar.position.y];
		}
		
		return accion;
	}
	
	// Este método calcula la gema con la mínima distancia manhattan y la devuelve
	private Vector2d calcularMejorGema (StateObservation stateObs,ArrayList<Observation> mejoresGemas) {
		Vector2d mejorGema = null;
		double distanciaMin = 9999;
		double distancia;
		
		// Sacamos la posición del avatar
		Node posAvatar = new Node (stateObs.getAvatarPosition());
		
		// Para cada gema calculamos su distancia manhattan al avatar
		// y si mejora a la distancia mínima encontrada hasta ahora
		// actualizamos la distancia mínima y la mejorGema a su posición.
		for (Observation gema : mejoresGemas) {
			Node gemaNode = new Node (gema.position);
			distancia = distanciaManhattan(posAvatar,gemaNode);
			
			if (distancia < distanciaMin) {
				distanciaMin = distancia;
				mejorGema = gema.position;
			}
		}
		
		return mejorGema;
	}
}
