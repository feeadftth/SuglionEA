//+------------------------------------------------------------------+
//|                                                    Functions.mqh |
//|                                                 Umberto Sugliano |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Umberto Sugliano"
#property link      ""
#property version   "1.3"
#property strict

//RICERCA DI SOSTEGNO, RESISTENZA E VALORE MEDIO
//Parametri formali passati per referenza e non coincidono con le variabili globali
void SupAndRes(double &Amp_ref, double &Hi_ref, double &Lo_ref, double &Mean_ref, const int bars_check_number_ref) 
    { 
    int Hi_bar = iHighest(NULL,0,3,bars_check_number_ref,0);  //Calcolo della barra globale in cui c'è il prezzo più alto
    int Lo_bar = iLowest(NULL,0,3,bars_check_number_ref,0);   //Calcolo della barra globale in cui c'è il prezzo più basso
    Hi_ref = NormalizeDouble(Close[Hi_bar], 6);               //Calcolo del prezzo globale più alto, normalizzato
    Lo_ref = NormalizeDouble(Close[Lo_bar], 6);               //Calcolo del prezzo globale più basso. normalizzato
    ObjectCreate("Res", OBJ_HLINE, 0, Time[0], Hi_ref, 0, 0); //Creazione linea di Resistenza
    ObjectCreate("Sup", OBJ_HLINE, 0, Time[0], Lo_ref, 0, 0); //Creazione linea di Sostegno
    Mean_ref = (Hi_ref+Lo_ref)/2;                             //Calcolo del prezzo medio
    ObjectCreate("Mean", OBJ_HLINE, 0, Time[0], Mean_ref, 0, 0); //Creazione linea di media
    double Price_diff = (Hi_ref - Lo_ref);                    //Calcolo della differenza di prezzo tra Sup e Res
    Amp_ref = NormalizeDouble(Price_diff, 6) / _Point;        //Normalizzazione e conversione in pips di Price_diff
    }

//RICERCA DINAMICA DI SOSTEGNO, RESISTENZA E VALORE MEDIO
//Se il gafico ha rotto le mura dell'oscillazione di un valore uguale ad una percentuale dell'oscillazione 
//specificata in input da SupResTolerance, i prezzi di sostegno e resistenza vengono aggiornati a quelli attuali
//Chiamata della funzione: DynamicSupAndRes(ChngCount, Amp, SupResTolerance, Hi_ref, Lo_ref, Mean_ref, bars_check_number)
void DynamicSupAndRes(int &ChngCount_ref, double &Amp_ref, const int SupResTolerance_ref, double &Hi_ref, double &Lo_ref, double &Mean_ref, const int bars_check_number_ref)
    {
    bool change = false; //Booleano che indica se è stato effettuato un cambio di Sup o Res
    int DynamicHi_bar = iHighest(NULL,0,3,bars_check_number_ref,0); //Calcolo della barra dyn in cui c'è il prezzo più alto
    int DynamicLo_bar = iLowest(NULL,0,3,bars_check_number_ref,0); //Calcolo della barra dyn in cui c'è il prezzo più basso
    double DynamicHi_ref = NormalizeDouble(Close[DynamicHi_bar], 6); //Calcolo del prezzo dyn più alto, normalizzato
    double DynamicLo_ref = NormalizeDouble(Close[DynamicLo_bar], 6); //Calcolo del prezzo dyn più basso, normalizzato
    
    double DynHiPoint = DynamicHi_ref /_Point; //Conversione prezzo dyn  più alto in pips
    double DynLoPoint = DynamicLo_ref /_Point; //Conversione prezzo dyn più basso in pips
    double HiPoint = Hi_ref /_Point; //Conversione prezzo globale più alto in pips
    double LoPoint = Lo_ref /_Point; //Conversione prezzo globale più basso in pips

    double Tolerance = Amp_ref*SupResTolerance_ref*0.01; //Calcolo valore di Tolerance, funzionamento spiegato sopra
    Print(Tolerance); //Stampa di Tolerance per testing
    
    //Res Check
    //Se il prezzo dyn è più alto di quello globale + Tolerance oppure più basso di quello globale - Tolerance, allora opera
    if(((DynHiPoint)>(HiPoint+Tolerance)) || ((DynHiPoint)<(HiPoint-(Tolerance))))
      {                                                                                                                 
      Hi_ref = NormalizeDouble(DynamicHi_ref, 6); //Normalizzazione del prezzo dyn più alto, già calcolato
      change = true;                              //Imposta change su true
      ObjectSet("Res", OBJ_HLINE, Hi_ref);        //Sposta la linea di Res al nuovo prezzo
      ChngCount_ref++;                            //Incrementa la variabile di conteggio
      }
  
    //Sup Check
    if(((DynLoPoint)<(LoPoint-Tolerance)) || ((DynLoPoint)>(LoPoint+(Tolerance))))
      {
      Lo_ref = NormalizeDouble(DynamicLo_ref, 6); //Normalizzazione del prezzo dyn più basso
      change = true;                              //Imposta change su true
      ObjectSet("Sup", OBJ_HLINE, Lo_ref);        //Sposta la linea di Sup al nuovo prezzo
      ChngCount_ref++;                            //Incrementa la variabile di conteggio
      }

    if(change) //Se change è stato impostato su true, quindi se sono stati aggiornati i prezzi globali di Sup e/o Res
      {
      Mean_ref = (Hi_ref+Lo_ref)/2;                      //Ricalcola il prezzo medio
      ObjectSet("Mean", OBJ_HLINE, Mean_ref);            //Sposta la linea di media al nuovo prezzo
      double Price_diff = (Hi_ref - Lo_ref);             //Ricalcolo della differenza di prezzo tra i nuovi Sup e Res
      Amp_ref = NormalizeDouble(Price_diff, 6) /_Point;  //Normalizzazione e conversione in pips di Price_diff
      }
    }


