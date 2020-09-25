//+------------------------------------------------------------------+
//|                                                    Main v1.6.mq4 |
//|                                                 Umberto Sugliano |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Umberto Sugliano"
#property link      ""
#property version   "1.6"
#property strict

//DICHIARAZIONE LIBRERIE E HEADERS
#include "Functions v1.6.mqh" //Carica in fase di preprocessore la libreria di funzioni custom

int OnInit()
  {
   //RICERCA DI SUPPORTO E RESISTENZA
   
   SupAndRes(Amp, Hi, Lo, Mean, bars_check_number);
   
   //ETICHETTE STATISTICHE CHART   
   if(Use_Stats)
     {
     LabelCreate("Balance",225,1,"Balance = ", CORNER_LEFT_UPPER);
     LabelCreate("Balance Value",285,1,"", CORNER_LEFT_UPPER);
     LabelCreate("Equity",335,1,"Equity = ", CORNER_LEFT_UPPER);
     LabelCreate("Equity Value",385,1,"", CORNER_LEFT_UPPER);
     LabelCreate("Profit",435,1,"Current Profit = ", CORNER_LEFT_UPPER);
     LabelCreate("Profit Value",525,1,"", CORNER_LEFT_UPPER);
     LabelCreate("Open Orders",575,1,"Open Orders = ", CORNER_LEFT_UPPER);
     LabelCreate("Open Orders Value",665,1,"", CORNER_LEFT_UPPER);
     LabelCreate("Max Drawback",705,1,"Max Drawback = ", CORNER_LEFT_UPPER);
     LabelCreate("Max Drawback Value",795,1,"", CORNER_LEFT_UPPER);
     }

   //ETICHETTE INDICATORI E CONDIZIONI DI APERTURA
   if(Use_Conditions_Stats) 
     {  
     LabelCreate("Conditions",140,97,"CONDITIONS", CORNER_RIGHT_LOWER);
     LabelCreate("MonMan",173,78,"Money Management = ", CORNER_RIGHT_LOWER);
     LabelCreate("MonMan Value",48,78,"", CORNER_RIGHT_LOWER);
     LabelCreate("MaxOrd",148,63,"Max Orders = ", CORNER_RIGHT_LOWER);
     LabelCreate("MaxOrd Value",73,63,"", CORNER_RIGHT_LOWER);
     LabelCreate("Pips Gap",137,48,"Pips Gap = ", CORNER_RIGHT_LOWER);
     LabelCreate("Pips Gap Value",72,48,"", CORNER_RIGHT_LOWER);
     LabelCreate("RSI",175,33,"RSI = ", CORNER_RIGHT_LOWER);
     LabelCreate("RSI Value",145,33,"", CORNER_RIGHT_LOWER);
     LabelCreate("MA",108,33,"MA = ", CORNER_RIGHT_LOWER);
     LabelCreate("MA Value",78,33,"", CORNER_RIGHT_LOWER);
     LabelCreate("BB Hi",193,18,"BB Hi = ", CORNER_RIGHT_LOWER);
     LabelCreate("BB Hi Value",150,18,"", CORNER_RIGHT_LOWER);
     LabelCreate("BB Lo",98,18,"BB Lo = ", CORNER_RIGHT_LOWER);
     LabelCreate("BB Lo Value",53,18,"", CORNER_RIGHT_LOWER);
     }

   return(INIT_SUCCEEDED);
  }

//FUNZIONE DI DEINIZIALIZZAZIONE: QUANDO IL BOT VIENE ARRESTATO VIENE ESEGUITA
void OnDeinit(const int reason)
  {
  if(DeleteObjOnDeinit)
    {
    DeleteObjects(); //Elimina gli elementi grafici accessori in deinizializzazione
    }
  }


