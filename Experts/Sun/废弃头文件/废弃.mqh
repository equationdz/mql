////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//bool Order::CloseHedgeOrder(int spreadhedge)
//  {
//   bool res=false;
//   MqlTradeResult closeresult={0};
//   MqlTradeRequest closerequest={0};
//   for(int i=PositionsTotal()-1; i>=0; i--)
//     {
//      ulong  position_ticket=PositionGetTicket(i);
//      string position_symbol=PositionGetString(POSITION_SYMBOL);
//      ulong  position_magic=PositionGetInteger(POSITION_MAGIC);
//      double position_volume=PositionGetDouble(POSITION_VOLUME);
//      ENUM_POSITION_TYPE position_type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
//      if(position_ticket)
//        {
//         if(position_magic==magicnumber && position_symbol==symbol)
//           {
//            for(int j=0; j<i; j++)
//              {
//               string closebysymbol=PositionGetSymbol(j); // 反向持仓交易品种
//               //--- 如果反向持仓交易品种和初始交易品种匹配
//               if(closebysymbol==position_symbol)
//                 {
//                  //--- 设置反向持仓类型
//                  ENUM_POSITION_TYPE type_by=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
//                  //--- 离开，如果初始持仓和反向持仓类型匹配
//                  if(position_type==type_by)
//                    {
//                     continue;
//                    }
//                  //--- 归零请求和结果值
//                  ZeroMemory(closerequest);
//                  ZeroMemory(closeresult);
//                  //--- 设置操作参数
//                  closerequest.action=TRADE_ACTION_CLOSE_BY;                         // 交易操作类型
//                  closerequest.position=position_ticket;                             // 持仓票据
//                  closerequest.position_by=PositionGetInteger(POSITION_TICKET);      // 反向持仓票据
//                  closerequest.symbol     =position_symbol;
//                  //closerequest.magic=position_magic;                                   // 持仓的幻数
//                  if(GetSpread()<=spreadhedge)
//                    {
//                     res=OrderSend(closerequest,closeresult);
//                     if(!res)
//                       {
//                        Print("OrderHedgeClose Failed. Error code=",GetLastError());
//                       }
//                     break;
//                    }
//                 }
//              }
//           }
//        }
//     }
//   return res;
//  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void Order::CloseHedgeOrder(double spreadhedge)
//  {
//   bool res=false;
//   for(int i=OrdersTotal()-1; i>=0; i--)
//     {
//      int ticket=0;
//      int  type=0;
//      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==True && OrderMagicNumber()==magicnumber && OrderSymbol()==symbol)
//        {
//         ticket=OrderTicket();
//         type=ENUM_ORDERTYPE();
//         for(int j=0; j<i; j++)
//           {
//            if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==True && OrderMagicNumber()==magicnumber && OrderSymbol()==symbol)
//              {
//               if(type!=ENUM_ORDERTYPE() && ENUM_ORDERTYPE()<=1)
//                 {
//                  if(GetSpread()<=spreadhedge)
//                    {
//                     res=OrderCloseBy(ticket,OrderTicket());
//                     if(!res)
//                       {
//                        Print("OrderClose Failed. Error code=",GetLastError());
//                        break;
//                       }
//                    }
//                 }
//              }
//           }
//        }
//     }
//  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void Order::TrailingStop(double trailingstoppoint)
//  {
//   bool res=false;
//   for(int i=OrdersTotal()-1; i>=0; i--)
//     {
//      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==True && OrderSymbol()==symbol && OrderMagicNumber()==magicnumber)
//        {
//         if(ENUM_ORDERTYPE()==OP_BUY)
//           {
//            if(MarketInfo(symbol,MODE_BID)-OrderOpenPrice()>trailingstoppoint)
//              {  //一定在盈利时启动盈利止损
//               if(OrderStopLoss()<MarketInfo(symbol,MODE_BID)-trailingstoppoint)
//                 {      //卖价-止损价大于移动止损时  修改止损价为  前止损价+追踪止损
//                  res=OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(symbol,MODE_BID)-trailingstoppoint,OrderTakeProfit(),0,Yellow);
//                 }
//              }
//              } else if(ENUM_ORDERTYPE()==OP_SELL) {
//            if(OrderOpenPrice()-MarketInfo(symbol,MODE_ASK)>trailingstoppoint)
//              {    //
//               if(OrderStopLoss()>MarketInfo(symbol,MODE_ASK)+trailingstoppoint || (OrderStopLoss()==0))
//                 {      //止损价减-买价大于移动止损时  修改止损价为  前止损价-追踪止损
//                  res=OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(symbol,MODE_ASK)+trailingstoppoint,OrderTakeProfit(),0,Yellow);
//                 }
//              }
//           }
//         if(!res)
//           {
//            Print("Error in TrailingStop OrderModify. Error code=",GetLastError());
//           }
//        }
//     }
//  }