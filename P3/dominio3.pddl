(define (domain ejercicio_3)

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

    ; Con estos predicados miramos de que tipo es una unidad edificio o recurso
    (EsTipoUnidad ?obj - unidad ?tu - tipoUnidad)
    (EsTipoEdificio ?e1 - edificio ?te - tipoEdificio)
    (EsTipoRecurso ?r1 - recurso ?tr - tipoRecurso)

    ; Con este predicado podemos ver si un VCE está libre o no
    (libre ?obj - unidad)

    ; Con este predicado indicamos que recurso necesita un edificio
    (RecursoConstruirEdificio ?e1 - tipoEdificio ?tre - tipoRecurso)
    
    ; Con este predicado indicamos que estamos extrayendo un tipo de recurso en concreto
    (estaextrayendotiporecurso ?tr - tipoRecurso)
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
                        ; Con este bloque de código comprobamos si estamos
                        ; extrayendo gas o mineral e indicamos lo que estamso extrayendo
                        (when   (EsTipoRecurso ?r Gas)  
                            (estaExtrayendoTipoRecurso Gas)
                        )
                        (when   (EsTipoRecurso ?r Mineral)  
                            (estaExtrayendoTipoRecurso Mineral)
                        )
                        ; Cuando completemos la acción la unidad estará extrayendo el recurso.
                        (estaExtrayendoRecurso ?r)
                        ; Y por tanto no está libre
                        (not (libre ?obj))
    )
)

(:action construir
    :parameters (?obj - unidad ?e1 - edificio ?loc - localizacion )
    :precondition (and 
                        ; Comprobamos que el VCE que quiere construir está libre
                        (libre ?obj)
                        ; Comprobamos que el VCE está en la localización donde queremos construir el edificio
                        (EstaEntidadEn ?obj ?loc)

                        ; Comprobamos que no haya ningún edificio más en
                        ; esta casilla
                        (not (exists (?e - edificio)
                            (EdificioConstruido ?e, ?loc)
                        ))

                        ; Si hay un tipo de edificio
                        (exists (?te - tipoEdificio)
                            (and
                                ; que sea del mismo tipo que el edificio que queremos construir
                                (EsTipoEdificio ?e1 ?te)

                                ; Y que para todos los tipos de recursos cumpla
                                (forall (?r - tipoRecurso)
                                    ; Que el antecedente es falso
                                    ; o que el antecedente y el consecuente sean verdaderos
                                    (imply (RecursoConstruirEdificio ?te ?r) (estaExtrayendoTipoRecurso ?r))
                                )
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