//ESECUZIONE AD OGNI TICK
void OnTick()
  { 
    RefreshRates(); //Aggiorna i valori per le funzioni standard, per variabili dichiarate globalmente

    /*LogVarValues(rsi, BandLo, BandHi, ma);*/
    
    Select(); //Selziona l'ultimo ordine
    LastOrderPrice = OrderOpenPrice(); //Prezzo dell'ultimo ordine selezionato

    //CALCOLO DINAMICO DI SOSTEGNO E RESISTENZA
    if(Use_Dyn_Sup_Res)
      {
      DynamicSupAndRes(ChngCount, Amp, SupResTolerance, Hi, Lo, Mean, dyn_bars_check_number);
      }

    //CALCOLO DINAMICO DEL PIPS GAP
    DynamicPipsGap(Use_Dyn_Pips_Gap, pips_gap_input, pips_gap_dyn, Amp, Dyn_Gap_Mult);
    
    O_orders = OrdersTotal(); //Calcolo numero ordini aperti
    Profit = AccountProfit(); //Calcolo Profit Attuale
    Equity = AccountEquity(); //Calcolo Equity
    Balance = AccountBalance(); //Calcolo Balance
    BandHi = iBands(NULL,0,BB_period,2,0,0,1,0); //Calcolo BB superiore
    BandLo = iBands(NULL,0,BB_period,2,0,0,2,0); //Calcolo BB inferiore
    ma = iMA(NULL,0,ma_period,0,0,0,0); //Calcolo MA
    rsi = iRSI(NULL,0,RSI_period,PRICE_MEDIAN,0); //Calcolo RSI
    if(Profit<MaxDrawback)
      {
      MaxDrawback = Profit;
      }
    

    
    if(LastOrderTime !=0) //Se LastOrderTime è 0, allora non c'è alcun ordine aperto
      {
      LastOrderBar = iBarShift(NULL,0,LastOrderTime); //Imposta valore di distanza tra la barra attuale e la barra dell'ultimo ordine
      };

    //FUNZIONE DI CONTROLLO DELLE CONDIZIONI DI APERTURA ORDINI
    ConditionsCheck(Use_Max_Orders, O_orders, Max_Orders, Use_MM, MM_Value, Equity, 
                    Balance, Use_Moving_Average, ma, Amp, Use_Clearance, Clearance,
                    Mean, Use_BB, BandHi, BandLo, Use_RSI_Check, rsi, Use_Pips_Gap,
                    pips_gap_dyn, LastOrderPrice, RSIsell, RSIbuy, MAsell, MAbuy,
                    BBsell, BBbuy, MeanSell, MeanBuy, PipsSell, PipsBuy, MaxOrd, MonMan);

    //ESECUZIONE FUNZIONE PER LE STATISTICHE IN ALTO SUL GRAFICO
    Stats(Use_Stats, Use_Conditions_Stats, Equity, Balance, 
          Profit, O_orders, MaxDrawback, ma, BandHi, BandLo, rsi,
          RSIsell, RSIbuy, MAsell, MAbuy, BBsell, BBbuy, MeanSell,
          MeanBuy, PipsSell, PipsBuy, MaxOrd, MonMan, MM_Value,
          Max_Orders, pips_gap_dyn);
      

    //----
    //SELL
    //----
    if((MaxOrd) &&              //Condizione di Max Orders
       (MonMan) &&              //Condizione di Money Management
       (MAsell) &&              //Condizione di Moving Average
       (MeanSell) &&            //Condizione di posizione rispetto alla linea di media
       (BBsell) &&              //Condizione di Bollinger Bands 
       (LastOrderBar != 0) &&   //Condizione di prossimità all'ultimo ordine
       (RSIsell) &&             //Condizione di RSI 
       (PipsSell))              //Condizione di Pips Gap
      {
      SendSell(lot_size); //Apre posizione Sell
      Select(); //Seleziona l'ordine appena aperto per il check al prossimo tick
      LastOrderTime = OrderOpenTime(); //Imposta LastOrderTime sul tempo dell'ordine appena aperto
      };
      
    //----
    //BUY
    //----  
    if((MaxOrd) &&              //Condizione di Max Orders
       (MonMan) &&              //Condizione di Money Management
       (MAbuy) &&               //Condizione di Moving Average 
       (MeanBuy) &&             //Condizione di posizione rispetto alla linea di media
       (BBbuy) &&               //Condizione di Bollinger Bands
       (LastOrderBar != 0) &&   //Condizione di prossimità all'ultimo ordine
       (RSIbuy) &&              //Condizione di RSI 
       (PipsBuy))               //Condizione di Pips Gap
      {
      SendBuy(lot_size); //Apre posizione Buy      
      Select();  //Seleziona l'ordine appena aperto per il check al prossimo tick
      LastOrderTime = OrderOpenTime();  //Imposta LastOrderTime sul tempo dell'ordine appena aperto
      };
      
    //TRAILING STOP LOSS
    if((Use_Trailing_Stop == True) && (OrdersTotal() != 0)) //Controlla se il Trailing Stop è abilitato e se ci sono ordini aperti
      {
      TrailingStop(TrailingStart, TrailingStep); //Funzione di Trailing Stop
      }
  }
