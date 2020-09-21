//+------------------------------------------------------------------+
//|                                                    Main v1.3.mq4 |
//|                                                 Umberto Sugliano |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Umberto Sugliano"
#property link      ""
#property version   "1.5"
#property strict

//DICHIARAZIONE LIBRERIE E HEADERS
#include "Functions.mqh" //Carica in fase di preprocessore la libreria di funzioni custom

//PARAMETRI DI INPUT
input bool     Use_Dyn_Sup_Res = true; //Usa Dynamic Sup & Res
input int      SupResTolerance = 8; //% Tolleranza 

input double   lot_size=0.01;
input int      bars_check_number=100; //Barre per calcolo Oscillazione

input bool     Use_Pips_Gap = true; //Usa Pips Gap to Open
input int      pips_gap_input = 30; //Base Pips Gap

input bool     Use_Dyn_Pips_Gap = true; //Usa Dynamic Pips Gap
input int      Dyn_Gap_Mult = 3; //% Moltiplicatore Dyn Pips Gap

input bool     Use_BB = true; //Usa Bollinger Bands
input int      BB_period = 20; //Periodo Bande di Bollinger

input bool     Use_RSI_Check = true; //Usa RSI Check
input int      RSI_period = 2; //Periodo RSI

input bool     Use_Moving_Average = true; //Usa Moving Average
input int      ma_period = 2; //Periodo Moving Average

input bool     Use_MM = true; //Usa Money Management
input int      MM_Value = 85; //MM %

input bool     Use_Max_Orders = true; //Usa Max Orders
input int      Max_Orders = 30; //Max Open Orders

input int      Clearance = 5; //% Clearance zone

input bool     Use_Trailing_Stop = true; //Usa Trailing Stop
input int      TrailingStart = 100; //Numero di pips di profitto oltre i quali si attiva il Trailing Stop
input int      TrailingStep = 60; //Pips di differenza tra il prezzo attuale ed il Trailing Stop da impostare

//INIZIALIZZAZIONE VARIABILI GLOBALI
double   Mean = 0;
double   ma = 0;
double   BandLo = 0;
double   BandHi = 0;
double   rsi = 0;
double   LastOrderPrice =0;
double   Balance = AccountBalance();
double   Equity = AccountEquity();
double   Profit = AccountProfit();
double   DynamicHi;
double   DynamicLo;
double   DynamicMean;
double   Hi = 0;
double   Lo = 0;
double   MaxDrawback = AccountProfit();

int      O_orders = OrdersTotal();
int      LastOrderBar = 1;
int      pips_gap_dyn = pips_gap_input;

int ChngCount = 0;

double    Amp = 0;
datetime LastOrderTime = 0;


int OnInit()
  {
   //RICERCA DI SUPPORTO E RESISTENZA
   
   SupAndRes(Amp, Hi, Lo, Mean, bars_check_number);
   
   //ETICHETTE STATISTICHE CHART
   LabelCreate("Balance",225,1,"Balance = ");
   LabelCreate("Balance Value",285,1,"");
   LabelCreate("Equity",335,1,"Equity = ");
   LabelCreate("Equity Value",385,1,"");
   LabelCreate("Profit",435,1,"Current Profit = ");
   LabelCreate("Profit Value",525,1,"");
   LabelCreate("Open Orders",575,1,"Open Orders = ");
   LabelCreate("Open Orders Value",665,1,"");
   LabelCreate("Max Drawback",705,1,"Max Drawback = ");
   LabelCreate("Max Drawback Value",795,1,"");
   
   Print( "High = ", Hi, " Low = ", Lo, " Amp = ", Amp);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   //PER ORA VUOTO, POI LO USEREMO
  }


