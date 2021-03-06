//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
//#define             TEST_MODE 
enum                ENUM_SWITCH{关=0,开=1};
enum                ENUM_LOTRATIO{功率100=100,功率200=200,功率300=300,功率400=400,功率500=500,功率600=600,功率700=700,功率800=800,功率900=900,功率1000=1000,功率1200=1200,功率1500=1500};
//*********************************************************************************************************************************************************************************** 
#ifdef   TEST_MODE
input int    s_01_sl_ratio_fibo=0;
input int    s_01_odds_fibo=14;
input int    s_01_period_fibo=4;
//*********************************************************************************************************************************************************************************** 
input int    s_04_sl_ratio_fibo=1;
input int    s_04_odds_fibo=20;
input int    s_04_period_fibo=3;
input int    s_04_x_fibo=10;
#endif  
//*********************************************************************************************************************************************************************************** 
#include            <..\Experts\sun\Header.mqh>
//*********************************************************************************************************************************************************************************** 
#property           copyright   "****************若有疑问请按此处通过QQ联系开发者****************"
#property           link        "http://wpa.qq.com/msgrd?v=3&uin=610667697&site=qq&menu=yes"
#property           version     "8.00"     
#property           icon        "\\Experts\\sun\\icon\\warbler.ico"
#property           description "只需在任意品种/周期的图表上加载一次"
#property           description "输入精准的品种名/包括大小写与符号"
#property           description "加载完毕后不要切换图表的周期/避免在信号出现时重置EA重复开仓"
#property           description "不建议手动干预/手动下单"
#property           strict
//*********************************************************************************************************************************************************************************** 
input string        小技巧="下方参数设置完毕后，右边有个保存按钮以便载入";
input string        input_pin="";//激活密匙
input string        激活密匙说明="请在上方粘贴正确激活密匙以运行程序";
input ENUM_LOTRATIO input_equity_ratio=功率500;//开仓功率
input string        开仓功率说明="默认:100%功率/开仓量匹配账户净值大小/以最小开仓量/例:0.01";
input double        input_equity_limit=0;      //回撤控制
input string        回撤控制说明="默认:0/账户净值低于该值停止新建仓/并非立即平所有仓";
input bool          input_sl_switch=开;        //止损开关
input string        止损开关说明="订单附带匹配的止损/警告:慎重关闭";
input double        input_s_01_positive_deviation_ratio=0.00002;
input double        input_s_04_positive_deviation_ratio=0.00015;
input double        input_negative_deviation_ratio=0.00025;
input bool          S_01_switch=开;
input bool          S_04_switch=开;
//*********************************************************************************************************************************************************************************** 
input string        sym_xauusd="XAUUSD";
input string        sym_eurusd="EURUSD";
input string        sym_usdjpy="USDJPY";
input string        sym_gbpusd="GBPUSD";
input string        sym_eurjpy="EURJPY";
input string        sym_eurgbp="EURGBP";
input string        sym_gbpjpy="GBPJPY";
input string        sym_usdchf="USDCHF";
input string        sym_usdcnh="";
input string        sym_usdcad="USDCAD";
input string        sym_audusd="AUDUSD";
//*********************************************************************************************************************************************************************************** 
input ENUM_BS      bs_xauusd=buysell;
input ENUM_BS      bs_eurusd=buysell;
input ENUM_BS      bs_usdjpy=buysell;
input ENUM_BS      bs_gbpusd=buysell;
input ENUM_BS      bs_eurjpy=buysell;
input ENUM_BS      bs_eurgbp=buysell;
input ENUM_BS      bs_gbpjpy=buysell;
input ENUM_BS      bs_usdchf=buysell;
input ENUM_BS      bs_usdcnh=buysell;
input ENUM_BS      bs_usdcad=buysell;
input ENUM_BS      bs_audusd=buysell;
//***********************************************************************************************************************************************************************************
input double        spd_xauusd=0.400;
input double        spd_eurusd=0.00006;
input double        spd_usdjpy=0.007;
input double        spd_gbpusd=0.00009;
input double        spd_eurjpy=0.015;
input double        spd_eurgbp=0.00009;
input double        spd_gbpjpy=0.025;
input double        spd_usdchf=0.00015;
input double        spd_usdcnh=0.00200;
input double        spd_usdcad=0.00015;
input double        spd_audusd=0.00006;
//*********************************************************************************************************************************************************************************** 
Program             *program;
Authorized          *authorized;
Object              *object;
Sequence            *sequence;
Value               *value;
HistoryData         *historydata;
Pre                 *pre[];
Base_Param          *base_param;
//*********************************************************************************************************************************************************************************** 
Pre                sym_input[SYMBOL_SIZE];
Pre                sym_trade[SYMBOL_SIZE];
int                 grp_start=0;
int                 sym_start=0;
int                 sym_size=0;
//*********************************************************************************************************************************************************************************** 
S_01_Param          *s_01_param[][GROUP_SIZE];//组合非必要
int                  s_01_grp_size[];
//*********************************************************************************************************************************************************************************** 
S_01                *s_01[][GROUP_SIZE];
TimeRate            *s_01_timerate[];
Monitor             *s_01_monitor[][GROUP_SIZE];
Order               *s_01_order[][GROUP_SIZE];
//*********************************************************************************************************************************************************************************** 
S_04_Param          *s_04_param[][GROUP_SIZE];
int                  s_04_grp_size[];
//*********************************************************************************************************************************************************************************** 
S_04                *s_04[][GROUP_SIZE];
TimeRate            *s_04_timerate[];
Monitor             *s_04_monitor[][GROUP_SIZE];
Order               *s_04_order[][GROUP_SIZE];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
#ifdef TEST_MODE
   program=new Program(TESTER);
