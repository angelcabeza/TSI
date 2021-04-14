package src_Cabeza_Martin_Angel;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;
import tools.com.google.gson.internal.bind.ArrayTypeAdapter;
import tools.Pair;

import java.lang.reflect.Array;
import java.lang.reflect.Type;
import java.util.*;

public class Agent extends AbstractPlayer{

	static final int ID_PORTAL = 5;
	static final int ID_GEMA = 6;
	
	Stack<Types.ACTIONS> plan;
	Vector2d portal;
	Vector2d fescala;
	int gemasConseguidas;
	int gemasAObtener;
	ArrayList<Observation> gemas;
	Stack<Node> caminoGemas;
	boolean puedoAcabar;
	boolean me_he_movido_riesgo;
	boolean reactivo;
	Double[][] riesgoMuros;
	Double[][] riesgoMundo;
	
	
	public Agent(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
		gemasAObtener = 9;
		gemasConseguidas = 0;
		puedoAcabar = false;
		me_he_movido_riesgo = true;
		reactivo = false;
		
		gemas = new ArrayList<>();
		plan = new Stack<>();
		
		// Calculo el factor para transformar las coordenadas pixel en coordenadas del grid
		fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length,
								stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);
		
		//Recupero la lista de posiciones de portales ordenadas por cercanía al avatar
		ArrayList<Observation>[] posiciones = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
		
		
		if (posiciones == null) {
			System.out.println("NO HAY PORTAL");
			portal = null;
			reactivo = true;
		}
		else {
			// Me quedo con el portal más cercano al avatar
			portal = posiciones[0].get(0).position;
			portal = calcularPosGrid(portal);
			
			// Recupero la lista de diamantes ordenados por cercanía al avatar
			ArrayList<Observation>[] mejoresGemas = stateObs.getResourcesPositions(stateObs.getAvatarPosition());
			
			
			if (mejoresGemas != null && mejoresGemas[0].size() >= gemasAObtener) {
				gemas = mejoresGemas[0];
				caminoGemas = new Stack<>();
				puedoAcabar = false;
				
				if (gemas.size() > 9) {
					List<Observation> aux = gemas.subList(0, 9);
					gemas = new ArrayList<>(aux);
				}
				
				calcularCaminoGemas(stateObs,gemasAObtener);
			}
			else {
				reactivo = true;
			}
		}
		
		Vector2d dimensionesMundo = new Vector2d(stateObs.getWorldDimension().width,stateObs.getWorldDimension().height);
		dimensionesMundo = calcularPosGrid(dimensionesMundo);
		
		riesgoMuros = new Double[(int)dimensionesMundo.x][(int)dimensionesMundo.y];
		riesgoMundo = new Double[(int)dimensionesMundo.x][(int)dimensionesMundo.y];
		
