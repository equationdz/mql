//+------------------------------------------------------------------+
//|                                                         取消挂单.mq4 |
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
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderSymbol()==_Symbol)
           {
            if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
              {
               if(OrderMagicNumber()==382828)
                 {
                  while(OrderDelete(OrderTicket())==false && !IsStopped())
                    {
                     Sleep(30);
                    }
                 }
              }
           }
        }
     }
  }

