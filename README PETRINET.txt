El presente programa forma parte del certamen N°1 de la asignatura Lenguajes de Programación
impartida por el profesor Alonso Inostrosa.

Integrantes:
 - Eugenio Cortés
 - Mauricio De Juan
 - Miguel Yañez

El programa permite la creación de una red de Petri y simula su comportamiento, para ello
se debe instanciar las entidades pertenecientes a la red con los siguientes comandos, varios
de estos presentan dos formas alternativas de instanciación.

 - Crear un Lugar: 		"P <nombre> <N° de tokens>"
				"PLACE <nombre> <N° de tokens>"

 - Crear una transición:	"T <nombre>
				"TRANSITION <nombre>"

 - Crear un Arco:		"A <nombre> <nombre>"
				"ARC <nombre> <nombre>"

Para disparar la red se utiliza el siguiente comando que también notificará en pantalla
todas las transiciones que se activaron.

 - Disparar la red:		FIRE

Para mostrar el camino más cercano de una red de petri debemos realizar lo siguiente:

- Mostrar camino cercano: FROM <nombre place1> TO <nombre place 2>

Finalmente, para mostrar todas las entidades de la red con sus respectivos estados se utiliza
el siguiente comando:

 - Mostrar red:			SHOW

Los modelos prefabricados que vienen con el código son la exclusión mutua y el fork, ambos reciben un parámetro que
define la cantidad de caminos alternos que estos tienen, se instancian de la siguiente manera:

 - Exclusión Mutua:		EX_MUTUA <N° C.A.>
 - Fork:			FORK <N° C.A.>

Cosas que tomar en consideración:
 - Las redes de Petri no permiten arcos entre entidades del mismo tipo, por lo cual nuestro programa tampoco lo permite.
 - Hasta la fecha no hemos logrado prevenir que el programa se detenga debido a un error de sintaxis.
 - Los comandos deben ser ingresados línea por línea.
 - Los espacios son parte de la sintaxis, por lo que deben ser puestos donde correspondan según los comandos anteriores.
 - Los lugares de arcos tienen valores por defecto de no ser instanciados con un valor, estos son 0 y 1 respectivamente.
 - Los modelos prefabricados vienen con una cantidad de caminos alternos por defecto de no ser instanciados con un valor, estos son 2 caminos alternos.

Compilación y Ejecución:

 - Escribir "make" en la consola estando en el directorio de los archivos
 - Escribir "./petrinet" para iniciar el archivo ejecutable creado