#else
   program=new Program(DEVELOPER);
#endif
//***********************************************************************************************************************************************************************************    
   if(program.mode==GUEST)
     {
      authorized=new Authorized();
      authorized.DecryptCode(input_pin);
      if(!program.mode!=GUEST?true:authorized.CheckAuthorized()){Alert("验证码无效或过期");ExpertRemove();}
      if(program.tester_trade==true){Alert("客户版不开放回测功能");ExpertRemove();}
     }
//*********************************************************************************************************************************************************************************** 
   sym_start=program.mode==TESTER?0:1;
   grp_start=program.mode==TESTER?0:1;
   sym_size=program.mode==TESTER?1:1;
//*********************************************************************************************************************************************************************************** 
   if(program.mode!=TESTER)
     {
      sym_input[XAUUSD].symbol=sym_xauusd;
      sym_input[EURUSD].symbol=sym_eurusd;
      sym_input[USDJPY].symbol=sym_usdjpy;
      sym_input[GBPUSD].symbol=sym_gbpusd;
      sym_input[EURJPY].symbol=sym_eurjpy;
      sym_input[EURGBP].symbol=sym_eurgbp;
      sym_input[GBPJPY].symbol=sym_gbpjpy;
      sym_input[USDCHF].symbol=sym_usdchf;
      sym_input[USDCNH].symbol=sym_usdcnh;
      sym_input[USDCAD].symbol=sym_usdcad;
      sym_input[AUDUSD].symbol=sym_audusd;
      //*********************************************************************************************************************************************************************************** 
      sym_input[XAUUSD].bs=bs_xauusd;
      sym_input[EURUSD].bs=bs_eurusd;
      sym_input[USDJPY].bs=bs_usdjpy;
      sym_input[GBPUSD].bs=bs_gbpusd;
      sym_input[EURJPY].bs=bs_eurjpy;
      sym_input[EURGBP].bs=bs_eurgbp;
      sym_input[GBPJPY].bs=bs_gbpjpy;
      sym_input[USDCHF].bs=bs_usdchf;
      sym_input[USDCNH].bs=bs_usdcnh;
      sym_input[USDCAD].bs=bs_usdcad;
      sym_input[AUDUSD].bs=bs_audusd;
      //*********************************************************************************************************************************************************************************** 
      sym_input[XAUUSD].spread_control=spd_xauusd;
      sym_input[EURUSD].spread_control=spd_eurusd;
      sym_input[USDJPY].spread_control=spd_usdjpy;
      sym_input[GBPUSD].spread_control=spd_gbpusd;
      sym_input[EURJPY].spread_control=spd_eurjpy;
      sym_input[EURGBP].spread_control=spd_eurgbp;
      sym_input[GBPJPY].spread_control=spd_gbpjpy;
      sym_input[USDCHF].spread_control=spd_usdchf;
      sym_input[USDCNH].spread_control=spd_usdcnh;
      sym_input[USDCAD].spread_control=spd_usdcad;
      sym_input[AUDUSD].spread_control=spd_audusd;
      //*********************************************************************************************************************************************************************************** 
      int sym_total=SymbolsTotal(false);
      for(int i_sym_id=0;i_sym_id<sym_total;i_sym_id++){SymbolSelect(SymbolName(i_sym_id,false),false);}
      //*********************************************************************************************************************************************************************************** 
      int sym_input_size=ArraySize(sym_input);
      for(int i=sym_start;i<sym_input_size;i++)
        {
         for(int i_sym_id=0;i_sym_id<sym_total;i_sym_id++)
           {
            string sym_name_selected=SymbolName(i_sym_id,false);
            if(sym_input[i].symbol==sym_name_selected)
              {
               sym_trade[sym_size].symbol=sym_input[i].symbol;
               sym_trade[sym_size].bs=sym_input[i].bs;
               sym_trade[sym_size].spread_control=sym_input[i].spread_control;
               SymbolSelect(sym_input[i].symbol,true);
               sym_size++;
               break;
              }
           }
        }
     }
