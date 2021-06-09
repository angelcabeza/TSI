include "globals.mzn";
include "cumulative.mzn";

% Este set nos servirá para guardar el rango de los distintos arrays que usemos
set of int : tareas = 1..12;

% Este array nos servirá para pasar de la codificación interna de la solución a una más entendible (la que daremos en la salida)
array[tareas] of string: letraTareas = [
"A",
"B",
"C",
"D",
"E",
"F",
"G",
"H",
"I",
"J",
"K",
"L"];

% array donde guardaremos la duración de cada tarea
array[tareas] of var int : duracion = [60,10,5,5,5,2,7,3,7,2,5,1];

% Variable con el tiempo de realizar todas las tareas
var int: coste;

% Variable con el tiempo de cada tarea
array[tareas] of var int : costeTareas;

% vamos a guardar las tareas predecesoras de cada una, como hay algunas que tienen dos tareas predecesoras he usado un array 2d. Cada índice representa una tarea que tiene quee estar hecha para empezar esa tarea, cuando tienen los mismos índices significa que solo necesita esperar a una tarea y cuando tiene dos distintos necesita esperar a dos tareas.
array[tareas, 1..2] of var int : predecesoras = [|0,0 | 1,1 | 2,2 | 3,3 | 4,4 | 4,4 | 4,5 | 3,3 | 5,6 | 5,6 | 9,10 | 11,11|];

% Array para guardar el orden en el que se van ejecutando todas las tareas
array[tareas] of var int : ordenTareas;

% Array de bools para saber que tarea ha finalizado y cual no
array[tareas] of var bool : finalizado;


% RESTRICCIONES

% En esta restricción voy a ir rellenando el vector de tareas finalizadas y el vector con las tareas en orden. Para ello miro las siguientes casuísticas:
% 1 ---> si no tiene predecesoras la meto directamente en el array con el orden de las tareas y la marco como finalizada.
% 2 ---> Si la tarea tiene dos predecesores. Miro si estas dos tareas (las predecesoras) han finalizado y si es así introduzco esta tarea en el array con el orden de tareas y la marco como finalizada
% 3 ---> Si no pasa nada de esto, quiere decir quee la tarea tenia un único predecesor por lo que compruebo si esta tarea predecesora ha acabado y si es así añado la tarea al array con el orden de las tareas y la marco como finalizada.
constraint forall(i in tareas) (if predecesoras[i,1] == 0 /\ predecesoras[i,2] == 0 then ordenTareas[i] == i /\ finalizado[i] == true elseif predecesoras[i,1] != predecesoras[i,2] then if finalizado[predecesoras[i,1]] == true /\ finalizado[predecesoras[i,2]] == true then ordenTareas[i] == i /\ finalizado[i] == true endif else if finalizado[predecesoras[i,1]] == true then ordenTareas[i] == i /\ finalizado[i] == true endif endif);

% Con esta restricción voy a rellenar el tiempo en el que empieza cada tarea. Para ello miro las siguientes posibilidades.
% 1 ----> Si es la tarea inicial su tiempo empieza en 1.
% 2 ----> Si tiene 1 solo predecesor (tanto el predecesor 1 como el 2 son iguales) entonces esta tarea empieza en el tiempo de lo que dure la tarea predecesora + el instante en el que empezo la tarea predecesora.
% 3 ----> Si tiene 2 predecesores esta tarea empieza en el instante en el que empezo la tarea predecesora que tardó mas en realizarse + la duración de esta tarea
% 4 ----> Si no se cumple ninguna de las anteriores el coste de la tarea es 1, en esta posibilidad nunca va a entrar pero minizinc me obligaba a poner un else.
constraint forall(i in 1..12) ((if predecesoras[i,1] == 0 /\ predecesoras[i,2] == 0 then costeTareas[i] == 1 elseif predecesoras[i,1] == predecesoras[i,2] then costeTareas[i] == duracion[predecesoras[i,1]] + costeTareas[predecesoras[i,1]] elseif predecesoras[i,1] != predecesoras[i,2] then costeTareas[i] == max(costeTareas[predecesoras[i,1]],costeTareas[predecesoras[i,2]]) + max(duracion[predecesoras[i,1]],duracion[predecesoras[i,2]]) else costeTareas[i] == 1 endif));

% Esta restricción indica que el coste total de todas las tareas tiene que ser igual al tiempo donde inició la ultima tarea más su duración
constraint coste == costeTareas[12] + duracion[ordenTareas[12]];

% Mostramos el resultado
output["TIEMPO MINIMO = \(coste)\n"];
  output["TAREA \(letraTareas[fix(ordenTareas[i])]) empieza en tiempo \(costeTareas[i])\n" | i in 1..12];

% Resolvemos minimizando el coste final (el de todas las tareas)
solve minimize coste;