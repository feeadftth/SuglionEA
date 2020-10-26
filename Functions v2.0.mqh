//+------------------------------------------------------------------+
//|                ┏━━━┓╋╋╋╋╋┏┓╋╋╋╋╋╋╋┏━━━┳━━━┓        Functions v2.0|
//|                ┃┏━┓┃╋╋╋╋╋┃┃╋╋╋╋╋╋╋┃┏━━┫┏━┓┃      Umberto Sugliano|
//|                ┃┗━━┳┓┏┳━━┫┃┏┳━━┳━┓┃┗━━┫┃╋┃┃                      |
//|                ┗━━┓┃┃┃┃┏┓┃┃┣┫┏┓┃┏┓┫┏━━┫┗━┛┃                      |
//|                ┃┗━┛┃┗┛┃┗┛┃┗┫┃┗┛┃┃┃┃┗━━┫┏━┓┃                      |
//|                ┗━━━┻━━┻━┓┣━┻┻━━┻┛┗┻━━━┻┛╋┗┛                      |
//|                ╋╋╋╋╋╋╋┏━┛┃                                       |
//|                ╋╋╋╋╋╋╋┗━━┛                                       |             
//+------------------------------------------------------------------+
#property copyright "Umberto Sugliano"
#property link      ""
#property version   "2.0"
#property strict

//Lista numerata per specificare il tipo di elaborazione avanzata dell'indicatore
enum EVAL_METHODS 
  {
  Exponential,
  Linear,
  Logarithmic
  };

//PARAMETRI DI INPUT
sinput string  str0 = "IMPOSTAZIONI CLASSICHE"; //-------------------------------------------------------
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

sinput string  str1 = "CLASSIC MAX ORDERS"; //-------------------------------------------------------
input bool     Use_Max_Orders = true; //Usa Max Orders
input int      MainMax_Orders = 8; //Max Open Orders
input bool     Use_Dyn_Max_Orders = true; //Usa Dynamic Max Orders

sinput string str2 = "CLEARANCE ZONE"; //-------------------------------------------------------
input bool     Use_Clearance = true; //Usa Clearance Zone
input int      Clearance = 15; //% Clearance Zone

sinput string str3 = "TRAILING STOP"; //-------------------------------------------------------
input bool     Use_Trailing_Stop = true; //Usa Trailing Stop
input int      TrailingStart = 120; //Trailing Start
input int      TrailingStep = 60; //Trailing Step
input bool     Use_Dynamic_TS = true; //Usa Dynamic Trailing Stop
input EVAL_METHODS TS_eval_method = Logarithmic; //Metodo Trailing Stop
input int      dyn_ts_power_input = 2; //Potenza Dynamic Trailing Stop
input bool     Use_decreasing_TS = true; //Usa Decreasing Trailing Stop
input int      ts_minprofit = 5; //Pips Minimi di Profit
input int      ts_lastbar = 288; //Ultima barra

sinput string  str4 = "STATISTICHE"; //-------------------------------------------------------
input bool     Use_Stats = true; //Usa Statistiche 
input bool     Use_Conditions_Stats = true; //Usa Etichette Indicatori
input bool     DeleteObjOnDeinit = true; //Elimina Oggetti Deinit


//DICHIARAZIONI INPUT PER L'ALGORITMO AVANZATO DI VALUTAZIONE DEGLI INDICATORI
sinput string str5="ADVANCED EVALUATION SETTINGS"; //-------------------------------------------------------

input bool     Use_Advanced_Evaluation = true; //Usa Elaborazione Avanzata
input bool     Use_Advanced_Stats = true; //Usa Statistiche Avanzate
input double   Agg = 100; //% Aggressività

sinput string  str6="DYNAMIC MAX LOT SIZE"; //-------------------------------------------------------
input bool     Use_Dynamic_Max_lot = true; //Usa Valore ordini massimo dinamico
input double   Max_lot_size = 0.1; //Valore ordini massimo
input int      MaAm_weight = 2; //Peso MainAmp Price Position
input int      DyAm_weight = 2; //Peso DynamicAmp Price Position
input int      AR_weight = 2; //Peso AmpRatio 


sinput string  rsi_sep="RELATIVE STRENGHT INDEX"; //-------------------------------------------------------

input EVAL_METHODS RSI_eval_method = Exponential; //Metodo RSI
input double   rsi_power_input = 2; //Potenza RSI
input int      RSI_weight = 17; //Peso RSI

sinput string  ma_sep="MOVING AVERAGE"; //-------------------------------------------------------

input EVAL_METHODS MA_eval_method = Exponential; //Metodo MA
input double   ma_power_input = 3; //Potenza MA
input int      ma_weight = 17; //Peso MA
input int      ma_margin_perc = 30; //% DynamicAmp check

sinput string  bb_sep="BOLLINGER BANDS"; //-------------------------------------------------------

input int      BB_factor = 20; //Fattore Bollinger Bands
input int      BB_weight = 17; //Peso Bollinger Bands

sinput string  PipsGap_sep="ANTI-CROWDING"; //-------------------------------------------------------

input EVAL_METHODS Pips_Gap_eval_method = Exponential; //Metodo Pips Gap
input double   pips_gap_power_input = 2; // Potenza Pips Gap
input int      Pips_gap_weight = 7; //Peso Pips Gap
input int      minpipsgap = 5; //Crowdzone Minima
input int      maxpipsgap = 100; //Crowdzone Massima

sinput string MaxOrd_sep="ADV MAX ORDERS"; //-------------------------------------------------------

input EVAL_METHODS Max_Orders_eval_method = Exponential; //Metodo Max Orders
input double   max_orders_power_input = 1.5; //Potenza Max Orders
input int      Max_Orders_weight = 10; //Peso Max Orders

sinput string MM_sep="MONEY MANAGEMENT"; //-------------------------------------------------------

input EVAL_METHODS MM_eval_method = Logarithmic; //Metodo MM
input double   MM_power_input = 2; //Potenza MM
input int      MM_weight = 12; //Peso MM

sinput string mean_sep="MEAN LINE"; //-------------------------------------------------------

input EVAL_METHODS Mean_eval_method = Exponential; //Metodo Mean Distribution
input double   Mean_power_input = 2; //Potenza Mean Distribution
input int      Mean_weight = 20; //Peso Mean Distribution

//INIZIALIZZAZIONE VARIABILI GLOBALI
double MainMean = 0;
double ma = 0;
double BandLo = 0;
double BandHi = 0;
double rsi = 0;
double LastOrderPrice =0;
double Balance = AccountBalance();
double Equity = AccountEquity();
double Profit = AccountProfit();
double DynamicHi;
double DynamicLo;
double DynamicMean;
double MainHi = 0;
double MainLo = 0;
double MaxDrawback = AccountProfit();
double MainAmp = 0;
double DynamicAmp = 0;
double offset = 0;
double dyn_ts_power = 0;

//VARIABILI DOUBLE PER L'ALGORITMO AVANZATO
double score = 0;
double dyn_lot_size = 0;
double dyn_Max_lot_size = Max_lot_size;

double rsi_power =0;
double pips_gap_power =0;
double max_orders_power = 0;
double MM_power =0;
double Mean_power =0;
double ma_power =0;

double RSI_score = 0;
double BB_score = 0;
double AntiCrowding_score = 0;
double MA_score = 0;
double MaxOrders_score = 0;
double MM_score = 0;
double Mean_score = 0;

int    DynTrailingStart = 0;
int    DynTrailingStep = 0;
int    DynMax_Orders = MainMax_Orders;
int    O_orders = OrdersTotal();
int    LastOrderBar = 1;
int    pips_gap_dyn = pips_gap_input;

