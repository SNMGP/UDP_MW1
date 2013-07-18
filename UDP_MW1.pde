/*
 * UDP endpoint
 *
 * A simple UDP endpoint example using the WiShield 1.0
 */
#include <Brain.h>
Brain brain(Serial);
#include <WiShield.h>

#define WIRELESS_MODE_INFRA	1
#define WIRELESS_MODE_ADHOC	2

// Wireless configuration parameters ----------------------------------------
unsigned char local_ip[] = {192,168,136,12};	// IP address of WiShield
unsigned char gateway_ip[] = {192,168,136,1};	// router or gateway IP address
unsigned char subnet_mask[] = {255,255,255,0};	// subnet mask for the local network
const prog_char ssid[] PROGMEM = {"esl"};	// max 32 bytes
//const prog_char ssid[] PROGMEM = {"OpenWrt"};	// max 32 bytes

unsigned char security_type = 3;	// 0 - open; 1 - WEP; 2 - WPA; 3 - WPA2

// WPA/WPA2 passphrase
const prog_char security_passphrase[] PROGMEM = {"12345678901234567890abcd"};	// max 64 characters
//const prog_char security_passphrase[] PROGMEM = {"A22806533"};	// max 64 characters


// WEP 128-bit keys
// sample HEX keys
prog_uchar wep_keys[] PROGMEM = {	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d,	// Key 0
									0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	0x00,	// Key 1
									0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	0x00,	// Key 2
									0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	0x00	// Key 3
								};

// setup the wireless mode
// infrastructure - connect to AP
// adhoc - connect to another WiFi device
unsigned char wireless_mode = WIRELESS_MODE_INFRA;
//unsigned char wireless_mode = WIRELESS_MODE_ADHOC;

unsigned char ssid_len;
unsigned char security_passphrase_len;
//---------------------------------------------------------------------------
extern const int STELLA_bfsize;
extern int STELLA_recvlen;
extern int STELLA_sendlen;
extern char STELLA_recv[256];
extern char STELLA_send[256];
extern int STELLA_len;
extern int STELLA_i;
extern int NATHY_command;
extern int NATHY_LS;
extern int NATHY_RS;
int rightspeed=50,leftspeed=50;



void setup()
{ 
       Serial.begin(115200);
       Serial.println("MW");
       
       Serial.write(194);
       
       WiFi.init();

       memset(STELLA_recv,'\0',sizeof(STELLA_recv));
       memset(STELLA_send,'\0',sizeof(STELLA_send));
}

void loop()
{
	WiFi.run();
        int i,tmp=0;
        int speedupFunction = 0;
        
    if (brain.update()) {
       Serial.println(brain.readCSV());
       Serial.println("123");
       speedupFunction = brain.speedup();
       //If Signal value == 0, then moving
    if (brain.testSignal())
    {
      //檢查Rover的行進是前進(加速)、後退、左轉、右轉、停止
      //function的值，可由約略的範圍去判斷是什麼行進
      switch(brain.testFunction()) {
        case 8:
    	  NATHY_command = 8;  //結合WiFiBee後，這裡要改成由WiFi送一個字元"8"<前進>，給 Rover
          testForward();
          NATHY_LS = leftspeed ;
          NATHY_RS = rightspeed;
          break;
    	case 2:
    	  NATHY_command = 2;  //結合WiFiBee後，這裡要改成由WiFi送一個字元"2"<後退>，給 Rover
          testForward();
          NATHY_LS = leftspeed ;
          NATHY_RS = rightspeed;
          break;
    	case 4:
    	  NATHY_command = 4;  //結合WiFiBee後，這裡要改成由WiFi送一個字元"4"<左轉>，給 Rover
          testForward();
          NATHY_LS = leftspeed ;
          NATHY_RS = rightspeed;
          break;
    	case 6:
    	  NATHY_command = 6;  //結合WiFiBee後，這裡要改成由WiFi送一個字元"6"<右轉>，給 Rover
          testForward();
          NATHY_LS = leftspeed ;
          NATHY_RS = rightspeed;
          break;
    	case 5:
    	  NATHY_command = 5;  //結合WiFiBee後，這裡要改成由WiFi送一個字元"8"<停止>，給 Rover
          NATHY_LS = 0 ;
          NATHY_RS = 0;
          break;
    	default:
    	  leftspeed = 0;
    	  rightspeed = 0;
    	  //forward(leftspeed,rightspeed);  //結合WiFiBee後，這裡要改成由WiFi送一個字元"0"<保持正常前進>，給 Rover
          break;
      }
    }
   }
        
    tmp = strlen(STELLA_send);
    if(tmp > 0)
    {
        Serial.println("Send:");     
        for (i = 0; i < tmp; i++)
        {
            Serial.print(STELLA_send[i]);
        }
        memset(STELLA_send,NULL,sizeof(STELLA_send));
        Serial.print("\n");
        showlen(STELLA_sendlen,STELLA_send,STELLA_recvlen,STELLA_recv);
    Serial.print("*************c");
    Serial.print(STELLA_i);
    Serial.print("************\n");
    }
    
    /*delay(500);
    Serial.print("*************c");
    Serial.print(STELLA_i);
    Serial.print("************\n");*/
    
    tmp = strlen(STELLA_recv);
    if(tmp > 0)
    {
        Serial.println("Recv:");
        for (i = 0; i < tmp; i++)
        {
            Serial.print(STELLA_recv[i]);
        }
        memset(STELLA_recv,NULL,sizeof(STELLA_recv));
        Serial.print("\n");
        showlen(STELLA_recvlen,STELLA_recv,STELLA_sendlen,STELLA_send);
    Serial.println("************************************************");
    }
    
    //delay(500);
    /*
    memset(STELLA_recv,'\0',sizeof(STELLA_recv));
    memset(STELLA_send,'\0',sizeof(STELLA_send));
    STELLA_recvlen = 0;
    STELLA_sendlen = 0;*/
    //Serial.println("************************************************");
       
}
void showlen(int len1,char data1[],int len2,char data2[])
{
        Serial.print("----");
        Serial.print(len1);
        Serial.print(" ( ");
        Serial.print(strlen(data1));
        Serial.print(" ) ");
        Serial.print(",");
        Serial.print(len2);
        Serial.print(" ( ");
        Serial.print(strlen(data2));
        Serial.print(" ) ");
        Serial.print("----");
        Serial.print(STELLA_i);
        Serial.println("----");
        
}

void testForward()
{
  int speedupFunction;
  speedupFunction = brain.speedup();
  switch(speedupFunction) {
       case 1:
         Serial.println("Level 1 : speed up : 180");
         leftspeed = 180;
         rightspeed = 180;
         //forward(leftspeed,rightspeed);
         break;
       case 2:
         Serial.println("Level 2 : speed up : 230");
         leftspeed = 255;
         rightspeed = 255;
         //forward(leftspeed,rightspeed);
         break;
       default:
         leftspeed = 50;
         rightspeed = 50;
         //forward(leftspeed,rightspeed);
         break;
  }
}
