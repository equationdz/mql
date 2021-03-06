//校验时间2017-04-25
//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#ifndef _SEQUENCE_H
#define _SEQUENCE_H
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Sequence
  {
public:
   int               FiboArray[];
   double            FiboArrayR1[];
   double            FiboArrayR2[];
   double            FiboArrayR3[];
   int               PeriodArray[];
   double            OddsArray[];
   double            RatioArray[];
   double            CompareArray[];
                     Sequence();
   int               Fibo(int position);
   void              Show();
  };
//+------------------------------------------------------------------+
Sequence::Sequence()
  {
   int fibo_range=47;
   int odds_range=25;
   int ratio_range=20;
   int period_range=15;
   int compare_range=20;
   ArrayResize(FiboArray,fibo_range);
   ArrayResize(FiboArrayR1,fibo_range);
   ArrayResize(FiboArrayR2,fibo_range);
   ArrayResize(FiboArrayR3,fibo_range);
   ArrayResize(OddsArray,odds_range);
   ArrayResize(RatioArray,ratio_range);
   ArrayResize(PeriodArray,period_range);
   ArrayResize(CompareArray,compare_range);
   for(int i=0;i<fibo_range;i++)
     {
      FiboArray[i]=Fibo(i);
      FiboArrayR1[i]=sqrt(FiboArray[i]);
      FiboArrayR2[i]=sqrt(sqrt(FiboArray[i]));
      FiboArrayR3[i]=sqrt(sqrt(sqrt(FiboArray[i])));
     }
   double tempoddsarray[],tempoddsarray2[];
   int temp_range=ArrayResize(tempoddsarray,12);
   ArrayResize(tempoddsarray2,temp_range);
   for(int i=0;i<temp_range;i++)
     {
      tempoddsarray[i]=FiboArrayR3[2*i+3];
      tempoddsarray2[i]=1/tempoddsarray[i];
     }
//Print("temp");
//ArrayPrint(tempoddsarray);
   OddsArray[(odds_range-1)/2]=1;
   ArrayCopy(OddsArray,tempoddsarray,(odds_range-1)/2+1,0);
   ArraySort(tempoddsarray2);
   ArrayCopy(OddsArray,tempoddsarray2,0,0);
   for(int i=0;i<ratio_range;i++)
     {
      RatioArray[i]=FiboArrayR1[i+2]*0.0010;
     }
   for(int i=0;i<period_range;i++)
     {
      PeriodArray[i]=FiboArray[i+2];
     }
   for(int i=0;i<compare_range;i++)
     {
      CompareArray[i]=FiboArrayR3[i*2+3];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Sequence::Fibo(int position)
  {
   double sqrt5=sqrt(5);
   int res=int(1/sqrt5*(pow((1+sqrt5)/2,position)-pow((1-sqrt5)/2,position)));
   return res;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Sequence::Show()
  {
#ifdef __MQL5__
   Print("FiboArray");
   ArrayPrint(FiboArray);
   Print("FiboArrayR1");
   ArrayPrint(FiboArrayR1);
   Print("FiboArrayR2");
   ArrayPrint(FiboArrayR2);
   Print("FiboArrayR3");
   ArrayPrint(FiboArrayR3);
   Print("PeriodArray");
   ArrayPrint(PeriodArray);
   Print("OddsArray");
   ArrayPrint(OddsArray);
   Print("RatioArray");
   ArrayPrint(RatioArray,6);
   Print("CompareArray");
   ArrayPrint(CompareArray);
#endif
  }
#endif 
//+------------------------------------------------------------------+
