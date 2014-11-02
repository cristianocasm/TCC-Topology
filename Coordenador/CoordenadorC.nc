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

  void sendMSG(){
      if (call AMSend.send(AM_FFD_ADDR,
          &pkt, sizeof(NetworkMsg)) == SUCCESS) {
        busy = TRUE;
      }
  }

  event void Boot.booted() {
    printf("(NODE %u) : Inicializando Coordenador ...\n", TOS_NODE_ID);
    printfflush();
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
    switch(counter % 2){
      case 0: // GET TEMPERATURE
        if (!busy) {
          NetworkMsg* btrpkt =
            (NetworkMsg*)(call Packet.getPayload(&pkt, sizeof(NetworkMsg)));

          if (btrpkt == NULL) { return; }

          btrpkt->node_id = TOS_NODE_ID;
          btrpkt->message_type = 0;
          btrpkt->param = 0;
          // btrpkt->value = ;
          // btrpkt->device_id = ;

          printf("(NODE %u) : Enviando GET_TEMPERATURE.\n", TOS_NODE_ID);
          printfflush();
          sendMSG();

        }
        break;
      case 1: // GET LIGHTNESS
        if (!busy) {
          NetworkMsg* btrpkt =
            (NetworkMsg*)(call Packet.getPayload(&pkt, sizeof(NetworkMsg)));

          if (btrpkt == NULL) { return; }

          btrpkt->node_id = TOS_NODE_ID;
          btrpkt->message_type = 0;
          btrpkt->param = 1;
          // btrpkt->value = ;
          // btrpkt->device_id = ;

          printf("(NODE %u) : Enviando GET_LIGHTNESS.\n", TOS_NODE_ID);
          printfflush();
          sendMSG();

        }
        break;
      case 2: // SET TEMPERATURE
        break;
      case 3: // SET LIGHTNESS
        break;
      case 4: // TURN AIR CONDITIONER ON
        break;
      case 5: // TURN AIR CONDITIONER OFF
        break;
    }

    counter++;

  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) { busy = FALSE; }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(NetworkMsg)) {
      NetworkMsg* btrpkt = (NetworkMsg*)payload;
      printf("(NODE %u) : What a great news!!! We've just received a message from the node %u.\n", TOS_NODE_ID, btrpkt->node_id);
      printfflush();
    }
    return msg;
  }
}
