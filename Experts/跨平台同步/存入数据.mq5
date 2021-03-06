//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <MQLMySQL.mqh>
enum DATABASE{metaquotes=0,apari=1,xm=2};
input string host="localhost";
input string user="root";
input string password="1234";
input DATABASE database=metaquotes;
int DB_1;
string db_name[10];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   db_name[0]="metaquotes";
   db_name[1]="apari";
   db_name[2]="xm";
   string db_usd=db_name[database];
   EventSetMillisecondTimer(100);
   Print(MySqlVersion());
   Print("Connecting...");
   DB_1=MySqlConnect(host,user,password,db_usd,3306,"0",CLIENT_MULTI_STATEMENTS);
   if(DB_1==-1) { Print("Connection failed! Error: "+MySqlErrorDescription); } else { Print("Connected! DBID#",DB_1);}
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   MySqlDisconnect(DB_1);
   Print("Disconnected. Script done!");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//ulong t1=GetMicrosecondCount();
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
   double mid=(tick.ask+tick.bid)/2;
   string Query="INSERT INTO `eurusd_tick` (symbol,time_local,mid,time_sever,bid,ask,spread) VALUES"+
                  "("
                  +"\'"+_Symbol+"\'"+","
                  +"\'"+TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS)+"\'"+","
                  +DoubleToString(mid,_Digits+1)+","
                  +"\'"+TimeToString(tick.time,TIME_DATE|TIME_SECONDS)+"\'"+","
                  +DoubleToString(tick.bid,_Digits)+","+DoubleToString(tick.ask,_Digits)+","+DoubleToString(tick.ask-tick.bid,_Digits)
                  +");";
   if(MySqlExecute(DB_1,Query))
     {
      //Print("Succeeded: ",Query);
      //Print((GetMicrosecondCount()-t1)/1000000.0);
     }
   else
     {
      Print("Error: ",MySqlErrorDescription);
      Print("Error Query: ",Query);
     }
  }
//+------------------------------------------------------------------+