		inicializarRiesgoMuros(stateObs);
	}
	
	@Override
	public Types.ACTIONS act (StateObservation stateObs, ElapsedCpuTimer elapsedTimer){

		Types.ACTIONS accion = Types.ACTIONS.ACTION_NIL;
		
		if (reactivo) {
			boolean estoyEnRiesgo = calcularRiesgoMundo(stateObs);
			
			if (estoyEnRiesgo) {
				accion = calcularAccionReactiva(stateObs);
			}
		}
		else {
			if (portal != null) {
				
				if (stateObs.getAvatarResources().get(ID_GEMA) != null) {
					gemasConseguidas = stateObs.getAvatarResources().get(ID_GEMA);
				}
				
				if (gemasConseguidas >= gemasAObtener) {
					puedoAcabar = true;
				}
				
				if (plan.empty() && puedoAcabar) {
					sacarPlanNodo(Astar(stateObs,calcularPosGrid(stateObs.getAvatarPosition()),portal));
					
				}
				else if (plan.empty()){
					//if (!gemas.isEmpty()) {
					
					// Cada vez que he cogido una gema calculo la mejor gema desde la posicion del avatar
					ArrayList<Observation>[] mejoresGemas = stateObs.getResourcesPositions(stateObs.getAvatarPosition());	
					Vector2d mejorGema = mejoresGemas[0].get(0).position;
					
					// Y calculo un plan para ir a esa gema
					sacarPlanNodo(Astar(stateObs,calcularPosGrid(stateObs.getAvatarPosition()),calcularPosGrid(mejorGema)));
					//}
				}
				
				if (!plan.empty() && elapsedTimer.remainingTimeMillis() > 0) {
					accion = plan.peek();
					plan.pop();
				}
			}
		}
 		
		return accion;
	}
	
	private Node Astar (StateObservation stateObs, Vector2d ini, Vector2d dest) {
		Node inicio = new Node(ini);
		inicio.orientation = traducirOrientacion(stateObs.getAvatarOrientation());
		
		Node destino = new Node(dest);
		
		PriorityQueue<Node> abiertos = new PriorityQueue<>();
		PriorityQueue<Node> cerrados = new PriorityQueue<>();
		
		inicio.totalCost = 0;
		
		inicio.estimatedCost = distanciaManhattan(inicio,destino);
		
		abiertos.add(inicio);
		
		Node solucion = null;
		Node mejorAbiertos = inicio;
		
		ArrayList<Types.ACTIONS> acciones = new ArrayList<>();
		acciones.add(Types.ACTIONS.ACTION_DOWN);
		acciones.add(Types.ACTIONS.ACTION_LEFT);
		acciones.add(Types.ACTIONS.ACTION_RIGHT);
		acciones.add(Types.ACTIONS.ACTION_UP);
		
		boolean tengoSolucion = false;
		
		while(!abiertos.isEmpty() && !tengoSolucion) {
			
			// Cogemos el primer elemento de la cola pero no lo sacamos de ella.
			mejorAbiertos = abiertos.poll();
			
			cerrados.add(mejorAbiertos);
			
			destino.orientation = mejorAbiertos.orientation;
			//sonIguales = mejorAbiertos.equals(destino);
			
			if (mejorAbiertos.equals(destino)) {
				tengoSolucion = true;
			}
			
			
			if(!tengoSolucion) {
				
				for (Types.ACTIONS accion : acciones) {
					Node hijo = new Node(mejorAbiertos);
					
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
					
					if (!esObstaculo(stateObs, hijo)) {
						hijo.parent = mejorAbiertos;
						
						hijo.totalCost = mejorAbiertos.totalCost +1;
						hijo.estimatedCost = distanciaManhattan(hijo,destino);
						
						if (hijo.orientation != mejorAbiertos.orientation) {
							hijo.totalCost = hijo.totalCost + 1;
						}
						
						if (!abiertos.contains(hijo) && !cerrados.contains(hijo)) {
							abiertos.add(hijo);
						}
						else {
							if (abiertos.contains(hijo)) {
								ArrayList<Node> abiertosEnArrayList = new ArrayList <Node>(Arrays.asList(abiertos.toArray(new Node[abiertos.size()])));
								Node actualAbiertos = abiertosEnArrayList.get(abiertosEnArrayList.indexOf(hijo));
								
								if (actualAbiertos.totalCost > hijo.totalCost) {
									abiertos.remove(actualAbiertos);
									abiertos.add(hijo);
								}
							}
						}
					}
					
				}
			}
			else {
				solucion = mejorAbiertos;
			}
			
			
		}
		
		if (solucion != null) {
			return solucion;
		}
		else {
			Node mal = new Node(ini);
			mal.totalCost = -1;
			return mal;
		}
	}

	private double distanciaManhattan(Node inicio, Node destino) {
		double distancia;
		
		distancia = Math.abs(inicio.position.x - inicio.position.y) - Math.abs(destino.position.x - destino.position.y);
		
		//distancia = Math.sqrt(distancia);
		
		return distancia;
	}
	
	private boolean esObstaculo(StateObservation stateObs, Node nodo) {
		ArrayList<Observation>[][] grid = stateObs.getObservationGrid();
		
		for (Observation obs : grid[(int)nodo.position.x][(int)nodo.position.y]) {
			if (obs.itype == 0)
				return true;
		}
		
		return false;
	}
	
	private int traducirOrientacion(Vector2d orientacion) {
		
		int orient = -1;
		
		if (orientacion.x == 0) {
			if (orientacion.y == -1)
				orient = 0;
			else
				orient = 2;
		}
		else {
			if (orientacion.x == -1)
				orient = 3;
			else
				orient = 1;
		}
		
		return orient;
	}
	
	private void sacarPlanNodo(Node nodo) {
		plan = new Stack<>();
		
		while (nodo != null) {
			if (nodo.parent != null) {
				plan.push(nodo.accion);
				
				if (nodo.orientation != nodo.parent.orientation)
					plan.push(plan.peek());
			}
			
			nodo = nodo.parent;
		}
	}
	
	private void calcularCaminoGemas(StateObservation stateObs, int numGemas) {
		Double[][] distancias = new Double[gemas.size() + 2 ][gemas.size() + 2];
		
		for (int i = 0; i < gemas.size(); i++) {
			for (int j = i; j < gemas.size(); j++) {
				distancias[i][j] = Astar(stateObs,calcularPosGrid(stateObs.getAvatarPosition()),calcularPosGrid(gemas.get(j).position)).totalCost;
				distancias[j][i] = distancias[i][j];
			}
			
			distancias[i][i] = 0.0;
		}
		
		for (int i = 0; i < gemas.size(); i++) {
			distancias[gemas.size()][i] = Astar(stateObs,calcularPosGrid(gemas.get(i).position),portal).totalCost;
			distancias[i][gemas.size()] = distancias[gemas.size()][i];
			
			distancias[gemas.size()+1][i] = Astar(stateObs, calcularPosGrid(stateObs.getAvatarPosition()), calcularPosGrid(gemas.get(i).position)).totalCost;
			distancias[i][gemas.size()+1] = distancias[gemas.size()+1][i];
		}
		
		distancias[gemas.size()][gemas.size()] = 0.0;
		distancias[gemas.size()+1][gemas.size()+1] = 0.0;
		
		PriorityQueue<Pair<ArrayList<Integer>,Double>> caminos = new PriorityQueue<>();
		
		for (int i = 0; i < gemas.size();i++) {
			ArrayList<Integer> ini = new ArrayList<>();
			ini.add(i);
			caminos.add(new Pair<>(ini, distancias[gemas.size()+1][i]));
		}
		
		boolean mejorEncontrado = false;
		Pair<ArrayList<Integer>, Double> mejor = caminos.peek();
		
		do {
			mejor = caminos.poll();
			
			if (mejor.first.size() >= numGemas ) {
				
				if(mejor.first.size() >= numGemas + 1) {
					mejorEncontrado = true;
				}
				else {
					ArrayList<Integer> nuevoCamino = new ArrayList<>(mejor.first);
					nuevoCamino.add(gemas.size());
					caminos.add(new Pair<>(nuevoCamino,mejor.second + distancias[gemas.size()][nuevoCamino.get(nuevoCamino.size()-2)]));
				}
			}
			else {
				for (int i = 0; i < gemas.size(); i++) {
					if (!mejor.first.contains(i) && distancias[i][mejor.first.get(mejor.first.size()-1)] != -1) {
						ArrayList<Integer> nuevoCamino = new ArrayList<>(mejor.first);
						nuevoCamino.add(i);
						caminos.add(new Pair<>(nuevoCamino,mejor.second + distancias[i][nuevoCamino.get(nuevoCamino.size() - 2)]));
						
					}
				}
			}
		} while(!mejorEncontrado);
		
		caminoGemas = new Stack<>();
		if (mejor != null) {
			mejor.first.remove(mejor.first.size() -1 );
			for (int i = mejor.first.size() -1; i >= 0; i--) {
				Node nuevo = new Node(gemas.get(mejor.first.get(i)).position);
				caminoGemas.add(nuevo);
			}
		}
	}
	
	
	private Vector2d calcularPosGrid (Vector2d posObjeto) {
		Vector2d posicion = new Vector2d(posObjeto.x / fescala.x, posObjeto.y / fescala.y);
		
		//posicion.x = Math.floor(posicion.x);
		//posicion.y = Math.floor(posicion.y);
		
		return posicion;
	}
	
	private void inicializarRiesgoMuros(StateObservation stateObs) {
		
		for (int i = 0; i < riesgoMuros.length; i++) {
			for (int j = 0; j < riesgoMuros[i].length; j++) {
				riesgoMuros[i][j] = 0.0;
			}
		}
		
		ArrayList<Observation>[] objetosInmoviles = stateObs.getImmovablePositions();
		
		if (objetosInmoviles != null) {
			ArrayList<Observation> muros = objetosInmoviles[0];
			
			for (Observation muro : muros) {
				Vector2d posMuro = new Vector2d(calcularPosGrid(muro.position));
				
				for (int i = 2; i >= -2; i--) {
					for(int j = 2; j >= -2; j--) {
						int x = (int)posMuro.x - i;
						int y = (int)posMuro.y - j;
						
						if (0 <= x && x < riesgoMuros.length && 0 <= y && y < riesgoMuros[x].length) {
							
							if (!esObstaculo(stateObs,new Node(new Vector2d(x,y)))) {
								
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
				
				riesgoMuros[(int)posMuro.x][(int)posMuro.y] = Double.MAX_VALUE;
			}
		}
	}
	
	private boolean calcularRiesgoMundo(StateObservation stateObs) {
		
		ArrayList<Observation>[] NPC = stateObs.getNPCPositions();
		
		for (int i = 0; i < riesgoMuros.length;i++) {
			for (int j = 0; j < riesgoMuros[i].length; j++) {
				riesgoMundo[i][j] = riesgoMuros[i][j];
			}
		}
		
		if (NPC != null) {
			ArrayList<Observation> enemigos = NPC[0];
			
			for (Observation enemigo : enemigos) {
				Vector2d posNPC = new Vector2d(calcularPosGrid(enemigo.position));
				
				for (int i = 5; i >= -5; i--) {
					for (int j = 5; j >= -5; j--) {
						int x = (int)posNPC.x + i;
						int y = (int)posNPC.y + j;
						
						if (0 <= x && x < riesgoMundo.length && 0 <= y && y < riesgoMundo[x].length) {
							if (!riesgoMundo[x][y].equals(Double.MAX_VALUE) && !esObstaculo(stateObs, new Node(new Vector2d(x,y)))) {
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
								else if ( Math.abs(j) < 5 && Math.abs(i) < 5){
									if (riesgoMundo[x][y] < 20.0)
										riesgoMundo[x][y] = 20.0;
								}
								else {
									if (riesgoMundo[x][y] < 17.0)
										riesgoMundo[x][y] = 17.0;
								}
							}
						}
					}
				}
				
				riesgoMundo[(int)posNPC.x][(int)posNPC.y] = Double.MAX_VALUE;
			}
		}
		Vector2d posAvatar = new Vector2d(calcularPosGrid(stateObs.getAvatarPosition()));
		
		return riesgoMundo[(int)posAvatar.x][(int)posAvatar.y] > 16.0;
	}
	
	private Types.ACTIONS calcularAccionReactiva(StateObservation stateObs){
		Types.ACTIONS accion = Types.ACTIONS.ACTION_NIL;
		
		Node posAvatar = new Node(calcularPosGrid(stateObs.getAvatarPosition()));
		posAvatar.orientation = traducirOrientacion(stateObs.getAvatarOrientation());
		
		Double riesgoActual = riesgoMundo[(int)posAvatar.position.x][(int)posAvatar.position.y];
		
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
}
