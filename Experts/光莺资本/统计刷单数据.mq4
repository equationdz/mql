//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property  strict
input bool symbolswitch=false;
input bool commentswitch=false;
input bool magicswitch=true;
input string  comment="333";
input int  magic=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   double tp=0;
   double swap=0;
   double commission=0;
   double countlot=0;
   double buy_cnt=0;
   double sell_cnt=0;
   datetime first_datetime=D'2500.01.01 00:00:00';
   datetime last_datetime=0;
   int num=0;
   for(int i=0;i<OrdersHistoryTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()==Symbol() || !symbolswitch)
           {
            if(StringFind(OrderComment(),comment,0)>=0 || !commentswitch)
              {
               if(OrderMagicNumber()==magic || !magicswitch)
                 {
                  datetime order_opentime=OrderOpenTime();
                  if(order_opentime<first_datetime){first_datetime=order_opentime;}
                  if(order_opentime>last_datetime){last_datetime=order_opentime;}
                  tp+=OrderProfit();
                  commission+=OrderCommission();
                  swap+=OrderSwap();
                  countlot+=OrderLots();
                  num++;
                  double deviationtemp=(OrderProfit()-OrderCommission())/_Point;
                  if(OrderType()==OP_BUY){buy_cnt++;}
                  else if(OrderType()==OP_SELL){sell_cnt++;}
                 }
              }
           }
        }
     }
   double day_between=double(last_datetime-first_datetime)/3600/24.0;
   Alert("选定历史周期里盈亏情况(账户基础货币):",NormalizeDouble(tp+commission+swap,2),"总共交易:",NormalizeDouble(countlot,2),"手");
   Alert(num,"单,","手续费:",NormalizeDouble(commission,2),"仓息费:",NormalizeDouble(swap,2));
   Alert("总共交易:",NormalizeDouble(countlot,2),"手",num,"单");
   Alert("相差",NormalizeDouble(day_between,4),"天");
   Alert("日均下单",NormalizeDouble(num/day_between,2),"月均下单",NormalizeDouble(num/day_between*30,2));
   Alert("日均手数",NormalizeDouble(countlot/day_between,2),"月均手数",NormalizeDouble(countlot/day_between*30,2));
   ExpertRemove();
  }
//+------------------------------------------------------------------+
void OnTick()
  {
  }
//+---------