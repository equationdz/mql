//校验时间2017-04-25
//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#ifndef _ORDER_H_
#define _ORDER_H_
#include "Base.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifdef __MQL4__ 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Order:public Base
  {
private:
   double            ratio_equity;      //净值使用率
   string            comment;           //注释
protected:
   double            lot_min;           //最小可开仓手数
   double            lot_max;           //最大可开仓手数
   int               magicnumber;       //魔术号码
   int               lot_digits;        //开仓手数小数点
   int               deviation_order;   //订单功能的滑点
   double            positive_deviation;
   double            negative_deviation;
   double            spread_control;
public:
   double            lot;               //手数
   struct MqlRequest
     {
      ulong             magic;            // EA交易 ID (幻数)
      string            symbol;           // 交易的交易品种
      double            volume;           // 一手需求的交易量
      double            price;            // 价格
      double            sl;               // 订单止损价位点位
      double            tp;               // 订单盈利价位点位
      ulong             deviation;        // 需求价格最可能的偏差
      int               type;             // 订单类型
      string            comment;          // 订单注释 64字节
     };
   MqlRequest        request;
                     Order(string param_symbol,double param_spread_control,double param_positive_deviation,double param_negative_deviation,int param_magic,string param_comment=NULL);
                    ~Order(void);
   int               SendOrder(ENUM_BS param_cmd,double param_sl=0,double param_tp=0,double param_m_price=0);
   double            LotsOptimized(double param_lot_base=0.01,double param_ratio_equity=0);
  };
#endif
#ifdef __MQL5__
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Order:public Base
  {
private:
   double            ratio_equity;      //净值使用率
   string            comment;           //注释
protected:
   double            lot_min;           //最小可开仓手数
   double            lot_max;           //最大可开仓手数
   int               magicnumber;       //魔术号码
   int               lot_digits;        //开仓手数小数点
   int               deviation_order;   //订单功能的滑点
   double            positive_deviation;
   double            negative_deviation;
   double            spread_control;
public:
   MqlTradeRequest   request;
   MqlTradeResult    result;
   double            lot;               //手数
                     Order(string param_symbol,double param_spread_control,double param_positive_deviation,double param_negative_deviation,int param_magic,string param_comment=NULL);
                    ~Order(void);
   int               SendOrder(ENUM_BS param_cmd,double param_sl=0,double param_tp=0,double param_m_price=0);
   double            LotsOptimized(double param_lot_base=0.01,double param_ratio_equity=0);
  };
