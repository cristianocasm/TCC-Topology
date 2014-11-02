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

  void sendBroadcast(){
    if (call AMSend.send(AM_BROADCAST_ADDR,
          &pkt, sizeof(NetworkMsg)) == SUCCESS) {
      busy = TRUE;
      }
  }

  void deal_with_get_msg(int param, int node_id){
    if(param == 0){
      printf("(NODE %u) : Mensagem GET_TEMPERATURE recebida de %u.\n", TOS_NODE_ID, node_id);

      if (!busy) {
          NetworkMsg* btrpkt =
            (NetworkMsg*)(call Packet.getPayload(&pkt, sizeof(NetworkMsg)));

          if (btrpkt == NULL) { return; }

          btrpkt->node_id = TOS_NODE_ID;
          btrpkt->message_type = 0;
          btrpkt->param = 0;

          printf("(NODE %u) : Enviando GET_TEMPERATURE em BROADCAST.\n", TOS_NODE_ID);
          sendBroadcast();

        }

    }else if(param == 1){
      printf("(NODE %u) : Mensagem GET_LIGHTNESS recebida de %u.\n", TOS_NODE_ID, node_id);

      if (!busy) {
          NetworkMsg* btrpkt =
            (NetworkMsg*)(call Packet.getPayload(&pkt, sizeof(NetworkMsg)));

          if (btrpkt == NULL) { return; }

          btrpkt->node_id = TOS_NODE_ID;
          btrpkt->message_type = 0;
          btrpkt->param = 1;

          printf("(NODE %u) : Enviando GET_LIGHTNESS em BROADCAST.\n", TOS_NODE_ID);
          sendBroadcast();

        }

    }else{
      printf("(NODE %u) : Mensagem GET recebida  recebida de %u com PARAM inválido.\n", TOS_NODE_ID, node_id);
    }

    printfflush();
  }

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
          deal_with_get_msg(btrpkt->param, btrpkt->node_id);
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
