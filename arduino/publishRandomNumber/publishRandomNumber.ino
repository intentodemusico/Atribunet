//#include <Adafruit_ESP8266.h>

//code write by Moz for YouTube changel logMaker360, 24-11-2016
//code belongs to this video: https://youtu.be/nAUUdbUkJEI

//#include <EEPROM.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>
#define LED_BUILTIN 2  

const char* ssid = "Tell my Wi-Fi love her"; // Rellena con el nombre de tu red WiFi
const char* password = "246813579"; // Rellena con la contraseña de tu red WiFi

long lastMsg = 0;
int value = 0;
char msg[50];

const char* mqtt_server = "broker.hivemq.com";                 //!!!!!!!!!!!!!!!!!!!!!
int randNumber;
WiFiClient espClient;
PubSubClient client(espClient);
 
 /*
void callback(char* topic, byte* payload, unsigned int length) {

 for (int i=0;i<length;i++) {
  char receivedChar = (char)payload[i];
  Serial.print(receivedChar);
  if (receivedChar == '1')
  digitalWrite(LED_BUILTIN, HIGH);
  if (receivedChar == '0')
   digitalWrite(LED_BUILTIN, LOW);
  }
  Serial.println();
}
 */

 void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  // Switch on the LED if an 1 was received as first character
  if ((char)payload[0] == '1') {
    digitalWrite(BUILTIN_LED, LOW);   // Turn the LED on (Note that LOW is the voltage level
    // but actually the LED is on; this is because
    // it is acive low on the ESP-01)
  } else {
    digitalWrite(BUILTIN_LED, HIGH);  // Turn the LED off by making the voltage HIGH
  }

}
 
void reconnect() {
 // Loop until we're reconnected
 Serial.print("Target server: ");
 Serial.println(mqtt_server);
 while (!client.connected()) {
 Serial.print("Attempting MQTT connection...");
 // Attempt to connect
 if (client.connect("ESP8266 Client")) {
  Serial.println("connected");
  // ... and subscribe to topic
  client.subscribe("ledStatus");
 } else {
  Serial.print("failed, rc=");
  Serial.print(client.state());
  Serial.println(" try again in 5 seconds");
  // Wait 5 seconds before retrying
  delay(5000);
  }
 }
}
 
void setup()
{
 Serial.begin(9600);
  delay(10);
 
  // Conectamos a la red WiFi
 
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
 
  /* Configuramos el ESP8266 como cliente WiFi. Si no lo hacemos 
  se configurará como cliente y punto de acceso al mismo tiempo */
  WiFi.mode(WIFI_STA); // Modo cliente WiFi
  WiFi.begin(ssid, password);
 
  // Esperamos a que estemos conectados a la red WiFi
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
 
  Serial.println("");
  Serial.println("WiFi connected"); 
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP()); // Mostramos la IP
 
 client.setServer(mqtt_server, 1883);
 client.setCallback(callback);
 
 pinMode(LED_BUILTIN, OUTPUT);
 digitalWrite(LED_BUILTIN, HIGH);
 delay(5000);
 digitalWrite(LED_BUILTIN, LOW);
}
 
void loop()
{
 if (!client.connected()) {
  reconnect();
 }
 client.loop();
 
  long now = millis();
  if (now - lastMsg > 2000) {
    lastMsg = now;
    randNumber=random(5191951952181);
    snprintf (msg, 75, "Nodo 1: #%ld", randNumber);
    Serial.print("Publish message: ");
    Serial.println(msg);
    client.publish("analytica/data", msg);
  }
 /* 
 
    String comsg;
    comsg="KESO";

client.publish("/test/confirm", (char*) comsg.c_str());
 //client.publish("atribunet/arduino",  randNumber);//String.toCharArray(randNumber));
 */
}
