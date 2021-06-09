include "globals.mzn";

% Definimos el número de profesores
set of int : num_profs = 1..4;

% Definimos el número de aulas
set of int : num_aulas = 1..3;

%Definimos las horas disponibles, el array va de 9 a 12, el 9 representa la franja horaria 9:00-10:00, el 10 de 10:00-11:00 y el 12 de 12:00-13:00
set of int : horas = 9..12;

% Este array nos ayudará para codificar la salida, ya que en nuestra representación interna cada casilla de la matriz de asignaciones tiene un número asociado a una asignatura, este array a cada número de la matriz le asigna un string con la asignatura, el grupo y el profesor.
array[1..12] of string: nombreAsignaturasProf = [
"IA-G1 (P1)",
"TSI-G1 (P3)",
"FBD-G1 (P1)",
"IA-G2 (P2)",
"TSI-G2 (P3)",
"FBD-G2 (P1)",
"IA-G3 (P3)",
"TSI-G3 (P4)",
"FBD-G3 (P1)",
"IA-G4 (P4)",
"TSI-G4 (P3)",
"FBD-G4 (P2)"];

% Definimos nuestra representación interna de las asignaturas
int : IA1 = 1;
int : TSI1 = 2;
int : FBD1 = 3;

int : IA2 = 4;
int : TSI2 = 5;
int : FBD2 = 6;

int : IA3 = 7;
int : TSI3 = 8;
int : FBD3 = 9;

int : IA4 = 10;
int : TSI4 = 11;
int : FBD4 = 12;

% Declaramos una matriz donde las filas serán las horas y las columnas las aulas. Cada casilla contendrá un número del 1 al 12 que corresponderá a cada asignatura según nuestra representación interna
array[horas, num_aulas] of var 1..12 : asignaciones;

% RESTRICCIONES:

% Las asignaturas se imparten en periodos de 1h semanal, es decir, no puede aparecer ninguna asignatura 2 veces en la matriz.
constraint alldifferent(asignaciones);

% El profesor 2 solo puede dar clase en el aula 2. Buscamos en la matriz todas las asignaturas que impartee el profesor dos y decimos que el aula = 2
constraint forall(hora in horas)(forall(aula in num_aulas)(if asignaciones[hora,aula] == IA2 \/ asignaciones[hora,aula] == FBD4 then aula == 2 endif));

% El profesor 4 solo puede dar clase en el aula 3. Buscamos en la matriz todas las asignatuas que imparte el profesor 4 y decimo que aula = 3
constraint forall(hora in horas)(forall(aula in num_aulas)(if asignaciones[hora,aula] == IA4 \/ asignaciones[hora,aula] == TSI3 then aula == 3 endif));

% La asignatura de TSI solo puede darse en el aula 2 o 3. Buscamos en la matriz todos los grupos de TSI y decimos que el aula == 2 or aula == 3
constraint forall(hora in horas)(forall(aula in num_aulas)(if (asignaciones[hora,aula] == TSI2 \/ asignaciones[hora,aula] == TSI1 \/ asignaciones[hora,aula] == TSI3 \/ asignaciones[hora,aula] == TSI4) then (aula == 3 \/ aula == 2) endif));

% El grupo 3 de IA debe tener clase de 11 a 12 en el aula 1
constraint asignaciones[11,1] == IA3;

% El grupo 1 de IA debe tener clase a las 9. La primera fila en una de sus columnas debe contener IA1.
constraint asignaciones[9,1] = IA1 \/ asignaciones[9,2] == IA1 \/ asignaciones[9,3] == IA1;

% El profesor 2 solo puede dar clase de 9 a 11. Buscamos las asignaturas que da el profesor 2 en la matriz y le indicamos que la hora tiene que ser o de 9 a 10 o de 11 a 12
constraint forall(hora in horas)(forall(aula in num_aulas)(if asignaciones[hora,aula] == IA2 \/ asignaciones[hora,aula] == FBD4 then hora == 9 \/ hora == 10 endif));


% Las asignaturas FBD1, FBD2  FBD3 e IA1 no pueden aparecer en la misma hora porque las imparte el profesor 1. Buscamos una de estas asignaturas y miramos en sus columnas adyacentes e indicamos que no puede aparecer ninguna de estas asignaturas
constraint forall(hora in horas)(forall (aula in num_aulas)(if asignaciones[hora,aula] == FBD1 \/ asignaciones[hora,aula] == FBD2 \/ asignaciones[hora,aula] == FBD3 \/ asignaciones[hora,aula] == IA1 then forall(k in aula+1..3)(asignaciones[hora,k] != FBD1 /\ asignaciones[hora,k] != FBD2 /\ asignaciones[hora,k] != FBD3 /\ asignaciones[hora,k] != IA1)endif));