//ESECUZIONE AD OGNI TICK
void OnTick()
  { 
    RefreshRates(); //Aggiorna i valori per le funzioni standard, per variabili dichiarate globalmente

    LogVarValues(rsi, BandLo, BandHi, ma);
    
    Select(); //Selziona l'ultimo ordine
    LastOrderPrice = OrderOpenPrice(); //Prezzo dell'ultimo ordine selezionato

    //CALCOLO DINAMICO DI SOSTEGNO E RESISTENZA
    if(Use_Dyn_Sup_Res)
      {
      DynamicSupAndRes(ChngCount, Amp, SupResTolerance, Hi, Lo, Mean, bars_check_number);
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
    
    //ESECUZIONE FUNZIONE PER LE STATISTICHE IN ALTO SUL GRAFICO
    Stats(Equity, Balance, Profit, O_orders, MaxDrawback);
    
    Print( "High = ", Hi/_Point, " Low = ", Lo/_Point, " Amp = ", Amp); //TESTING
    
    if(LastOrderTime !=0) //Se LastOrderTime è 0, allora non c'è alcun ordine aperto
      {
      LastOrderBar = iBarShift(NULL,0,LastOrderTime); //Imposta valore di distanza tra la barra attuale e la barra dell'ultimo ordine
      };

    //----
    //SELL
    //----
    if((MaxOrders(Use_Max_Orders, O_orders, Max_Orders)) &&      //Condizione di Max Orders
       (!MoneyManagement(Use_MM, MM_Value, Equity, Balance)) &&  //Condizione di Money Management
       (MA_Check_SELL(Use_Moving_Average, ma)) &&                //Condizione di Moving Average
       (Bid>Mean+(Amp*0.01*Clearance)*Point) &&                  //Condizione di posizione rispetto alla linea di media
       (BB_Check_SELL(Use_BB, BandHi)) &&                        //Condizione di Bollinger Bands 
       (LastOrderBar != 0) &&                                    //Condizione di prossimità all'ultimo ordine
       (RSI_Check_SELL(Use_RSI_Check, rsi)) &&                   //Condizione di RSI 
       (PipsGap_SELL(Use_Pips_Gap, pips_gap_dyn, LastOrderPrice)))   //Condizione di Pips Gap
      {
      SendSell(lot_size); //Apre posizione Sell
      Select(); //Seleziona l'ordine appena aperto per il check al prossimo tick
      LastOrderTime = OrderOpenTime(); //Imposta LastOrderTime sul tempo dell'ordine appena aperto
      };
      
    //----
    //BUY
    //----  
    if((MaxOrders(Use_Max_Orders, O_orders, Max_Orders)) &&       //Condizione di Max Orders
       (!MoneyManagement(Use_MM, MM_Value, Equity, Balance)) &&   //Condizione di Money Management
       (MA_Check_BUY(Use_Moving_Average, ma)) &&                  //Condizione di Moving Average 
       (Ask<Mean-(Amp*0.01*Clearance)*Point) &&                   //Condizione di posizione rispetto alla linea di media
       (BB_Check_BUY(Use_BB, BandLo)) &&                          //Condizione di Bollinger Bands
       (LastOrderBar != 0) &&                                     //Condizione di prossimità all'ultimo ordine
       (RSI_Check_BUY(Use_RSI_Check, rsi)) &&                     //Condizione di RSI 
       (PipsGap_BUY(Use_Pips_Gap, pips_gap_dyn, LastOrderPrice)))     //Condizione di Pips Gap
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
double   ma = 0;
double   BandLo = 0;
double   BandHi = 0;
double   rsi = 0;
double   LastOrderPrice =0;
double   Balance = AccountBalance();
double   Equity = AccountEquity();
double   Profit = AccountProfit();
double   DynamicHi;
double   DynamicLo;
double   DynamicMean;
double   Hi = 0;
double   Lo = 0;
double   MaxDrawback = AccountProfit();

int      O_orders = OrdersTotal();
int      LastOrderBar = 1;
int      pips_gap_dyn = pips_gap_input;

int ChngCount = 0;

double    Amp = 0;
datetime LastOrderTime = 0;


int OnInit()
  {
   //RICERCA DI SUPPORTO E RESISTENZA
   SupAndRes(Amp, Hi, Lo, Mean, bars_check_number);
   
   //ETICHETTE STATISTICHE CHART
   LabelCreate("Balance",225,1,"Balance = ");
   LabelCreate("Balance Value",285,1,"");
   LabelCreate("Equity",335,1,"Equity = ");
   LabelCreate("Equity Value",385,1,"");
   LabelCreate("Profit",435,1,"Current Profit = ");
   LabelCreate("Profit Value",525,1,"");
   LabelCreate("Open Orders",575,1,"Open Orders = ");
   LabelCreate("Open Orders Value",665,1,"");
   LabelCreate("Max Drawback",705,1,"Max Drawback = ");
   LabelCreate("Max Drawback Value",795,1,"");
   
   Print( "High = ", Hi, " Low = ", Lo, " Amp = ", Amp);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   //PER ORA VUOTO, POI LO USEREMO
  }


//ESECUZIONE AD OGNI TICK
void OnTick()
  { 
    RefreshRates(); //Aggiorna i valori per le funzioni standard, per variabili dichiarate globalmente

    LogVarValues(rsi, BandLo, BandHi, ma);
    
    Select(); //Selziona l'ultimo ordine
    LastOrderPrice = OrderOpenPrice(); //Prezzo dell'ultimo ordine selezionato

    //CALCOLO DINAMICO DI SOSTEGNO E RESISTENZA
    DynamicSupAndRes(ChngCount, Amp, SupResTolerance, Hi, Lo, Mean, bars_check_number);

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
    
    //ESECUZIONE FUNZIONE PER LE STATISTICHE IN ALTO SUL GRAFICO
    Stats(Equity, Balance, Profit, O_orders, MaxDrawback);
    
    Print( "High = ", Hi/_Point, " Low = ", Lo/_Point, " Amp = ", Amp); //TESTING
    
    if(LastOrderTime !=0) //Se LastOrderTime è 0, allora non c'è alcun ordine aperto
      {
      LastOrderBar = iBarShift(NULL,0,LastOrderTime); //Imposta valore di distanza tra la barra attuale e la barra dell'ultimo ordine
      };

    //----
    //SELL
    //----
    if((MaxOrders(Use_Max_Orders, O_orders, Max_Orders)) &&      //Condizione di Max Orders
       (!MoneyManagement(Use_MM, MM_Value, Equity, Balance)) &&  //Condizione di Money Management
       (MA_Check_SELL(Use_Moving_Average, ma)) &&                //Condizione di Moving Average
       (Bid>Mean) &&                                             //Condizione di posizione rispetto alla linea di media
       (BB_Check_SELL(Use_BB, BandHi)) &&                        //Condizione di Bollinger Bands 
       (LastOrderBar != 0) &&                                    //Condizione di prossimità all'ultimo ordine
       (RSI_Check_SELL(Use_RSI_Check, rsi)) &&                   //Condizione di RSI 
       (PipsGap_SELL(Use_Pips_Gap, pips_gap_dyn, LastOrderPrice)))   //Condizione di Pips Gap
      {
      SendSell(lot_size); //Apre posizione Sell
      Select(); //Seleziona l'ordine appena aperto per il check al prossimo tick
      LastOrderTime = OrderOpenTime(); //Imposta LastOrderTime sul tempo dell'ordine appena aperto
      };
      
    //----
    //BUY
    //----  
    if((MaxOrders(Use_Max_Orders, O_orders, Max_Orders)) &&       //Condizione di Max Orders
       (!MoneyManagement(Use_MM, MM_Value, Equity, Balance)) &&   //Condizione di Money Management
       (MA_Check_BUY(Use_Moving_Average, ma)) &&                  //Condizione di Moving Average 
       (Ask<Mean) &&                                              //Condizione di posizione rispetto alla linea di media
       (BB_Check_BUY(Use_BB, BandLo)) &&                          //Condizione di Bollinger Bands
       (LastOrderBar != 0) &&                                     //Condizione di prossimità all'ultimo ordine
       (RSI_Check_BUY(Use_RSI_Check, rsi)) &&                     //Condizione di RSI 
       (PipsGap_BUY(Use_Pips_Gap, pips_gap_dyn, LastOrderPrice)))     //Condizione di Pips Gap
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
