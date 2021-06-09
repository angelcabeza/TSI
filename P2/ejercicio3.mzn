% Definimos un array con el coste de los colores
array [1..5] of int: costeColores = {100,200,300,400,500};

% Defino un array con los colores según su índice (esto para los "cáclulos no nos sirve pero nos servirá para formatear la salida a nuestro gusto
array [1..5] of string: colores = ["Verde", "Naranja", "Rojo", "Azul", "Amarillo"];

% Hacemos lo mismo pero para un array con los países ordenados por orden alfabético
array[1..13] of string: paises = [
"Argentina        ",
"Bolivia          ",
"Brasil           ",
"Chile            ",
"Colombia         ",
"Ecuador          ",
"Guayana Francesa ",
"Guyana           ",
"Paraguay         ",
"Perú             ",
"Surinam          ",
"Uruguay          ",
"Venezuela        "];

% defino el array donde asignaré un color a cada ciudad
% La posición del vector corresponde a la posición de los países, en orden alfabético,
% que estamos usando y el valor que tenga en el array corresponde al color:
% 0 = Verde
% 1 = Naranja
% 2 = Rojo
% 3 = Azul
% 4 = Amarillo
array[0..12] of var 0..4: colorPaises;

% variable que recogerá el coste de hacer el coloreado actual
var int : coste_total;

%Defino las restricciones:

% Nos aseguramos de que ningún país tiene el mismo color que sus vecinos
% El color de Argentina (0) tiene que ser distinto de Bolivia (1), Brasil(2), Chile(3), 
% Paraguay (8) y Uruguay (11)
constraint (colorPaises[0] != colorPaises[1] /\ colorPaises[0] != colorPaises[2] /\ colorPaises[0] != colorPaises[3] /\ colorPaises[0] != colorPaises[8] /\ colorPaises[0] != colorPaises[11]);

% El color de Bolivia (1) tiene que ser distinto de Argentina (0), Brasil (2) , Chile(3), Paraguay (8) y Perú (9)
constraint (colorPaises[1] != colorPaises[0] /\ colorPaises[1] != colorPaises[2] /\ colorPaises[1] != colorPaises[3] /\ colorPaises[1] != colorPaises[8] /\ colorPaises[1] != colorPaises[9]);

% El color de Brasil (2) tiene que ser distinto de Argentina (0), Bolivia (1), Colombia (4), Guayana Francesa (6), Guyana (7), Paraguay(8), Perú (9), Surinam (10), Uruguay(11) y Venezuela (12)
constraint (colorPaises[2] != colorPaises[0] /\ colorPaises[2] != colorPaises[1] /\ colorPaises[2] != colorPaises[4] /\ colorPaises[2] != colorPaises[7] /\ colorPaises[2] != colorPaises[6] /\ colorPaises[2] != colorPaises[8] /\ colorPaises[2] != colorPaises[9] /\ colorPaises[2] != colorPaises[10] /\ colorPaises[2] != colorPaises[11] /\ colorPaises[2] != colorPaises[12]);

% El color de Chile tiene que ser distinto al de Argentina (0), Bolivia (1) y Perú (9)
constraint (colorPaises[3] != colorPaises[0] /\ colorPaises[3] != colorPaises[1] /\ colorPaises[3] != colorPaises[9]);

% El color de Colombia tiene que ser distinto al de Brasil  (2), Ecuador (5), Perú (9) y Venezuela (12)
constraint (colorPaises[4] != colorPaises[2] /\ colorPaises[4] != colorPaises[5] /\ colorPaises[4] != colorPaises[9] /\ colorPaises[4] != colorPaises[12]);

% El color de Ecuador tiene que ser distinto al de Colombia (4) y al de Perú (9)
constraint (colorPaises[5] != colorPaises[4] /\ colorPaises[5] != colorPaises[9]);

% El color de Guayana Francesa tiene que ser distinto al de Brasil (2) y al de Surinam (10)
constraint (colorPaises[6] != colorPaises[2] /\ colorPaises[6] != colorPaises[10]);

% El color de Guyana tiene que ser distinto al de Brasil (2), al de Surinam (10) y al de Venezuela (12)
constraint (colorPaises[7] != colorPaises[2] /\ colorPaises[7] != colorPaises[10] /\ colorPaises[7] != colorPaises[12]);

% El color de Paraguay tiene que ser distinto al de Argentina (0), Bolivia (1), Brasil (2) y Uruguay (11)
constraint(colorPaises[8] != colorPaises[0] /\ colorPaises[8] != colorPaises[1] /\ colorPaises[8] != colorPaises[2] /\ colorPaises[8] != colorPaises[11]);

% El color de Perú tiene que ser distinto al de Bolivia (1), Brasil (2), Chile (3), Colombia (4) y Ecuador (5)
constraint (colorPaises[9] != colorPaises[1] /\ colorPaises[9] != colorPaises[2] /\ colorPaises[9] != colorPaises[4] /\ colorPaises[3] != colorPaises[4] /\ colorPaises[9] != colorPaises[5]);

% El color de Surinam tiene que ser distinto al de Brasil (2), Guayana Francesa (6), y al de Guayana (7)
constraint (colorPaises[10] != colorPaises[2] /\ colorPaises[10] != colorPaises[6] /\ colorPaises[10] != colorPaises[7]);

% El color de Uruguay tiene que ser distinto al de Argentina (0), Brasil (2) y al de Paraguay (8)
constraint (colorPaises[11] != colorPaises[0] /\ colorPaises[11] != colorPaises[2] /\ colorPaises[11] != colorPaises[8]);

% El color de Venezuela tiene que ser distinto al de Brasil (2), Colombia (4) y al de Guyana (7)
constraint (colorPaises[12] != colorPaises[2] /\ colorPaises[12] != colorPaises[4] /\ colorPaises[12] != colorPaises[7]);

% Sumamos el coste total de usar los colores tantas veces como hayamos asignado
coste_total = costeColores[colorPaises[0]] + costeColores[colorPaises[1]] + costeColores[colorPaises[2]] + costeColores[colorPaises[3]] + costeColores[colorPaises[4]] + costeColores[colorPaises[5]] + costeColores[colorPaises[6]] + costeColores[colorPaises[7]] + costeColores[colorPaises[8]] + costeColores[colorPaises[9]] + costeColores[colorPaises[10]] + costeColores[colorPaises[11]] + costeColores[colorPaises[12]];

% Bloque de código para que la salida sea igual que como se pide en el enunciado
output["total: \(coste_total)\n\n"];

output["\(paises[1]): \(colores[fix(colorPaises[0])])\t\(costeColores[colorPaises[0]])\n"];
output["\(paises[2]): \(colores[fix(colorPaises[1])])\t\(costeColores[colorPaises[1]])\n"];
output["\(paises[3]): \(colores[fix(colorPaises[2])])\t\(costeColores[colorPaises[2]])\n"];
output["\(paises[4]): \(colores[fix(colorPaises[3])])\t\(costeColores[colorPaises[3]])\n"];
output["\(paises[5]): \(colores[fix(colorPaises[4])])\t\(costeColores[colorPaises[4]])\n"];
output["\(paises[6]): \(colores[fix(colorPaises[5])])\t\(costeColores[colorPaises[5]])\n"];
output["\(paises[7]): \(colores[fix(colorPaises[6])])\t\(costeColores[colorPaises[6]])\n"];
output["\(paises[8]): \(colores[fix(colorPaises[7])])\t\(costeColores[colorPaises[7]])\n"];
output["\(paises[9]): \(colores[fix(colorPaises[8])])\t\(costeColores[colorPaises[8]])\n"];
output["\(paises[10]): \(colores[fix(colorPaises[9])])\t\(costeColores[colorPaises[9]])\n"];
output["\(paises[11]): \(colores[fix(colorPaises[10])])\t\(costeColores[colorPaises[10]])\n"];
output["\(paises[12]): \(colores[fix(colorPaises[11])])\t\(costeColores[colorPaises[11]])\n"];
output["\(paises[13]): \(colores[fix(colorPaises[12])])\t\(costeColores[colorPaises[12]])\n"];

% Queremos resolvere minimizando el coste de pintar el mapa
solve minimize coste_total;