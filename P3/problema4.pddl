(define (problem ejercicio_4) (:domain ejercicio_4)
(:objects 
    ;mapa 3x4, estas son todas las casillas
    loc1_1 loc1_2 loc1_3 loc1_4 loc2_1 loc2_2 loc2_3 loc2_4 loc3_1 loc3_2 loc3_3 loc3_4 - localizacion
    ;Hay un centro de mando, un barracon, un extractor, tres unidad VCE, 2 marines, un segador y dos recursos de mineral y uno de gas
    centroMando extractor1 barracones1 - edificio
    vce1 vce2 vce3  marine1 marine2 segador1 - unidad
    mineral1 mineral2 gas1 - recurso
)

(:init
    ;Conexiones de las localizaciones tal y como indica el grafo de la práctica. Así definimos los caminos del mundo.
    (HayCaminoEntre loc1_1, loc1_2)
    (HayCaminoEntre loc1_1, loc2_1)
    (HayCaminoEntre loc2_1, loc1_1)
    (HayCaminoEntre loc2_1, loc3_1)
    (HayCaminoEntre loc3_1, loc3_2)
    (HayCaminoEntre loc3_1, loc2_1)
    (HayCaminoEntre loc1_2, loc1_1)
    (HayCaminoEntre loc1_2, loc2_2)
    (HayCaminoEntre loc2_2, loc1_2)
    (HayCaminoEntre loc2_2, loc3_2)
    (HayCaminoEntre loc2_2, loc2_3)
    (HayCaminoEntre loc3_2, loc2_2)
    (HayCaminoEntre loc3_2, loc3_1)
    (HayCaminoEntre loc1_3, loc1_4)
    (HayCaminoEntre loc1_3, loc2_3)
    (HayCaminoEntre loc2_3, loc2_2)
    (HayCaminoEntre loc2_3, loc1_3)
    (HayCaminoEntre loc3_3, loc3_4)
    (HayCaminoEntre loc1_4, loc1_3)
    (HayCaminoEntre loc1_4, loc2_4)
    (HayCaminoEntre loc2_4, loc1_4)
    (HayCaminoEntre loc2_4, loc3_4)
    (HayCaminoEntre loc3_4, loc2_4)
    (HayCaminoEntre loc3_4, loc3_3)

    ;Ponemos las entidades en la localización a la que pertenecen
    (EstaEntidadEn centroMando, loc1_1)
    (EstaEntidadEn vce1, loc1_1)
    (EdificioConstruido centroMando, loc1_1)

    ;Asignamos los tipos de cada cosa
    ; Decimos que los vce declarados son una unidad de tipo VCE
    (EsTipoUnidad vce1 VCE)
    (EsTipoUnidad vce2 VCE)
    (EsTipoUnidad vce3 VCE)

    ; Decimos que los marines declarados son una unidad de tipo Marines
    (EsTipoUnidad marine1 Marines)
    (EsTipoUnidad marine2 Marines)

    ; Decimos que los segadores declarados son una unidad de tipo Segador
    (EsTipoUnidad segador1 Segadores)

    ; Decimos que el edificio centroMando declarado es de tipo CentroDeMando
    (EsTipoEdificio centroMando CentroDeMando)

    ; Decimos que el edificio extractor1 declarado es de tipo Extractor
    (EsTipoEdificio extractor1 Extractor)

    ; Decimos que el eedificio barracones1 declarado es de tipo Barracones
    (EsTipoEdificio barracones1 Barracones)

    ; Decimos que los minerales declarados son de tipo Mineral
    (EsTipoRecurso mineral1 Mineral)
    (EsTipoRecurso mineral2 Mineral)

    ; Decimos que el gas declarado es de tipo Gas
    (EsTipoRecurso gas1 Gas)

    ; Indicamos que el recurso que necesita el Extractor es Mineral
    ; que los barracones y los segadores necesitan mineral y gas
    ; y que los vces necesitan mineral
    (RecursoConstruirEdificio Extractor Mineral)
    (RecursoConstruirEdificio Barracones Mineral)
    (RecursoConstruirEdificio Barracones Gas)
    (RecursoConstruirUnidad Marines Mineral)
    (RecursoConstruirUnidad Segadores Mineral)
    (RecursoConstruirUnidad Segadores Gas)
    (RecursoConstruirUnidad VCE Mineral)

    ; Al principio todos los VCE están libres
    (libre vce1)

    ;Ponemos los dos minerales en la localización que les corresponde
    (AsignarRecursoLocalizacion mineral1 loc2_3)
    (AsignarRecursoLocalizacion mineral2 loc3_3)
    (AsignarRecursoLocalizacion gas1 loc1_3)

)

(:goal (and
            ; Nuestro objetivo es tener un marine en la casilla 3x1
            ; tener otro marine en la 2x4
            ; un segador en la 1x2
            ; y he supuesto que se mantiene el objetivo de que el barracon hay que construirlo
            ; en la localización 3x2 del ejercicio anterior
            (EstaEntidadEn marine1 loc3_1)
            (EstaEntidadEn marine2 loc2_4)
            (EstaEntidadEn segador1 loc1_2)
            (EdificioConstruido barracones1, loc3_2)
        )
)
)
