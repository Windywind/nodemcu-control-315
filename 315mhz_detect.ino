/*以下四个管脚定义，对应遥控器上的四个按键*/
int D0 = 8;    //解码芯片数字输出管脚D0,串口值0001,按键A
int D1 = 9;    //解码芯片数字输出管脚D1,串口值0010,按键B
int D2 = 10;   //解码芯片数字输出管脚D2,串口值1000,按键C
int D3 = 11;   //解码芯片数字输出管脚D3,串口值0100,按键D
int ledPin = 13;   //接收指示灯
int interruptPin = 2;

volatile int state = LOW;

void setup()
{
  Serial.begin(9600);
  /*以下管脚的顺序分别对应遥控器的4个按键*/
  pinMode(D3, INPUT);  //分别初始化为输入端口，读取解码芯片输出管脚的电平
  pinMode(D1, INPUT);
  pinMode(D0, INPUT);
  pinMode(D2, INPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(interruptPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(interruptPin), blink, RISING); //数字口2，中断1，对应解码芯片的接收中断管脚
  digitalWrite(ledPin, LOW);
}

void loop()
{
  if (state != LOW) //如果接收到遥控器的命令，则进入该语句
  {
    state = LOW;
    delay(1);   //适当延时，等待管脚电平稳定
    digitalWrite(ledPin, HIGH);
    Serial.print(digitalRead(D3));  //分别读取解码芯片输出管脚的电平，并打印出来
    Serial.print(digitalRead(D1));
    Serial.print(digitalRead(D0));
    Serial.println(digitalRead(D2));
    delay(300);
    digitalWrite(ledPin, LOW);
  }
}

void blink()
{
  state = ! state;
}
