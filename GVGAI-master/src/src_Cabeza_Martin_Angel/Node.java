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

    public double totalCost;
    public double estimatedCost;
    public Node parent;
    public Vector2d position;
    public Vector2d comingFrom;
    public int id;
    public int orientation = -1;
    public Types.ACTIONS accion;  

    public Node(Vector2d pos)
    {
        estimatedCost = 0.0f;
        totalCost = 1.0f;
        parent = null;
        position = pos;
        id = ((int)(position.x) * 100 + (int)(position.y));
    }
    
    public Node(Node otro) {
    	totalCost = otro.totalCost;
    	estimatedCost = otro.estimatedCost;
    	parent = null;
    	position = new Vector2d(otro.position);
    	//comingFrom = new Vector2d(otro.comingFrom);
    	id = ((int)(position.x) * 100 + (int)(position.y));
    	orientation = otro.orientation;
    	accion = otro.accion;
    }

    @Override
    public int compareTo(Node n) {
        if(this.estimatedCost + this.totalCost < n.estimatedCost + n.totalCost)
            return -1;
        if(this.estimatedCost + this.totalCost > n.estimatedCost + n.totalCost)
            return 1;
        return 0;
    }

    @Override
    public boolean equals(Object o)
    {
        return this.position.equals(((Node)o).position);
    }


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
