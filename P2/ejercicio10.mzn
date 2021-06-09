include "globals.mzn";

% número de objetos posibles
set of int : num_objetos = 1..12;

% array con el peso de los objetos
array[num_objetos] of var int : pesos = [50,500,1000,3000,1500,3000,500,1000,2000,500,250,500];

% array con la preferencia de los objetos
array[num_objetos] of var int : preferencias = [100,90,75,95,85,10,5,70,90,20,50,40];

% array con el nombre de los objetos, esto nos servirá para codificar la salida
array[num_objetos] of string : nombreObjetos = [
"Mapa",
"Cuchillo",
"Prismáticos",
"Agua",
"Linterna",
"Cerveza",
"Novela",
"Manual de Supervivencia",
"Plátanos",
"Caramelos",
"Cerillas",
"Espejo"];

% peso máximo
int : MAX_PESO = 5000;

% variable para contar el peso que llevo en la mochila
var int : peso_actual;

% variable para saber qué objetos llevo en la mochila
array[num_objetos] of var bool : seleccionados;

% el peso actual es la suma del peso de todos los objetos que hemso seleccionado
peso_actual = sum(i in num_objetos)(if seleccionados[i] == true then pesos[i] else 0 endif);

% Una restricción es que el peso actual no supere el peso máximo (5kg)
constraint peso_actual <= MAX_PESO;

var int : preferencia;

% La preferencia es la suma de las preferencias de los objetos que hemos seeleccionado
preferencia = sum(i in num_objetos)(if seleccionados[i] == true then preferencias[i] else 0 endif);

output["Objetos  =  "];
output["\(if seleccionados[i] == true then nombreObjetos[i] else "" endif) " | i in num_objetos];
output["\n|   Preferencias   =   \(preferencia)\t |   PesoFinal   =   \(peso_actual)"];

% Resolvemos maximiznado la preferencia
solve maximize preferencia;