//校验时间2017-04-25
//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#ifndef _BASE_H
#define _BASE_H
#define           SYMBOL_SIZE 20
#define           GROUP_SIZE  4
enum              ENUM_SYMBOL  {XAUUSD=1,EURUSD=2,USDJPY=3,GBPUSD=4,EURJPY=5,EURGBP=6,GBPJPY=7,USDCHF=8,USDCNH=9,USDCAD=10,AUDUSD=11};
enum              ENUM_BS      {buy=1,sell=2,buysell=3};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Base
  {
public:
   string            symbol;
   ENUM_TIMEFRAMES   timeframe;
   double            point;
   int               digits;
                     Base(string param_symbol=NULL,ENUM_TIMEFRAMES param_timeframe=PERIOD_CURRENT);
                    ~Base();
   double            ND(double param_price,int param_digits=-1);
   double            Price();
   double            Spread();
   datetime          Time();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Base::Base(string param_symbol=NULL,ENUM_TIMEFRAMES param_timeframe=PERIOD_CURRENT)
  {
   symbol=param_symbol;
   timeframe=param_timeframe;
   point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   digits=int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Base::~Base(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Base::ND(double param_price,int param_digits=-1)
  {
   int digits_used=param_digits==-1?digits:param_digits;
   return NormalizeDouble(param_price,digits_used);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Base::Price(void)
  {
   return SymbolInfoDouble(symbol,SYMBOL_BID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Base::Spread()
  {
   return SymbolInfoInteger(symbol,SYMBOL_SPREAD)*point;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Base::Time(void)
  {
   return TimeCurrent();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TimeRate:public Base
  {
public:
   datetime          period_flag;
   MqlRates          periods[];
   MqlRates          rates[];
                     TimeRate(string param_symbol=NULL,ENUM_TIMEFRAMES param_timeframe=PERIOD_CURRENT);
   bool              NewFlag(void);
   void              RenewFlag(void);
   bool              GetMQL(int param_position,int param_size);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TimeRate::TimeRate(string param_symbol=NULL,ENUM_TIMEFRAMES param_timeframe=0):Base(param_symbol,param_timeframe)
  {
   ArraySetAsSeries(periods,true);
   ArraySetAsSeries(rates,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TimeRate::NewFlag(void)
  {
   return CopyRates(symbol,timeframe,0,1,periods)==1?period_flag!=periods[0].time:false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TimeRate::RenewFlag(void)
  {
   period_flag=periods[0].time;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TimeRate::GetMQL(int param_position,int param_size)
  {
   int fail_cnt=0;
   while(fail_cnt<50 && !IsStopped())
     {
      if(CopyRates(symbol,timeframe,param_position,param_size,rates)==param_size){return true;}
      else{fail_cnt++;Sleep(20);}
     }
   Print(symbol,timeframe,"copy failed");
   return false;
  }
#endif 
//+------------------------------------------------------------------+