//*********************************************************************************************************************************************************************************** 
   ArrayResize(pre,sym_size);
   if(program.mode==TESTER){pre[0]=new Pre(_Symbol,buysell,1,sym_usdjpy,sym_gbpusd);}
   if(program.mode!=TESTER)
     {
      for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
        {
         pre[i_sym]=new Pre(sym_trade[i_sym].symbol,sym_trade[i_sym].bs,sym_trade[i_sym].spread_control,sym_usdjpy,sym_gbpusd);
        }
     }
//***********************************************************************************************************************************************************************************      
   sequence=new Sequence();
   if(S_01_switch)
     {
      ArrayResize(s_01_param,sym_size);
      ArrayResize(s_01,sym_size);
      ArrayResize(s_01_order,sym_size);
      ArrayResize(s_01_monitor,sym_size);
      ArrayResize(s_01_timerate,sym_size);
      ArrayResize(s_01_grp_size,sym_size);
      ArrayInitialize(s_01_grp_size,1);
      ENUM_TIMEFRAMES s_01_timeframe=PERIOD_H1;
      //*********************************************************************************************************************************************************************************** 
      for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
        {
         historydata=new HistoryData(pre[i_sym].symbol,s_01_timeframe);
         delete(historydata);
        }
      //*********************************************************************************************************************************************************************************** 
#ifdef  TEST_MODE
      s_01_param[0][0]=new S_01_Param(s_01_sl_ratio_fibo,s_01_odds_fibo,s_01_period_fibo);
      s_01_grp_size[0]=1;
#endif  
      //***********************************************************************************************************************************************************************************         
      if(program.mode!=TESTER)
        {
         for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
           {
            for(int i_grp=grp_start;i_grp<GROUP_SIZE;i_grp++)
              {
               s_01_param[i_sym][i_grp]=new S_01_Param();
               base_param=s_01_param[i_sym][i_grp];//使用多态设置参数
               base_param.SetParam(pre[i_sym].tag_symbol,i_grp);
               //*********************************************************************************************************************************************************************************** 
               if(s_01_param[i_sym][i_grp].pf!=0)
                 {
                  if(s_01_param[i_sym][i_grp].pf>1.4){s_01_param[i_sym][i_grp].pf=1.4;}
                  if(program.mode==DEVELOPER)
                    {
                     Print
                     (
                      "S_01:",pre[i_sym].symbol,"-",i_grp,":",
                      s_01_param[i_sym][i_grp].pf,"-",
                      s_01_param[i_sym][i_grp].sl_ratio_fibo,"-",
                      s_01_param[i_sym][i_grp].odds_fibo,"-",
                      s_01_param[i_sym][i_grp].period_fibo
                      );
                    }
                  s_01_grp_size[i_sym]++;
                 }
               else{break;}
              }
           }
        }
      //***********************************************************************************************************************************************************************************  
      for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
        {
         s_01_timerate[i_sym]=new TimeRate(pre[i_sym].symbol,s_01_timeframe);
         for(int i_grp=grp_start;i_grp<s_01_grp_size[i_sym];i_grp++)
           {
            s_01[i_sym][i_grp]         =new S_01(sequence.PeriodArray[s_01_param[i_sym][i_grp].period_fibo],3);
            s_01_order[i_sym][i_grp]   =new Order(pre[i_sym].symbol,pre[i_sym].spread_control,input_s_01_positive_deviation_ratio,input_negative_deviation_ratio,1,s_01_param[i_sym][i_grp].symgrp);
            s_01_monitor[i_sym][i_grp] =new Monitor(pre[i_sym].symbol);
           }
        }
     }
