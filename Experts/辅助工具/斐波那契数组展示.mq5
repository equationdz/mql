//+------------------------------------------------------------------+
//|                                                     斐波那契数组展示.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include            <..\Experts\sun\Sequence.mqh>
input int ratio_fibo=3;
input int odd_fibo=20;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
//---
   Sequence a;
   Print("odds: ",ArrayRange(a.OddsArray,0),"  值1起点: ",(ArrayRange(a.OddsArray,0)-1)/2);
   ArrayPrint(a.OddsArray);
   Print("ratio: ",ArrayRange(a.RatioArray,0));
   ArrayPrint(a.RatioArray,6);
   Print("period: ",ArrayRange(a.PeriodArray,0));
   ArrayPrint(a.PeriodArray);
   Print("compare: ",ArrayRange(a.CompareArray,0));
   ArrayPrint(a.CompareArray);
//Print("compare1: ",ArrayRange(a.FiboArrayR1,0));
//ArrayPrint(a.FiboArrayR1);
   double ratio=a.RatioArray[ratio_fibo];
   Print(ratio);
   double odds=a.OddsArray[odd_fibo];
   Print(odds);
   Print(ratio*odds);
   ExpertRemove();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
  }
//+------------------------------------------------------------------+
//void AP(double&array[])
//{
//for (int i=0;i<ArrayRange(array,0);i++)
//{
//Print("["
//
//}
//
//}