int ChngCount = 0;

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

//Varibili grafiche
int x_pos=0, width=0; //Posizione X e Larghezza
int y_pos=0, height=0; //Posizione Y e Altezza
int stat_rows = 0; //Righe di statistiche avanzate
int indexarr[]; //Array di indici nella lista di oggetti totali


//RICERCA DI SOSTEGNO, RESISTENZA E VALORE MEDIO
//Parametri formali passati per referenza e non coincidono con le variabili globali
void MainSupAndRes() 
  { 
  int Hi_bar = iHighest(NULL,0,3,bars_check_number,0);  //Calcolo della barra globale in cui c'è il prezzo più alto
  int Lo_bar = iLowest(NULL,0,3,bars_check_number,0);   //Calcolo della barra globale in cui c'è il prezzo più basso
  MainHi = NormalizeDouble(Close[Hi_bar], 6);               //Calcolo del prezzo globale più alto, normalizzato
  MainLo = NormalizeDouble(Close[Lo_bar], 6);               //Calcolo del prezzo globale più basso. normalizzato
  ObjectCreate("Main Res", OBJ_HLINE, 0, Time[0], MainHi, 0, 0); //Creazione linea di Resistenza
  ObjectCreate("Main Sup", OBJ_HLINE, 0, Time[0], MainLo, 0, 0); //Creazione linea di Sostegno
  ObjectSet("Main Res", OBJPROP_COLOR, clrDarkViolet); //Imposta il colore della Main Res Line
  ObjectSet("Main Sup", OBJPROP_COLOR, clrDarkViolet); //Imposta il colore della Main Sup Line
  MainMean = (MainHi+MainLo)/2;                             //Calcolo del prezzo medio
  ObjectCreate("Main Mean Line", OBJ_HLINE, 0, Time[0], MainMean, 0, 0); //Creazione linea di media
  ObjectSet("Main Mean Line", OBJPROP_COLOR, clrMagenta);         //Imposta il colore della Mean Line
  double Price_diff = (MainHi - MainLo);                    //Calcolo della differenza di prezzo tra Sup e Res
  MainAmp = NormalizeDouble(Price_diff, 6) /_Point;     //Normalizzazione e conversione in pips di Price_diff
  DynamicAmp = MainAmp; //Imposta i valori dinamici uguali a quelli Main, in modo da
  DynamicHi = MainHi;   //rendere il funzionamento del resto del codice identico in caso
  DynamicLo = MainLo;   //di non attivazione del DynamicSup&Res.
  DynamicMean = MainMean;
  }

//RICERCA DINAMICA DI SOSTEGNO, RESISTENZA E VALORE MEDIO
//Se il gafico ha rotto le mura dell'oscillazione di un valore uguale ad una percentuale dell'oscillazione 
//specificata in input da SupResTolerance, i prezzi di sostegno e resistenza vengono aggiornati a quelli attuali
//Chiamata della funzione: DynamicSupAndRes(ChngCount, Amp, SupResTolerance, Hi, Lo, Mean, dyn_bars_check_number)
void DynamicSupAndRes()
  {
  bool change = false; //Booleano che indica se è stato effettuato un cambio di Sup o Res
   
  int DynamicHi_bar = iHighest(NULL,0,3,dyn_bars_check_number,0); //Calcolo della barra dyn in cui c'è il prezzo più alto
  int DynamicLo_bar = iLowest(NULL,0,3,dyn_bars_check_number,0); //Calcolo della barra dyn in cui c'è il prezzo più basso
   
  double tempHi = NormalizeDouble(Close[DynamicHi_bar], 6); //Calcolo del prezzo dyn più alto, normalizzato
  double tempLo = NormalizeDouble(Close[DynamicLo_bar], 6); //Calcolo del prezzo dyn più basso, normalizzato    
  double tempHiPoint = tempHi /_Point; //Conversione prezzo dyn più alto in pips
  double tempLoPoint = tempLo /_Point; //Conversione prezzo dyn più basso in pips
  double HiPoint = DynamicHi /_Point; //Conversione prezzo globale più alto in pips
  double LoPoint = DynamicLo /_Point; //Conversione prezzo globale più basso in pips
  double Tolerance = DynamicAmp*SupResTolerance*0.01; //Calcolo valore di Tolerance, funzionamento spiegato sopra
       
  //Res Check
  //Se il prezzo dyn è più alto di quello globale + Tolerance oppure più basso di quello globale - Tolerance, allora opera
  if(((tempHiPoint)>(HiPoint+Tolerance)) || ((tempHiPoint)<(HiPoint-(Tolerance))))
    {                                                                                                                 
    DynamicHi = NormalizeDouble(tempHi, 6); //Normalizzazione del prezzo dyn più alto, già calcolato
    change = true;                              //Imposta change su true
    if(ObjectFind("Dynamic Res")<0)
      {
      ObjectCreate("Dynamic Res", OBJ_HLINE, 0, Time[0], DynamicHi); //Se non trova la Dynamic Res la crea e la formatta
      ObjectSet("Dynamic Res", OBJPROP_COLOR, clrPeru);
      }
    else
      {
      ObjectSet("Dynamic Res", OBJ_HLINE, DynamicHi);        //Sposta la linea di Res al nuovo prezzo
      }
    ChngCount++;                            //Incrementa la variabile di conteggio
    }
       
  //Sup Check
  if(((tempLoPoint)<(LoPoint-Tolerance)) || ((tempLoPoint)>(LoPoint+(Tolerance))))
    {
    DynamicLo = NormalizeDouble(tempLo, 6); //Normalizzazione del prezzo dyn più basso
    change = true;                              //Imposta change su true
    if(ObjectFind("Dynamic Sup")<0)
      {
      ObjectCreate("Dynamic Sup", OBJ_HLINE, 0, Time[0], DynamicLo);
      ObjectSet("Dynamic Sup", OBJPROP_COLOR, clrPeru);
      }
    else
    {
      ObjectSet("Dynamic Sup", OBJ_HLINE, DynamicLo);        //Sposta la linea di Sup al nuovo prezzo
    }
    ChngCount++;                            //Incrementa la variabile di conteggio
    }
     
  if(change) //Se change è stato impostato su true, quindi se sono stati aggiornati i prezzi globali di Sup e/o Res
    {
    DynamicMean = (DynamicHi+DynamicLo)/2;                      //Ricalcola il prezzo medio
    if(ObjectFind("Dynamic Mean Line")<0)
      {
      ObjectCreate("Dynamic Mean Line", OBJ_HLINE, 0, Time[0], DynamicMean);
      ObjectSet("Dynamic Mean Line", OBJPROP_COLOR, clrDarkOrange);
      }
    else
      {
      ObjectSet("Dynamic Mean Line", OBJ_HLINE, DynamicMean);            //Sposta la linea di media al nuovo prezzo
      }
    double Price_diff = (DynamicHi - DynamicLo);             //Ricalcolo della differenza di prezzo tra i nuovi Sup e Res
    DynamicAmp = NormalizeDouble(Price_diff, 6) /_Point;  //Normalizzazione e conversione in pips di Price_diff
    }
  }