% Las asignaturas IA2 y FBD4 no pueden apareecer en la misma hora porque las imparte el profesor 2. Buscamos una de estas asignaturas y miramos en sus columnas adyacentes e indicamos que no puede aparecer ninguna de estas asignaturas
constraint forall(hora in horas)(forall (aula in num_aulas)(if asignaciones[hora,aula] == IA2 \/ asignaciones[hora,aula] == FBD4 then forall(k in aula+1..3)(asignaciones[hora,k] != IA2 /\ asignaciones[hora,k] != FBD4) endif));

% Las asignaturas IA3 TSI1 TSI2 Y TSI4 no puedene aparecer en la misma hora porque las imparte el profesor 3. Buscamos una de estas asignaturas y miramos en sus columnas adyacentes e indicamos que no puede aparecer ninguna de estas asignaturas
constraint forall(hora in horas)(forall (aula in num_aulas)(if asignaciones[hora,aula] == IA3 \/ asignaciones[hora,aula] == TSI1 \/ asignaciones[hora,aula] == TSI2 \/ asignaciones[hora,aula] == TSI4 then forall(k in aula+1..3)(asignaciones[hora,k] != IA3 /\ asignaciones[hora,k] != TSI1 /\ asignaciones[hora,k] != TSI2 /\ asignaciones[hora,k] != TSI4)endif));

% Las asignaturas IA4 Y TSI3 no pueden aparecer en la misma hora porque las imparte el profesro 4. Buscamos una de estas asignaturas y miramos en sus columnas adyacentes e indicamos que no puede aparecer ninguna de estas asignaturas
constraint forall(hora in horas)(forall (aula in num_aulas)(if asignaciones[hora,aula] == IA4 \/ asignaciones[hora,aula] == TSI3 then forall(k in aula+1..3)(asignaciones[hora,k] != IA4 /\ asignaciones[hora,k] != TSI3) endif));

% El grupo 1 no puede tener dos asignaturas a la misma hora. Procedimiento igual que para asegurarnos de que un profesor no da dos asignaturas a la misma hora. Buscamos una asignatura del grupo 1 y nos aseguramos de que en el resto de aulas, en esa fila, no se da otra asignatura del grupo 1.
constraint forall(hora in horas)(forall (aula in num_aulas)(if asignaciones[hora,aula] == IA1 \/ asignaciones[hora,aula] == TSI1 \/ asignaciones[hora,aula] == FBD1 then forall (k in aula+1..3)(forall(j in 1..3)(asignaciones[hora,k] != j)) endif));

% El grupo 2 no puede tener dos asignaturas a la misma hora. Procedimiento igual que para asegurarnos de que un profesor no da dos asignaturas a la misma hora. Buscamos una asignatura del grupo 2 y nos aseguramos de que en el resto de aulas, en esa fila, no se da otra asignatura del grupo 2.
constraint forall(hora in horas)(forall (aula in num_aulas)(if asignaciones[hora,aula] == IA2 \/ asignaciones[hora,aula] == TSI2 \/ asignaciones[hora,aula] == FBD2 then forall (k in aula+1..3)(forall(j in 4..6)(asignaciones[hora,k] != j)) endif));

% El grupo 3 no puede tener dos asignaturas a la misma hora. . Procedimiento igual que para asegurarnos de que un profesor no da dos asignaturas a la misma hora. Buscamos una asignatura del grupo 3 y nos aseguramos de que en el resto de aulas, en esa fila, no se da otra asignatura del grupo 3.
constraint forall(hora in horas)(forall (aula in num_aulas)(if asignaciones[hora,aula] == IA3 \/ asignaciones[hora,aula] == TSI3 \/ asignaciones[hora,aula] == FBD3 then forall (k in aula+1..3)(forall(j in 7..9)(asignaciones[hora,k] != j)) endif));

% El grupo 4 no puede tener dos asignaturas a la misma hora. Procedimiento igual que para asegurarnos de que un profesor no da dos asignaturas a la misma hora. Buscamos una asignatura del grupo 4 y nos aseguramos de que en el resto de aulas, en esa fila, no se da otra asignatura del grupo 4.
constraint forall(hora in horas)(forall (aula in num_aulas)(if asignaciones[hora,aula] == IA4 \/ asignaciones[hora,aula] == TSI4 \/ asignaciones[hora,aula] == FBD4 then forall (k in aula+1..3)(forall(j in 10..12)(asignaciones[hora,k] != j)) endif));


% Representación de la solución, recorremos las columnas de cada fila y vamos enseñando el contenido con el array que asociaba a números un string.
output["\t\t  Aula1\t\t\t   Aula2\t\t\tAula3\n"];
output[" 9  -  10 ->"];
output["\t\([nombreAsignaturasProf[fix(asignaciones[9, i])]])  " |  i in num_aulas];
output["\n10  -  11 ->"];
output["\t\([nombreAsignaturasProf[fix(asignaciones[10, i])]])  " |  i in num_aulas];
output["\n11  -  12 ->"];
output["\t\([nombreAsignaturasProf[fix(asignaciones[11, i])]])  " |  i in num_aulas];
output["\n12  -  13 ->"];
output["\t\([nombreAsignaturasProf[fix(asignaciones[12, i])]])  " |  i in num_aulas];

solve satisfy;