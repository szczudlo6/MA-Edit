//+------------------------------------------------------------------+
//|                                                         MA class |
//|                                            Make your trade SMART |
//|                                     by FOREXALLDAY.wordpress.com |
//+------------------------------------------------------------------+
#property copyright "MA class"
#property link      "https://forexallday.wordpress.com"
#property version   "1.00"
#property strict

#import "clsHelperFunction.ex4"
      string CreateMagicNumber();
#import


class clsMA
  {
private:
                     int MAPeriod;
                     int CandleNumber;
                     int order;
                     int MagicNumber;
                     double StopLoss;
                     double StopLossLine;
                     double GetMAPrice();
public:
                     bool MACheckPrice();
                     int GetOrder() {return(order);};
                     int GetMagicNumber() {return(MagicNumber);};
                     double GetStopLoss() {return(StopLoss);};
                     clsMA(double _StopLossLine, int _MAPeriod, int _CandleNumber);
                    ~clsMA();
  };
   
   
double clsMA::GetMAPrice()
{
   double Price=iMA(Symbol(),Period(),MAPeriod,0,MODE_SMA,PRICE_CLOSE,CandleNumber);
   
   return(Price);
}

bool clsMA::MACheckPrice()
{
   double CloseBar;
   double PrevCloseBar;
   double MAPrice;
   bool b=false;
   
   CloseBar = Close[CandleNumber];
   PrevCloseBar=Close[CandleNumber+1];
   MAPrice=GetMAPrice();
   
   if(CloseBar>=MAPrice && PrevCloseBar < MAPrice)
   {
      order=0; //buy
      MagicNumber =(int)CreateMagicNumber();
      StopLoss= MathAbs((((MAPrice-(StopLossLine*Point))-Ask)/Point));
      b=true;  
   }
   else if (CloseBar<=MAPrice && PrevCloseBar >MAPrice)
   {
      order=1; //sell
      MagicNumber =(int)CreateMagicNumber();
      StopLoss= MathAbs((((MAPrice+(StopLossLine*Point))-Bid)/Point));
      b=true;
   }
   
   return(b);
}

clsMA::clsMA(double _StopLossLine, int _MAPeriod, int _CandleNumber)
  {
      MAPeriod=_MAPeriod;
      CandleNumber=_CandleNumber;
      StopLossLine=_StopLossLine;
  }

clsMA::~clsMA()
  {
  }

