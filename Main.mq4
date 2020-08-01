//+------------------------------------------------------------------+
//|                                                       Prova3.mq4 |
//|                                                 Umberto Sugliano |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Umberto Sugliano"
#property link      ""
#property version   "1.00"
#property strict

//DICHIARAZIONE LIBRERIE E HEADERS
#include "Prova 3 Functions.mqh" //Carica in fase di preprocessore la libreria di funzioni custom

//PARAMETRI DI INPUT
input double   lot_size=0.01;
input int      bars_check_number=100; //Numero di barre da usare per calcolo Sostegno e Resistenza
input int      pips_gap = 30; //Pips di differenza con l'ultima posizione per poterne aprire una nuova
input int      BB_period = 20; //Periodo Bande di Bollinger
input int      RSI_period = 2; //Periodo RSI

input bool     Use_Trailing_Stop = True; //Opzione per l'uso del Trailing Stop
input int      TrailingStart = 100; //Numero di pips di profitto oltre i quali si attiva il Trailing Stop
input int      TrailingStep = 60; //Pips di differenza tra il prezzo attuale ed il Trailing Stop da impostare

//INIZIALIZZAZIONE VARIABILI GLOBALI
double   Mean = 0;
double   ma = 0;
double   BandLo = 0;
double   BandHi = 0;
double   rsi = 0;
double   LastOrderPrice =0;
int         LastOrderBar = 1;
int         hival = 0;
int         lowval = 0;
datetime LastOrderTime = 0;



int OnInit()
  {
   //RICERCA DI SUPPORTO E RESISTENZA
   SupAndRes(hival, lowval, Mean, bars_check_number);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   //PER ORA VUOTO, POI LO USEREMO
  }


//ESECUZIONE AD OGNI TICK
void OnTick()
  { 
    Select(); //Selziona l'ultimo ordine
    LastOrderPrice = OrderOpenPrice(); //Prezzo dell'ultimo ordine selezionato
    
    BandHi = iBands(NULL,0,BB_period,2,0,0,1,0); //Calcolo BB superiore
    BandLo = iBands(NULL,0,BB_period,2,0,0,2,0); //Calcolo BB inferiore
    ma = iMA(NULL,0,RSI_period,0,0,0,0); //Calcolo MA
    rsi = iRSI(NULL,0,14,PRICE_MEDIAN,0); //Calcolo RSI
    
    if(LastOrderTime !=0) //Se LastOrderTime è 0, allora non c'è alcun ordine aperto
      {
      LastOrderBar = iBarShift(NULL,0,LastOrderTime); //Imposta valore di distanza tra la barra attuale e la barra dell'ultimo ordine
      };
      
    //SELL
    if((Bid>ma) && (Bid>Mean) && (Bid>BandHi) && (LastOrderBar != 0) && (rsi>=70) && (LastOrderPrice+pips_gap*Point<Bid)) //Check condizioni di apertura Sell
      {
      SendSell(lot_size); //Apre posizione Sell
      Select(); //Seleziona l'ordine appena aperto per il check al prossimo tick
      LastOrderTime = OrderOpenTime(); //Imposta LastOrderTime sul tempo dell'ordine appena aperto
      };
      
    //BUY  
    if((Ask<ma) && (Ask<Mean) && (Bid<BandLo) && (LastOrderBar != 0) && (rsi<=30) && (LastOrderPrice-pips_gap*Point>Ask))  //Check condizioni di apertura Buy
      {
      SendBuy(lot_size); //Apre posizione Buy      
      Select();  //Seleziona l'ordine appena aperto per il check al prossimo tick
      LastOrderTime = OrderOpenTime();  //Imposta LastOrderTime sul tempo dell'ordine appena aperto
      };
      
      RefreshRates(); //Aggiorna i valori per le funzioni standard, per variabili dichiarate globalmente
      
    //STOP LOSS
    if((Use_Trailing_Stop == True) && (OrdersTotal() != 0)) //Controlla se il Trailing Stop è abilitato e se ci sono ordini aperti
      {
      TrailingStop(TrailingStart, TrailingStep); //Funzione di Trailing Stop
      }
      
  }
 
