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

  nx_uint16_t counter;
  message_t pkt;
  bool busy = FALSE;

  void sendMSG(nx_uint8_t type,
                          nx_uint16_t service,
                          nx_uint8_t param,
                          nx_uint8_t node_id,
                          nx_uint8_t device_id){

    if (!busy) {
          NetworkMsg* btrpkt =
            (NetworkMsg*)(call Packet.getPayload(&pkt, sizeof(NetworkMsg)));

          if (btrpkt == NULL) { return; }

          btrpkt->sender = TOS_NODE_ID;
          btrpkt->message_type = type;
          btrpkt->service = service;
          btrpkt->param = param;
          btrpkt->node_id = node_id;
          btrpkt->device_id = device_id;

          if (call AMSend.send(node_id,
              &pkt, sizeof(NetworkMsg)) == SUCCESS)
            busy = TRUE;

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

    switch(counter % 10){
      case 0: // GET TEMPERATURE
        printf("(Coordenador %u) : Enviando GET_TEMPERATURE para %u.\n", TOS_NODE_ID, SENSOR);
        sendMSG(GET, TEMP, NIL, SENSOR, NIL);
        break;
      case 1: // GET LIGHTNESS
          printf("(Coordenador %u) : Enviando GET_LIGHTNESS para %u.\n", TOS_NODE_ID, SENSOR);
          sendMSG(GET, LIGHT, NIL, SENSOR, NIL);
      case 2: // SET TEMPERATURE
          printf("(Coordenador %u) : Enviando SET_TEMPERATURE para %u.\n", TOS_NODE_ID, FFD);
          sendMSG(SET, TEMP, 20, FFD, AIR);
        break;
      case 3: // SET LIGHTNESS
          printf("(Coordenador %u) : Enviando SET_LIGHTNESS para %u.\n", TOS_NODE_ID, FFD);
          sendMSG(SET, LIGHT, 30, FFD, LAMP);
        break;
      case 4: // TURN AIR CONDITIONER ON
          printf("(Coordenador %u) : Enviando TURN_AIR_ON para %u.\n", TOS_NODE_ID, FFD);
          sendMSG(TURN, NIL, ON, FFD, AIR);
        break;
      case 5: // TURN AIR CONDITIONER OFF
          printf("(Coordenador %u) : Enviando TURN_AIR_OFF para %u.\n", TOS_NODE_ID, FFD);
          sendMSG(TURN, NIL, OFF, FFD, AIR);
        break;
      case 6: // TURN TV ON
          printf("(Coordenador %u) : Enviando TURN_TV_ON para %u.\n", TOS_NODE_ID, FFD);
          sendMSG(TURN, NIL, ON, FFD, TV);
        break;
      case 7: // TURN TV OFF
          printf("(Coordenador %u) : Enviando TURN_TV_OFF para %u.\n", TOS_NODE_ID, FFD);
          sendMSG(TURN, NIL, OFF, FFD, TV);
          break;
      case 8: // SET TV VOL
        printf("(Coordenador %u) : Enviando SET_TV_VOL para %u.\n", TOS_NODE_ID, FFD);
        sendMSG(SET, VOL, 100, FFD, TV);
        break;
      case 9: // SET TV CHANNEL
        printf("(Coordenador %u) : Enviando SET_TV_CHAN para %u.\n", TOS_NODE_ID, FFD);
        sendMSG(SET, CHAN, 86, FFD, TV);
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

        if(btrpkt->service == TEMP)
            printf("(Coordenador %u) : Temperatura %u graus recebida de %u.\n", TOS_NODE_ID, btrpkt->param, btrpkt->sender);
        else if(btrpkt->service == LIGHT)
            printf("(Coordenador %u) : Luminosidade %u lux  recebida de %u.\n", TOS_NODE_ID, btrpkt->param, btrpkt->sender);

        printfflush();
      }

    }
    return msg;
  }
}
