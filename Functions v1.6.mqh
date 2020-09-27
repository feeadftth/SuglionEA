//+------------------------------------------------------------------+
//|                                                    Functions.mqh |
//|                                                 Umberto Sugliano |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Umberto Sugliano"
#property link      ""
#property version   "1.6"
#property strict

//PARAMETRI DI INPUT
input double   lot_size=0.01; //Valore ordini
input int      bars_check_number=1000; //Initial Oscillation Check

input bool     Use_Pips_Gap = true; //Usa Pips Gap to Open
input int      pips_gap_input = 30; //Base Pips Gap

input bool     Use_MM = true; //Usa Money Management
input int      MM_Value = 85; //MM %

input bool     Use_Dyn_Pips_Gap = true; //Usa Dynamic Pips Gap
input int      Dyn_Gap_Mult = 3; //% Moltiplicatore Dyn Pips Gap

input bool     Use_Dyn_Sup_Res = true; //Usa Dynamic Sup & Res
input int      SupResTolerance = 8; //% Tolleranza 
input int      dyn_bars_check_number = 200; //Dynamic Oscillation Check

input bool     Use_BB = true; //Usa Bollinger Bands
input int      BB_period = 20; //Periodo Bande di Bollinger

input bool     Use_RSI_Check = true; //Usa RSI Check
input int      RSI_period = 8; //Periodo RSI

input bool     Use_Moving_Average = true; //Usa Moving Average
input int      ma_period = 14; //Periodo Moving Average

input bool     Use_Max_Orders = true; //Usa Max Orders
input int      Max_Orders = 30; //Max Open Orders

input bool     Use_Clearance = true; //Usa Clearance Zone
input int      Clearance = 5; //% Clearance Zone

input bool     Use_Trailing_Stop = true; //Usa Trailing Stop
input int      TrailingStart = 120; //Trailing Start
input int      TrailingStep = 60; //Trailing Step

input bool     Use_Stats = true; //Usa Statistiche 
input bool     Use_Conditions_Stats = true; //Usa Etichette Indicatori
input bool     DeleteObjOnDeinit = true; //Elimina Oggetti Deinit

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

