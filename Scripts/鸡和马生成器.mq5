//+------------------------------------------------------------------+
//|                                                       鸡和马生成器.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs
#include            <..\Experts\sun\Authorization.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
input long input_id=123456;
input datetime input_datetime=D'2020.01.01';
Authorization a("");
void OnStart()
  {
//---
  string code=a.CreatePin(input_id,input_datetime);
  //a.DecryptPin(code);
  }
//+------------------------------------------------------------------+
