#include <Timer.h>
#include "../Network.h"
#include "printf.h"

configuration SensorAppC {
}
implementation {
  components MainC;
  components SensorC as App;
  components ActiveMessageC;
  components new AMSenderC(AM_NETWORK);
  components new AMReceiverC(AM_NETWORK);
  components PrintfC;
  components SerialStartC;
  components new SensirionSht11C() as TempSensor;
  components new HamamatsuS10871TsrC() as LightSensor;

  App.Boot -> MainC;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.TempRead -> TempSensor.Temperature;
  App.LightRead -> LightSensor;
}
