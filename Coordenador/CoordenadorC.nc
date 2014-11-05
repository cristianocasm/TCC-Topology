#include <Timer.h>
#include "printf.h"
#include "../Network.h"

module CoordenadorC {
  uses interface Boot;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
}
implementation {

  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;

  void sendMSG(uint16_t type, uint16_t param, uint16_t value, uint16_t device_id){
    if (!busy) {
          NetworkMsg* btrpkt =
            (NetworkMsg*)(call Packet.getPayload(&pkt, sizeof(NetworkMsg)));

          if (btrpkt == NULL) { return; }

          btrpkt->node_id = TOS_NODE_ID;
          btrpkt->message_type = GET;
          btrpkt->param = TEMP;
          btrpkt->value = value;
          btrpkt->device_id = device_id;

          if (call AMSend.send(device_id,
              &pkt, sizeof(NetworkMsg)) == SUCCESS) {
            busy = TRUE;
          }

        }
  }

  event void Boot.booted() {
    printf("(Coordenador %u) : Inicializando Coordenador ...\n", TOS_NODE_ID);
    printfflush();
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS)
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    else
      call AMControl.start();
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
    switch(counter % 8){
      case 0: // GET TEMPERATURE
        printf("(Coordenador %u) : Enviando GET_TEMPERATURE.\n", TOS_NODE_ID);
        sendMSG(GET, TEMP, NIL, SENSOR);
        break;
      case 1: // GET LIGHTNESS
          printf("(Coordenador %u) : Enviando GET_LIGHTNESS.\n", TOS_NODE_ID);
          sendMSG(GET, LIGHT, NIL, SENSOR);
      case 2: // SET TEMPERATURE
          printf("(Coordenador %u) : Enviando SET_TEMPERATURE.\n", TOS_NODE_ID);
          sendMSG(SET, TEMP, 20, FFD);
        break;
      case 3: // SET LIGHTNESS
          printf("(Coordenador %u) : Enviando SET_LIGHTNESS.\n", TOS_NODE_ID);
          sendMSG(SET, LIGHT, 30, FFD);
        break;
      case 4: // TURN AIR CONDITIONER ON
          printf("(Coordenador %u) : Enviando TURN_AIR_ON.\n", TOS_NODE_ID);
          sendMSG(TURN, AIR, ON, FFD);
        break;
      case 5: // TURN AIR CONDITIONER OFF
          printf("(Coordenador %u) : Enviando TURN_AIR_OFF.\n", TOS_NODE_ID);
          sendMSG(TURN, AIR, OFF, FFD);
        break;
      case 6: // TURN TV ON
          printf("(Coordenador %u) : Enviando TURN_TV_ON.\n", TOS_NODE_ID);
          sendMSG(TURN, TV, ON, FFD);
        break;
      case 7: // TURN TV OFF
          printf("(Coordenador %u) : Enviando TURN_TV_OFF.\n", TOS_NODE_ID);
          sendMSG(TURN, TV, OFF, FFD);
        break;
    }

    printfflush();
    counter++;

  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) { busy = FALSE; }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(NetworkMsg)) {
      NetworkMsg* btrpkt = (NetworkMsg*)payload;
      if(btrpkt->message_type == TAKE){
        if(btrpkt->param == TEMP){
            printf("(Coordenador %u) : Temperatura %u graus.\n", TOS_NODE_ID, btrpkt->value);
        }else if(btrpkt->param == LIGHT){
              printf("(Coordenador %u) : Luminosidade %u lux.\n", TOS_NODE_ID, btrpkt->value);
          }
      }
    }
    return msg;
  }
}