//*********************************************************************************************************************************************************************************** 
   if(S_04_switch)
     {
      ArrayResize(s_04_param,sym_size);
      ArrayResize(s_04,sym_size);
      ArrayResize(s_04_order,sym_size);
      ArrayResize(s_04_monitor,sym_size);
      ArrayResize(s_04_timerate,sym_size);
      ArrayResize(s_04_grp_size,sym_size);
      ArrayInitialize(s_04_grp_size,1);
      ENUM_TIMEFRAMES s_04_timeframe=PERIOD_M5;
      //*********************************************************************************************************************************************************************************** 
      for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
        {
         historydata=new HistoryData(pre[i_sym].symbol,s_04_timeframe);
         delete(historydata);
        }
      //*********************************************************************************************************************************************************************************** 
#ifdef  TEST_MODE
      s_04_param[0][0]=new S_04_Param(s_04_sl_ratio_fibo,s_04_odds_fibo,s_04_period_fibo,s_04_x_fibo);
      s_04_grp_size[0]=1;
#endif  
      //*********************************************************************************************************************************************************************************** 
      if(program.mode!=TESTER)
        {
         for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
           {
            for(int i_grp=grp_start;i_grp<GROUP_SIZE;i_grp++)
              {
               s_04_param[i_sym][i_grp]=new S_04_Param();
               base_param=s_04_param[i_sym][i_grp];
               base_param.SetParam(pre[i_sym].tag_symbol,i_grp);
               if(s_04_param[i_sym][i_grp].pf!=0)
                 {
                  if(s_04_param[i_sym][i_grp].pf>1.4){s_04_param[i_sym][i_grp].pf=1.4;}
                  if(program.mode==DEVELOPER)
                    {
                     Print(
                           "S_04:",pre[i_sym].symbol,"-",i_grp,":",
                           s_04_param[i_sym][i_grp].pf,"-",
                           s_04_param[i_sym][i_grp].sl_ratio_fibo,"-",
                           s_04_param[i_sym][i_grp].odds_fibo,"-",
                           s_04_param[i_sym][i_grp].period_fibo,"-",
                           s_04_param[i_sym][i_grp].x_fibo
                           );
                    }
                  s_04_grp_size[i_sym]++;
                 }
               else{break;}
              }
           }
        }
      for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
        {
         s_04_timerate[i_sym]=new TimeRate(pre[i_sym].symbol,s_04_timeframe);
         for(int i_grp=grp_start;i_grp<s_04_grp_size[i_sym];i_grp++)
           {
            s_04[i_sym][i_grp]         =new S_04(sequence.PeriodArray[s_04_param[i_sym][i_grp].period_fibo],sequence.RatioArray[s_04_param[i_sym][i_grp].x_fibo]);
            s_04_order[i_sym][i_grp]   =new Order(pre[i_sym].symbol,pre[i_sym].spread_control,input_s_04_positive_deviation_ratio,input_negative_deviation_ratio,4,s_04_param[i_sym][i_grp].symgrp);
            s_04_monitor[i_sym][i_grp] =new Monitor(pre[i_sym].symbol);
           }
        }
     }
//*********************************************************************************************************************************************************************************** 
   for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
     {
      Print("品种:",pre[i_sym].symbol,"合约大小",pre[i_sym].contract_size,"末尾点值",pre[i_sym].ND(pre[i_sym].GetTickValue()));
      Print("品种:",pre[i_sym].symbol,"最小开仓量",pre[i_sym].volumn_min,"最大开仓量",pre[i_sym].volumn_max);
     }
//*********************************************************************************************************************************************************************************** 
   object=new Object();
   string label_left_upper[5];
   string label_left_lower[SYMBOL_SIZE];
   string label_right_lower[2];
   label_left_upper[0]="外汇保证金交易具有极高风险";
   label_left_upper[1]="技术分析是理论，走势回测是实践";
   label_left_upper[2]="历史回测结果证明策略有效,但不代表其未来绩效";
   label_left_upper[3]="模拟和真实交易环境存在滑点区别,本EA只采用市价单入场";
   label_left_upper[4]="无未来函数，记事本写入等欺诈操作";
   if(program.tester_trade)
     {
      int label_left_upper_size=ArraySize(label_left_upper);
      for(int i=0;i<label_left_upper_size;i++)
        {
         object.LabelCreate(0,label_left_upper[i],0,0,20+i*20,CORNER_LEFT_UPPER,label_left_upper[i],"Arial",12,clrGold,0.0,ANCHOR_LEFT_UPPER);
        }
     }
