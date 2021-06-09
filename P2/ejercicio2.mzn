% defino las monedas con su valor
% los he definido como enteros porque las comparaciones de floats/doubles dan problemas
% por la coma flotante. En mi representación 2,79 euros = 279.
int : UnCentimo = 1;
int : DosCentimos = 2;
int : CincoCentimos = 5;
int : DiezCentimos = 10;
int : VeinteCentimos = 20;
int : CincuentaCentimos = 50;
int : UnEuro = 100;
int : DosEuros = 200;


% defino el array donde están las monedas cada posición corresponde con una moneda en particular siendo la posicion 0 la moneda de 1 céntimo y la 7 la de dos euros
array[0..7] of var 0..7: monedas;
% variable en la que guardaré las monedas que he usado
var int : total_monedas;

% Genero la restricción de que la suma de los valores de las monedas tiene que ser igual
% a 799 (7,99 euros)
constraint (monedas[0] * UnCentimo + monedas[1] * DosCentimos + monedas[2] * CincoCentimos + monedas[3] * DiezCentimos + monedas[4] * VeinteCentimos + monedas[5] * CincuentaCentimos + monedas[6] * UnEuro + monedas[7] * DosEuros) == 799;

% Actualizo la variable de las monedas usadas
total_monedas = (monedas[0] + monedas[1] + monedas[2] + monedas[3] + monedas[4] + monedas[5] + monedas[6] + monedas[7]);

% Aquí estructuro la salida tal y como viene en el ejercicio 2
output["monedas: \(monedas[0]), \(monedas[1]), \(monedas[2]), \(monedas[3]), \(monedas[4]), \(monedas[5]), \(monedas[6]), \(monedas[7])\n"];
output["total monedas: \(total_monedas)\n"];

% Resuelvo minimizando el número de monedas tal y como pide el ejercicio
solve minimize total_monedas;