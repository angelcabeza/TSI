include "globals.mzn";

% definimos las letras con su valor en el array, es decir, por ejemplo la X será 0 en el array
int : X = 0;
int : T = 1;
int : N = 2;
int : W = 3;
int : Y = 4;
int : I = 5;
int : S = 6;
int : V = 7;
int : E = 8;

% definimos el array donde estaran las letras, esta va a ser nuestra representación interna, un array que guarda números del 0 al 9 y cada número corresponde a una letra de arriba.
array[0..9] of var 0..9: letras;

% definimos las variables para gestionar el acarreo
var int : acarreo; var int : acarreo2; var int : acarreo3; var int : acarreo4; var int : acarreo5;

% usando globals.mzn nos aseguramos que todos los valores de las letras serán disintos
constraint alldifferent(letras);

% aplicamos las operaciones que nos piden, haciendo modulo 10 para que esten
% entre 0..9, y calculamos el accareo para la siguiente operacion
constraint (letras[X] + letras[N] + letras[N]) mod 10 == letras[Y];
acarreo = (letras[X] + letras[N] + letras[N]) div 10;

constraint (letras[I] + letras[E] + letras[E] + acarreo) mod 10 == letras[T];
acarreo2 = (letras[I] + letras[E] + letras[E] + acarreo) div 10;

constraint (letras[S] + letras[V] + letras[V] + acarreo2) mod 10 == letras[N];
acarreo3 = (letras[S] + letras[V] + letras[V] + acarreo2) div 10;


constraint (letras[E] + letras[E] + acarreo3) mod 10 == letras[E];
acarreo4 = (letras[E] + letras[E] + acarreo3) div 10;

constraint (letras[S] + letras[S] + acarreo4) mod 10 == letras[W];
acarreo5 = (letras[S] + letras[S] + acarreo4) div 10;

% K se corresponde al acarreo de la última operacion
constraint letras[T] == acarreo5;

% sacamos por pantalla la solución
output ["\t\t     SIX \t\t    \(letras[S])\(letras[I])\(letras[X])\n"];
output ["\t\t + SEVEN \t\t +\(letras[S])\(letras[E])\(letras[V])\(letras[E])\(letras[N])\n"];
output ["\t\t + SEVEN \t\t +\(letras[S])\(letras[E])\(letras[V])\(letras[E])\(letras[N])\n"];
output ["\t\t======== \t\t ------\n"];
output ["\t\t  TWENTY \t\t \(letras[T])\(letras[W])\(letras[E])\(letras[N])\(letras[T])\(letras[Y])\n"];



solve satisfy;