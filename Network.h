// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef NETWORK_H
#define NETWORK_H

enum {
  // AM_BLINKTORADIO = 6,
  AM_NETWORK = 6,
  TIMER_PERIOD_MILLI = 5000,
  AM_FFD_ADDR = 2
};

// O prefixo nx_ é específico da linguagem nesC e significa
// que a estrutura e uint16_t são tipos externos. Tipos externos
// possuem a mesma representação em todas as plataformas. Mais
// especificamente, um tipo externo _nx tem representação big
// endian. Estruturas externas _nxle tem representação little
// endian.
typedef nx_struct NetworkMsg {
  nx_uint8_t node_id; // [0, 255] ~> 256 nós distintos
  nx_uint8_t message_type;
  nx_uint8_t param;
  nx_uint16_t value;
  nx_uint8_t device_id;
} NetworkMsg;

#endif

// Definição necessária para evitar warning durante a compilação
#ifndef NEW_PRINTF_SEMANTICS
#define NEW_PRINTF_SEMANTICS
#endif