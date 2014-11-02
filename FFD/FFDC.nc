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
    printf("(NODE %u) : Inicializando FFD ...\n", TOS_NODE_ID);
    printfflush();
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err != SUCCESS) { call AMControl.start(); }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(NetworkMsg)) {
      NetworkMsg* btrpkt = (NetworkMsg*)payload;

      switch(btrpkt->message_type){
        case 0:
          printf("(NODE %u) : Mensagem GET recebida de %u.\n", TOS_NODE_ID, btrpkt->node_id);
          printfflush();
          break;
        case 1:
          printf("(NODE %u) : Mensagem SET recebida de %u.\n", TOS_NODE_ID, btrpkt->node_id);
          printfflush();
          break;
      }
    }
    return msg;
  }
}
