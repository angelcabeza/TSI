(define (domain ejercicio_2)

(:requirements :strips :fluents :adl)

(:types

    ; Defino nuestros tipos básicos entidad (es una cosa), localización (un cuadrado del mundo) y recurso (un recurso) 
    entidad localizacion recurso - object

    ; Defino los tipos de entidades, hay dos una unidad (un bicho que hace cosas dentro del juego) y un edificio
    unidad - entidad
    edificio - entidad

    ; Por último defino los tipos de unidades, de edificios y de recursos
    tipoEdificio - edificio
    tipoUnidad - unidad
    tipoRecurso - recurso
)

(:constants 

    ; VCE es un tipo de Unidad
    VCE - tipoUnidad

    ;Estos son los dos edificios que nos podemos encontrar
    CentroDeMando - tipoEdificio
    Barracones - tipoEdificio
    Extractor - tipoEdificio

    ; Estos son los dos tipos de recursos que nos podemos encontrar
    Mineral - tipoRecurso
    Gas - tipoRecurso
)

(:predicates

    ; Con este predicado miro si una entidad está en una localización concreta
    ; le paso la entidad y la localización que queremos comprobar
    (EstaEntidadEn ?obj - entidad ?x - localizacion)

    ; Con este predicado miro si hay un posible camino entre dos localizaciones
    ; le paso las dos localizaciones (el inicio y el final del camino)
    (HayCaminoEntre ?l1 - localizacion ?l2 - localizacion)

    ; Con este predicado miro si un edificio está construido
    ; Le paso el edificio que queremos mirar y la localización de la construcción
    (EdificioConstruido ?e - edificio, ?l1 - localizacion)

    ; Con este predicado le asigno a una localización un recurso
    ; Le paso el recurso que quiera asignar y su localización
    (AsignarRecursoLocalizacion ?r1 - recurso ?x - localizacion)

    ; Con este predicado miro si un VCE está extrayendo un recurso
    ; le paso el VCE y el recurso que queremos comprobar que está extrayendo
    (estaExtrayendoRecurso ?r - recurso)

    ; Con estos predicados vemos el tipo de unidad de edificio y de recurso
    (EsTipoUnidad ?obj - unidad ?tu - tipoUnidad)
    (EsTipoEdificio ?e1 - edificio ?te - tipoEdificio)
    (EsTipoRecurso ?r1 - recurso ?tr - tipoRecurso)

    ; Este predicado sirve para ver qué vces están ocupadas y cuales no
    (libre ?obj - unidad)

    ; COn este predicado indicamos que recurso necesitas para construir un edificio
    (RecursoConstruirEdificio ?e1 - tipoEdificio ?tre - tipoRecurso)
)

(:action navegar
    ; Recibe la unidad que queremos mover, la localización inicial de la unidad y donde queremos moverla
    :parameters (?obj - unidad ?l1 ?l2 - localizacion)
    :precondition (and
                        ; La primera precondición es que la entidad se encuentre en
                        ; la localización inicial 
                        (EstaEntidadEn ?obj ?l1)

                        ; La segunda precondición es que exista un camino entre la 
                        ; localización inicial y la localización final
                        (HayCaminoEntre ?l1 ?l2)
    )
    :effect (and 

                    ; Cuando acabemos la acción, la entidad estará en la posición final
                    (EstaEntidadEn ?obj ?l2)

                    ; Y por tanto no estará en la posición inicial
                    (not (EstaEntidadEn ?obj ?l1))
    )
)

(:action asignar

    ; Recibe la unidad que queremos asignar, la localización del recurso y el recurso que le queremos asignar a la unidad
    :parameters (?obj - unidad ?loc - localizacion ?r - recurso)
    :precondition (and 
                        ; La primera precondición es que la unidad esté en la misma localización
                        ; que el recurso
                        (EstaEntidadEn ?obj ?loc)

                        ; La segunda precondición es que el recurso esté en la localización en la que
                        ; debería esta (la que hemos pasado por parámetro)
                        (AsignarRecursoLocalizacion ?r ?loc)

                        ; Aquí estamos viendo si estamos tratando de coger Gas que haya un
                        ; extractor en la misma casilla que el recurso
                        ; OR
                        ; que estamos tratando de picar mineral y por tanto no necesitamos nada
                        ; si alguna de esas dos es cierta podemso asignar un recurso a un vce
                        (or
                            (and
                                (EsTipoRecurso ?r Gas)

                                (exists (?e1 - edificio)
                                    (and
                                        (EsTipoEdificio ?e1 Extractor)
                                        (EdificioConstruido ?e1 ?loc)
                                    )
                                )

                            )

                            (EsTipoRecurso ?r Mineral)
                        )
    )
    :effect (and 
                        ; Cuando completemos la acción la unidad estará extrayendo el recurso.
                        (estaExtrayendoRecurso ?r)
                        ; Y por tanto no estaŕa libre
                        (not (libre ?obj))
    )
)

(:action construir
    :parameters (?obj - unidad ?e1 - edificio ?loc - localizacion ?r1 - recurso)
    :precondition (and 
                        ; Comprobamos que el VCE que quiere construir está libre
                        (libre ?obj)
                        ; Comprobamos que el VCE está en la localización donde queremos construir el edificio
                        (EstaEntidadEn ?obj ?loc)

                        ; Comprobamos quee existe un recurso y un tipo edificio que cumpla que:
                        ; 1.- el tipo de recurso sea el mismo que el recurso que hemos pasado
                        ; 2.- el tipo de edificio sea el mismo que el que queremos construir
                        ; 3.- estamos extrayendo el recurso que pasamos por argumento
                        ; 4.- Y que ese recurso es el que necesita el edificio para ser construido
                        (exists (?tre - tipoRecurso ?te1 - tipoEdificio)
                            (and
                                (EsTipoRecurso ?r1 ?tre)
                                (EsTipoEdificio ?e1 ?te1)
                                (estaExtrayendoRecurso ?r1)
                                (RecursoConstruirEdificio ?te1 ?tre)
                            )
                        )
    
    )
    :effect (and
                ; Esta acción causa que haya un edificio construido en esa localización
                (EdificioConstruido ?e1, ?loc)
                (EstaEntidadEn ?e1 ?loc)
    )
)

)