//DYNAMIC PIPS GAP
//Il pips gap necessario per aprire una nuova posizione varia in base alla ampiezza dell'oscillazione (Amp_ref)
//di un valore percentuale intero definito in input (Dyn_Gap_Mult_ref)
//Chiamata di funzione: DynamicPipsGap(Use_Dyn_Pips_Gap, pips_gap_input, pips_gap_dyn, Amp, Dyn_Gap_Mult)
void DynamicPipsGap(bool Use_Dyn_Pips_Gap_ref, const int pips_gap_input_ref, int &pips_gap_dyn_ref, double Amp_ref, const int Dyn_Gap_Mult_ref)
      {
      if(Use_Dyn_Pips_Gap_ref)
        {
        pips_gap_dyn_ref = MathRound(Amp_ref*Dyn_Gap_Mult_ref*0.01);
        }
      } 

//SELEZIONE ULTIMO ORDINE APERTO
void Select() 
      {
      if(!OrderSelect(OrdersTotal()-1,SELECT_BY_POS))
         {
         GetLastError();
         }
      }

//ESECUZIONE ORDINE BUY
void SendBuy(double lot_size_ref) 
      {
      if(!OrderSend(NULL,0,lot_size_ref,Ask,3,0,0,NULL,0,0,clrGreen)) 
         {
         GetLastError();
         }     
      }

