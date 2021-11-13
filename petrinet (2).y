%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>

void yyerror(char *s);
void parse_string(char* in);
void create_ex_mutua(int alt);
int pt_path(char * from_place_name, char * to_place_name);
int tp_path(char * from_transition_name, char * to_place_name, char * from_place_name);

//Definimos el objeto para los lugares
typedef struct{
  char name[100];
  int value;
  int activated_already;
}PLACE;
//Definimos el objeto para las transiciones
typedef struct{
  char name[100];
  int canfire;
}TRANSITION;
//Definimos el objeto para los arcos que van desde un lugar a una transicion
typedef struct{
  int value;
  PLACE *from;
  TRANSITION *to;
  int buscado;
}PTARC;
//Definimos el objeto para los arcos que van desde una transicion a un lugar
typedef struct{
  int value;
  TRANSITION *from;
  PLACE *to;
  int buscado;
}TPARC;

// Por que definimos dos objetos diferentes para los arcos?
// Simplemente para falicitarnos la tarea de recorrer todos
// los arcos en un FOR sin tener que estar filtrando entre
// un tipo u otro.



// Llevamos el contero de las entidades por cada tipo
// para no tener que medir el tamaño de los arreglos
// por cada FOR
int nPlaces = 0;
int nTransitions = 0;
int nPtarcs = 0;
int nTparcs = 0;

// Definimos los arreglos en donde se almacenarán los objetos...
// no creo que necesite más de 100
PLACE places[100];
TRANSITION transitions[100];
PTARC ptarcs[100];
TPARC tparcs[100];

// Función para crear un PLACE (lugar), value es el numero de tokens y
// activated_already se utiliza para saber si una transición ya le
// quitó un token para que las demas no lo hagan
void addPlace(char* n, int v){
  strcpy(places[nPlaces].name, n);
  places[nPlaces].value = v;
  places[nPlaces].activated_already = 0;
  nPlaces++;
}
// Función para crear una TRANSITION (transición), canfire determina
// si la transición se puede disparar, esto para no disparla sin evaluar
// las demás transiciones
void addTransition(char* n){
  strcpy(transitions[nTransitions].name, n);
  transitions[nTransitions].canfire = 0;
  nTransitions++;
}

// Esta función determina si el usuario quiere crear un arco desde un lugar a una
// transición (TPA) o un arco desde una transición a un lugar (TPA) y asi
// asignarlo a su debido objeto. Tambien verifica que las entidades existan y
// que no haga un arco desde entidades del mismo tipo.
int checkARC(char* from, char* to){
  int fromPlace = 0;
  int toPlace = 0;
  int fromTransition = 0;
  int toTransition = 0;
  for(int i = 0; i < nPlaces; i++){
    if (!strcmp(places[i].name, from)){
      fromPlace++;
    }
    if (!strcmp(places[i].name, to)){
      toPlace++;
    }
  }
  for(int i = 0; i < nTransitions; i++){
    if (!strcmp(transitions[i].name, from)){
      fromTransition++;
    }
    if (!strcmp(transitions[i].name, to)){
      toTransition++;
    }
  }
  if (fromPlace == 1 && toTransition == 1){
    return 0;
  }
  if (fromTransition == 1 && toPlace == 1){
    return 1;
  }
  return -1;
}
// Función para crear los arcos (ARCS), se le asignará al objeto dependiendo
// del resultado de la función anterior
void addArc(char* from, char* to, int v){
  switch (checkARC(from, to)){
  case 0:
    for(int i = 0; i < nPlaces; i++){
      if (!strcmp(places[i].name, from)) ptarcs[nPtarcs].from = &places[i];
    }
    for(int i = 0; i < nTransitions; i++){
      if (!strcmp(transitions[i].name, to)) ptarcs[nPtarcs].to = &transitions[i];
    }
    ptarcs[nPtarcs].value = v;
    ptarcs[nPtarcs].buscado = 0;
    nPtarcs++;
    break;
  case 1:
    for(int i = 0; i < nTransitions; i++){
      if (!strcmp(transitions[i].name, from)) tparcs[nTparcs].from = &transitions[i];
    }
    for(int i = 0; i < nPlaces; i++){
      if (!strcmp(places[i].name, to)) tparcs[nTparcs].to = &places[i];
    }
    tparcs[nTparcs].value = v;
    ptarcs[nTparcs].buscado = 0;
    nTparcs++;
    break;
  case -1:
    break;
  default:
    break;
  }
}

// Verifica que las transiciones se puedan disparar...
int canFire(TRANSITION t){
  int canfire = 1;
  for (int j = 0; j < nPtarcs; j++){
    if(!strcmp(ptarcs[j].to->name, t.name)){
      if(ptarcs[j].value != ptarcs[j].from->value){
        canfire = 0;
      }
    }
  }
  return canfire;
}

