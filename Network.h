// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef NETWORK_H
#define NETWORK_H

enum {
  AM_NETWORK = 6,
  TIMER_PERIOD_MILLI = 5000,

  //message_type
  GET = 0,
  SET = 1,
  TAKE = 2,
  TURN = 3,

  //service
  TEMP = 0,
  LIGHT = 1,
  VOL = 2,
  CHAN = 3,

  //param
  OFF = 0,
  ON = 1,

  //node_id
  COORD = 1,
  FFD = 2,
  SENSOR = 6,

  //device_id
  T_SENSOR = 0,
  L_SENSOR = 1,
  AIR = 2,
  LAMP = 3,
  TV = 4,
  B_RAY = 5,
  SOUND = 6,
  H_THEAT = 7,

  NIL = -1
};

// O prefixo nx_ é específico da linguagem nesC e significa
// que a estrutura e uint16_t são tipos externos. Tipos externos
// possuem a mesma representação em todas as plataformas. Mais
// especificamente, um tipo externo _nx tem representação big
// endian. Estruturas externas _nxle tem representação little
// endian.
typedef nx_struct NetworkMsg {
  nx_uint8_t sender;
  nx_uint8_t message_type;
  nx_uint8_t param;
  nx_uint16_t service;
  nx_uint8_t device_id;
  nx_uint8_t node_id; // [0, 255] ~> 256 nós distintos
} NetworkMsg;

#endif

// Definição necessária para evitar warning durante a compilação
#ifndef NEW_PRINTF_SEMANTICS
#define NEW_PRINTF_SEMANTICS
#endif
