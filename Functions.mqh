//+------------------------------------------------------------------+
//|                                            Functions.mqh |
//|                                                 Umberto Sugliano |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Umberto Sugliano"
#property link      ""
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


//RICERCA DI SOSTEGNO, RESISTENZA E VALORE MEDIO
//Parametri formali passati per referenza e non coincidono con le variabili globali
void SupAndRes(int &H, int &L, double &M, const int bars_check_number_Ref) 
      { 
      H = iHighest(NULL,0,3,bars_check_number_Ref,0); //Ricerca su coppia attuale, timeframe attuale, su prezzi close e dal dato 0 iniziale
      L = iLowest(NULL,0,3,bars_check_number_Ref,0); //Ricerca su coppia attuale, timeframe attuale, su prezzi close e dal dato 0 iniziale
      double Hi = Close[H];
      double Lo = Close[L];
      ObjectCreate("Res", OBJ_HLINE, 0, Time[0], Hi, 0, 0);
      ObjectCreate("Sup", OBJ_HLINE, 0, Time[0], Lo, 0, 0);
      M = (Hi+Lo)/2;
      ObjectCreate("Mean", OBJ_HLINE, 0, Time[0], M, 0, 0);
      }

//SELEZIONE ULTIMO ORDINE APERTO
void Select() 
      {
      if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS) != True)
         {
         GetLastError();
         }
      }

//ESECUZIONE ORDINE BUY
void SendBuy(double lot_size_ref) 
      {
      if(OrderSend(NULL,0,lot_size_ref,Ask,3,0,0,NULL,0,0,clrGreen) != True) 
         {
         GetLastError();
         }     
      }

//ESECUZIONE ORDINE SELL
void SendSell(double lot_size_ref)
      {
      if(OrderSend(NULL,1,lot_size_ref,Bid,3,0,0,NULL,0,0,clrRed)!= True) 
         {
         GetLastError();
         }
      }

//FUNZIONE DI CONTROLLO DELLE VARIABILI IN TEMPO REALE (OPZIONALE)
//Per chiamare la funzione nel main -> LogVarValues(rsi, BandLo, BandHi, ma);   
void LogVarValues(double rsi_ref, double BandLo_ref, double BandHi_ref, double ma_ref)
      {
      Print("rsi = ", rsi_ref, " ", "BandLo = ", BandLo_ref, "BandHi = ", BandHi_ref, " ", "ma = ", ma_ref, " ");
      }
      

//FUNZIONE DI TRAILING STOP
void TrailingStop(int TrailingStart_ref, int TrailingStep_ref) 
      {
      for(int n_order = OrdersTotal()-1; n_order >=0; n_order--) //Ciclo FOR per controllare tutti gli ordini
         {
         if(OrderSelect(n_order,SELECT_BY_POS,MODE_TRADES) != True) //Seleziona l'ordine numero n_order in ordine cronologico decrescente di apertura
           {
           GetLastError(); //Check per eventuali errori dell'OrderSelect
           } 
            
         //TRAILING PER LE POSIZIONI SELL
         if(OrderType() == OP_SELL)
           {
           if(OrderOpenPrice()>Ask+TrailingStart_ref*Point) //Controlla se la posizione è in profitto
             {
             if(OrderStopLoss() == 0 || OrderStopLoss()>Ask+TrailingStep_ref*Point) //Controlla se lo Stop Loss è 0 o maggiore del prezzo Ask attuale aumentato di X pips
               {
               if(OrderModify( //Funzione di modifica dell'ordine
                            OrderTicket(), //Ticket identificativo unico dell'ordine
                            OrderOpenPrice(), //Prezzo di apertura dell'ordine, non modificato
                            Ask+TrailingStep_ref*Point, //Prezzo a cui viene impostato lo Stop Loss
                            OrderTakeProfit(), //Take Profit dell'ordine, non modificato
                            0, //Scadenza dell'ordine
                            clrNONE
                            ) != True)
                 {
                 GetLastError(); //Check per eventuali errori dell'OrderSelect
                 }
               }
             }
           }
         //TRAILING PER LE POSIZIONI BUY  
         if(OrderType() == OP_BUY) 
           {
           if(OrderOpenPrice()<Bid-TrailingStart_ref*Point) //Controlla se la posizione è in profitto
             {
             if(OrderStopLoss() == 0 || OrderStopLoss()<Bid-TrailingStep_ref*Point) //Controlla se lo Stop Loss è 0 o minore del prezzo Bid attuale aumentato di X pips
               {
               if(OrderModify( //Funzione di modifica dell'ordine
                            OrderTicket(), //Ticket identificativo unico dell'ordine
                            OrderOpenPrice(), //Prezzo di apertura dell'ordine, non modificato
                            Bid-TrailingStep_ref*Point, //Prezzo a cui viene impostato lo Stop Loss
                            OrderTakeProfit(), //Take Profit dell'ordine, non modificato
                            0, //Scadenza dell'ordine
                            clrNONE
                            ) != True)
                 {  
                 GetLastError(); //Check per eventuali errori dell'OrderSelect
                 }            
               }
             }
           }
         }
      }

//FUNZIONE DI MONEY MANAGEMENT
bool MoneyManagement(int MM_Value_ref) //La funzione è di tipo bool, cioè ritorna un valore booleano (vero o falso, 1 o 0)
      {
      double XPercent = double(MM_Value_ref)/100; //Conversione in valore percentuale dell'input di Money Management
      double Equity = AccountEquity(); //Double di Liquidità
      double Balance = AccountBalance(); //Double di Bilancio
      double Ratio = Equity/Balance; //Double di rapporto tra liquidità e bilancio (<1 significa che il profit è negativo)

      if(Ratio <= XPercent) //Se il rapporto è inferiore alla percentuale indicata in input, la funzione ritorna true => 1
        {
        return true;
        }
      else //altrimenti ritorna false => 0
        {
         return false;
        }
      }
