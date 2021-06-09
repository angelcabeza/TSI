(define (domain ejercicio_5)

(:requirements :strips :fluents :adl)

(:types

    ; Defino nuestros tipos básicos entidad (es una cosa), localización (un cuadrado del mundo) y recurso (un recurso) 
    entidad localizacion recurso - object

    ; Defino los tipos de entidades, hay dos una unidad (un bicho que hace cosas dentro del juego) y un edificio
    unidad - entidad
    edificio - entidad
    investigacion - entidad

    ; Por último defino los tipos de unidades, de edificios y de recursos
    tipoEdificio - edificio
    tipoUnidad - unidad
    tipoRecurso - recurso
    tipoInvestigacion - entidad
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
    BahiaIngenieria - tipoEdificio

    ; Estos son los dos tipos de recursos que nos podemos encontrar
    Mineral - tipoRecurso
    Gas - tipoRecurso

    ImpulsarSegador - tipoInvestigacion
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

    ; Con este predicado decimos que un tipo de investigación necesita un recurso concreto
    (RecursoConstruirInvestigacion ?ti - tipoInvestigacion ?tr - tipoRecurso)

    ; Con este predicado indico que el recurso que necesita unidad para que pueda ser reclutada
    (investigacionCreada ?ti - investigacion)

    ; Con este predicado decimos que una investigación es de cierto tipo de investigación
    (estipoinvestigacion ?t - investigacion ?ti - tipoInvestigacion)
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
                        ; En estos dos whens compruebo que tipo de recurso
                        ; es el que he asignado y digo que estoy extrayendo
                        ; ese tipo de recurso. He necesitado hacer esto porque
                        ; al tener un tipo recurso y tipoRecurso, no podía saber
                        ; si estaba extrayendo un tipo de recurso o no y e
                        (when   (EsTipoRecurso ?r Gas)  
                            (estaExtrayendoTipoRecurso Gas)
                        )
                        (when   (EsTipoRecurso ?r Mineral)  
                            (estaExtrayendoTipoRecurso Mineral)
                        )

                        ; Cuando completemos la acción la unidad estará extrayendo el recurso.
                        (estaExtrayendoRecurso ?r)

                        ; Y por tanto la unidad estará ocupada extrayeendo el recurso
                        (not (libre ?obj))
    )
)

(:action construir
    :parameters (?obj - unidad ?e1 - edificio ?loc - localizacion )
    :precondition (and 
                        ; Compruebo que la unidad que va a construir está libre
                        (libre ?obj)

                        ; Y que está en la localización donde queremos construir el edificio
                        (EstaEntidadEn ?obj ?loc)

                        ; Comprobamos que no hay otro edificio en esta localizacion
                        (not (exists (?e - edificio)
                            (EdificioConstruido ?e, ?loc)
                        ))

                        ; Comprobamos que el edificio no ha sido construido ya
                        (not (exists (?l - localizacion)
                            (EdificioConstruido ?e1, ?l)
                        ))

                        ; Comprobamos que existe un edificio con el tipoEdificio que buscamos
                        (exists (?te - tipoEdificio)
                            (and
                                (EsTipoEdificio ?e1 ?te)

                                (forall (?r - tipoRecurso) 
                                    ; Y que tenemos los recursos necesarios para construirlo
                                    (imply (RecursoConstruirEdificio ?te ?r) (estaExtrayendoTipoRecurso ?r))
                                )
                            )
                        )
                )
    :effect (and 
                ; Una vez se cumplen las condiciones, habrá un edificio construido en esa localización
                (EdificioConstruido ?e1, ?loc)
                (EstaEntidadEn ?e1 ?loc)
            )
)

(:action reclutar
    :parameters (?e - edificio ?obj - unidad ?loc - localizacion)
    :precondition (and

                        ; Comprobamos que no hemos reclutado esa unidad
                        (not (exists (?l1 - localizacion)
                                (and
                                    (EstaEntidadEn ?obj ?l1)
                                )
                             )
                        )

                        ; Comprobamos que existe un tipoUnidad
                        ; que sea igual que nuestra unidad a reclutar
                        (exists (?tu - tipoUnidad)
                            (and
                                (EsTipoUnidad ?obj ?tu)
                                (forall (?r - tipoRecurso)
                                    ; Comprobamos que tenemos los recursos necesarios para reclutar la unidad
                                    (imply (RecursoConstruirUnidad ?tu ?r) (estaExtrayendoTipoRecurso ?r))
                                )

                                ; Comprobamos que si la unidad que queremos reclutar es VCE
                                ; tenemos un edificio en la casilla donde queremos reclutar
                                ; que es un CentroDeMando
                                ; OR
                                ; Si queremos reclutar un Segador comrpboamos que tenemos la investigacion necesaria
                                ; y que tenemos un edificio en la casilla donde queremos reclutar
                                ; que es un barracon
                                ; OR
                                ; Si queremos reclutar un Marine comprobamos que haya un barracon en la localización
                                ; donde queremos reclutar al marine
                                (or
                                    (and
                                        (EsTipoUnidad ?obj VCE)
                                        (EsTipoEdificio ?e CentroDeMando)
                                        (EdificioConstruido ?e, ?loc)
                                    )

                                    (and
                                        (EsTipoUnidad ?obj Segadores)
                                        (exists (?i - investigacion)
                                            (and
                                                (estipoinvestigacion ?i ImpulsarSegador)
                                                (investigacionCreada ?i)
                                            )
                                        )
                                        (EsTipoEdificio ?e Barracones)
                                        (EdificioConstruido ?e, ?loc)
                                    
                                    )
                                    (and
                                        (EsTipoUnidad ?obj Marines)
                                        (EsTipoEdificio ?e Barracones)
                                        (EdificioConstruido ?e, ?loc)
                                    )
                                )
                            )
                        )

    
    
    )
    :effect (and
                ; Cuando se cumplan las precondiciones, la unidad que hemos reclutado
                ; estará en la localización deseada y estará libre
                (libre ?obj)
                (EstaEntidadEn ?obj ?loc)
    )
)

(:action investigar
    :parameters (?e1 - edificio ?i - investigacion)
    :precondition (and 

                        ; Comprobamos que el edificio en el que queremos 
                        ; investigar es la bahia de ingenieria
                        (esTipoEdificio ?e1 BahiaIngenieria)

                        ; Comprobamos que el edificio está construido en algún lado
                        (exists (?loc - localizacion)
                            (EstaEntidadEn ?e1 ?loc)
                        )

                        ; Que la investigación no ha sido creada antes
                        (not (investigacionCreada ?i))

                        ; Comprobamos que existe un tipoInvestigacion que sea igual 
                        ; que la investigacion que queremos y hacer
                        (exists (?ti - tipoInvestigacion)
                            (and
                                (EsTipoInvestigacion ?i ?ti)

                                (forall (?r - tipoRecurso) 
                                    ; y que para la investigación tneemos todos los recursos necesarios
                                    (imply (RecursoConstruirInvestigacion ?ti ?r) (estaExtrayendoTipoRecurso ?r))
                                )
                            )
                        )
    )
    :effect (and 
                ; Cuando se cumpla todo habremos creado la investigacion
                (investigacionCreada ?i)
    )
)


)