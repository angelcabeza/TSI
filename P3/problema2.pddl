(define (problem ejercicio_2) (:domain ejercicio_2)
(:objects 
    ;mapa 3x4, estas son todas las casillas
    loc1_1 loc1_2 loc1_3 loc1_4 loc2_1 loc2_2 loc2_3 loc2_4 loc3_1 loc3_2 loc3_3 loc3_4 - localizacion
    ;Hay un centro de mando, dos unidades VCE y dos recursos de mineral y uno de gas
    centroMando extractor1 - edificio
    vce1 vce2 - unidad
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
    (EstaEntidadEn vce2, loc1_1)

    ;Asignamos los tipos de cada cosa
    (EsTipoUnidad vce1 VCE)
    (EsTipoUnidad vce2 VCE)
    (EsTipoEdificio centroMando CentroDeMando)
    (EsTipoEdificio extractor1 Extractor)
    (EsTipoRecurso mineral1 Mineral)
    (EsTipoRecurso mineral2 Mineral)
    (EsTipoRecurso gas1 Gas)

    ; Indicamos que el recurso que necesita el Extractor es Mineral
    (RecursoConstruirEdificio Extractor Mineral)

    ; Al principio todos los VCE están libres
    (libre vce1)
    (libre vce2)

    ;Ponemos los dos minerales en la localización que les corresponde
    (AsignarRecursoLocalizacion mineral1 loc2_3)
    (AsignarRecursoLocalizacion mineral2 loc3_3)
    (AsignarRecursoLocalizacion gas1 loc1_3)

)

(:goal (and
            ; Nuestro objetivo esta vez es extraer gas 
            (estaExtrayendoRecurso gas1)

        )
)
)