//***********************************************************************************************************************************************************************************     
   label_left_lower[0]="EA运行中-"+"开始时间:"+TimeToString(program.time_start);
   if(program.mode==GUEST){label_left_lower[0]+="-过期时间:"+TimeToString(authorized.GetExpiredTime());}
   for(int i=1;i<sym_size;i++)
     {
      label_left_lower[i]=pre[i].symbol+"/"+DoubleToString(pre[i].spread_control,pre[i].digits);
      if(S_01_switch){label_left_lower[i]+="-S_01_grp:"+IntegerToString(s_01_grp_size[i]-1);}
      if(S_04_switch){label_left_lower[i]+="-S_04_grp:"+IntegerToString(s_04_grp_size[i]-1);}
     }
   int label_left_lower_size=ArraySize(label_left_lower);
   for(int i=0;i<label_left_lower_size;i++)
     {
      if(label_left_lower[i]!=NULL){object.LabelCreate(0,label_left_lower[i],0,0,0+i*12,CORNER_LEFT_LOWER,label_left_lower[i],"Arial",8,clrGold,0.0,ANCHOR_LEFT_LOWER);}
     }
//***********************************************************************************************************************************************************************************      
   label_right_lower[0]="光莺资本";
   label_right_lower[1]="功率:"+DoubleToString(input_equity_ratio,0);
   int label_right_lower_size=ArraySize(label_right_lower);
   for(int i=0;i<label_right_lower_size;i++)
     {
      if(label_right_lower[i]!=NULL){object.LabelCreate(0,label_right_lower[i],0,0,0+i*20,CORNER_RIGHT_LOWER,label_right_lower[i],"Arial",12,clrGold,0.0,ANCHOR_RIGHT_LOWER);}
     }
//*********************************************************************************************************************************************************************************** 
   Print(program.ea_name,"初始化完毕");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!program.auto_trade){return;}
   if(AccountInfoDouble(ACCOUNT_EQUITY)<input_equity_limit)
     {
      ExpertRemove();
      return;
     }
//***********************************************************************************************************************************************************************************      
   for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
     {
      if(S_01_switch)
        {
         for(int i_grp=grp_start;i_grp<s_01_grp_size[i_sym];i_grp++)
           {
            s_01_monitor[i_sym][i_grp].Cross();
            if(pre[i_sym].bs==buysell || pre[i_sym].bs==sell)
              {
               int lower_size=ArraySize(s_01_monitor[i_sym][i_grp].lower);
               for(int i=0;i<lower_size;i++)
                 {
                  if(s_01_monitor[i_sym][i_grp].lower[i].cross==false){continue;}
                  if(s_01_monitor[i_sym][i_grp].lower[i].finish==true){continue;}
                  s_01_order[i_sym][i_grp].lot=s_01_monitor[i_sym][i_grp].lower[i].lot;
                  if(!input_sl_switch){s_01_monitor[i_sym][i_grp].lower[i].above_price=0;}
                  int ord_res=s_01_order[i_sym][i_grp].SendOrder(sell,s_01_monitor[i_sym][i_grp].lower[i].above_price,s_01_monitor[i_sym][i_grp].lower[i].below_price,s_01_monitor[i_sym][i_grp].lower[i].price);
                  if(ord_res>0 || ord_res==130){s_01_monitor[i_sym][i_grp].lower[i].finish=true;}
                 }
              }
            if(pre[i_sym].bs==buysell || pre[i_sym].bs==buy)
              {
               int upper_size=ArraySize(s_01_monitor[i_sym][i_grp].upper);
               for(int i=0;i<upper_size;i++)
                 {
                  if(s_01_monitor[i_sym][i_grp].upper[i].cross==false){continue;}
                  if(s_01_monitor[i_sym][i_grp].upper[i].finish==true){continue;}
                  s_01_order[i_sym][i_grp].lot=s_01_monitor[i_sym][i_grp].upper[i].lot;
                  if(!input_sl_switch){s_01_monitor[i_sym][i_grp].upper[i].below_price=0;}
                  int ord_res=s_01_order[i_sym][i_grp].SendOrder(buy,s_01_monitor[i_sym][i_grp].upper[i].below_price,s_01_monitor[i_sym][i_grp].upper[i].above_price,s_01_monitor[i_sym][i_grp].upper[i].price);
                  if(ord_res>0 || ord_res==130){s_01_monitor[i_sym][i_grp].upper[i].finish=true;}
                 }
              }
           }
        }
      //*********************************************************************************************************************************************************************************** 
      if(S_04_switch)
        {
         for(int i_grp=grp_start;i_grp<s_04_grp_size[i_sym];i_grp++)
           {
            s_04_monitor[i_sym][i_grp].Cross();
            if(pre[i_sym].bs==buysell || pre[i_sym].bs==sell)
              {
               int lower_size=ArraySize(s_04_monitor[i_sym][i_grp].lower);
               for(int i=0;i<lower_size;i++)
                 {
                  if(s_04_monitor[i_sym][i_grp].lower[i].cross==false){continue;}
                  if(s_04_monitor[i_sym][i_grp].lower[i].finish==true){continue;}
                  s_04_order[i_sym][i_grp].lot=s_04_monitor[i_sym][i_grp].lower[i].lot;
                  if(!input_sl_switch){s_04_monitor[i_sym][i_grp].lower[i].above_price=0;}
                  int ord_res=s_04_order[i_sym][i_grp].SendOrder(sell,s_04_monitor[i_sym][i_grp].lower[i].above_price,s_04_monitor[i_sym][i_grp].lower[i].below_price,s_04_monitor[i_sym][i_grp].lower[i].price);
                  if(ord_res>0 || ord_res==130){s_04_monitor[i_sym][i_grp].lower[i].finish=true;}
                 }
              }
            if(pre[i_sym].bs==buysell || pre[i_sym].bs==buy)
              {
               int upper_size=ArraySize(s_04_monitor[i_sym][i_grp].upper);
               for(int i=0;i<upper_size;i++)
                 {
                  if(s_04_monitor[i_sym][i_grp].upper[i].cross==false){continue;}
                  if(s_04_monitor[i_sym][i_grp].upper[i].finish==true){continue;}
                  s_04_order[i_sym][i_grp].lot=s_04_monitor[i_sym][i_grp].upper[i].lot;
                  if(!input_sl_switch){s_04_monitor[i_sym][i_grp].upper[i].below_price=0;}
                  int ord_res=s_04_order[i_sym][i_grp].SendOrder(buy,s_04_monitor[i_sym][i_grp].upper[i].below_price,s_04_monitor[i_sym][i_grp].upper[i].above_price,s_04_monitor[i_sym][i_grp].upper[i].price);
                  if(ord_res>0 || ord_res==130){s_04_monitor[i_sym][i_grp].upper[i].finish=true;}
                 }
              }
           }
        }
      //*********************************************************************************************************************************************************************************** 
     }
