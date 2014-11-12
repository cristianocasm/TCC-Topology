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

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){

    if (len == sizeof(NetworkMsg)) {
      NetworkMsg* btrpkt = (NetworkMsg*)payload;

      switch(btrpkt->message_type){
        case SET:

          if(btrpkt->service == TEMP)
            printf("(FFD %u) : Mensagem SET_TEMPERATURE recebida de %u.\n",
                    TOS_NODE_ID,
                    btrpkt->sender);
          else if(btrpkt->service == LIGHT)
            printf("(FFD %u) : Mensagem SET_LIGHT recebida de %u.\n",
                    TOS_NODE_ID,
                    btrpkt->sender);
          else if(btrpkt->service == VOL)
            printf("(FFD %u) : Mensagem SET_VOL recebida de %u.\n",
                    TOS_NODE_ID,
                    btrpkt->sender);
          else if(btrpkt->service == CHAN)
            printf("(FFD %u) : Mensagem SET_CHAN recebida de %u.\n",
              TOS_NODE_ID,
              btrpkt->sender);

          break;
        case TURN:

          if(btrpkt->device_id == AIR){

            if(btrpkt->param == ON)
              printf("(FFD %u) : Mensagem TURN_AIR_ON recebida de %u.\n",
                      TOS_NODE_ID,
                      btrpkt->sender);
            else if(btrpkt->param == OFF)
              printf("(FFD %u) : Mensagem TURN_AIR_OFF recebida de %u.\n",
                      TOS_NODE_ID,
                      btrpkt->sender);

          }else if(btrpkt->device_id == TV){

            if(btrpkt->param == ON)
              printf("(FFD %u) : Mensagem TURN_TV_ON recebida de %u.\n",
                      TOS_NODE_ID,
                      btrpkt->sender);
            else if(btrpkt->param == OFF)
              printf("(FFD %u) : Mensagem TURN_TV_OFF recebida de %u.\n",
                      TOS_NODE_ID,
                      btrpkt->sender);

          }

          break;
      }
      printfflush();
    }
    return msg;
  }

  // Implementação dos eventos das interfaces utilizadas
  event void AMControl.startDone(error_t err) {
    if (err != SUCCESS) { call AMControl.start(); }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) { busy = FALSE; }
  }

}