// Función de dispara una transición en expecifico, quita el token
// que la activó y lo mueve al lugar de destino, solo si otra transición
// no lo ha hecho antes, en ese caso el token se duplica como en el caso de
// Exclusión mutua
void fireTransition(TRANSITION t){
  //Se quita un token de los places que activaron la transition
  for (int i = 0; i < nPtarcs; i++){
    if(!strcmp(ptarcs[i].to->name, t.name)){
      if (ptarcs[i].from->activated_already == 0){
        ptarcs[i].from->value--;
        ptarcs[i].from->activated_already = 1;
      }
    }
  }
  //Se agrega un token a los places a los que apunta la transition
  for (int i = 0; i < nTparcs; i++){
    if(!strcmp(tparcs[i].from->name, t.name)){
      if (tparcs[i].to->activated_already == 0){
        tparcs[i].to->value++;
        tparcs[i].to->activated_already = 1;
      }
    }
  }
  
}
// Función principal que se encarga de disparar todas las transiciones que se
// puedan disparar, primero determina que transiciones se pueden activar y
// luego las dispara. Tambien se resetea la entidad activated_already de los
// lugares.
void fireNET(){
  for(int i = 0; i < nTransitions; i++){
    if (canFire(transitions[i])){
      transitions[i].canfire = 1;
    }
  }
  for(int i = 0; i < nTransitions; i++){
    if (transitions[i].canfire == 1){
      fireTransition(transitions[i]);
      transitions[i].canfire = 0;
      printf("transición %s se activó\n", transitions[i].name);
    }
  }
  //Para devolver todos los places a su estado normal
  for (int i = 0; i < nPlaces; i++){
    places[i].activated_already = 0;
  }
}

void showPlaces(){
  for(int i = 0; i < nPlaces; i++){
    printf("PLACE %d\n", i);
    printf("	name: %s\n", places[i].name);
    printf("	tokens: %d\n", places[i].value);
  }
}
void showTransitions(){
  for(int i = 0; i < nTransitions; i++){
    printf("TRANSITION %d\n", i);
    printf("	name: %s\n", transitions[i].name);
  }
}
// Función para mostrar todas las entidades en la pantalla
void showArcs(){
  for(int i = 0; i < nPtarcs; i++){
    printf("ARC (P->T) %d\n", i);
    printf("	from: %s\n", ptarcs[i].from->name);
    printf("	to: %s\n", ptarcs[i].to->name);
    printf("	value: %d\n", ptarcs[i].value);
  }
  for(int i = 0; i < nTparcs; i++){
    printf("ARC (T->P) %d\n", i);
    printf("	from: %s\n", tparcs[i].from->name);
    printf("	to: %s\n", tparcs[i].to->name);
    printf("	value: %d\n", tparcs[i].value);
  }
}
// Función para mostrar una bienvenida y algunos comandos utiles al usuario
void welcome(){
  printf("#############################################################\n");
  printf("	Bienvenido al simulador de Redes de Petri\n");
  printf("#############################################################\n");
  printf("Comandos:\n");
  printf("- Crear Lugar -> 'PLACE nombre tokens' o 'P nombre tokens' (default 0)\n");
  printf("- Crear Transición -> 'TRANSITION nombre' o 'T nombre'\n");
  printf("- Crear Arco -> 'ARC nombre nombre valor' o 'A nombre nombre valor' (default 1)\n");
  printf("- Disparar Red -> FIRE\n");
  printf("- Mostrar entidades de la Red -> SHOW\n");
  printf("#############################################################\n");
  printf("Modelos prefabricados:\n");
  printf("- EX_MUTUA (n de caminos alternos, default: 2)\n");
  printf("- FORK (n de caminos alternos, default: 2)\n");
printf("#############################################################\n\n");
}
void showAll(){
  printf("#############################################################\n\n");
  showPlaces();
  showTransitions();
  showArcs();
  printf("\n#############################################################\n");
}

// Estas dos funciones solo crean nombres para las entidades de los modelos
// pre-armados, ejemplo: el usuario necesita 10 PLACES, entonces se crearian
// los lugares con los nombres p0, p1, p2, p3 ... , p10.
char* t_str(int a){
  char *buf = malloc(sizeof(char) * 100); 
  snprintf(buf, 100, "EM_T%d", a);
  return buf;
}
char* p_str(int a){
  char *buf = malloc(sizeof(char) * 100); 
  snprintf(buf, 100, "EM_P%d", a);
  return buf;
}
char* t_str_fork(int a){
  char *buf = malloc(sizeof(char) * 100); 
  snprintf(buf, 100, "FK_T%d", a);
  return buf;
}
char* p_str_fork(int a){
  char *buf = malloc(sizeof(char) * 100); 
  snprintf(buf, 100, "FK_P%d", a);
  return buf;
}

