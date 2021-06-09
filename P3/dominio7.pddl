(define (domain ejercicio_7)

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
    Marines - tipoUnidad
    Segadores - tipoUnidad

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

    ; Con este predicado asigno a una unidad un tipo de unidad
    ; también uso este predicado para comprobar que una unidad es de un tipoUnidad concreto
    (EsTipoUnidad ?obj - unidad ?tu - tipoUnidad)

    ; Con este predicado asigno a una edificio un tipo de edificio
    ; también uso este predicado para comprobar que una edificio es de un tipoEdificio concreto
    (EsTipoEdificio ?e1 - edificio ?te - tipoEdificio)

    ; Con este predicado asigno a un recurso un tipo de recurso
    ; también uso este predicado para comprobar que una recurso es de un tipoRecurso concreto
    (EsTipoRecurso ?r1 - recurso ?tr - tipoRecurso)

    ; Este predicado sirve para decir que una unidad está libre (no está recogiendo recursos)
    ; también sirve para comprobar si la unidad está libre o no
    (libre ?obj - unidad)

    ; Con este predicado indico el recurso que necesita un edificio para que lo pueda construir
    (RecursoConstruirEdificio ?e1 - tipoEdificio ?tre - tipoRecurso)

    ; Con este predicado indico que se esta extrayendo un tipo de recurso concreto
    (estaextrayendotiporecurso ?tr - tipoRecurso)

    ; Con este predicado indico que el recurso que necesita unidad para que pueda ser reclutada
    (RecursoConstruirUnidad ?tu - tipoUnidad ?tr - tipoRecurso)
)
(:functions

    ; Con esta función almaceno el número de recursos
    ; que requiere una entidad  
    (necesitaRecurso ?x - entidad ?r - recurso)

    ; Con esta función almacenamos el número de recurso de un tipo concreto que hemos recolectado
    (almacenRecurso ?tr - tipoRecurso)

    ; Con esta función almacenamos el máximo número de recursos que podemos recolectar de cada tipo de recurso
    (maxRecurso ?tr - tipoRecurso)

    ; Con esta función almacenamos las unidades que están extrayendo un tipo de recurso cncreto
    (unidadesExtrayendo ?tr - tipoRecurso)

    ; Con esta función llevaremos un contador del tiempo
    (contadorTiempo)
)

(:action navegar
    ; Recibe la unidad que queremos mover, la localización inicial de la unidad y donde queremos moverla
    :parameters (?obj - unidad ?l1 ?l2 - localizacion)
    :precondition (and

                        ; Compruebo que la unidad que queremos mover esté libre
                        (libre ?obj)

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

                    ; Aumento el tiempo según lo que tarda cada unidad
                    ; en moverse una casilla
                    ; VCE = 10
                    ; MARINES = 5
                    ; SEGADORES = 1
                    (when (esTipoUnidad ?obj VCE) 
                        (increase
                            (contadorTiempo)
                            10
                        )
                    )

                    (when (esTipoUnidad ?obj Marines) 
                        (increase
                            (contadorTiempo)
                            5
                        )
                    )

                    (when (esTipoUnidad ?obj Segadores) 
                        (increase
                            (contadorTiempo)
                            1
                        )
                    )

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

                        (libre ?obj)


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
                        ; En estos dos whens compruebo que tipo de recurso
                        ; es el que he asignado y digo que estoy extrayendo
                        ; ese tipo de recurso. He necesitado hacer esto porque
                        ; al tener un tipo recurso y tipoRecurso, no podía saber
                        ; si estaba extrayendo un tipo de recurso o no y esta 
                        ; información la necesito en la acción construir
                        ; además ahora incrementamos en 1 nuestro contador de unidades
                        ; que están extrayendo ese tipo de recurso
                        (when   (EsTipoRecurso ?r Gas)
                            (and 
                                (estaExtrayendoTipoRecurso Gas)

                                (increase 
                                    (unidadesExtrayendo Gas)
                                    1
                                )
                            )
                        )
                        (when   (EsTipoRecurso ?r Mineral)  
                            (and 
                                (estaExtrayendoTipoRecurso Mineral)

                                (increase 
                                    (unidadesExtrayendo Mineral)
                                    1
                                )
                            )
                        )

                        ; Cuando completemos la acción la unidad estará extrayendo el recurso.
                        (estaExtrayendoRecurso ?r)

                        ; Y por tanto la unidad estará ocupada extrayeendo el recurso
                        (not (libre ?obj))

    )
)


