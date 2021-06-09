package src_Cabeza_Martin_Angel;

import core.game.StateObservation;
import ontology.Types;
import tools.Direction;
import tools.Vector2d;

import java.lang.reflect.Type;

import ontology.Types;
import tools.Direction;
import tools.Vector2d;

import java.util.ArrayList;


/**
 * Created by dperez on 13/01/16.
 */

// ESTA ES LA CLASE NODE QUE TIENE GVGAI IMPLEMENTADA
// CON LA ÚNICA MODIFICACIÓN DE AÑADIR COMO ATRIBUTO DE LA CLASE
// LA ORIENTACIÓN DEL AGENTE Y LA ACCION QUE HA DE REALIZARSE PARA LLEGAR
// AL NODO
public class Node implements Comparable<Node> {

    public double totalCost;		//  Variable donde almacenaremos el coste total de ir al nodo inicio hasta este nodo (g(n))
    public double estimatedCost;	// Variable donde almacenaremos el coste estimado según DManhattan (h(n))
    public Node parent;				// Variable donde guardaremos el padre del nodo
    public Vector2d position;		// Variable donde guardaremos la posicion del nodo
    public Vector2d comingFrom;		// NO LA HE USADO
    public int id;					// id del nodo
    public int orientation = -1;	// Variable que almacena la orientación del avatar en este nodo
    public Types.ACTIONS accion;  	// Variable que almacena la acción que el avatar ha hecho para llegar a este nodo

    
    // Constructor de Node al que se le pasa una posicion almacenada
    // en un vector2d
    // Ponemos todos los valroes a nulo menos la posicion
    // que la inicializamos a la que nos pasan por parametro
    // id se calcula con la posicion en x * 100 + posicion en y
    public Node(Vector2d pos)
    {
        estimatedCost = 0.0f;
        totalCost = 1.0f;
        parent = null;
        position = pos;
        id = ((int)(position.x) * 100 + (int)(position.y));
    }
    
    // Constructor de Node que inicializa el nodo a los valores de otro nado pasado por argumento
    public Node(Node otro) {
    	totalCost = otro.totalCost;
    	estimatedCost = otro.estimatedCost;
    	parent = null;
    	position = new Vector2d(otro.position);
    	id = ((int)(position.x) * 100 + (int)(position.y));
    	orientation = otro.orientation;
    	accion = otro.accion;
    }

    // Método para comparar nodos según su f (f = g(n) + h(n)), si este es mejor que el que se pasa devuelve -1
    // si es peor 1 y si es igual 0
    @Override
    public int compareTo(Node n) {
        if(this.estimatedCost + this.totalCost < n.estimatedCost + n.totalCost)
            return -1;
        if(this.estimatedCost + this.totalCost > n.estimatedCost + n.totalCost)
            return 1;
        return 0;
    }

    // Método para comparar las posiciones de un nodo.
    // Si están en la misma posicion ambos nodos, devuelve true y si no false
    @Override
    public boolean equals(Object o)
    {
        return this.position.equals(((Node)o).position);
    }

    // ESTE METODO NO LO HE USADO EN TODA LA IMPLEMENTACIÓN POR ESO NO LO VOY A COMENTAR
    public void setMoveDir(Node pre) {

        //TODO: New types of actions imply a change in this method.
        Direction action = Types.DNONE;

        if(pre.position.x < this.position.x)
            action = Types.DRIGHT;
        if(pre.position.x > this.position.x)
            action = Types.DLEFT;

        if(pre.position.y < this.position.y)
            action = Types.DDOWN;
        if(pre.position.y > this.position.y)
            action = Types.DUP;

        this.comingFrom = new Vector2d(action.x(), action.y());
    }
}
