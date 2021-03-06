//+------------------------------------------------------------------+
//|                                                         LRMA.mq5 |
//|                                            Copyright 2014, Vinin |
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Vinin"
#property link      "http:\\vinin.ucoz.ru"
#property version   "1.00"
#property description "Ëèíåéíàÿ ðåãðåññèÿ ÿâëÿåòñÿ ñòàòèñòè÷åñêèì èíñòðóìåíòîì, èñïîëüçóåìûì äëÿ"
#property description "ïðîãíîçèðîâàíèÿ áóäóùèõ öåí èñõîäÿ èç ïðîøëûõ äàííûõ. Èñïîëüçóåòñÿ ìåòîä "
#property description "íàèìåíüøèõ êâàäðàòîâ äëÿ ïîñòðîåíèÿ «íàèáîëåå ïîäõîäÿùåé» ïðÿìîé ëèíèè "
#property description "÷åðåç ðÿä òî÷åê öåíîâûõ çíà÷åíèé. Â êà÷åñòâå âõîäíûõ ïàðàìåòðîâ èñïîëüçóåòñÿ "
#property description "êîëè÷åñòâî ðàñ÷åòíûõ áàðîâ (ñâå÷åé). Äàííûé èíäèêàòîð õîðîøî èñïîëüçîâàòü äëÿ àâòîìàòè÷åñêîé òîðãîâëè"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot LRMA
#property indicator_label1  "LRMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input int      LRMAPeriod=14; // Period LRMA
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE;
//--- indicator buffers
double         LRMABuffer[];
//#include <MovingAverages.mqh>

#include <AZ-INVEST/SDK/TickChartIndicator.mqh>
TickChartIndicator customChartIndicator;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,LRMABuffer,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

   ArraySetAsSeries(LRMABuffer,true);
   //
   //  Indicator uses Price[] array for calculations so we need to set this in the MedianRenkoIndicator class
   //
  
   customChartIndicator.SetUseAppliedPriceFlag(InpAppliedPrice);
   
   //
   //
   //
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
  
   if(!customChartIndicator.OnCalculate(rates_total,prev_calculated,time,close))
      return(0);
      
   if(!customChartIndicator.BufferSynchronizationCheck(close))
      return(0);
      
//---
//   ArraySetAsSeries(LRMABuffer,true);
   //CIRP... ArraySetAsSeries(close,true);
   ArraySetAsSeries(customChartIndicator.Close,true);

   if(rates_total<=LRMAPeriod) return(0);
   int limit=rates_total-customChartIndicator.GetPrevCalculated(); //prev_calculated CIRP;
   if(limit>1)
     {
      ArrayInitialize(LRMABuffer,0.0);
      limit=rates_total-LRMAPeriod-1;
     }

   for(int pos=limit;pos>=0;pos--)
     {
      LRMABuffer[pos]=LRMA(pos,LRMAPeriod,customChartIndicator.Close);//close);
      //      Print("Bar(",pos,")=", LRMABuffer[pos]);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+\\
// Calculate LRMA
//+------------------------------------------------------------------+\\
double LRMA(const int pos,const int period,const double  &price[])
  {
   double Res=0;
   double tmpS=0,tmpW=0,wsum=0;;
   for(int i=0;i<period;i++)
     {
      tmpS+=price[pos+i];
      tmpW+=price[pos+i]*(period-i);
      wsum+=(period-i);
     }
   tmpS/=period;
   tmpW/=wsum;
   Res=3.0*tmpW-2.0*tmpS;

   return(Res);
  }
//+------------------------------------------------------------------+
