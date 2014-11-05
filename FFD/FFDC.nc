#include <Timer.h>
#include "printf.h"
#include "../Network.h"

module FFDC {
  uses interface Boot;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
}
implementation {

  message_t pkt;
  bool busy = FALSE;

  event void Boot.booted() {
    printf("(FFD %u) : Inicializando FFD ...\n", TOS_NODE_ID);
    printfflush();
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err != SUCCESS) { call AMControl.start(); }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) { busy = FALSE; }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){

    if (len == sizeof(NetworkMsg)) {
      NetworkMsg* btrpkt = (NetworkMsg*)payload;

      switch(btrpkt->message_type){
        case SET:
          if(btrpkt-> param == TEMP)
            printf("(FFD %u) : Mensagem SET_TEMPERATURE recebida de %u.\n", TOS_NODE_ID, btrpkt->node_id);
          else if(btrpkt->param == LIGHT)
            printf("(FFD %u) : Mensagem SET_LIGHT recebida de %u.\n", TOS_NODE_ID, btrpkt->node_id);
          break;
        case TURN:
          if(btrpkt->param == AIR){
            if(btrpkt->value == ON){
              printf("(FFD %u) : Mensagem TURN_AIR_ON recebida de %u.\n", TOS_NODE_ID, btrpkt->node_id);
            }else if(btrpkt->value == OFF){
              printf("(FFD %u) : Mensagem TURN_AIR_OFF recebida de %u.\n", TOS_NODE_ID, btrpkt->node_id);
            }
          }else if(btrpkt->param == TV){
            if(btrpkt->value == ON){
              printf("(FFD %u) : Mensagem TURN_TV_ON recebida de %u.\n", TOS_NODE_ID, btrpkt->node_id);
            }else if(btrpkt->value == OFF){
              printf("(FFD %u) : Mensagem TURN_TV_OFF recebida de %u.\n", TOS_NODE_ID, btrpkt->node_id);
            }
          }
          break;
      }
      printfflush();
    }
    return msg;
  }
}