//*********************************************************************************************************************************************************************************** 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(program.mode==GUEST)
     {
      ObjectsDeleteAll(0);
      datetime now=TimeCurrent();
      if(authorized.GetExpiredTime()<now || program.time_dead<now){Alert("超过期限");ExpertRemove();}
     }
   if(S_01_switch)
     {
      for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
        {
         if(s_01_timerate[i_sym].NewFlag())
           {
            s_01_timerate[i_sym].RenewFlag();
            if(!s_01_timerate[i_sym].GetMQL(0,1000)){continue;}
            for(int i_grp=grp_start;i_grp<s_01_grp_size[i_sym];i_grp++)
              {
               Print(pre[i_sym].symbol,"S_01_Fun:","period:",s_01[i_sym][i_grp].period);
               s_01[i_sym][i_grp].Function(s_01_timerate[i_sym].rates);
               if(program.show)
                 {
                  Print(pre[i_sym].symbol,"第一支撑位:",s_01[i_sym][i_grp].lower[0].price,"成立时间:",s_01[i_sym][i_grp].lower[0].time);
                  Print(pre[i_sym].symbol,"第一阻力位:",s_01[i_sym][i_grp].upper[0].price,"成立时间:",s_01[i_sym][i_grp].upper[0].time);
                 }
               double sl_ratio=sequence.RatioArray[s_01_param[i_sym][i_grp].sl_ratio_fibo];//得到止损的价格百分比率
               double odds=sequence.OddsArray[s_01_param[i_sym][i_grp].odds_fibo];//得到赔率
               double tp_ratio=sl_ratio*odds;//得到盈利的价格百分比率
               int reduce=1;
               //重置初始化信号数组，拷贝买卖数组到信号数组
               int s_01_monitor_lower_size=ArraySize(s_01[i_sym][i_grp].lower);
               int s_01_monitor_upper_size=ArraySize(s_01[i_sym][i_grp].upper);
               s_01_monitor[i_sym][i_grp].ResizeInitial(s_01_monitor_lower_size,s_01_monitor_upper_size);
               //*********************************************************************************************************************************************************************************** 
               for(int i=0;i<s_01_monitor_lower_size;i++)
                 {
                  s_01_monitor[i_sym][i_grp].lower[i].price=s_01[i_sym][i_grp].lower[i].price;
                  if(s_01_monitor[i_sym][i_grp].lower[i].price!=0)
                    {
                     //万分比止盈止损
                     s_01_monitor[i_sym][i_grp].lower[i].above_price=s_01_monitor[i_sym][i_grp].lower[i].price*(1+sl_ratio);
                     s_01_monitor[i_sym][i_grp].lower[i].below_price=s_01_monitor[i_sym][i_grp].lower[i].price*(1-tp_ratio);
                     //*********************************************************************************************************************************************************************************** 
                     //因为点值会变所以一定要新new，10000万块1手波动*点值=净损率,建立凯利价值
                     //提前准备好检测买卖，牺牲最精确的净值和点值的凯利系数计算
                     value=new Value(false,(sl_ratio*s_01_monitor[i_sym][i_grp].lower[i].price/pre[i_sym].point)*pre[i_sym].GetTickValue()/10000,odds,s_01_param[i_sym][i_grp].pf);
                     //得到修正的凯利系数
                     double lot_equity_ratio=value.GetRatioKelly()/(s_01_grp_size[i_sym]-grp_start)/reduce*input_equity_ratio/1000;
                     //根据修正凯利系数根据净值计算1万块1手得到具体手数
                     s_01_order[i_sym][i_grp].LotsOptimized(0.01,lot_equity_ratio);
                     s_01_monitor[i_sym][i_grp].lower[i].lot=s_01_order[i_sym][i_grp].lot;
                     delete value;
                     //*********************************************************************************************************************************************************************************** 
                    }
                 }
               //***********************************************************************************************************************************************************************************
               for(int i=0;i<s_01_monitor_upper_size;i++)
                 {
                  s_01_monitor[i_sym][i_grp].upper[i].price=s_01[i_sym][i_grp].upper[i].price;
                  if(s_01_monitor[i_sym][i_grp].upper[i].price!=0)
                    {
                     s_01_monitor[i_sym][i_grp].upper[i].below_price=s_01_monitor[i_sym][i_grp].upper[i].price*(1-sl_ratio);
                     s_01_monitor[i_sym][i_grp].upper[i].above_price=s_01_monitor[i_sym][i_grp].upper[i].price*(1+tp_ratio);
                     //*********************************************************************************************************************************************************************************** 
                     value=new Value(false,(sl_ratio*s_01_monitor[i_sym][i_grp].upper[i].price/pre[i_sym].point)*pre[i_sym].GetTickValue()/10000,odds,s_01_param[i_sym][i_grp].pf);
                     double lot_equity_ratio=value.GetRatioKelly()/(s_01_grp_size[i_sym]-grp_start)/reduce*input_equity_ratio/1000;
                     s_01_order[i_sym][i_grp].LotsOptimized(0.01,lot_equity_ratio);
                     s_01_monitor[i_sym][i_grp].upper[i].lot=s_01_order[i_sym][i_grp].lot;
                     delete value;
                     //*********************************************************************************************************************************************************************************** 
                    }
                 }
              }
           }
        }
     }
   if(S_04_switch)
     {
      for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
        {
         if(s_04_timerate[i_sym].NewFlag())
           {
            s_04_timerate[i_sym].RenewFlag();
            if(!s_04_timerate[i_sym].GetMQL(0,1100)){continue;}
            for(int i_grp=grp_start;i_grp<s_04_grp_size[i_sym];i_grp++)
              {
               Print(pre[i_sym].symbol,"S_04_Fun:","period:",s_04[i_sym][i_grp].period);
               s_04[i_sym][i_grp].Function(s_04_timerate[i_sym].rates);
               double sl_ratio=sequence.RatioArray[s_04_param[i_sym][i_grp].sl_ratio_fibo];
               double odds=sequence.OddsArray[s_04_param[i_sym][i_grp].odds_fibo];
               double tp_ratio=sl_ratio*odds;
               int reduce=1;
               int s_04_monitor_lower_size=ArraySize(s_04[i_sym][i_grp].lower);
               int s_04_monitor_upper_size=ArraySize(s_04[i_sym][i_grp].upper);
               s_04_monitor[i_sym][i_grp].ResizeInitial(s_04_monitor_lower_size,s_04_monitor_upper_size);
               //*********************************************************************************************************************************************************************************** 
               for(int i=0;i<s_04_monitor_lower_size;i++)
                 {
                  s_04_monitor[i_sym][i_grp].lower[i].price=s_04[i_sym][i_grp].lower[i].price;
                  if(s_04_monitor[i_sym][i_grp].lower[i].price!=0)
                    {
                     s_04_monitor[i_sym][i_grp].lower[i].above_price=s_04_monitor[i_sym][i_grp].lower[i].price*(1+sl_ratio);
                     s_04_monitor[i_sym][i_grp].lower[i].below_price=s_04_monitor[i_sym][i_grp].lower[i].price*(1-tp_ratio);
                     //*********************************************************************************************************************************************************************************** 
                     value=new Value(false,(sl_ratio*s_04_monitor[i_sym][i_grp].lower[i].price/pre[i_sym].point)*pre[i_sym].GetTickValue()/10000,odds,s_04_param[i_sym][i_grp].pf);
                     double lot_equity_ratio=value.GetRatioKelly()/(s_04_grp_size[i_sym]-grp_start)/reduce*input_equity_ratio/1000;
                     s_04_order[i_sym][i_grp].LotsOptimized(0.01,lot_equity_ratio);
                     s_04_monitor[i_sym][i_grp].lower[i].lot=s_04_order[i_sym][i_grp].lot;
                     delete value;
                     //*********************************************************************************************************************************************************************************** 
                    }
                 }
               //***********************************************************************************************************************************************************************************
               for(int i=0;i<s_04_monitor_upper_size;i++)
                 {
                  s_04_monitor[i_sym][i_grp].upper[i].price=s_04[i_sym][i_grp].upper[i].price;
                  if(s_04_monitor[i_sym][i_grp].upper[i].price!=0)
                    {
                     s_04_monitor[i_sym][i_grp].upper[i].below_price=s_04_monitor[i_sym][i_grp].upper[i].price*(1-sl_ratio);
                     s_04_monitor[i_sym][i_grp].upper[i].above_price=s_04_monitor[i_sym][i_grp].upper[i].price*(1+tp_ratio);
                     //*********************************************************************************************************************************************************************************** 
                     value=new Value(false,(sl_ratio*s_04_monitor[i_sym][i_grp].upper[i].price/pre[i_sym].point)*pre[i_sym].GetTickValue()/10000,odds,s_04_param[i_sym][i_grp].pf);
                     double lot_equity_ratio=value.GetRatioKelly()/(s_04_grp_size[i_sym]-grp_start)/reduce*input_equity_ratio/1000;
                     s_04_order[i_sym][i_grp].LotsOptimized(0.01,lot_equity_ratio);
                     s_04_monitor[i_sym][i_grp].upper[i].lot=s_04_order[i_sym][i_grp].lot;
                     delete value;
                     //*********************************************************************************************************************************************************************************** 
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
   double result=0;
#ifdef   TEST_MODE
   datetime time_end=TimeCurrent();
   double deposit=TesterStatistics(STAT_INITIAL_DEPOSIT);
   double pf=TesterStatistics(STAT_PROFIT_FACTOR);
   double maxdd=TesterStatistics(STAT_EQUITY_DDREL_PERCENT);
   double recovery=TesterStatistics(STAT_RECOVERY_FACTOR);
   double year=double(time_end-program.time_start)/3600/24/365;
   double trades=TesterStatistics(STAT_TRADES);
   double tradesperyear=trades/year;
   double odds=0;
   if(S_01_switch){odds=(sequence.OddsArray[s_01_odds_fibo]);}
   if(S_04_switch){odds=(sequence.OddsArray[s_04_odds_fibo]);}
   Value back(program.show,0.1,odds,pf);//止损为0也没关系，只认胜率赔率盈利比计算凯利值
   double maxvalue=MathPow(back.value_kelly,tradesperyear);
   result=maxvalue;
   Print("采收率",recovery);
   Print("订单数",trades);
   Print("年",year);
   Print("年均订单",tradesperyear);
   Print("理论年凯利值",maxvalue);
   Print("最大回撤",maxdd);
   Print("返回值",result);
#endif 
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(!program.tester_trade){ObjectsDeleteAll(0);}
   delete (base_param);
   delete (authorized);
   delete (sequence);
   delete (object);
   delete (value);
   delete (historydata);
   for(int i_sym=sym_start;i_sym<sym_size;i_sym++)
     {
      delete (pre[i_sym]);
      if(S_01_switch)
        {
         for(int i_grp=0;i_grp<GROUP_SIZE;i_grp++)
           {
            delete (s_01_timerate[i_sym]);
            delete (s_01_order[i_sym][i_grp]);
            delete (s_01[i_sym][i_grp]);
            delete (s_01_param[i_sym][i_grp]);
            delete (s_01_monitor[i_sym][i_grp]);
           }
        }
      if(S_04_switch)
        {
         for(int i_grp=0;i_grp<GROUP_SIZE;i_grp++)
           {
            delete (s_04_timerate[i_sym]);
            delete (s_04_order[i_sym][i_grp]);
            delete (s_04[i_sym][i_grp]);
            delete (s_04_param[i_sym][i_grp]);
            delete (s_04_monitor[i_sym][i_grp]);
           }
        }
     }
   delete (program);
  }
//+------------------------------------------------------------------+