//DYNAMIC PIPS GAP
//Il pips gap necessario per aprire una nuova posizione varia in base alla ampiezza dell'oscillazione (Amp)
//di un valore percentuale intero definito in input (Dyn_Gap_Mult)
//Chiamata di funzione: DynamicPipsGap(Use_Dyn_Pips_Gap, pips_gap_input, pips_gap_dyn, Amp, Dyn_Gap_Mult)
void DynamicPipsGap()
  {
  if(Use_Dyn_Pips_Gap)
    {
    pips_gap_dyn = (int)MathCeil(DynamicAmp*Dyn_Gap_Mult*0.01);
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
void LogVarValues(double rsi_power_ref, double Max_orders_power_ref, double pips_gap_power_ref, double ma_power_ref, double MM_power_ref, double Mean_power_ref)
  {
  Print("RSI = ", rsi_power_ref, " | MaxOrd = ", Max_orders_power_ref, " | PipsG = ", pips_gap_power_ref, " | MA = ", ma_power_ref, " | MM = ", MM_power_ref, " | Mean = ", Mean_power_ref);
  }
      

//FUNZIONE DI TRAILING STOP
void TrailingStop() 
  {
  int tempTrailingstart = DynTrailingStart;
  int tempTrailingstep = DynTrailingStep;
  
  for(int n_order = OrdersTotal()-1; n_order >=0; n_order--) //Ciclo FOR per controllare tutti gli ordini
    {
    if(OrderSelect(n_order,SELECT_BY_POS,MODE_TRADES) != True) //Seleziona l'ordine numero n_order in ordine cronologico decrescente di apertura
      {
      GetLastError(); //Check per eventuali errori dell'OrderSelect
      } 
    if(Use_decreasing_TS) //Se Decreasing TS è attiva, i valori di TS diminuiscono col numero di barre passate dall'apertura della posizione
      {
      string Sym = ChartSymbol(); //Calcolo del simbolo
      double Spread = MarketInfo(Sym, MODE_SPREAD); //Calcolo Spread attuale
      datetime opentime = OrderOpenTime(); //Calcolo timestamp di apertura dell'ordine selezionato
      int openbar = iBarShift(NULL, 0, opentime); //Calcolo bar-displacement dell'ordine selezionato
      tempTrailingstart = (int)MathRound(TrailingMath(DynTrailingStart, ts_minprofit, 1, Spread, ts_lastbar, openbar)); //Modifica al valore di Start
      tempTrailingstep = (int)MathRound(TrailingMath(DynTrailingStep, ts_minprofit, 0, Spread, ts_lastbar, openbar)); //Modifica al valore di Step
      }
       
     //TRAILING PER LE POSIZIONI SELL
    if(OrderType() == OP_SELL)
      {
      if(OrderOpenPrice()>Ask+tempTrailingstart*Point) //Controlla se la posizione è in profitto
        {
        if(OrderStopLoss() == 0 || OrderStopLoss()>Ask+tempTrailingstep*Point) //Controlla se lo Stop Loss è 0 o maggiore del prezzo Ask attuale aumentato di X pips
          {
          if(OrderModify( //Funzione di modifica dell'ordine
                         OrderTicket(), //Ticket identificativo unico dell'ordine
                         OrderOpenPrice(), //Prezzo di apertura dell'ordine, non modificato
                         Ask+tempTrailingstep*Point, //Prezzo a cui viene impostato lo Stop Loss
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
      if(OrderOpenPrice()<Bid-tempTrailingstart*Point) //Controlla se la posizione è in profitto
        {
        if(OrderStopLoss() == 0 || OrderStopLoss()<Bid-tempTrailingstep*Point) //Controlla se lo Stop Loss è 0 o minore del prezzo Bid attuale aumentato di X pips
          {
          if(OrderModify( //Funzione di modifica dell'ordine
                         OrderTicket(), //Ticket identificativo unico dell'ordine
                         OrderOpenPrice(), //Prezzo di apertura dell'ordine, non modificato
                         Bid-tempTrailingstep*Point, //Prezzo a cui viene impostato lo Stop Loss
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

//FUNZIONE DI CALCOLO DEI PARAMETRI DI TRAILING IN BASE AL TEMPO PASSATO DALL'APERTURA DELL'ORDINE
double TrailingMath(int a, int k, int n, double p, int t, int x)
  {
  double eval = ((2*a*t*t)-(x*x*a)-(x*a*t)+(2*x*(x+t)*(p+(n*p)+k)))/((2*t*(x+t))+0.0);
  return(eval);
  }

//FUNZOINE DI DYNAMIC TRAILING STOP VALUES UPDATE
void DynamicTrailing() 
  {
  double amp_coeff = DynamicAmp/MainAmp;
  string Sym = ChartSymbol(0);
  double Spread = MarketInfo(Sym, MODE_SPREAD);

  DynTrailingStart = (int)MathRound(TrailingStart*MathPow(((DynamicAmp+(Spread*(1-amp_coeff)))/MainAmp), dyn_ts_power));
  DynTrailingStep = (int)MathRound(TrailingStep*MathPow(((DynamicAmp+(Spread*(1-amp_coeff)))/MainAmp), dyn_ts_power));
  }

//FUNZIONE DI DYNAMIC MAX LOT SIZE
double DynamicMaxLotSize()
  {
  double eval = 0;
  double MainAmp_pos_score = 0;
  double DynAmp_pos_score = 0;
  double AmpRatio_score = 0;

  MainAmp_pos_score = NormalizeDouble((2*MathAbs(Bid-MainMean)/(MainAmp*Point)), 4);
  Print("MainAmp_pos_score = "+MainAmp_pos_score);

  DynAmp_pos_score = NormalizeDouble((2*MathAbs(Bid-DynamicMean)/(DynamicAmp*Point)), 4);
  Print("DynAmp_pos_score = "+DynAmp_pos_score);

  AmpRatio_score = NormalizeDouble((DynamicAmp/MainAmp), 4);
  Print("AmpRatio_score = "+AmpRatio_score);

  eval = Max_lot_size*NormalizeDouble(((MainAmp_pos_score*MaAm_weight)+(DynAmp_pos_score*DyAm_weight)+
              (AmpRatio_score*AR_weight))/(AR_weight+DyAm_weight+MaAm_weight), 2);
  Print("Max Lot Eval = ", eval);

  return(eval);
  }


//FUNZIONE DI MONEY MANAGEMENT
bool MoneyManagement() //La funzione è di tipo bool, cioè ritorna un valore booleano (vero o falso, 1 o 0)
      {
      double XPercent = double(MM_Value)/100; //Conversione in valore percentuale dell'input di Money Management
      double Ratio = Equity/Balance; //Double di rapporto tra liquidità e bilancio (<1 significa che il profit è negativo)

      if((Ratio <= XPercent) || (!Use_MM)) //Se il rapporto è inferiore alla percentuale indicata in input, la funzione ritorna true => 1
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
void Stats() 
      {
      //STATITSTICHE CLASSICHE - "Use_Stats = false" per disattivarle
      if(Use_Stats)
        {
        string Max = DoubleToStr(MaxDrawback, 2); //Conversione a stringa del valore double di massimo drawback
        string Ord = IntegerToString(O_orders); //Conversione a stringa del valore intero di ordini aperti
        string Prft = DoubleToStr(Profit, 2); //Conversione a stringa del valore double di Profit
        string Blnc = DoubleToStr(Balance, 2); //^^ per il Balance
        string Eqty = DoubleToStr(Equity, 2); //^^ per l'Equity

        ObjectSetString(0,"Balance Value", OBJPROP_TEXT, Blnc); //Modifica valore Balance
        ObjectSetString(0,"Equity Value", OBJPROP_TEXT, Eqty); //Modifica valore Equity
        ObjectSetString(0,"Profit Value", OBJPROP_TEXT, Prft); //Modifica valore Profit
        ObjectSetString(0,"Open Orders Value", OBJPROP_TEXT, Ord); //Modifica valore Ordini Aperti
        ObjectSetString(0,"Max Drawback Value", OBJPROP_TEXT, Max); //Modifica valore Max Drawback
        }
      //STATISTICHE AVANZATE - "Use_Conditions_Stats = false" per disattivarle
      if(!Use_Advanced_Evaluation)
        {
        if(Use_Conditions_Stats)
          {
  
          double drawback_perc = (((Equity/Balance)-1)*100);
  
          string ma_str = DoubleToStr(ma, 5); //Conversione a stringa del Moving Average
          string BandHi_str = DoubleToStr(BandHi, 5); //Conversione a stringa della High BB
          string BandLo_str = DoubleToStr(BandLo, 5); //Conversione a stringa della Low BB
          string rsi_str = DoubleToStr(rsi, 2); //Conversione a stringa dell'RSI
          string pips_str = IntegerToString(pips_gap_dyn); //Conversione a stringa del Pips Gap
          string MM_str = DoubleToStr(drawback_perc, 2); //Conversione a stringa della percentuale di MM
          string MaxOrd_str = IntegerToString(DynMax_Orders); //Conversione a stringa degli Ordini Massimi
  
          ObjectSetString(0,"MA Value", OBJPROP_TEXT, ma_str); //Modifica valore Moving Average
          ObjectSetString(0,"RSI Value", OBJPROP_TEXT, rsi_str); //Modifica valore RSI
          ObjectSetString(0,"BB Hi Value", OBJPROP_TEXT, BandHi_str); //Modifica valore High BB
          ObjectSetString(0,"BB Lo Value", OBJPROP_TEXT, BandLo_str); //Modifica valore Low BB
          ObjectSetString(0,"Anti-Crowding Value", OBJPROP_TEXT, pips_str); //Modifica valore Pips Gap
          ObjectSetString(0,"MaxOrd Value", OBJPROP_TEXT, MaxOrd_str); //Modifica valore Ordini Massimi
          ObjectSetString(0,"MonMan Value", OBJPROP_TEXT, MM_str + "%"); //Modifica valore MM
  
          
          //LIGHT-UP CONDITIONS
          //Se si verifica la condizione per l'apertura di una posizione, la statistica cambia colore:
          //Verde per Buy, Rosso per Sell, Blu per nessuna delle due
  
          //Condizione di illuminazione RSI Label
          if(RSIbuy)
            {
            ObjectSetInteger(0,"RSI", OBJPROP_COLOR, clrLimeGreen);
            ObjectSetInteger(0,"RSI Value", OBJPROP_COLOR, clrLimeGreen);
            }
          else if(RSIsell)
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
          if(MAbuy)
            {
            ObjectSetInteger(0,"MA", OBJPROP_COLOR, clrLimeGreen);
            ObjectSetInteger(0,"MA Value", OBJPROP_COLOR, clrLimeGreen);
            }
          else if(MAsell)
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
          if(BBsell)
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
          if(BBbuy)
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
          if(PipsBuy)
            {
            ObjectSetInteger(0,"Anti-Crowding", OBJPROP_COLOR, clrLimeGreen);
            ObjectSetInteger(0,"Anti-Crowding Value", OBJPROP_COLOR, clrLimeGreen);
            }
          else if(PipsSell)
            {
            ObjectSetInteger(0,"Anti-Crowding", OBJPROP_COLOR, clrRed);
            ObjectSetInteger(0,"Anti-Crowding Value", OBJPROP_COLOR, clrRed);
            }
          else if(PipsBuy && PipsSell)
            {
            ObjectSetInteger(0,"Anti-Crowding", OBJPROP_COLOR, clrMagenta);
            ObjectSetInteger(0,"Anti-Crowding Value", OBJPROP_COLOR, clrMagenta);
            }
          else
            {
            ObjectSetInteger(0,"Anti-Crowding", OBJPROP_COLOR, clrDodgerBlue);
            ObjectSetInteger(0,"Anti-Crowding Value", OBJPROP_COLOR, clrDodgerBlue);
            }
  
          //Condizine di illuminazine Max Orders
          if(MaxOrd)
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
          if(MonMan)
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
      else
        {
          if(Use_Advanced_Stats)
            {
            string score_str = DoubleToStr(MathAbs(score), 2); //Conversione a stringa dell'Advanced Score
            string dyn_Max_lot_size_str = DoubleToStr(dyn_Max_lot_size, 2); //Conversione a stringa del Dyn Max Lot Size
            string dyn_max_orders = DoubleToStr(DynMax_Orders, 0); //Conversione a stringa del Dynamic Max Orders
            string MM_perc_profit = DoubleToStr((AccountProfit()/Balance)*100, 2); // Conversione a stringa della percentuale di Drawback attuale
            string ma_score_str = DoubleToStr(MA_score, 2); //Conversione a stringa dello score Moving Average
            string BB_score_str = DoubleToStr(BB_score, 2); //Conversione a stringa dello score BB
            string rsi_score_str = DoubleToStr(RSI_score, 2); //Conversione a stringa dello score RSI
            string AntiCrowding_score_str = DoubleToStr(AntiCrowding_score, 2); //Conversione a stringa dello score Anti-Crowding
            string Crowdzone_str = DoubleToStr(pips_gap_dyn, 0); //Conversione a stringa dell'ampiezza della Crowdzone
            string MM_score_str = DoubleToStr(MM_score, 2); //Conversione a stringa dello score MM
            string MaxOrders_score_str = DoubleToStr(MaxOrders_score, 2); //Conversione a stringa dello score Max Orders
            string Mean_score_str = DoubleToStr(Mean_score, 2); //Conversione a stringa dello score Mean
            string DynAmp_str = DoubleToStr(DynamicAmp, 0); //Conversione a stringa ampiezza dinamica oscillazione
            string AmpRatio_str = DoubleToStr((DynamicAmp*100)/MainAmp, 2); //Conversione a stringa del rapporto tra DynAmp e MainAmp in %
            string MainAmp_str = DoubleToStr(MainAmp, 0); //Conversione a stringa dell'ampiezza iniziale dell'oscillazione
            string Maxlot_str = DoubleToStr(Max_lot_size, 0); //Conversione a stringa numero lotti massimi

            if(MathAbs(score)>0)
              {
              ObjectSetString(0,"02Global Score", OBJPROP_TEXT, "Global Score = "+score_str); //Modifica valore Advanced Score
              }
            ObjectSetString(0,"03Dynamic Max Lot", OBJPROP_TEXT, "Dynamic Max Lot ("+Maxlot_str+"%) = "+dyn_Max_lot_size_str); //Modifica Dynamic Max Lot Size
            ObjectSetString(0,"04MonMan", OBJPROP_TEXT, "Money Management ("+MM_perc_profit+"%) = "+MM_score_str); //Modifica Money Management
            ObjectSetString(0,"05MaxOrd", OBJPROP_TEXT, "Max Orders("+dyn_max_orders+") = "+MaxOrders_score_str); //Modifica Max Orders
            ObjectSetString(0,"06Anti-Crowding", OBJPROP_TEXT, "Anti-Crowding ("+Crowdzone_str+") = "+AntiCrowding_score_str); //Modifica Anti-Crowding
            ObjectSetString(0,"07RSI-MA", OBJPROP_TEXT, "RSI = "+rsi_score_str+" | MA = "+ma_score_str); //Modifica RSI ed MA
            ObjectSetString(0,"08BB-Mean", OBJPROP_TEXT, "BB = "+BB_score_str+" | Mean = "+Mean_score_str); //Modifica BB e Mean
            ObjectSetString(0,"09Dyn Amp", OBJPROP_TEXT, "Dynamic Amp ("+AmpRatio_str+"%) = "+DynAmp_str); //Modifica DynamicAmp
            ObjectSetString(0,"10Main Amp", OBJPROP_TEXT, "MainAmp = "+MainAmp_str); //Modifica MainAmp
            

            //LIGHT-UP CONDITIONS
            //Se si verifica la condizione per l'apertura di una posizione, la statistica cambia colore:
            //Verde per Buy, Rosso per Sell, Blu per nessuna delle due
    
            
  
    
            //Condizione di illuminazione Pips Gap Label
            //Nota sul comportamento di Pips Gap: Sarà molto spesso di un colore per molto tempo perché dipende dalla posizione
            //rispetto all'ultimo ordine. Se l'ultimo ordine è un SELL più alto del prezzo attuale, ovviamente non ci potranno essere
            //le condizioni per un nuovo sell perché il pips gap si calcola in alto (per il Sell), quindi il gap è negativo e il colore
            //dell'indicatore sarà spesso verde o blu.
            if(AntiCrowding_score>=1)
              {
              ObjectSetInteger(0,"06Anti-Crowding", OBJPROP_COLOR, clrLimeGreen);
              }
            else if(AntiCrowding_score<=-1)
              {
              ObjectSetInteger(0,"06Anti-Crowding", OBJPROP_COLOR, clrRed);
              }
            else
              {
              ObjectSetInteger(0,"06Anti-Crowding", OBJPROP_COLOR, clrDodgerBlue);
              }
    
            //Condizine di illuminazine Max Orders
            if(MaxOrders_score>0.6)
              {
              ObjectSetInteger(0,"05MaxOrd", OBJPROP_COLOR, clrMediumSpringGreen);
              }
            else
              {
              ObjectSetInteger(0,"05MaxOrd", OBJPROP_COLOR, clrSienna);
              }
    
            //Condizione di illuminazione Money Management
            if(MM_score>0.6)
              {
              ObjectSetInteger(0,"04MonMan", OBJPROP_COLOR, clrMediumSpringGreen);
              }
            else
              {
              ObjectSetInteger(0,"04MonMan", OBJPROP_COLOR, clrSienna);
              }
            }
        }
      }

//FUNZIONE DI CONTROLLO DELLE CONDIZIONI DI APERTURA ORDINI
//Controlla se le condizioni di mercato soddisfano i criteri di apertura degli ordini, passando per referenza una variabile booleana per ogni
//criterio, a cui viene assegnato il valore corrispondente al return value della funzione di controllo, chiamata allo stesso modo in cui 
//veniva chiamata all'interno dell'IF in Main nelle versioni precedenti.
//Per poter chiamare ogni funzione c'è bisogno di ogni variabile indispensabile all'esecuzione di ogni funzione di controllo, motivo per cui 
//sono presenti tutti questi parametri.
void ConditionsCheck()
    {
    RSIsell = RSI_Check_SELL(); //Chiamata funzione di controllo RSI Sell
    RSIbuy = RSI_Check_BUY(); //Chiamata funzione di controllo RSI Buy

    BBsell = BB_Check_SELL(); //Chiamata funzione di controllo BB Sell
    BBbuy = BB_Check_BUY(); //Chiamata funzione di controllo BB Buy

    MAsell = MA_Check_SELL(); //Chiamata funzione di controllo MA Sell
    MAbuy = MA_Check_BUY(); ///Chiamata funzione di controllo MA Buy

    MaxOrd = MaxOrders(); //Chiamata funzione di controllo Max Orders
    MonMan = !MoneyManagement(); //Chiamata funzione di controllo Money Management

    if(LastOrderPrice != 0)
      {
      PipsSell = PipsGap_SELL(); //Chiamata funzione di controllo Pips Gap Sell
      PipsBuy = PipsGap_BUY(); //Chiamata funzione di controllo Pips Gap Buy
      }
    else
      {
      PipsSell = true;
      PipsBuy = true;
      }

    //Funzioni di controllo per la posizione rispetto alla linea mediana, che prima era controllata direttamente negli IF di BUY e SELL in Main
    if(Bid>DynamicMean+(offset*Use_Clearance)*Point)
      {
      MeanSell = true;
      }
    else
      {
      MeanSell = false;
      }

    if(Ask<DynamicMean-(offset*Use_Clearance)*Point)
      {
      MeanBuy = true;
      }
    else
      {
      MeanBuy = false;
      }
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
bool PipsGap_SELL()
    {
    if((LastOrderPrice+pips_gap_dyn*Point<Bid) || !(Use_Pips_Gap))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//PIPS GAP CHECK BUY
bool PipsGap_BUY()
    {
    if((LastOrderPrice-pips_gap_dyn*Point>Ask) || !(Use_Pips_Gap))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//MAX ORDERS CHECK
bool MaxOrders()
    {
    if((O_orders < DynMax_Orders) || (!Use_Max_Orders)) 
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//MOVING AVERAGE CHECK SELL
bool MA_Check_SELL()
    {
    if((ma<Bid) || (!Use_Moving_Average))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//MOVING AVERAGE CHECK BUY
bool MA_Check_BUY()
    {
    if((ma>Ask) || (!Use_Moving_Average))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//RSI CHECK SELL
bool RSI_Check_SELL()
    {
    if((rsi>=70) || (!Use_RSI_Check))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//RSI CHECK BUY
bool RSI_Check_BUY()
    {
    if((rsi<=30) || (!Use_RSI_Check))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//BOLLINGER BANDS CHECK SELL
bool BB_Check_SELL()
    {
    if((BandHi<Bid) || (!Use_BB))
      {
      return true;
      }
    else
      {
      return false;
      }
    }

//BOLLINGER BANDS CHECK BUY
bool BB_Check_BUY()
    {
    if((BandLo>Bid) || (!Use_BB))
      {
      return true;
      }
    else
      {
      return false;
      }
    }


//ADVANCED EVALUATION ALGORITHM FUNCTIONS
//Le funzioni seguenti sono necessarie per il funzionamento dell'algoritmo avanzato di valutazione degli indicatori
//In caso negli input fosse specificato che non si intende utilizzare l'algoritmo avanzato, le funzioni di valutazione 
//precedenti sono comunque necessarie al funzionamento canonico dell'EA.

double Evaluation()
  {
  double temp_score = 0;
  
  RSI_score = RSI_eval();
  BB_score = BB_eval();
  AntiCrowding_score = AntiCrowding_eval();
  MaxOrders_score = MaxOrders_eval();
  MM_score = MM_eval();
  Mean_score = Mean_eval();
  MA_score = MA_eval();

  Print("RSI_score = ", RSI_score, " | BB_score = ", BB_score, " | AntiCrowding_score = ", AntiCrowding_score, " | MaxOrd_score = ", MaxOrders_score);
  Print("MM_score = ", MM_score, " | Mean_score = ", Mean_score, " | MA_score = ", MA_score);

  bool signcheck = SignChecker();

  if((AntiCrowding_score==0) || (Mean_score==0) || (MaxOrders_score==0) || (LastOrderBar==0) || (MM_score==0))
    {
    return 0;
    }
  else if(!signcheck)
    {
    Print("Evaluation: Some indicators have different score signs");
    return 0;
    }
  else
    {
    if(Mean_score>0)
      {
      temp_score = (((RSI_score*RSI_weight)+
           (BB_score*BB_weight)+
           (AntiCrowding_score*Pips_gap_weight)+
           (MA_score*ma_weight)+
           (MaxOrders_score*Max_Orders_weight)+
           (MM_score*MM_weight)+
           (Mean_score*Mean_weight))/100);
      return(temp_score);
      }
    else 
      {
      temp_score = -(((MathAbs(RSI_score)*RSI_weight)+
           (MathAbs(BB_score)*BB_weight)+
           (MathAbs(AntiCrowding_score)*Pips_gap_weight)+
           (MathAbs(MA_score)*ma_weight)+
           (MathAbs(MaxOrders_score)*Max_Orders_weight)+
           (MathAbs(MM_score)*MM_weight)+
           (MathAbs(Mean_score)*Mean_weight))/100);
      return(temp_score);
      }
    }
  }

void PowerMethod()
  {
  rsi_power = MethodApplicator(RSI_eval_method, rsi_power_input);
  ma_power = MethodApplicator(MA_eval_method, ma_power_input);
  pips_gap_power = MethodApplicator(Pips_Gap_eval_method, pips_gap_power_input);
  max_orders_power = MethodApplicator(Max_Orders_eval_method, max_orders_power_input);
  MM_power = MethodApplicator(MM_eval_method, MM_power_input);
  Mean_power = MethodApplicator(Mean_eval_method, Mean_power_input);
  LogVarValues(rsi_power, max_orders_power, pips_gap_power, ma_power, MM_power, Mean_power);
  }
//EVALUATION OF RSI INDICATOR (by x^rsi_power function)
double RSI_eval()
  {
  if(rsi >= 70)
    {
    double eval = MathPow(((rsi-70)/30), rsi_power);
    return(eval);
    }
  else if(rsi <= 30)
    {
    double eval = MathPow(((30-rsi)/30), rsi_power);
    return(-eval);
    }
  else
    {
    return 0;
    } 

  }

//EVALUATION OF BOLLINGER INDICATOR
//La variabile BB_factor è arbitraria e determina variazione nel comportamento della
//funzione matematica, così come espresso nell'equazione 7 del foglio Desmos delle funzoini.
//BB_factor deve essere maggiore di 0 ed è più sensibile tanto più si va verso lo 0.
double BB_eval()
  {
  if(BB_factor<=0)
    {
    string BB_factor_str = IntegerToString(BB_factor);
    Print("ERROR: BB_factor can't be = " + BB_factor_str);
    return 0;
    }
  else
    {
    if(Bid<BandLo) //PREZZO BASSO - POSIZIONE BUY - EVAL NEGATIVO
      {
      double diff = MathRound((BandLo - Bid)/Point);
      double eval = (-1)/((diff/BB_factor)+1)+1;
      return(-eval);
      }
    else if(Bid>BandHi) //PREZZO ALTO - POSIZIONE SELL - EVAL POSITIVO
      {
      double diff = (Bid - BandHi)/Point;
      double eval = (-1)/((diff/BB_factor)+1)+1;
      return(eval);
      }
    else
      {
      return 0;
      }
    }
  }

//ANTI-CROWDING EVALUATION FUNCTION
double AntiCrowding_eval()
  {
  int n_order = OrdersTotal();
  double eval = 0;
  int crowdzone = pips_gap_dyn;

  double diff_arr_ov[]; //Array di diff nella metà alta dell'oscillazione
  double diff_arr_un[]; //Array di diff nella metà bassa dell'oscillazione

  if(n_order>0)
    {
    ArrayResize(diff_arr_ov, n_order);
    ArrayResize(diff_arr_un, n_order);
    }

  if((crowdzone<minpipsgap) && (crowdzone>=0)) //Se crowdzone è positiva ma minore di minpipsgap
    {
    crowdzone = minpipsgap; //Assegna a crowdzone il valore minimo
    }
  else if(crowdzone>maxpipsgap) //Se crowdzone è maggiore di maxpipsgap
    {
    crowdzone = maxpipsgap;//Assegna a crowdzone il valore massimo
    }
  else if(crowdzone<0) //Gestione eccezione in cui crowdzone è negativa
    {
    crowdzone = 0;
    Print("ANTI-CROWDING ERROR: crowdzone is negative.");
    }

  for(int for_order = n_order-1; for_order>=0; for_order--)
    {
    if(OrderSelect(for_order,SELECT_BY_POS,MODE_TRADES) != True) //Seleziona l'ordine numero n_order in ordine cronologico decrescente di apertura
          {
          GetLastError(); //Check per eventuali errori dell'OrderSelect
          }       
    if(Ask<DynamicMean) //Se il prezzo si trova nella metà bassa dell'oscillazione
      {
      double diff = NormalizeDouble(MathAbs((OrderOpenPrice()-Ask)/Point), 6);
      diff_arr_un[for_order] = diff;
      }
    else if(Bid>DynamicMean)//Se il prezzo si trova nella metà alta dell'oscillazione
      {
      double diff = NormalizeDouble(MathAbs((OrderOpenPrice()-Bid)/Point), 6);
      diff_arr_ov[for_order] = diff;
      }
    }

  if(Ask<DynamicMean)
    {
    if(n_order>0)
      {
      int closest_ind = ArrayMinimum(diff_arr_un, WHOLE_ARRAY, 0);
      double closest_diff = diff_arr_un[closest_ind];
      eval = (closest_diff/crowdzone)-1;
      if(eval<0)
        {
        return 0;
        }
      else if(eval>1)
        {
        return(-1);
        }
      else
        {
        return(-eval);
        }
      }
    else
      {
      return(-1);
      }
    }
  else if(Bid>DynamicMean)
    {
    if(n_order>0)
      {
      int closest_ind = ArrayMinimum(diff_arr_ov, WHOLE_ARRAY, 0);
      double closest_diff = diff_arr_ov[closest_ind];
      eval = (closest_diff/crowdzone)-1;
      if(eval<0)
        {
        return 0;
        }
      else if(eval>1)
        {
        return(1);
        }
      else
        {
        return(eval);
        }
      }
    else
      {
      return(1);
      }
    }
  else
    {
    return 0;
    }
  }


//EVALUATION OF OPEN ORDERS NUMBER
double MaxOrders_eval()
  {
  double eval = - (MathPow((O_orders+0.00)/DynMax_Orders, max_orders_power)-1);
  if(eval<0)
    {
    return 0;
    }
  else
    {
    return(eval);
    }
  }


//EVALUATION OF MONEY MANAGEMENT AND DRAWBACK
double MM_eval()
  {
  if((Equity/Balance)>=1)
    {
    return 1;
    }
  else
    {
    double eval = -(MathPow(MathAbs(AccountProfit())/((100-MM_Value)*Balance*0.01), MM_power)-1);
    return(eval);
    }
  }


//EVALUATION OF MEAN LINE AND PRICE POSITION
//Funzione di valutazione della posizione del prezzo rispetto alla linea mediana calcolata dal Sup&Res, che sia dinamico o statico.
//Non è necessaria disambiguazione in caso di uguaglianza con Mean perché il prezzo di Bid e di Ask differiscono sempre di almeno
//1 pip o 10 points (o, in casi estremi, di 1 point), rendendo impossibile che Ask=Bid=Mean.
double Mean_eval()
  {

  if(Bid>= DynamicMean+offset)
    {
    double diff = MathRound((Bid - DynamicMean)/Point);
    double eval = MathPow(2*diff/DynamicAmp, Mean_power);
    return(eval);
    }
  else if(Ask<= DynamicMean-offset)
    {
    double diff = MathRound((DynamicMean - Bid)/Point);
    double eval = MathPow(2*diff/DynamicAmp, Mean_power);
    return(-eval);
    }
  else
    {
    return 0;
    }
  }


//EVALUATION OF MOVING AVERAGE
double MA_eval()
  {
  int ma_margin = (int)MathRound(DynamicAmp*ma_margin_perc*0.01);

  if(Bid > ma)
    {
    double diff = MathRound((Bid - ma)/Point);
    double eval = MathPow(diff/ma_margin, ma_power);
    if(eval>1)
      {
      return 1;
      }
    else
      {
      return(eval);
      }
    }
  else if(Ask < ma)
    {
    string Sym = ChartSymbol(0);
    double Spread = MarketInfo(Sym, MODE_SPREAD);

    int carota = (int)MathRound(ma_margin-Spread);
    if(carota==0)
      {
      carota = 1;
      }
    double diff = MathRound((ma - Ask)/Point);
    double eval = MathPow(diff/(carota), ma_power);
    if(eval>1)
      {
      return(-1);
      }
    else
      {
      return(-eval);
      }
    }
  else
    {
    return 0;
    }
  }


//CONVERTITORE POTENZA PER ELABORAZIONE INDICATORE
//Converte la potenza dell'input XXX_power_input in quella necessaria per ottenere
//un'elaborazione Esponenziale, Lineare o Logaritmica.
double MethodApplicator(EVAL_METHODS method, double power_input)
  {
  switch(method)
    {
    case 0: //Exponential
      return(power_input);
      break;
    case 1: //Linear
      return(1);
      break;
    case 2: //Logarithmic
      {
      double log_power = NormalizeDouble(1/power_input, 4);
      return(log_power);
      break;
      }
    }
  Alert("METHOD APPLICATOR ERROR: NO CASE HAS BEEN SELECTED");
  return(0);
  }

//FUNZIONE DI CONTROLLO DI CONCORDANZA DEI SEGNI
//La funzione controlla che tutte le funzioni di valutazione che ammettono valore positivo e negativo abbiano lo stesso segno,
//in modo da assicurare che un indicatore di segno negativo non possa contribuire all'apertura di una posizione Sell quando tutti
//gli altri indicatori sono positivi. E' quasi impossibile che accada un forte contrasto o una situazione di 4vs1 tra gli indicatori, 
//ma è buona pratica per il protocollo di gestione delle eccezioni.
//La funzione ritorna true se gli indicatori 'signed' sono tutti positivi o tutti negativi, false in tutti gli altri casi.
bool SignChecker()
  {
  if((RSI_score>0) && (BB_score>0) && (MA_score>0) && (Mean_score>0) && (AntiCrowding_score>0))
    {
    return true;
    }
  else if((RSI_score<0) && (BB_score<0) && (MA_score<0) && (Mean_score<0) && (AntiCrowding_score<0))
    {
    return true;
    }
  else
    {
    return false;
    }
  }

void DynamicClearanceLines()
  {
  offset = NormalizeDouble((DynamicAmp/2)*((Clearance*0.01)*Point), 5);
  double pos_offset_price = DynamicMean+offset;
  double neg_offset_price = DynamicMean-offset;

  if(ObjectFind("Mean Offset +")<0)
    {
    ObjectCreate("Mean Offset +", OBJ_HLINE, 0, Time[0], pos_offset_price);
    ObjectSet("Mean Offset +", OBJPROP_COLOR, clrDodgerBlue);
    ObjectSet("Mean Offset +", OBJPROP_STYLE, STYLE_DASHDOT);
    }
  else
    {
    ObjectSet("Mean Offset +", OBJ_HLINE, pos_offset_price);
    }

  if(ObjectFind("Mean Offset -")<0)
    {
    ObjectCreate("Mean Offset -", OBJ_HLINE, 0, Time[0], neg_offset_price);
    ObjectSet("Mean Offset -", OBJPROP_COLOR, clrDodgerBlue);
    ObjectSet("Mean Offset -", OBJPROP_STYLE, STYLE_DASHDOT);
    }
  else
    {
    ObjectSet("Mean Offset -", OBJ_HLINE, neg_offset_price);
    }
  }
void ParamRefresh()
  {
  O_orders = OrdersTotal(); //Calcolo numero ordini aperti
  Profit = AccountProfit(); //Calcolo Profit Attuale
  Equity = AccountEquity(); //Calcolo Equity
  Balance = AccountBalance(); //Calcolo Balance
  BandHi = iBands(NULL,0,BB_period,2,0,0,1,0); //Calcolo BB superiore
  BandLo = iBands(NULL,0,BB_period,2,0,0,2,0); //Calcolo BB inferiore
  ma = iMA(NULL,0,ma_period,0,0,0,0); //Calcolo MA
  rsi = iRSI(NULL,0,RSI_period,PRICE_MEDIAN,0); //Calcolo RSI
  }


  /*--------------------------------------------------------------------------------------------------*/
  //DA SPOSTARE IN FILE APPOSITO

//FUNZIONE DI CREAZIONE LABELS PER DATI
bool LabelCreate(const string name, const int x, const int y, const string text, const ENUM_BASE_CORNER corner)
  {
  
  //Definizione costanti che NON VARIANO tra le varie labels
  const long              chart_ID = 0;          //Chart ID
  const int               sub_window = 0;        //Indice Sottofinestra
  const string            font = "Arial";        //Font
  const double            angle = 0.0;           //Inclinazione della label
  const ENUM_ANCHOR_POINT anchor=ANCHOR_CENTER;  //Angolo da usare come centro di rotazione
  const bool              back=false;            //Sullo sfondo rispetto al resto = false
  const bool              selection=false;       //Spostabile con mouse = false
  const bool              hidden=true;           //Nascosto nella lista oggetti = true
  const long              z_order=0;             //Priorità rispetto ai click col mouse
  
  color clr; //Colore
  int font_size = 1; //Font size
  color bgcolor = ChartBackColorGet(); //Trova colore di sfondo del grafico
  if(bgcolor == clrBlack) clr=clrWhite; else clr=clrBlack; //Rara istanza di single-line if statement :)
  
  ResetLastError(); //Resetta il valore di ultimo errore

  if(ObjectFind(chart_ID, name) != 0) //Check sull'esistenza di un oggetto con lo stesso nome
    {
    if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)) //Creazione oggetto (funzione booleana) con if statement per catch error
      {
      Print(__FUNCTION__, ": failed to create text label! Error code = ", GetLastError()); //Catch per eventualli errori
      return(false);
      }
    }

  //SET OBJECT PROPERTIES
  ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);          //Coordinata X
  ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);          //Coordinata Y
  ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);        //Angolo del grafico
  ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);             //Testo
  ObjectSetString(chart_ID,name,OBJPROP_FONT,font);             //Font
  ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);   //Font Size
  ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);           //Angolo d'inclinazione
  ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);        //Centro di rotazione
  ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);         //Colore
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
  return((color)result);
  }

//FUNZIONE DI CREAZIONE PANNELLO
bool RectLabelCreate()
  {
  const long             chart_ID=0;                      //Chart ID
  const string           name="Panel";                    //label Name
  const int              sub_window=0;                    //Subwindow Index
  const color            back_clr=clrBeige;               //Background Color
  const ENUM_BORDER_TYPE border=BORDER_FLAT;              //Border Type
  const ENUM_BASE_CORNER corner=CORNER_RIGHT_LOWER;       //Corner Anchor
  const color            clr=clrBlack;                    //Flat Border Color
  const ENUM_LINE_STYLE  style=STYLE_SOLID;               //Flat Border Style
  const int              line_width=2;                    //Flat Border Width
  const bool             back=false;                      //Sullo sfondo rispetto al resto = false
  const bool             selection=true;                  //Spostabile con mouse = false
  const bool             hidden=false;                    //Nascosto nella lista oggetti = true
  const long             z_order=0;                       //Priorità rispetto ai click col mouse
  const string           tooltip="STATISTICHE AVANZATE";  //Tooltip per Mouse Hover

  x_pos = width; //Coordinata X (Le coordinate sono impostate uguali alle dimensioni perché essendo posizionato nell'angolo in basso
  y_pos = height; //Coordinata Y  a destra del chart verrebbe disegnato fuori dal chart, necessitando una rettifica di posizione di partenza)

  ResetLastError();

  if(ObjectFind(chart_ID,name)!=0) //Check sull'esistenza di un oggetto con lo stesso nome
    { 
    if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0)) //Creazione oggetto (funzione booleana) con if statement per catch error
      {
      Print(__FUNCTION__,": failed to create a rectangle label! Error code = ",GetLastError());
      return(false);
      }
    //SET OBJECT PROPERTIES
    ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x_pos);
    ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y_pos);
    ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
    ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
    ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
    ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
    ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
    ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
    ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
    ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
    ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
    ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
    ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
    ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
    ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
    ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
    }
  return(true);
  }

void ObjectReposition(bool Move = 0)
  {
  for(int i = 0; i<stat_rows; i++) //Ciclo for di modifica delle posizioni degli oggetti rispetto al pannello 
    {
    //Print("height = ", height);
    int font_size = width/((2*stat_rows)+2); //Calcolo font size
    int index = indexarr[i]; //Calcolo indice in indexarr usando l'indice attuale del ciclo for
    string name = ObjectName(index); //Calcolo nome dell'oggeto dall'indice
    int flip = (2*i)+1; //Moltiplicatore per far occupare un "rigo" si ed uno no in modo da lasciare spazio tra le etichette
    //Print("flip = ", flip);
    int y_pos2 = (y_pos-(flip*(width/(2*stat_rows)))); //Calcolo posizione Y dell'oggetto in base alla cardinalità dello stesso nella lista
    //Print("y_pos = ", y_pos);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size); //Cambio FONTSIZE dell'oggetto
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y_pos2); //Cambio posizione Y dell'oggetto
    if(Move)
      {
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, (x_pos+(x_pos-width))/2); //Se Move è true modifica anche la posizione X
      }
    //Print("Modifica a ", name, " a buon fine con font size ", font_size);
    }
  }

//FUNZIONE DI CREAZIONE LABELS DI STATISTICHE AVANZATE
void CreateObjects()
  {
  //CREAZIONE OGGETTI LABEL CON POSIZIONE CENTRALIZZATA SU ASSE X
  LabelCreate("01Conditions", x_pos/2, 0, "CONDITIONS", CORNER_RIGHT_LOWER);
  LabelCreate("02Global Score", x_pos/2, 0, "Global Score = 0.00", CORNER_RIGHT_LOWER);
  LabelCreate("03Dynamic Max Lot", x_pos/2, 0, "Dynamic Max Lot (0) = " ,CORNER_RIGHT_LOWER);
  LabelCreate("04MonMan", x_pos/2, 0, "Money Management (%) = ", CORNER_RIGHT_LOWER);
  LabelCreate("05MaxOrd", x_pos/2, 0,"Max Orders (0) = ", CORNER_RIGHT_LOWER);
  LabelCreate("06Anti-Crowding", x_pos/2, 0,"Anti-Crowding (0) = ", CORNER_RIGHT_LOWER);
  LabelCreate("07RSI-MA", x_pos/2, 0,"RSI = 0.00000 | MA = 0.00000", CORNER_RIGHT_LOWER);
  LabelCreate("08BB-Mean", x_pos/2, 0,"BB = 0.00000 | Mean = 0.00000", CORNER_RIGHT_LOWER);
  LabelCreate("09Dyn Amp", x_pos/2, 0,"DynAmp (%) = 0000", CORNER_RIGHT_LOWER);
  LabelCreate("10Main Amp", x_pos/2, 0,"MainAmp = 0000", CORNER_RIGHT_LOWER);

  int obj_total = ObjectsTotal(); //Conteggio oggetti totali presenti
  ArrayResize(indexarr, 1, obj_total); //Resize iniziale dell'array di indici con riserva di memoria massima
  for(int i = 0; i<obj_total; i++) //Conteggio e scrittura del nome oggetto delle righe di statistiche avanzate
    {
    string name = ObjectName(i); //Ricerca del nome dell'oggetto con indice i = cardinalità del ciclo attuale
    //Print("name = ", name);
    long id = ObjectGetInteger(0, name, OBJPROP_CORNER); //Ricerca proprietà OBJPROP_CORNER dell'oggetto selezionato
    //Print("id = ", id);
    int type = ObjectType(name); //Ricerca tipo dell'oggetto selezionato
    //Print("type = ", type);
    if((id == CORNER_RIGHT_LOWER) && (type == OBJ_LABEL)) //Selezione oggetti giusti: oggetti di tipo LABEL con angolo di ancoraggio RIGHT LOWER
      {
      stat_rows++; //Incremento conteggio righe di statistiche
      ArrayResize(indexarr, stat_rows, obj_total); //Resize array di indici
      ArrayFill(indexarr, stat_rows-1, 1, i); //Scrittura Push nell'array di indici dell'indice corrispondente di OrdersTotal
      //Print("dobby = ", indexarr[stat_rows-1]);
      }
    }

  ObjectReposition();
  Print("stat rows = ", stat_rows);
  }

//FUNZIONE DI RICERCA DIMENSIONI CHART E CALCOLO DIMENSIONI PANNELLO 
void GetWindowSize()
  {
  long x_chartsize;
  long y_chartsize;
  if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_chartsize)) //Calcola dimensione X del chart
    {
    Print("Failed to get the chart width! Error code = ",GetLastError()); //Eccezione d'errore
    return;
    }
  if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_chartsize)) //Calcola dimensione Y del chart
    {
    Print("Failed to get the chart width! Error code = ",GetLastError()); //Eccezione d'errore
    return;
    }
  Print("X= ", x_chartsize, " pixels | Y= ", y_chartsize, " pixels");
  width = (int)((x_chartsize+y_chartsize)/90)*10; //Calcola dimensioni pannello come un quadrato 
  height = width;                                  //di lato 1/10 della somma delle dimensioni X e Y del chart
  //Print("width = ", width, " | height = ", height);
  }

//FUNZIONE DI CONTROLLO EVENTI
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
  if(id == CHARTEVENT_MOUSE_MOVE)
    {
      if(sparam == "1") //Check che il sia tenuto premuto il tasto sinistro del mouse per lo spostamento
        {
        if(ObjectGetInteger(0,"Panel", OBJPROP_SELECTED))
          {
          x_pos = (int)ObjectGetInteger(0, "Panel", OBJPROP_XDISTANCE);
          y_pos = (int)ObjectGetInteger(0, "Panel", OBJPROP_YDISTANCE);
          ObjectReposition(true);
          }
        }
    }
  }

//FUNZIONE DI ATTIVAZIONE EVENT LISTENER PER MOVIMENTO DEL MOUSE
bool ChartEventMouseMoveSet(const bool value)
  {
  ResetLastError();
  if(!ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0,value))
    {
    Print(__FUNCTION__,", Error Code = ",_LastError);
    return(false);
    }
  return(true);
  }
