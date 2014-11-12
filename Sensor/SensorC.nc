#include "printf.h"
#include "../Network.h"

module SensorC {
  uses interface Boot;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface Read<uint16_t> as TempRead;
  uses interface Read<uint16_t> as LightRead;
}
implementation {

  message_t pkt;
  bool busy = FALSE;
  nx_uint16_t centigrade;
  nx_uint16_t luminance;

  void getSensorVal(nx_uint16_t service){
    if(service == TEMP)
      call TempRead.read();
    else if(service == LIGHT)
      call LightRead.read();
  }

  void sendSensorVal(nx_uint16_t service, nx_uint8_t param){
    if (!busy) {
          NetworkMsg* btrpkt =
              (NetworkMsg*)(call Packet.getPayload(&pkt, sizeof(NetworkMsg)));

          if (btrpkt == NULL) { return; }

          btrpkt->sender = TOS_NODE_ID;
          btrpkt->message_type = TAKE;
          btrpkt->param = param;
          btrpkt->service = service;
          btrpkt->node_id = COORD;

          if (call AMSend.send(COORD,
                &pkt, sizeof(NetworkMsg)) == SUCCESS) {
            busy = TRUE;
          }
    }
  }

  event void Boot.booted() {
    printf("(SENSOR %u) : Inicializando Sensor ...\n", TOS_NODE_ID);
    printfflush();
    call AMControl.start();
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){

    if (len == sizeof(NetworkMsg)) {
      NetworkMsg* btrpkt = (NetworkMsg*)payload;

      if(btrpkt->message_type == GET)
          getSensorVal(btrpkt->service);

    }
    return msg;
  }

   event void TempRead.readDone( error_t result, uint16_t val ){
     if(result == SUCCESS){
        centigrade = (val / 100) - 40;
        printf("(SENSOR %u) : Temperatura lida: %d graus \n", TOS_NODE_ID, centigrade);
        printfflush();
        sendSensorVal(TEMP, centigrade);
      }else{
        call TempRead.read();
      }
   }

   event void LightRead.readDone( error_t result, uint16_t val ){
     if(result == SUCCESS){
        luminance = 2.5 * (val / 4096.0) * 6250.0;
        printf("(SENSOR %u) : Luminancia lida: %u lux \n", TOS_NODE_ID, luminance);
        printfflush();
        sendSensorVal(LIGHT, luminance);
      }else{
        call LightRead.read();
      }
   }

    // Implementação dos eventos das interfaces utilizadas
   event void AMControl.startDone(error_t err) {
    if (err != SUCCESS) { call AMControl.start(); }
  }

  event void AMControl.stopDone(error_t err) {}

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) { busy = FALSE; }
  }

}
