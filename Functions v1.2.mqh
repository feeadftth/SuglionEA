//+------------------------------------------------------------------+
//|                                                    Functions.mqh |
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
bool MoneyManagement(int MM_Value_ref, double Equity_ref, double Balance_ref) //La funzione è di tipo bool, cioè ritorna un valore booleano (vero o falso, 1 o 0)
      {
      double XPercent = double(MM_Value_ref)/100; //Conversione in valore percentuale dell'input di Money Management
      double Ratio = Equity_ref/Balance_ref; //Double di rapporto tra liquidità e bilancio (<1 significa che il profit è negativo)

      if(Ratio <= XPercent) //Se il rapporto è inferiore alla percentuale indicata in input, la funzione ritorna true => 1
        {
        return true;
        }
      else //altrimenti ritorna false => 0
        {
         return false;
        }
      }

//STATISTICS LABELS UPDATER FUNCTION
void Stats(double Equity_ref, double Balance_ref, double Profit_ref, int O_orders_ref) 
      {
      string Ord = IntegerToString(O_orders_ref, 0); //Conversione a stringa del valore intero di ordini aperti
      string Prft = DoubleToStr(Profit_ref, 2); //Conversione a stringa del valore double di Profit
      string Blnc = DoubleToStr(Balance_ref, 2); //^^ per il Balance
      string Eqty = DoubleToStr(Equity_ref, 2); //^^ per l'Equity
      ObjectSetString(0,"Balance Value", OBJPROP_TEXT, Blnc); //Modifica valore Balance
      ObjectSetString(0,"Equity Value", OBJPROP_TEXT, Eqty); //Modifica valore Equity
      ObjectSetString(0,"Profit Value", OBJPROP_TEXT, Prft); //Modifica valore Profit
      ObjectSetString(0,"Open Orders Value", OBJPROP_TEXT, Ord);
      }

//FUNZIONE DI CREAZIONE LABELS PER DATI
bool LabelCreate(        const string name,            // label name
                         const int               x,    // X coordinate
                         const int               y,    // Y coordinate
                         const string          text)   // text
  {
  
   //Definizione costanti che NON VARIANO tra le varie labels
   const long              chart_ID = 0; //Chart ID
   const int                sub_window = 0; //Indice Sottofinestra
   const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER; //Angolo da usare come punto di partenza
   const string            font = "Arial"; //Font
   const int                font_size = 9; //Font size
   const color             clr = clrWhite; //Label Color
   const double          angle = 0.0; //Inclinazione della label
   const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER; //Angolo da usare come centro di rotazione
   const bool              back=false;               //Sullo sfondo rispetto al resto = false
   const bool              selection=false;          //Spostabile con mouse = false
   const bool              hidden=true;              //Nascosto nella lista oggetti = true
   const long              z_order=0;                //Priorità rispetto ai click col mouse
   

   ResetLastError(); //Resetta il valore di ultimo errore

   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)) //Creazione oggetto (funzione booleana) con if statement per catch
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError()); //Catch per eventualli errori
      return(false);
     }

   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); //Coordinata X
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); //Coordinata Y
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); //Angolo del grafico
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); //Testo
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); //Font
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); //Font Size
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle); //Angolo d'inclinazione
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); //Centro di rotazione
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); //Colore
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); //Opzione per embedding nel background (true=embedded)
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); //Opzione per muovere il label col mouse (true=abilitato)
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); // ^^
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); //Mostra nella Lista Oggetti (true=visibile)
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); //Priorità click del mouse sul grafico

   return(true);
  }