#endif
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::Order(string param_symbol,double param_spread_control,double param_positive_deviation,double param_negative_deviation,int param_magic,string param_comment=NULL):Base(param_symbol)
  {
#ifdef __MQL5__  
   ZeroMemory(request);
   ZeroMemory(result);
#endif    
   ratio_equity=0;
   lot=0;
   deviation_order=0;
   magicnumber=param_magic;
   comment=param_comment;
   positive_deviation=param_positive_deviation;
   negative_deviation=param_negative_deviation;
   spread_control=param_spread_control;
   lot_digits=int(MathLog(SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP))/MathLog(0.1));
   lot_min=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   lot_max=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::~Order(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order::SendOrder(ENUM_BS param_cmd,double param_sl=0,double param_tp=0,double param_m_price=0)
  {
   int res=-1;
//***********************************************************************************************************************************************************************************
   double price_buy=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double price_sell=SymbolInfoDouble(symbol,SYMBOL_BID);
   double spread=ND(price_buy-price_sell);
   double spread_gap=spread-spread_control;
   if(spread_gap>0)
     {
      Print(symbol,"点差:",spread,"限制值:",spread_control,"偏差:",spread_gap);
      return -10;
     }
//***********************************************************************************************************************************************************************************
   double sl_buy=0;
   double tp_buy=0;
   double sl_sell=0;
   double tp_sell=0;
   string final_comment=comment;
   final_comment+=param_m_price==0?"":"m"+string(param_m_price)+"s"+DoubleToString(round(spread/point),0);
//***********************************************************************************************************************************************************************************
   if(param_cmd==buy)
     {
      if(param_m_price)
        {
         double deviation_ratio=price_sell/param_m_price-1;
         if(deviation_ratio>=positive_deviation){return -20;}
         if(-deviation_ratio>=negative_deviation){return -21;}
        }
      sl_buy=param_sl==0?0:param_sl+spread;
      tp_buy=param_tp==0?0:param_tp+spread;
      final_comment+="r"+string(price_buy);
     }
   else if(param_cmd==sell)
     {
      if(param_m_price)
        {
         double deviation_ratio=1-price_sell/param_m_price;
         if(deviation_ratio>=positive_deviation){return -30;}
         if(-deviation_ratio>=negative_deviation){return -31;}
        }
      sl_sell=param_sl==0?0:param_sl;
      tp_sell=param_tp==0?0:param_tp;
      final_comment+="r"+string(price_sell);
     }
//***********************************************************************************************************************************************************************************     
#ifdef __MQL4__
   ZeroMemory(request);
   if(param_cmd==buy)
     {
      request.type=OP_BUY;
      request.price=price_buy;
      request.sl=ND(sl_buy);
      request.tp=ND(tp_buy);
     }
   else if(param_cmd==sell)
     {
      request.type=OP_SELL;
      request.price=price_sell;
      request.sl=ND(sl_sell);
      request.tp=ND(tp_sell);
     }
   res=OrderSend(symbol,request.type,lot,request.price,deviation_order,request.sl,request.tp,final_comment,magicnumber);
   if(res<0){Print("发送订单失败，错误号:",res);}
#endif
//***********************************************************************************************************************************************************************************   
#ifdef __MQL5__
   ZeroMemory(request);
   ZeroMemory(result);
   request.action=TRADE_ACTION_DEAL;
   request.magic=magicnumber;
   request.symbol=symbol;
   request.volume=lot;
   request.deviation=deviation_order;
   request.type_filling=ORDER_FILLING_FOK;
   request.comment=final_comment;
   if(param_cmd==buy)
     {
      request.price=price_buy;
      request.sl=ND(sl_buy);
      request.tp=ND(tp_buy);
      request.type=ORDER_TYPE_BUY;
     }
   else if(param_cmd==sell)
     {
      request.price=price_sell;
      request.sl=ND(sl_sell);
      request.tp=ND(tp_sell);
      request.type=ORDER_TYPE_SELL;
     }
   res=OrderSend(request,result);
   if(!res){Print("发送订单失败，错误号:",GetLastError());}
   if(result.retcode==10009 || result.retcode==10010){res=1;} //暂定
#endif
//***********************************************************************************************************************************************************************************   
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order::LotsOptimized(double param_lot_base=0.01,double param_ratio_equity=0)
  {
   lot=NormalizeDouble(param_ratio_equity==0?param_lot_base:AccountInfoDouble(ACCOUNT_EQUITY)*param_ratio_equity/10000,lot_digits);
   lot=lot<lot_min?lot_min:lot;
   lot=lot>lot_max?lot_max:lot;
   return lot;
  }
//*********************************************************************************************************************************************************************************** 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderManage:public Order
  {
public:
   int               count;
   double            profit_take;
   double            i_p;
   bool              profit_take_lot_switch;
   double            profit_total;
   datetime          datetime_first;
   datetime          datetime_last;
   double            gap_start;
   double            gap_ratio;
   double            gap_trade;
   double            lot_start;
   double            lot_ratio;
   double            lot_trade_max;
   double            lot_buy;
   double            lot_sell;
   double            lot_net;
   double            lot_total;
   double            price_last;
   int               cmd_last;
   void              Function();
                     OrderManage(bool param_show,int param_magic,double param_profit_take,bool param_profit_take_lot_switch,double param_lot_start,double param_lot_ratio,double param_gap_start,double param_gap_ratio);
                    ~OrderManage();
   void              Initail();
   void              CloseOrder(ENUM_BS param_cmd);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OrderManage::OrderManage(bool param_show,int param_magic,double param_profit_take,bool param_profit_take_lot_switch,double param_lot_start,double param_lot_ratio,double param_gap_start,double param_gap_ratio):Order(_Symbol,1,0.001,0.001,0)
  {
   magicnumber=param_magic;
   profit_take=param_profit_take;
   i_p=param_profit_take;
   profit_take_lot_switch=param_profit_take_lot_switch;
   gap_start=param_gap_start;
   gap_ratio=param_gap_ratio;
   lot_start=param_lot_start;
   lot_ratio=param_lot_ratio;
   Initail();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OrderManage::~OrderManage()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderManage::Initail()
  {
   count=0;
   profit_total=0;
   datetime_first=TimeCurrent();
   datetime_last=0;
   gap_trade=0;
   lot_trade_max=0;
   lot_buy=0;
   lot_sell=0;
   lot_total=0;
   price_last=0;
   cmd_last=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderManage::CloseOrder(ENUM_BS param_cmd)
  {
   Print("close");
#ifdef __MQL4__
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==True)
        {
         if(OrderMagicNumber()==magicnumber && OrderSymbol()==_Symbol)
           {
            if((param_cmd==buysell || param_cmd==sell) && OrderType()==OP_SELL)
              {
               while(!OrderClose(OrderTicket(),OrderLots(),SymbolInfoDouble(_Symbol,SYMBOL_ASK),0,Yellow) && !IsStopped())
                 {
                  Print(GetLastError());
                 }
              }
            else if((param_cmd==buysell || param_cmd==buy) && OrderType()==OP_BUY)
              {
               while(!OrderClose(OrderTicket(),OrderLots(),SymbolInfoDouble(_Symbol,SYMBOL_BID),0,Yellow) && !IsStopped())
                 {
                  Print(GetLastError());
                 }
              }
           }
        }
     }
#endif
#ifdef __MQL5__
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong  position_ticket=PositionGetTicket(i);                                      // 持仓价格
      string position_symbol=PositionGetString(POSITION_SYMBOL);                        // 交易品种 
      ulong  magictemp=PositionGetInteger(POSITION_MAGIC);
      double volume=PositionGetDouble(POSITION_VOLUME);                                 // 持仓交易量
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // 持仓类型
      if(magictemp==magicnumber)
        {
         ZeroMemory(request);
         ZeroMemory(result);
         request.action   =TRADE_ACTION_DEAL;        // 交易操作类型
         request.position =position_ticket;          // 持仓价格
         request.symbol   =position_symbol;          // 交易品种 
         request.volume   =volume;                   // 持仓交易量
         request.deviation=0;                        // 允许价格偏差
         request.magic=magicnumber;                        // 持仓幻数
         if((param_cmd==buysell || param_cmd==sell) && type==POSITION_TYPE_SELL)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
           }
         else if((param_cmd==buysell || param_cmd==buy) && type==POSITION_TYPE_BUY)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type=ORDER_TYPE_SELL;
           }
         if(!OrderSend(request,result)){PrintFormat("OrderSend error %d",GetLastError());}
         //PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
        }
     }
#endif
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderManage::Function()
  {
   Initail();
#ifdef __MQL4__ 
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==True)
        {
         if(OrderSymbol()==_Symbol && OrderMagicNumber()==magicnumber)
           {
            count++;
            datetime order_opentime=OrderOpenTime();
            if(order_opentime<datetime_first){datetime_first=order_opentime;}
            if(order_opentime>datetime_last)
              {
               datetime_last=order_opentime;
               price_last=OrderOpenPrice();
               if(OrderType()==OP_BUY)
                 {
                  cmd_last=buy;
                 }
               else if(OrderType()==OP_SELL)
                 {
                  cmd_last=sell;
                 }
              }
            if(OrderType()==OP_BUY)
              {
               lot_buy+=OrderLots();
              }
            else if(OrderType()==OP_SELL)
              {
               lot_sell+=OrderLots();
              }
            if(lot_trade_max<=OrderLots())
              {
               lot_trade_max=OrderLots();
              }
            lot_total+=OrderLots();
            profit_total+=OrderProfit()+OrderCommission()+OrderSwap();
           }
        }
     }
