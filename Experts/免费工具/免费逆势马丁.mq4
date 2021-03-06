//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property    copyright   "****************若有疑问请按此处通过QQ联系开发者****************"
#property    description "光莺资本制作发布，用户盈亏自负"
#property    description "设定参数可保存后便于下次加载"
#property    link        "http://wpa.qq.com/msgrd?v=3&uin=610667697&site=qq&menu=yes"
#property strict
#include            <..\Experts\sun\Order.mqh>
#include            <..\Experts\sun\Object.mqh>
#include            <..\Experts\sun\AuthorizedFree.mqh>
enum Switch{关=0,开=1};
input string input_pin="";//激活密匙
input double input_profit=1;//品种单独清算获利XXX美金全部平仓
input ENUM_BS input_type=buy;//指定开仓方向买多/买空/双向
input bool   input_first_switch=开;//第一单开仓开关/（关）收尾操作
input bool   input_add_switch=true;//加仓开关
input bool   input_profit_lot_switch=false;//净头寸/初始头寸*设定盈利
input double input_lot_start=0.01;//第一单手数
input string warning="友情提醒：注意加仓距离的填写！！！";
input double input_spread=0.0002;//点差控制(报价)
input double input_gap=0.00100;   //下一单加仓距离(按报价欧美10标准点=0.001)
input double input_lot_ratio=1.0; //下一单加仓手数倍数
input double input_gap_ratio=1.0; //下一单加仓距离倍数
input bool   input_add_spread_switch=开;//加仓时点差控制
input int    input_equitylimit=0;//账户净值低于该值立即平所有仓
OrderManage *sellfunction;
OrderManage *buyfunction;
AuthorizedFree *authorization;
Object *object;
bool allow=true;
string ea_name;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ea_name=MQLInfoString(MQL_PROGRAM_NAME);
   Print(ea_name,"开始初始化");
   ObjectsDeleteAll(0);
   authorization=new AuthorizedFree();
   authorization.DecryptCode(input_pin);
//if(!authorization.CheckAuthorizedFree())
//  {
//   Alert("验证码无效或过期,EA已卸载");
//   ExpertRemove();
//   return INIT_FAILED;
//  }
   sellfunction=new OrderManage(true,7771,input_profit,input_profit_lot_switch,input_lot_start,input_lot_ratio,input_gap,input_gap_ratio);
   buyfunction=new OrderManage(true,7772,input_profit,input_profit_lot_switch,input_lot_start,input_lot_ratio,input_gap,input_gap_ratio);
   if(!MQLInfoInteger(MQL_TESTER)){allow=TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);}
   object=new Object();
   string label_left_lower[10];
   label_left_lower[0]="点差"+DoubleToString(input_spread,_Digits);
   label_left_lower[1]="距离"+DoubleToString(input_gap,_Digits);
   string way[4]={"","买","卖","双向"};
   string kaiguan[2]={"关","开"};
   label_left_lower[2]="方向"+way[input_type];
   label_left_lower[3]="手数"+DoubleToString(input_lot_start,2);
   label_left_lower[4]="开仓"+kaiguan[input_first_switch];
   label_left_lower[5]="加仓"+kaiguan[input_add_switch];
   label_left_lower[6]="仓系"+DoubleToString(input_lot_ratio,1);
   label_left_lower[7]="距系"+DoubleToString(input_gap_ratio,1);
   label_left_lower[7]="强平"+DoubleToString(input_equitylimit,1);
   for(int i=0;i<ArrayRange(label_left_lower,0);i++)
     {
      if(label_left_lower[i]!=NULL){object.LabelCreate(0,label_left_lower[i],0,0,0+i*10,CORNER_LEFT_LOWER,label_left_lower[i],"Arial",8,clrGold,0.0,ANCHOR_LEFT_LOWER);}
     }
   Print(ea_name,"初始化完毕");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete sellfunction;
   delete buyfunction;
   delete authorization;
   delete object;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(allow==false){return;}
   if(TimeCurrent()>=D'2017.08.17')
     {
      Alert("超过使用期限");
      ExpertRemove();
     }
   if(AccountInfoDouble(ACCOUNT_EQUITY)<input_equitylimit)
     {
      sellfunction.CloseOrder(buysell);
      return;
     }
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double spread=NormalizeDouble(SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)*_Point,_Digits);
   if(input_type==sell || input_type==buysell)
     {
      sellfunction.Function();
      //Print("sellprofit:",sellfunction.profit_total,"take",sellfunction.profit_take);
      if(sellfunction.profit_total>=sellfunction.profit_take)
        {
         sellfunction.CloseOrder(sell);
        }
      if(sellfunction.count==0)
        {
         if(input_first_switch)
           {
            if(spread<=input_spread)
              {
               sellfunction.lot=input_lot_start;
               sellfunction.SendOrder(sell);
              }
           }
        }
      else if(input_add_switch)
        {
         if(spread<=input_spread || !input_add_spread_switch)
           {
            if(sellfunction.cmd_last==sell && bid>=sellfunction.price_last+sellfunction.gap_trade)
              {
               sellfunction.SendOrder(sell);
              }
           }
        }
     }
   if(input_type==buy || input_type==buysell)
     {
      buyfunction.Function();
      //Print("buyprofit:",sellfunction.profit_total,"take",buyfunction.profit_take);
      if(buyfunction.profit_total>=buyfunction.profit_take)
        {
         buyfunction.CloseOrder(buy);
        }
      if(buyfunction.count==0)
        {
         if(input_first_switch)
           {
            if(spread<=input_spread)
              {
               buyfunction.lot=input_lot_start;
               buyfunction.SendOrder(buy);
              }
           }
        }
      else if(input_add_switch)
        {
         if(spread<=input_spread || !input_add_spread_switch)
           {
            if(buyfunction.cmd_last==buy && ask<=buyfunction.price_last-buyfunction.gap_trade)
              {
               buyfunction.SendOrder(buy);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
double OnTester()
  {
   double maxdd=TesterStatistics(STAT_EQUITY_DD_RELATIVE);//最大回撤
   double value=TesterStatistics(STAT_PROFIT);
   return value/maxdd*100;
  }
//+------------------------------------------------------------------+
