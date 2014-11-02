#include <Timer.h>
#include "../Network.h"
#include "printf.h"

configuration FFDAppC {
}
implementation {
  components MainC;
  components FFDC as App;
  components ActiveMessageC;
  components new AMSenderC(AM_NETWORK);
  components new AMReceiverC(AM_NETWORK);
  components PrintfC;
  components SerialStartC;

  App.Boot -> MainC;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
}