//ESECUZIONE ORDINE SELL
void SendSell(double lot_size_ref)
      {
      if(!OrderSend(NULL,1,lot_size_ref,Bid,3,0,0,NULL,0,0,clrRed)) 
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
bool MoneyManagement(bool Use_MM_ref, int MM_Value_ref, double Equity_ref, double Balance_ref) //La funzione è di tipo bool, cioè ritorna un valore booleano (vero o falso, 1 o 0)
      {
      double XPercent = double(MM_Value_ref)/100; //Conversione in valore percentuale dell'input di Money Management
      double Ratio = Equity_ref/Balance_ref; //Double di rapporto tra liquidità e bilancio (<1 significa che il profit è negativo)

      if((Ratio <= XPercent) || (!Use_MM_ref)) //Se il rapporto è inferiore alla percentuale indicata in input, la funzione ritorna true => 1
        {
        return true;
        }
      else //altrimenti ritorna false => 0
        {
         return false;
        }
      }

//STATISTICS LABELS UPDATER FUNCTION
void Stats(double Equity_ref, double Balance_ref, double Profit_ref, int O_orders_ref, double MaxDrawback_ref) 
      {
      string Max = DoubleToStr(MaxDrawback_ref, 2); //Conversione a stringa del valore double di massimo drawback
      string Ord = IntegerToString(O_orders_ref); //Conversione a stringa del valore intero di ordini aperti
      string Prft = DoubleToStr(Profit_ref, 2); //Conversione a stringa del valore double di Profit
      string Blnc = DoubleToStr(Balance_ref, 2); //^^ per il Balance
      string Eqty = DoubleToStr(Equity_ref, 2); //^^ per l'Equity

      ObjectSetString(0,"Balance Value", OBJPROP_TEXT, Blnc); //Modifica valore Balance
      ObjectSetString(0,"Equity Value", OBJPROP_TEXT, Eqty); //Modifica valore Equity
      ObjectSetString(0,"Profit Value", OBJPROP_TEXT, Prft); //Modifica valore Profit
      ObjectSetString(0,"Open Orders Value", OBJPROP_TEXT, Ord); //Modifica valore Ordini Aperti
      ObjectSetString(0,"Max Drawback Value", OBJPROP_TEXT, Max); //Modifica valore Max Drawback
      }

//AGGIORNAMENTO DELLE VARIABILI USATE (PULIZIA DEL MAIN)
//Chiamata della funzione: RefreshVars(MaxDrawback, O_orders, Profit, Equity, Balance, BandHi, BandLo, BB_period, ma, ma_period, rsi, RSI_period);
/*void RefreshVars(double &MaxDrawback_ref, //Massimo drawback
                int &O_orders_ref, //Ordini aperti
                double &Profit_ref, //Real time profit su posizioni aperte
                double &Equity_ref, //Liquidità
                double &Balance_ref, //Balance
                double &BandHi_ref, double &BandLo_ref, const int BB_period_ref, //Variabili Bollinger Bands
                double &ma_ref, const int ma_period_ref,  //Variabili Moving Average
                double &rsi_ref, const int RSI_period_ref) //Variabilli RSI
      {
      O_orders_ref = OrdersTotal(); //Calcolo numero ordini aperti
      Profit_ref = AccountProfit(); //Calcolo Profit Attuale
      Equity_ref = AccountEquity(); //Calcolo Equity
      Balance_ref = AccountBalance(); //Calcolo Balance
      BandHi_ref = iBands(NULL,0,BB_period,2,0,0,1,0); //Calcolo BB superiore
      BandLo_ref = iBands(NULL,0,BB_period,2,0,0,2,0); //Calcolo BB inferiore
      ma_ref = iMA(NULL,0,ma_period,0,0,0,0); //Calcolo MA
      rsi_ref = iRSI(NULL,0,RSI_period,PRICE_MEDIAN,0); //Calcolo RSI

      if(Profit_ref < MaxDrawback_ref)
        {
        MaxDrawback_ref = Profit_ref;
        }
      }*/



//FUNZIONE DI CREAZIONE LABELS PER DATI
bool LabelCreate(        const string name,            // label name
                         const int               x,    // X coordinate
                         const int               y,    // Y coordinate
                         const string          text)   // text
  {
  
   //Definizione costanti che NON VARIANO tra le varie labels
   const long              chart_ID = 0;              //Chart ID
   const int                sub_window = 0;           //Indice Sottofinestra
   const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER; //Angolo da usare come punto di partenza
   const string            font = "Arial";            //Font
   const int                font_size = 9;            //Font size
   const color             clr = clrWhite;            //Label Color
   const double          angle = 0.0;                 //Inclinazione della label
   const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER;  //Angolo da usare come centro di rotazione
   const bool              back=false;                //Sullo sfondo rispetto al resto = false
   const bool              selection=false;           //Spostabile con mouse = false
   const bool              hidden=true;               //Nascosto nella lista oggetti = true
   const long              z_order=0;                 //Priorità rispetto ai click col mouse
   

   ResetLastError(); //Resetta il valore di ultimo errore

   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)) //Creazione oggetto (funzione booleana) con if statement per catch
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError()); //Catch per eventualli errori
      return(false);
     }

   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);          //Coordinata X
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);          //Coordinata Y
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);        //Angolo del grafico
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);             //Testo
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);             //Font
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);   //Font Size
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);           //Angolo d'inclinazione
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);        //Centro di rotazione
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);            //Colore
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);            //Opzione per embedding nel background (true=embedded)
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); //Opzione per muovere il label col mouse (true=abilitato)
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);   // ^^
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);        //Mostra nella Lista Oggetti (true=visibile)
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);       //Priorità click del mouse sul grafico

   return(true);
  }


