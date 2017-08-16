//+------------------------------------------------------------------+
//|                                                        class.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
  A a;
  B b;
  Print("刚构造好的实例",a.a);
  a.a=6;
  Print("修改",a.a);
  //A修改之后B仍然为4
  Print(" A.a changed,b.a",b.a);
  b.a=10;
  Print(b.a);
  Print(a.a);
  }
//+------------------------------------------------------------------+
class A
{
public:
int a;
A()
{
a=3;
}
};

class B:public A
{
public:
//int a;
B()
{
a=4;
}
};

class C:public B
{
public:
//int a;

};