(:action construir
    :parameters (?obj - unidad ?e1 - edificio ?loc - localizacion ?te - tipoEdificio)
    :precondition (and

                        ; Si la unidad está libre
                        (libre ?obj)
                        
                        ; Y en la localización que pasamos como parámetro
                        (EstaEntidadEn ?obj ?loc)

                        ; y ademas no existe ningún edificio construido en 
                        ; esta localización
                        (not (exists (?e - edificio)
                            (EdificioConstruido ?e, ?loc)
                        ))

                        ; y este edificio no está construido en ningún otro lado
                        (not (exists (?l - localizacion)
                            (EdificioConstruido ?e1, ?l)
                        ))

                        ; Comprobamos que el tipo de edificio que pasamos como parámetro
                        ; coincide con el edificio que queremos construir
                        (EsTipoEdificio ?e1 ?te)

                        ; Para cada tipo de recurso
                        ; comprobamos que nuestras existencias de ese recurso son mayores o iguales
                        ; que las que necesita el edificio
                        (forall (?r - tipoRecurso)        
                            (>=
                                (almacenRecurso ?r)
                                (necesitaRecurso ?te ?r)    
                            )
                        )
                )
    :effect (and 

                ; Cuando construyamos el edificio, estará en la localización pasada como parámetro
                (EdificioConstruido ?e1, ?loc)
                (EstaEntidadEn ?e1 ?loc)


                ; Y quitamos de nuestros almacenes el gas y mineral gastados para construir el edificio
                (decrease 
                    (almacenRecurso Gas)
                    (necesitaRecurso ?te Gas)
                )

                (decrease 
                    (almacenRecurso Mineral)
                    (necesitaRecurso ?te Mineral)
                )

                ; Y si hemos construido un barracon o un extractor aumentamos el tiemp
                ; a lo que corresponda
                ; BARRACONES = 46
                ; EXTRACTOR = 21
                (when (esTipoEdificio ?e1 Barracones)
                    (increase 
                        (contadorTiempo)
                        46
                    )
                )

                (when (esTipoEdificio ?e1 Extractor)
                    (increase 
                        (contadorTiempo)
                        21
                    )
                )

            )
)

(:action reclutar
    :parameters (?e - edificio ?obj - unidad ?loc - localizacion ?tu - tipoUnidad)
    :precondition (and

                        ; Comprobamos que la unidad que queremos reclutar tiene el mismo tipo
                        ; que el que le pasamos como parámetro
                        (EsTipoUnidad ?obj ?tu)

                        ; Comprobamos que no está la unidad ya reclutada
                        (not (exists (?l1 - localizacion)
                                (and
                                    (EstaEntidadEn ?obj ?l1)
                                )
                          )
                        )

                        ; Y comprobamos si nuestras existencias de Mineral y Gas son
                        ; mayores iguales que la que necesita la unidad para ser reclutada
                        (>= 
                            (almacenRecurso Mineral)
                            (necesitaRecurso ?tu Mineral)
                        )

                        (>= 
                            (almacenRecurso Gas)
                            (necesitaRecurso ?tu Gas)
                        )

                        ; Comprobamos que el edificio está construido en la localización que se dice
                        (EdificioConstruido ?e, ?loc)

                        ; Y comprobamos que si estamos reclutando un VCE el edificio que tenemos en la misma casilla
                        ; es un CentroDeMando
                        ; OR
                        ; es un barracon
                        (or
                            (and
                                (EsTipoUnidad ?obj VCE)
                                (EsTipoEdificio ?e CentroDeMando)                            
                            )

                            (EsTipoEdificio ?e Barracones)

                        )
                )
    :effect (and

                ; Cuando todas las condiciones se dan, la unidad que reclutemos estará libre
                (libre ?obj)

                ; Y estará colocada en la localización en la que la hemos reclutado
                (EstaEntidadEn ?obj ?loc)

                ; Y quitamos de nuestros almacenes el gas y mineral gastados para reclutar la unidad
                (decrease 
                    (almacenRecurso Mineral)
                    (necesitaRecurso ?tu Mineral)
                )

                (decrease 
                    (almacenRecurso Gas)
                    (necesitaRecurso ?tu Gas)
                )

                ; Aumentamos el contador de tiempo según el tiempo que tarde cada unidad en reclutarse
                ; VCE = 12
                ; MARINES = 18
                ; SEGADORES = 32
                (when (esTipoUnidad ?obj VCE)
                    (increase 
                        (contadorTiempo)
                        12
                    )
                )

                (when (esTipoUnidad ?obj Marines)
                    (increase 
                        (contadorTiempo)
                        18
                    )
                )

                (when (esTipoUnidad ?obj Segadores)
                    (increase
                        (contadorTiempo)
                        32
                    )
                )              
    )
)

(:action recolectar
    :parameters (?tr - tipoRecurso ?loc - localizacion)
    :precondition (and 
                        ; Si estoy extrayendo el recurso que quereemos recolectar
                        (estaExtrayendoTipoRecurso ?tr)

                        ; Y tengo espacio en el almacen
                        (< 
                            (almacenRecurso ?tr)
                            (maxRecurso ?tr)
                        )
    )
    :effect (and 
                ; Aumento el número de existencias del recurso en 10 unidades por cada unidad extrayendo ese recurso
                (increase
                    (almacenRecurso ?tr)
                    (*
                        10
                        (unidadesExtrayendo ?tr)
                    )
                )

                ; Aumento el contador de tiempo en 10 porque es lo que se tarda en recolectar
                (increase 
                    (contadorTiempo)
                    10
                )
    )
)
)