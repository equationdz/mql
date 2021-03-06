//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#ifndef _PARAMETER_H
#define _PARAMETER_H
#include  "Base.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Base_Param:public Base
  {
public:
   double            pf;
   string            symgrp;
   int               sl_ratio_fibo;
   int               odds_fibo;
   virtual void      SetParam(int tag_sym,int tag_grp)=0;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class S_01_Param:public Base_Param
  {
public:
   enum ENUM_S_01{S_01_PF=0,S_01_SL_RATIO=1,S_01_ODDS=2,S_01_PERIOD=3};
   int               period_fibo;
                     S_01_Param(int param_sl_ratio_fibo=0,int param_odds_fibo=0,int param_period_fibo=0);
   virtual void      SetParam(int tag_sym,int tag_grp);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class S_04_Param:public Base_Param
  {
public:
   enum ENUM_S_04{S_04_PF=0,S_04_SL_RATIO=1,S_04_ODDS=2,S_04_PERIOD=3,S_04_X=4};
   int               x_fibo;
   int               period_fibo;
                     S_04_Param(int param_sl_ratio_fibo,int param_odds_fibo,int param_period_fibo,int param_x_fibo);
   virtual void      SetParam(int tag_sym,int tag_grp);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
S_01_Param::S_01_Param(int param_sl_ratio_fibo=0,int param_odds_fibo=0,int param_period_fibo=0)
  {
   pf=0;
   symgrp="S_01测试";
   sl_ratio_fibo=param_sl_ratio_fibo;
   odds_fibo=param_odds_fibo;
   period_fibo=param_period_fibo;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
S_04_Param::S_04_Param(int param_sl_ratio_fibo=0,int param_odds_fibo=0,int param_period_fibo=0,int param_x_fibo=0)
  {
   pf=0;
   symgrp="S_04测试";
   sl_ratio_fibo=param_sl_ratio_fibo;
   odds_fibo=param_odds_fibo;
   period_fibo=param_period_fibo;
   x_fibo=param_x_fibo;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void S_01_Param::SetParam(int tag_sym,int tag_grp)
  {
   double arr[SYMBOL_SIZE][GROUP_SIZE][4];
   ArrayInitialize(arr,0);
   arr[XAUUSD][1][S_01_PF]=1.20;//修正
   arr[XAUUSD][1][S_01_SL_RATIO]=4;
   arr[XAUUSD][1][S_01_ODDS]=17;
   arr[XAUUSD][1][S_01_PERIOD]=4;
//------------------------------------------------------------------------------------------  
   arr[EURUSD][1][S_01_PF]=1.17;
   arr[EURUSD][1][S_01_SL_RATIO]=0;
   arr[EURUSD][1][S_01_ODDS]=20;
   arr[EURUSD][1][S_01_PERIOD]=4;
//------------------------------------------------------------------------------------------  
   arr[USDJPY][1][S_01_PF]=1.41;
   arr[USDJPY][1][S_01_SL_RATIO]=0;
   arr[USDJPY][1][S_01_ODDS]=14;
   arr[USDJPY][1][S_01_PERIOD]=4;
//------------------------------------------------------------------------------------------  
   arr[GBPUSD][1][S_01_PF]=1.42;
   arr[GBPUSD][1][S_01_SL_RATIO]=1;
   arr[GBPUSD][1][S_01_ODDS]=10;
   arr[GBPUSD][1][S_01_PERIOD]=6;
//------------------------------------------------------------------------------------------  
   arr[EURJPY][1][S_01_PF]=1.11;
   arr[EURJPY][1][S_01_SL_RATIO]=4;
   arr[EURJPY][1][S_01_ODDS]=9;
   arr[EURJPY][1][S_01_PERIOD]=3;
//------------------------------------------------------------------------------------------  
   arr[EURGBP][1][S_01_PF]=1.20;//修正
   arr[EURGBP][1][S_01_SL_RATIO]=3;
   arr[EURGBP][1][S_01_ODDS]=17;
   arr[EURGBP][1][S_01_PERIOD]=6;
//------------------------------------------------------------------------------------------  
   arr[GBPJPY][1][S_01_PF]=1.27;
   arr[GBPJPY][1][S_01_SL_RATIO]=4;
   arr[GBPJPY][1][S_01_ODDS]=20;
   arr[GBPJPY][1][S_01_PERIOD]=6;
//------------------------------------------------------------------------------------------  
   arr[USDCHF][1][S_01_PF]=1.11;
   arr[USDCHF][1][S_01_SL_RATIO]=3;
   arr[USDCHF][1][S_01_ODDS]=7;
   arr[USDCHF][1][S_01_PERIOD]=6;
//------------------------------------------------------------------------------------------  
   arr[USDCNH][1][S_01_PF]=1.46;
   arr[USDCNH][1][S_01_SL_RATIO]=1;
   arr[USDCNH][1][S_01_ODDS]=17;
   arr[USDCNH][1][S_01_PERIOD]=6;
//------------------------------------------------------------------------------------------  
   arr[USDCAD][1][S_01_PF]=1.12;
   arr[USDCAD][1][S_01_SL_RATIO]=1;
   arr[USDCAD][1][S_01_ODDS]=9;
   arr[USDCAD][1][S_01_PERIOD]=5;
//------------------------------------------------------------------------------------------  
   arr[AUDUSD][1][S_01_PF]=1.12;
   arr[AUDUSD][1][S_01_SL_RATIO]=0;
   arr[AUDUSD][1][S_01_ODDS]=14;
   arr[AUDUSD][1][S_01_PERIOD]=5;
//------------------------------------------------------------------------------------------  
   symgrp=string(tag_sym)+"/"+string(tag_grp)+"/"+string(1);
   pf=arr[tag_sym][tag_grp][S_01_PF];
   sl_ratio_fibo=int(arr[tag_sym][tag_grp][S_01_SL_RATIO]);
   odds_fibo=int(arr[tag_sym][tag_grp][S_01_ODDS]);
   period_fibo=int(arr[tag_sym][tag_grp][S_01_PERIOD]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void S_04_Param::SetParam(int tag_sym,int tag_grp)
  {
   double arr[SYMBOL_SIZE][GROUP_SIZE][5];
   ArrayInitialize(arr,0);
   arr[XAUUSD][1][S_04_PF]=1.13;
   arr[XAUUSD][1][S_04_SL_RATIO]=7;
   arr[XAUUSD][1][S_04_ODDS]=20;
   arr[XAUUSD][1][S_04_PERIOD]=1;
   arr[XAUUSD][1][S_04_X]=6;
//------------------------------------------------------------------------------------------    
   arr[EURUSD][1][S_04_PF]=1.26;
   arr[EURUSD][1][S_04_SL_RATIO]=5;
   arr[EURUSD][1][S_04_ODDS]=15;
   arr[EURUSD][1][S_04_PERIOD]=0;
   arr[EURUSD][1][S_04_X]=2;
//------------------------------------------------------------------------------------------  
   arr[USDJPY][1][S_04_PF]=1.27;
   arr[USDJPY][1][S_04_SL_RATIO]=5;
   arr[USDJPY][1][S_04_ODDS]=15;
   arr[USDJPY][1][S_04_PERIOD]=3;
   arr[USDJPY][1][S_04_X]=6;
//------------------------------------------------------------------------------------------  
   arr[GBPUSD][1][S_04_PF]=1.29;
   arr[GBPUSD][1][S_04_SL_RATIO]=3;
   arr[GBPUSD][1][S_04_ODDS]=20;
   arr[GBPUSD][1][S_04_PERIOD]=3;
   arr[GBPUSD][1][S_04_X]=5;
//------------------------------------------------------------------------------------------  
   arr[USDCHF][1][S_04_PF]=1.24;
   arr[USDCHF][1][S_04_SL_RATIO]=0;
   arr[USDCHF][1][S_04_ODDS]=20;
   arr[USDCHF][1][S_04_PERIOD]=3;
   arr[USDCHF][1][S_04_X]=5;
//------------------------------------------------------------------------------------------  
   arr[USDCNH][1][S_04_PF]=1.59;
   arr[USDCNH][1][S_04_SL_RATIO]=2;
   arr[USDCNH][1][S_04_ODDS]=17;
   arr[USDCNH][1][S_04_PERIOD]=2;
   arr[USDCNH][1][S_04_X]=1;
//------------------------------------------------------------------------------------------  
   arr[USDCAD][1][S_04_PF]=1.24;
   arr[USDCAD][1][S_04_SL_RATIO]=3;
   arr[USDCAD][1][S_04_ODDS]=13;
   arr[USDCAD][1][S_04_PERIOD]=2;
   arr[USDCAD][1][S_04_X]=4;
//------------------------------------------------------------------------------------------  
   arr[AUDUSD][1][S_04_PF]=1.32;
   arr[AUDUSD][1][S_04_SL_RATIO]=1;
   arr[AUDUSD][1][S_04_ODDS]=18;
   arr[AUDUSD][1][S_04_PERIOD]=2;
   arr[AUDUSD][1][S_04_X]=5;
//------------------------------------------------------------------------------------------  
   symgrp=string(tag_sym)+"/"+string(tag_grp)+"/"+string(4);
   pf=arr[tag_sym][tag_grp][S_04_PF];
   sl_ratio_fibo=int(arr[tag_sym][tag_grp][S_04_SL_RATIO]);
   odds_fibo=int(arr[tag_sym][tag_grp][S_04_ODDS]);
   period_fibo=int(arr[tag_sym][tag_grp][S_04_PERIOD]);
   x_fibo=int(arr[tag_sym][tag_grp][S_04_X]);
  }
#endif 
//+------------------------------------------------------------------+
