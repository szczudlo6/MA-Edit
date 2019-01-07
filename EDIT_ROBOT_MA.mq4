 //+-----------------------------------------------------------------+
//|                                                         MA ROBOT |
//|                                            Make your trade SMART |
//|                                     by FOREXALLDAY.wordpress.com |
//+------------------------------------------------------------------+
#property copyright "MA ROBOT"
#property link      "https://forexallday.wordpress.com"
#property version   "1.00"
#property strict

extern int MAPeriod = 33;
extern int CandleNumber=1;
extern double MoneyRisk=2.0;
extern double StopLossLine = 100;

extern double PriceDeviation=20;
extern double TrailingStop = 0;

#include <EDIT_clsMA.mqh>
#include <EDIT_clsOrder.mqh>
#include <EDIT_clsFile.mqh>
#include <hCandle.mqh>

int OpenedOrders=0;
int MaxOpenPosition = 1;

clsOrder Order(MoneyRisk,MaxOpenPosition);
clsFile FilesOrders("MA_ROBOT_"+(string)AccountNumber() + "_"+Symbol()+"_"+(string)Period()+"_Orders.txt");
clsMA MA(StopLossLine,MAPeriod,CandleNumber);

int OnInit()
  {
   strGlobal arr[];
   int CheckOpenPosition=0;
   //initTrendLineClass(TrendLinePeriod,BarsLimit,TrendLinesNum,PriceDeviation,CandleNumber);
   Comment("Account Balance: " + (string)NormalizeDouble(AccountBalance(),2));
   
   initTimeCandle(CandleNumber);
   FilesOrders.Init();
   //get open position
   CheckOpenPosition=FilesOrders.GetOpenOrder();
   
   if(CheckOpenPosition > OpenedOrders)
      OpenedOrders=CheckOpenPosition;

   //copy array
   FilesOrders.GetOrderArrayFromFile(arr);
   Order.SetOrderArrayFromFile(arr);
   
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {   
   if(OpenedOrders==0 && CheckCurrentCandle(CandleNumber))
      if(MA.MACheckPrice())
         if(Order.OpenOrder(OpenedOrders,MA.GetOrder(),0,MA.GetStopLoss(),0,MA.GetMagicNumber()))
         {
            //add magicnumber to file
            if (!FilesOrders.AddMagicNumber(MA.GetMagicNumber()))
               Print("Cannot add order to array");
               
            OpenedOrders++;
         }
   else if (OpenedOrders>0)
      CheckCurrentOrders();
   
  }
  
void CheckCurrentOrders()
{  
   int magicnumber=0;
   int b=false;
   
   for (int i=OrdersTotal()-1; i >= 0 ;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         magicnumber = OrderMagicNumber();
         if(Order.CheckMagicNumber(magicnumber))
         {
            b=true;
            Order.Trailing(magicnumber,TrailingStop);
            if(MA.MACheckPrice())
               if(Order.CloseOrderByMagicNumber(magicnumber))
               {
                  OpenedOrders--;
                  FilesOrders.Init();
               }
         } 
      }
   }
   
   //if order was opened but not exist in server
   if (!b)
      OpenedOrders=0;
}