/*------------------------------------------------
FUNZIONI BOOLEANE DEI FILTRI DI APERTURA POSIZIONI
Il funzionamento degli switch ON/OFF per le
conidzioni di apertura delle posizioni è ottenuto
usando una condizione OR (||) in degli if statements
che quindi ritorneranno true se si verifica la
condizione oppure se la variabile booleana che
attiva la condizione stessa è impostata su false.
Es. In PipsGap_SELL, se LastOrderPrice ecc si verifica
OPPURE se Use_Pips_Gap è impostata su false, allora la
funzione ritorna true
------------------------------------------------*/

//PIPS GAP CHECK SELL
bool PipsGap_SELL(bool Use_Pips_Gap_ref ,int pips_gap_ref, double LastOrderPrice_ref)
    {
    if((LastOrderPrice_ref+pips_gap_ref*Point<Bid) || (!Use_Pips_Gap_ref))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//PIPS GAP CHECK BUY
bool PipsGap_BUY(bool Use_Pips_Gap_ref ,int pips_gap_ref, double LastOrderPrice_ref)
    {
    if((LastOrderPrice_ref-pips_gap_ref*Point>Ask) || (!Use_Pips_Gap_ref))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//MAX ORDERS CHECK
bool MaxOrders(bool Use_Max_Orders_ref, int O_orders_ref, int Max_Orders_ref)
    {
    if((O_orders_ref < Max_Orders_ref) || (!Use_Max_Orders_ref)) 
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//MOVING AVERAGE CHECK SELL
bool MA_Check_SELL(bool Use_Moving_Average_ref, double ma_ref)
    {
    if((ma_ref<Bid) || (!Use_Moving_Average_ref))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//MOVING AVERAGE CHECK BUY
bool MA_Check_BUY(bool Use_Moving_Average_ref, double ma_ref)
    {
    if((ma_ref>Ask) || (!Use_Moving_Average_ref))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//RSI CHECK SELL
bool RSI_Check_SELL(bool Use_RSI_Check_ref, double rsi_ref)
    {
    if((rsi_ref>=70) || (!Use_RSI_Check_ref))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//RSI CHECK BUY
bool RSI_Check_BUY(bool Use_RSI_Check_ref, double rsi_ref)
    {
    if((rsi_ref<=30) || (!Use_RSI_Check_ref))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//BOLLINGER BANDS CHECK SELL
bool BB_Check_SELL(bool Use_BB_ref, double BandHi_ref)
    {
    if((BandHi_ref<Bid) || (!Use_BB_ref))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//BOLLINGER BANDS CHECK BUY
bool BB_Check_BUY(bool Use_BB_ref, double BandLo_ref)
    {
    if((BandLo_ref>Bid) || (!Use_BB_ref))
      {
      return true;
      }
    else
      {
      return false;
      }
    }
