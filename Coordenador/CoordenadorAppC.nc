#include <Timer.h>
#include "../Network.h"
#include "printf.h"

configuration CoordenadorAppC {
}
implementation {
  components MainC;
  components CoordenadorC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_NETWORK);
  components new AMReceiverC(AM_NETWORK);
  components PrintfC;
  components SerialStartC;

  App.Boot -> MainC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
}
