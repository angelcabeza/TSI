(define (problem ejercicio_1) (:domain ejercicio_1)
(:objects 
    ;mapa 3x4, estas son todas las casillas
    loc1_1 loc1_2 loc1_3 loc1_4 loc2_1 loc2_2 loc2_3 loc2_4 loc3_1 loc3_2 loc3_3 loc3_4 - localizacion
    ;Hay un centro de mando, una unidad VCE y dos recursos de mineral
    centroMando - edificio
    vce1 - unidad
    mineral1 mineral2 - recurso
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

    ;Asignamos los tipos de cada cosa
    (EsTipoUnidad vce1 VCE)
    (EsTipoEdificio centroMando CentroDeMando)
    (EsTipoRecurso mineral1 Mineral)
    (EsTipoRecurso mineral2 Mineral)

    ;Ponemos los dos minerales en la localización que les corresponde
    (AsignarRecursoLocalizacion mineral1 loc2_3)
    (AsignarRecursoLocalizacion mineral2 loc3_3)

)

(:goal (and
            ;Nuestro objetivo es extraer recursos de tipo mineral
            ; con esta instrucción decimos que nuestro objetivo
            ; es que al menos un recurso de los que hay en el mundo
            ; esté siendo extraido por la unidad vce que tenemos en el mundo 
            (exists (?x - recurso)
                (estaExtrayendoRecurso vce1 ?x)
            )
        )
)
)
