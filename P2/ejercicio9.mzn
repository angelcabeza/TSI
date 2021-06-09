% PREDICADOS DADOS EN EL ENUNCIADO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcular la distancia entre dos pacientes.
%
predicate distancia(array[int] of int: a, array[int] of var int: v, var int: d)=
 
       d = sum(i in index_set(a))(
               (a[i]-v[i])*(a[i]-v[i])
           )
      /\ d>= 0
;

% Recuperar el indice del menor valor de un array (i.e. argmin)
%
predicate indice_minimo(var int: mi, array[int] of var int: x) =
  exists(i in index_set(x))  (
    x[i] = min(x)
    /\
    mi = i
  )
;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sets que nos sirven como variables de las longitudes de los distintos arrays y matrices que vamos a usar
set of int: FILS = 1..20;
set of int: COLS = 1..4;

% Array donde guardo el diagnostico de cada paciente. El 1 = COVID, 2 = GRIPE, 3 = ALERGIAS
array[FILS] of int: diagnostico = [1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3];

% Este array lo usaré para pasar de la codificación de números enteros a un string con el diagnóstico
array[1..3] of string : diagnosticoString = ["COVID","GRIPE","ALERGIAS"];

% Matriz con todos los síntomas de los 20 pacientes 
array [FILS,COLS] of int: pacientes = [|0,0,1,1
       | 1, 1, 1, 0
       | 1, 1, 0, 1
       | 1, 0, 0 ,1 
       | 1, 1, 0, 1
       | 0, 1, 1, 1
       | 1, 0, 0, 0
       | 1, 1, 0, 0
       | 0, 1, 0, 0
       | 0, 0, 1, 1
       | 1, 0, 0, 1
       | 1, 0, 0 ,1
       | 0, 1, 1, 0
       | 1, 1, 0, 0
       | 1, 0, 1, 0
       | 1, 0, 0, 0
       | 1, 0, 0, 1
       | 0, 1, 1, 0
       | 0, 0, 1, 0
       | 1, 0, 1, 0 |];
   
  
% Este es el paciente nuevo que queremos examinar     
array[COLS] of int : pacienteNuevo = [0,1,1,1];
% En este array almacenaré la distancia entre el los distintos pacientes con el nuevo paciente
array[FILS] of var int: distPacientes;
% En esta variable almacenaré el índice con la mínima distanncia
var int : indiceDistMin;

% RESTRICCIONES

% Rellenamos el array de distancias utilizando el predicado dado en el enunciado. Cogemos la primera fila dee la matriz, calculamos su distancia con el paciente nuevo y la almacenamos en la posicion 1 del array de distnacias y así sucesivamente.
constraint forall(i in FILS)( distancia(pacienteNuevo,[pacientes[i,j] | j in COLS],distPacientes[i]));

% En indiceDistMin almacenamos la distancia minima entre todas las distancias que tenemos en el array.
constraint (indice_minimo(indiceDistMin,distPacientes));

% Imprimimos la solución
output["La distancia entre el Paciente \(i) y el nuevo paciente es de: \(distPacientes[i]) \n" | i in 1..13];
output["El paciente más parecido con el nuevo paciente es: Paciente \(indiceDistMin)\n"];
output["Su posible diagnóstico es: \(diagnosticoString[fix(diagnostico[indiceDistMin])])"];

solve satisfy;