//Booleani di funzioni di controllo condizioni
bool RSIsell = 0;
bool RSIbuy = 0;
bool MAsell = 0;
bool MAbuy = 0;
bool MeanSell = 0;
bool MeanBuy = 0;
bool BBsell = 0;
bool BBbuy = 0;
bool MaxOrd = 0;
bool PipsSell = 0;
bool PipsBuy = 0;
bool MonMan = 0;

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
//Chiamata della funzione: DynamicSupAndRes(ChngCount, Amp, SupResTolerance, Hi_ref, Lo_ref, Mean_ref, dyn_bars_check_number)
void DynamicSupAndRes(int &ChngCount_ref, double &Amp_ref, const int SupResTolerance_ref, double &Hi_ref, double &Lo_ref, double &Mean_ref, const int dyn_bars_check_number_ref)
    {
    bool change = false; //Booleano che indica se è stato effettuato un cambio di Sup o Res
    int DynamicHi_bar = iHighest(NULL,0,3,dyn_bars_check_number_ref,0); //Calcolo della barra dyn in cui c'è il prezzo più alto
    int DynamicLo_bar = iLowest(NULL,0,3,dyn_bars_check_number_ref,0); //Calcolo della barra dyn in cui c'è il prezzo più basso
    double DynamicHi_ref = NormalizeDouble(Close[DynamicHi_bar], 6); //Calcolo del prezzo dyn più alto, normalizzato
    double DynamicLo_ref = NormalizeDouble(Close[DynamicLo_bar], 6); //Calcolo del prezzo dyn più basso, normalizzato
    
    double DynHiPoint = DynamicHi_ref /_Point; //Conversione prezzo dyn  più alto in pips
    double DynLoPoint = DynamicLo_ref /_Point; //Conversione prezzo dyn più basso in pips
    double HiPoint = Hi_ref /_Point; //Conversione prezzo globale più alto in pips
    double LoPoint = Lo_ref /_Point; //Conversione prezzo globale più basso in pips

    double Tolerance = Amp_ref*SupResTolerance_ref*0.01; //Calcolo valore di Tolerance, funzionamento spiegato sopra
    
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
//Ogni modifica si riferisce al testo o al valore dell'etichetta associata al parametro, non al parametro stesso
void Stats(bool Use_Stats_ref, bool Use_Conditions_Stats_ref,
           double Equity_ref, double Balance_ref, double Profit_ref, 
           int O_orders_ref, double MaxDrawback_ref, double ma_ref, 
           double BandHi_ref, double BandLo_ref, double rsi_ref,
           bool RSIsell_ref, bool RSIbuy_ref, bool MAsell_ref, bool MAbuy_ref,
           bool BBsell_ref, bool BBbuy_ref, bool MeanSell_ref, bool MeanBuy_ref,
           bool PipsSell_ref, bool PipsBuy_ref, bool MaxOrd_ref, bool MonMan_ref,
           int MM_Value_ref, int Max_Orders_ref, int pips_gap_dyn_ref) 
      {
      //STATITSTICHE CLASSICHE - "Use_Stats = false" per disattivarle
      if(Use_Stats_ref)
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
      //STATISTICHE AVANZATE - "Use_Conditions_Stats = false" per disattivarle
      if(Use_Conditions_Stats_ref)
        {

        double drawback_perc = (((Equity/Balance)-1)*100);

        string ma_str = DoubleToStr(ma_ref, 5); //Conversione a stringa del Moving Average
        string BandHi_str = DoubleToStr(BandHi_ref, 5); //Conversione a stringa della High BB
        string BandLo_str = DoubleToStr(BandLo_ref, 5); //Conversione a stringa della Low BB
        string rsi_str = DoubleToStr(rsi_ref, 2); //Conversione a stringa dell'RSI
        string pips_str = IntegerToString(pips_gap_dyn_ref); //Conversione a stringa del Pips Gap
        string MM_str = DoubleToStr(drawback_perc, 2); //Conversione a stringa della percentuale di MM
        string MaxOrd_str = IntegerToString(Max_Orders_ref); //Conversione a stringa degli Ordini Massimi

        ObjectSetString(0,"MA Value", OBJPROP_TEXT, ma_str); //Modifica valore Moving Average
        ObjectSetString(0,"RSI Value", OBJPROP_TEXT, rsi_str); //Modifica valore RSI
        ObjectSetString(0,"BB Hi Value", OBJPROP_TEXT, BandHi_str); //Modifica valore High BB
        ObjectSetString(0,"BB Lo Value", OBJPROP_TEXT, BandLo_str); //Modifica valore Low BB
        ObjectSetString(0,"Pips Gap Value", OBJPROP_TEXT, pips_str); //Modifica valore Pips Gap
        ObjectSetString(0,"MaxOrd Value", OBJPROP_TEXT, MaxOrd_str); //Modifica valore Ordini Massimi
        ObjectSetString(0,"MonMan Value", OBJPROP_TEXT, MM_str + "%"); //Modifica valore MM

        
        //LIGHT-UP CONDITIONS
        //Se si verifica la condizione per l'apertura di una posizione, la statistica cambia colore:
        //Verde per Buy, Rosso per Sell, Blu per nessuna delle due

        //Condizione di illuminazione RSI Label
        if(RSIbuy_ref)
          {
          ObjectSetInteger(0,"RSI", OBJPROP_COLOR, clrLimeGreen);
          ObjectSetInteger(0,"RSI Value", OBJPROP_COLOR, clrLimeGreen);
          }
        else if(RSIsell_ref)
          {
          ObjectSetInteger(0,"RSI", OBJPROP_COLOR, clrRed);
          ObjectSetInteger(0,"RSI Value", OBJPROP_COLOR, clrRed);
          }
        else
          {
          ObjectSetInteger(0,"RSI", OBJPROP_COLOR, clrDodgerBlue);
          ObjectSetInteger(0,"RSI Value", OBJPROP_COLOR, clrDodgerBlue);
          }
        
        //Condizione di illuminazione MA Label
        if(MAbuy_ref)
          {
          ObjectSetInteger(0,"MA", OBJPROP_COLOR, clrLimeGreen);
          ObjectSetInteger(0,"MA Value", OBJPROP_COLOR, clrLimeGreen);
          }
        else if(MAsell_ref)
          {
          ObjectSetInteger(0,"MA", OBJPROP_COLOR, clrRed);
          ObjectSetInteger(0,"MA Value", OBJPROP_COLOR, clrRed);
          }
        else
          {
          ObjectSetInteger(0,"MA", OBJPROP_COLOR, clrDodgerBlue);
          ObjectSetInteger(0,"MA Value", OBJPROP_COLOR, clrDodgerBlue);
          }
          
        //Condizione di illuminazione BB Hi Label
        if(BBsell_ref)
          {
          ObjectSetInteger(0, "BB Hi", OBJPROP_COLOR, clrRed);
          ObjectSetInteger(0, "BB Hi Value", OBJPROP_COLOR, clrRed);
          }
        else
          {
          ObjectSetInteger(0, "BB Hi", OBJPROP_COLOR, clrDodgerBlue);
          ObjectSetInteger(0, "BB Hi Value", OBJPROP_COLOR, clrDodgerBlue);
          }
        
        //Condizione di illuminazione BB Lo Label
        if(BBbuy_ref)
          {
          ObjectSetInteger(0, "BB Lo", OBJPROP_COLOR, clrLimeGreen);
          ObjectSetInteger(0, "BB Lo Value", OBJPROP_COLOR, clrLimeGreen);
          }
        else
          {
          ObjectSetInteger(0, "BB Lo", OBJPROP_COLOR, clrDodgerBlue);
          ObjectSetInteger(0, "BB Lo Value", OBJPROP_COLOR, clrDodgerBlue);
          }

        //Condizione di illuminazione Pips Gap Label
        //Nota sul comportamento di Pips Gap: Sarà molto spesso di un colore per molto tempo perché dipende dalla posizione
        //rispetto all'ultimo ordine. Se l'ultimo ordine è un SELL più alto del prezzo attuale, ovviamente non ci potranno essere
        //le condizioni per un nuovo sell perché il pips gap si calcola in alto (per il Sell), quindi il gap è negativo e il colore
        //dell'indicatore sarà spesso verde o blu.
        if(PipsBuy_ref)
          {
          ObjectSetInteger(0,"Pips Gap", OBJPROP_COLOR, clrLimeGreen);
          ObjectSetInteger(0,"Pips Gap Value", OBJPROP_COLOR, clrLimeGreen);
          }
        else if(PipsSell_ref)
          {
          ObjectSetInteger(0,"Pips Gap", OBJPROP_COLOR, clrRed);
          ObjectSetInteger(0,"Pips Gap Value", OBJPROP_COLOR, clrRed);
          }
        else if(PipsBuy_ref && PipsSell_ref)
          {
          ObjectSetInteger(0,"Pips Gap", OBJPROP_COLOR, clrMagenta);
          ObjectSetInteger(0,"Pips Gap Value", OBJPROP_COLOR, clrMagenta);
          }
        else
          {
          ObjectSetInteger(0,"Pips Gap", OBJPROP_COLOR, clrDodgerBlue);
          ObjectSetInteger(0,"Pips Gap Value", OBJPROP_COLOR, clrDodgerBlue);
          }

        //Condizine di illuminazine Max Orders
        if(MaxOrd_ref)
          {
          ObjectSetInteger(0,"MaxOrd", OBJPROP_COLOR, clrMediumSpringGreen);
          ObjectSetInteger(0,"MaxOrd Value", OBJPROP_COLOR, clrMediumSpringGreen);
          }
        else
          {
          ObjectSetInteger(0,"MaxOrd", OBJPROP_COLOR, clrSienna);
          ObjectSetInteger(0,"MaxOrd Value", OBJPROP_COLOR, clrSienna);
          }

        //Condizione di illuminazione Money Management
        if(MonMan_ref)
          {
          ObjectSetInteger(0,"MonMan", OBJPROP_COLOR, clrMediumSpringGreen);
          ObjectSetInteger(0,"MonMan Value", OBJPROP_COLOR, clrMediumSpringGreen);
          }
        else
          {
          ObjectSetInteger(0,"MonMan", OBJPROP_COLOR, clrSienna);
          ObjectSetInteger(0,"MonMan Value", OBJPROP_COLOR, clrSienna);
          }
        }
      }

//FUNZIONE DI CONTROLLO DELLE CONDIZIONI DI APERTURA ORDINI
//Controlla se le condizioni di mercato soddisfano i criteri di apertura degli ordini, passando per referenza una variabile booleana per ogni
//criterio, a cui viene assegnato il valore corrispondente al return value della funzione di controllo, chiamata allo stesso modo in cui 
//veniva chiamata all'interno dell'IF in Main nelle versioni precedenti.
//Per poter chiamare ogni funzione c'è bisogno di ogni variabile indispensabile all'esecuzione di ogni funzione di controllo, motivo per cui 
//sono presenti tutti questi parametri.
void ConditionsCheck(bool Use_Max_Orders_ref, int O_orders_ref, int Max_Orders_ref,
                     bool Use_MM_ref, int MM_Value_ref, double Equity_ref, double Balance_ref,
                     bool Use_Moving_Average_ref, double ma_ref, double Amp_ref,
                     bool Use_Clearance_ref, int Clearance_ref, double Mean_ref,
                     bool Use_BB_ref, double BandHi_ref, double BandLo_ref,
                     bool Use_RSI_Check_ref, double rsi_ref,
                     bool Use_Pips_Gap_ref, int pips_gap_dyn_ref, double LastOrderPrice_ref,
                     bool &RSIsell_ref, bool &RSIbuy_ref, bool &MAsell_ref, bool &MAbuy_ref,
                     bool &BBsell_ref, bool &BBbuy_ref, bool &MeanSell_ref, bool &MeanBuy_ref,
                     bool &PipsSell_ref, bool &PipsBuy_ref, bool &MaxOrd_ref, bool &MonMan_ref)
    {

    RSIsell_ref = RSI_Check_SELL(Use_RSI_Check_ref, rsi_ref); //Chiamata funzione di controllo RSI Sell
    RSIbuy_ref = RSI_Check_BUY(Use_RSI_Check_ref, rsi_ref); //Chiamata funzione di controllo RSI Buy

    BBsell_ref = BB_Check_SELL(Use_BB_ref, BandHi_ref); //Chiamata funzione di controllo BB Sell
    BBbuy_ref = BB_Check_BUY(Use_BB_ref, BandLo_ref); //Chiamata funzione di controllo BB Buy

    MAsell_ref = MA_Check_SELL(Use_Moving_Average_ref, ma_ref); //Chiamata funzione di controllo MA Sell
    MAbuy_ref = MA_Check_BUY(Use_Moving_Average_ref, ma_ref); ///Chiamata funzione di controllo MA Buy

    MaxOrd_ref = MaxOrders(Use_Max_Orders_ref, O_orders_ref, Max_Orders_ref); //Chiamata funzione di controllo Max Orders
    MonMan_ref = !MoneyManagement(Use_MM_ref, MM_Value_ref, Equity_ref, Balance_ref); //Chiamata funzione di controllo Money Management

    if(LastOrderPrice_ref != 0)
      {
      PipsSell_ref = PipsGap_SELL(Use_Pips_Gap_ref, pips_gap_dyn_ref, LastOrderPrice_ref); //Chiamata funzione di controllo Pips Gap Sell
      PipsBuy_ref = PipsGap_BUY(Use_Pips_Gap_ref, pips_gap_dyn_ref, LastOrderPrice_ref); //Chiamata funzione di controllo Pips Gap Buy
      }
    else
      {
      PipsSell_ref = true;
      PipsBuy_ref = true;
      }

    //Funzioni di controllo per la posizione rispetto alla linea mediana, che prima era controllata direttamente negli IF di BUY e SELL in Main
    if(Bid>Mean_ref+(Amp_ref*0.01*Clearance_ref*Use_Clearance_ref)*Point)
      {
      MeanSell_ref = true;
      }
    else
      {
      MeanSell_ref = false;
      }

    if(Ask<Mean_ref-(Amp_ref*0.01*Clearance_ref*Use_Clearance_ref)*Point)
      {
      MeanBuy_ref = true;
      }
    else
      {
      MeanBuy_ref = false;
      }
    }


//FUNZIONE DI CREAZIONE LABELS PER DATI
bool LabelCreate(        const string           name,   // label name
                         const int              x,      // X coordinate
                         const int              y,      // Y coordinate
                         const string           text,   // text
                         const ENUM_BASE_CORNER corner) // Angolo da usare come punto di partenza
  {
   long backclr = ChartBackColorGet(); //                                  
   color clr;                          //        
   if(backclr == 0)                    //              
     {                                 // 
     clr =  16777215;                  //Lasciamo stare sta parte di codice che fa schifo in culo.                
     }                                 //Serve a cambiare colore alle etichette in base allo sfondo, ma
   else                                //è brutta perché non funzionava e così va, ma è da cambiare.
     {                                 // 
     clr = 0;                          //        
     }                                 // 
  
   //Definizione costanti che NON VARIANO tra le varie labels
   const long              chart_ID = 0;              //Chart ID
   const int                sub_window = 0;           //Indice Sottofinestra
   const string            font = "Arial";            //Font
   const int                font_size = 9;            //Font size
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

//Funzione per ottenere il colore del background in formato long
// ChartBackColorGet()
color ChartBackColorGet()
  {
  long result=clrNONE;
  ResetLastError();
  if(!ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,result))
    {
    Print(__FUNCTION__+", Error Code = ",GetLastError());
    }
  Print(result);
  return(result);
}

//FUNZIONE CHE ELIMINA OGNI ELEMENTO GRAFICO DISEGNATO DAL BOT QUANDO CHIAMATA
//Non ha bisogno di parametri
void DeleteObjects()
    {
    ObjectDelete("Res");
    ObjectDelete("Mean");
    ObjectDelete("Sup");
    ObjectDelete("Balance");
    ObjectDelete("Balance Value");
    ObjectDelete("Equity");
    ObjectDelete("Equity Value");
    ObjectDelete("Profit");
    ObjectDelete("Profit Value");
    ObjectDelete("Open Orders");
    ObjectDelete("Open Orders Value");
    ObjectDelete("Max Drawback");
    ObjectDelete("Max Drawback Value");
    ObjectDelete("RSI");
    ObjectDelete("RSI Value");
    ObjectDelete("MA");
    ObjectDelete("MA Value");
    ObjectDelete("BB Hi");
    ObjectDelete("BB Hi Value");
    ObjectDelete("BB Lo");
    ObjectDelete("BB Lo Value");
    ObjectDelete("Conditions");
    ObjectDelete("MaxOrd");
    ObjectDelete("MaxOrd Value");
    ObjectDelete("MonMan");
    ObjectDelete("MonMan Value");
    ObjectDelete("Pips Gap");
    ObjectDelete("Pips Gap Value");
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
funzione ritorna true.
------------------------------------------------*/

//PIPS GAP CHECK SELL
bool PipsGap_SELL(bool Use_Pips_Gap_ref2 ,int pips_gap_ref2, double LastOrderPrice_ref2)
    {
    if((LastOrderPrice_ref2+pips_gap_ref2*Point<Bid) || !(Use_Pips_Gap_ref2))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//PIPS GAP CHECK BUY
bool PipsGap_BUY(bool Use_Pips_Gap_ref2 ,int pips_gap_ref2, double LastOrderPrice_ref2)
    {
    if((LastOrderPrice_ref2-pips_gap_ref2*Point>Ask) || !(Use_Pips_Gap_ref2))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//MAX ORDERS CHECK
bool MaxOrders(bool Use_Max_Orders_ref2, int O_orders_ref2, int Max_Orders_ref2)
    {
    if((O_orders_ref2 < Max_Orders_ref2) || (!Use_Max_Orders_ref2)) 
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//MOVING AVERAGE CHECK SELL
bool MA_Check_SELL(bool Use_Moving_Average_ref2, double ma_ref2)
    {
    if((ma_ref2<Bid) || (!Use_Moving_Average_ref2))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//MOVING AVERAGE CHECK BUY
bool MA_Check_BUY(bool Use_Moving_Average_ref2, double ma_ref2)
    {
    if((ma_ref2>Ask) || (!Use_Moving_Average_ref2))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//RSI CHECK SELL
bool RSI_Check_SELL(bool Use_RSI_Check_ref2, double rsi_ref2)
    {
    if((rsi_ref2>=70) || (!Use_RSI_Check_ref2))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//RSI CHECK BUY
bool RSI_Check_BUY(bool Use_RSI_Check_ref2, double rsi_ref2)
    {
    if((rsi_ref2<=30) || (!Use_RSI_Check_ref2))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//BOLLINGER BANDS CHECK SELL
bool BB_Check_SELL(bool Use_BB_ref2, double BandHi_ref2)
    {
    if((BandHi_ref2<Bid) || (!Use_BB_ref2))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//BOLLINGER BANDS CHECK BUY
bool BB_Check_BUY(bool Use_BB_ref2, double BandLo_ref2)
    {
    if((BandLo_ref2>Bid) || (!Use_BB_ref2))
      {
      return true;
      }
    else
      {
      return false;
      }
    }