#endif   
#ifdef __MQL5__    
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong  position_ticket=PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL)==_Symbol && PositionGetInteger(POSITION_MAGIC)==magicnumber)
        {
         count++;
         long ordertypenow=PositionGetInteger(POSITION_TYPE);
         double orderlots=PositionGetDouble(POSITION_VOLUME);
         datetime order_opentime=datetime(PositionGetInteger(POSITION_TIME));
         if(order_opentime<datetime_first){datetime_first=order_opentime;}
         if(order_opentime>datetime_last)
           {
            datetime_last=order_opentime;
            price_last=PositionGetDouble(POSITION_PRICE_OPEN);
            if(ordertypenow==POSITION_TYPE_BUY)
              {
               cmd_last=buy;
              }
            else if(ordertypenow==POSITION_TYPE_SELL)
              {
               cmd_last=sell;
              }
           }
         if(ordertypenow==POSITION_TYPE_BUY)
           {
            lot_buy+=orderlots;
           }
         else if(ordertypenow==POSITION_TYPE_SELL)
           {
            lot_sell+=orderlots;
           }
         if(lot_trade_max<=orderlots)
           {
            lot_trade_max=orderlots;
           }
         lot_total+=orderlots;
         profit_total+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
        }
     }
#endif   
   if(profit_take_lot_switch)
     {
      if(cmd_last==buy)
        {
         profit_take=lot_buy/lot_start*i_p;
        }
      else if(cmd_last==sell)
        {
         profit_take=lot_sell/lot_start*i_p;
        }
     }
   gap_trade=gap_start*pow(gap_ratio,count-1);
   lot=NormalizeDouble(lot_start*pow(lot_ratio,count-1),lot_digits);
   lot_net=MathAbs(lot_buy-lot_sell);
   if(lot<lot_min) {lot=lot_min;}//如果小于最小仓位（负数）用最小仓位
   if(lot>lot_max) {lot=lot_max;}//如果大于最大仓位用
  }

//request.action=TRADE_ACTION_DEAL;
//request.magic=magicnumber;
//request.order=0;
//request.symbol=symbol;
//request.volume=lot;
//request.stoplimit=0;
//request.deviation=deviation_order;
//request.type=ORDER_TYPE_BUY;
//request.type_filling=ORDER_FILLING_FOK;
//request.type_time=ORDER_TIME_GTC;
//request.expiration=0;
//request.comment=comment;
//request.position=0;
//request.position_by=0;
//res=OrderSend(request,result);
#endif
//+------------------------------------------------------------------+