// Función para crear el modelo de exclusión mutua con una cantidad
// N de caminos alternos... Lo creamos con las funciones directamente y
// no con el lector de strings de Bison porque por alguna extraña y aun
// desconocida razón esta arrojaba syntax error antes de crear el modelo
// lo que hacia que el programa se detuviera despues de crearlo.

void create_ex_mutua(int alt){
  if (alt < 1) alt = 2;
  int left_t = 1;
  int mid_p = 2;
  int right_t = 2;
  addPlace("EM_P0",1);
  addPlace("EM_P1",0);
  addTransition("EM_T0");
  addArc("EM_P1", "EM_T0", 1);
  addArc("EM_T0", "EM_P0", 1);
  for(int i = 0; i < alt; i++){
    addTransition(t_str(left_t));
    addArc(p_str(0), t_str(left_t), 1);
    addPlace(p_str(mid_p),0);
    addArc(t_str(left_t), p_str(mid_p), 1);
    addTransition(t_str(right_t));
    addArc(p_str(mid_p), t_str(right_t), 1);
    addArc(t_str(right_t), p_str(1), 1);
    left_t+=2;
    mid_p++;
    right_t+=2;
  }
}
// Función para crear el modelo Fork el cual recibe como parametro la
// cantidad de caminos alternos, por default serán 2
void create_fork(int alt){
  if (alt < 1) alt = 2;
  int begin_places = 1;
  addPlace("FK_P0",1);
  addTransition("FK_T0");
  addArc("FK_P0", "FK_T0", 1);
  for(int i = 0; i < alt; i++){
    addPlace(p_str_fork(begin_places),0);
    addArc("FK_T0", p_str_fork(begin_places), 1);
    begin_places++;
  }
}
//Busqueda de caminos de un lugar a otro

int FOUND = 0;

int tp_path(char * from_transition_name, char * to_place_name, char * from_place_name){
  for(int i = 0; i < nTparcs; i++){
    if (!strcmp(tparcs[i].from->name, from_transition_name) && tparcs[i].buscado == 0){
      tparcs[i].buscado = 1;
      if (!strcmp(tparcs[i].to->name, from_place_name)){
        return 0;
      }
      pt_path(tparcs[i].to->name, to_place_name);
    }
  }
  return 0;
}

int pt_path(char * from_place_name, char * to_place_name){
  if (!strcmp(from_place_name, to_place_name)){
    printf("camino encontrado\n");
    FOUND = 1;
    return 1;
  }
  for(int i = 0; i < nPtarcs; i++){
    if (!strcmp(ptarcs[i].from->name, from_place_name) && ptarcs[i].buscado == 0){
      ptarcs[i].buscado = 1;
      tp_path(ptarcs[i].to->name, to_place_name, from_place_name);
    }
  }
  return 0;
}

void reset_arcs(){
  for(int i = 0; i < nPtarcs; i++){ ptarcs[i].buscado = 0;}
  for(int i = 0; i < nTparcs; i++){ tparcs[i].buscado = 0;}
  if (!FOUND) { printf("camino no encontrado\n"); }
  FOUND = 0;
}

int yylex();

%}

%union {
  char *n;
  int v;
}

%token place spc transition arc fire EX_MUTUA SHOW FORK FROM TO
%token <v> NUMERO
%token <n> name
%token FINLINEA



%%

input	:
	| input linea
	;
linea	: FINLINEA
	| exp linea
	;
exp:  	place spc name { addPlace($3,0); }
	| place { printf("Dede asignar un nombre a su place"); }
	| name { printf("Debe indicar a que entidad se le esta asignando el nombre"); }
	| place spc name spc NUMERO { addPlace($3,$5); }
	| transition spc name { addTransition($3); }
	| arc spc name spc name { addArc($3, $5, 1); }
	| arc spc name spc name spc NUMERO{ addArc($3, $5, $7); }
	| fire { fireNET(); }
	| EX_MUTUA { create_ex_mutua(2); }
	| EX_MUTUA spc NUMERO { create_ex_mutua($3); }
	| FORK { create_fork(2); }
	| FORK spc NUMERO { create_fork($3); }
	| SHOW {showAll();}
	| FROM spc name spc TO spc name {pt_path($3, $7); reset_arcs();}
	;

%%

void yyerror(char *s){
  printf("%s", s);
}


int main(int argc, char **argv){
	welcome();
	yyparse();
	showAll();

}
