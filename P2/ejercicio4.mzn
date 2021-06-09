include "globals.mzn";

% Defino cada día con un valor numérico
int : LUNES = 1;
int : MARTES = 2;
int : MIERCOLES = 3;
int : JUEVES = 4;
int : VIERNES = 5;
int : SABADO = 6;
int : DOMINGO = 0;

%Este array lo uso para pasar de la codificación interna en la que asigno a los días números a la codificación externa de días en letra (Lunes, Martes...)
array [1..7] of string: diasSemana = ["Lunes","Martes","Miercoles","Jueves","Viernes","Sabado","Domingo"];

% En este array guardaré los nombres de la personas
array [1..7] of string : personas = ["Juan","Maria","Carmen","Francisco","Marta","Olga","Pepe"];

% En este array voy a guardar la codficación de los días HOY,AYER,MAÑANA
array[0..2] of var 0..6: dias;

% En esta variable guardaré el índice de la persona que ha dicho la verdad
var int : persona;

% Vamos a ir plasmando todas las restricciones

% Primera restricción es que todos los días tienen que ser diferentes
constraint alldifferent(dias);

% Segunda restricción es que ayer tiene que ser un día menos que hoy
constraint dias[0] == (dias[1] - 1);

% Tercera restricción es que mañana tiene que ser un día mas que hoy
constraint dias[2] == ((dias[1] + 1) mod 7);

% En este bloque tan aparatoso lo que he hecho es plasmar las hipótesis de todas las personas y voy asumiendo que sólo una es cierta y las conecto mediante una XOR, esta función lógica devolverá false si hay dos personas o más que dicen la verdad y true si sólo una dice la verdad y entonces tendremos nuestra solución
constraint ( 
% Asumimos que Juan dice la verdad
(dias[0] == LUNES /\ dias[1] == MARTES /\ dias[2] == MIERCOLES) /\
not (dias[0] == DOMINGO /\ dias[1] == LUNES /\ dias[2] == MARTES) /\
not (dias[0] == MARTES /\ dias[1] == MIERCOLES /\ dias[2] == JUEVES) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not ((dias [0] == MIERCOLES /\ dias[1] == JUEVES /\ dias[2] == VIERNES) \/ (dias[0] == JUEVES /\ dias[1] == VIERNES /\ dias[2] == SABADO)) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not (dias[1] != DOMINGO) xor

%Asumimos que María dice la verdad
not (dias[0] == LUNES /\ dias[1] == MARTES /\ dias[2] == MIERCOLES) /\
(dias[0] == DOMINGO /\ dias[1] == LUNES /\ dias[2] == MARTES) /\
not (dias[0] == MARTES /\ dias[1] == MIERCOLES /\ dias[2] == JUEVES) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not ((dias [0] == MIERCOLES /\ dias[1] == JUEVES /\ dias[2] == VIERNES) \/ (dias[0] == JUEVES /\ dias[1] == VIERNES /\ dias[2] == SABADO)) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not (dias[1] != DOMINGO) xor

% Asumimos que Carmen dice la verdad
not(dias[0] == LUNES /\ dias[1] == MARTES /\ dias[2] == MIERCOLES) /\
not(dias[0] == DOMINGO /\ dias[1] == LUNES /\ dias[2] == MARTES) /\
(dias[0] == MARTES /\ dias[1] == MIERCOLES /\ dias[2] == JUEVES) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not ((dias [0] == MIERCOLES /\ dias[1] == JUEVES /\ dias[2] == VIERNES) \/ (dias[0] == JUEVES /\ dias[1] == VIERNES /\ dias[2] == SABADO)) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not (dias[1] != DOMINGO) xor

% Asumimos que Francisco dice la verdad
not (dias[0] == LUNES /\ dias[1] == MARTES /\ dias[2] == MIERCOLES) /\
not (dias[0] == DOMINGO /\ dias[1] == LUNES /\ dias[2] == MARTES) /\
not (dias[0] == MARTES /\ dias[1] == MIERCOLES /\ dias[2] == JUEVES) /\
(dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not ((dias [0] == MIERCOLES /\ dias[1] == JUEVES /\ dias[2] == VIERNES) \/ (dias[0] == JUEVES /\ dias[1] == VIERNES /\ dias[2] == SABADO)) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not (dias[1] != DOMINGO) xor

% Asumimos que Marta dice la verdad
not (dias[0] == LUNES /\ dias[1] == MARTES /\ dias[2] == MIERCOLES) /\
not (dias[0] == DOMINGO /\ dias[1] == LUNES /\ dias[2] == MARTES) /\
not (dias[0] == MARTES /\ dias[1] == MIERCOLES /\ dias[2] == JUEVES) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
((dias [0] == MIERCOLES /\ dias[1] == JUEVES /\ dias[2] == VIERNES) \/ (dias[0] == JUEVES /\ dias[1] == VIERNES /\ dias[2] == SABADO)) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not (dias[1] != DOMINGO) xor

% Asumimos que Olga dice la verdad
not(dias[0] == LUNES /\ dias[1] == MARTES /\ dias[2] == MIERCOLES) /\
not (dias[0] == DOMINGO /\ dias[1] == LUNES /\ dias[2] == MARTES) /\
not (dias[0] == MARTES /\ dias[1] == MIERCOLES /\ dias[2] == JUEVES) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not ((dias [0] == MIERCOLES /\ dias[1] == JUEVES /\ dias[2] == VIERNES) \/ (dias[0] == JUEVES /\ dias[1] == VIERNES /\ dias[2] == SABADO)) /\
(dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not (dias[1] != DOMINGO) xor

% Asumimos que Pepe dice la verdad
not (dias[0] == LUNES /\ dias[1] == MARTES /\ dias[2] == MIERCOLES) /\
not (dias[0] == DOMINGO /\ dias[1] == LUNES /\ dias[2] == MARTES) /\
not (dias[0] == MARTES /\ dias[1] == MIERCOLES /\ dias[2] == JUEVES) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
not ((dias [0] == MIERCOLES /\ dias[1] == JUEVES /\ dias[2] == VIERNES) \/ (dias[0] == JUEVES /\ dias[1] == VIERNES /\ dias[2] == SABADO)) /\
not (dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES) /\
(dias[1] != DOMINGO));

% Con esta instrucción simplemente compruebo quién dijo la verdad y le asigno un índice correspondiente a su nombre en el vector de nombres que hemos definido arriba
persona = (if dias[0] == LUNES /\ dias[1] == MARTES /\ dias[2] == MIERCOLES then 1 elseif dias[0] == DOMINGO /\ dias[1] == LUNES /\ dias[2] == MARTES then 2 elseif dias[0] == MARTES /\ dias[1] == MIERCOLES /\ dias[2] == JUEVES then 3 elseif dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES then 4 elseif (dias [0] == MIERCOLES /\ dias[1] == JUEVES /\ dias[2] == VIERNES) \/ (dias[0] == JUEVES /\ dias[1] == VIERNES /\ dias[2] == SABADO) then 5 elseif dias[0] == SABADO /\ dias[1] == DOMINGO /\ dias[2] == LUNES then 6 else 7 endif);

output["Hoy: \(diasSemana[fix(dias[1])])\n"];
output["Emisor: \(personas[fix(persona)])\n"];

solve satisfy;