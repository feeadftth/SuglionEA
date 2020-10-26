//+------------------------------------------------------------------+
//|                ┏━━━┓╋╋╋╋╋┏┓╋╋╋╋╋╋╋┏━━━┳━━━┓             Main v2.0|
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

//CUSTOM INDICATOR PROPERTIES

//DICHIARAZIONE LIBRERIE E HEADERS
#include "Functions v2.0.mqh" //Carica in fase di preprocessore la libreria di funzioni custom

int OnInit()
  {
  if(Use_Advanced_Evaluation)
    {
    if((RSI_weight+BB_weight+ma_weight+Mean_weight+MM_weight+Max_Orders_weight+Pips_gap_weight)!=100)
      {
      Alert("INITIALIZATION ERROR: THE SUM OF SCORE WEIGHTS ISN'T 100");
      ExpertRemove();
      }
    }

  //RICERCA DI SUPPORTO E RESISTENZA
  MainSupAndRes();

  if(Use_Advanced_Evaluation)
    {
    PowerMethod();
    }

  if(Use_Dynamic_TS)
    {
    dyn_ts_power = MethodApplicator(TS_eval_method, dyn_ts_power_input);
    }
   
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
  if(Use_Advanced_Evaluation)
    {
    if(Use_Advanced_Stats)
      {
      if(!IsTesting()) //Controlla che l'EA non stia girando nel Tester
      {
      ChartEventMouseMoveSet(true); //Attiva l'event listener del movimento del mouse
      }
      GetWindowSize(); //Calcola le dimensioni del Chart
      RectLabelCreate(); //Crea il pannello delle Statistiche Avanzate
      CreateObjects(); //Crea gli oggetti del pannello delle statistiche avanzate
      }
    }
  else
    {
    if(Use_Conditions_Stats) 
      {  
      string MM_string = IntegerToString(100-MM_Value);
      string MM_label = "Money Management (" + MM_string + "%) = ";
    
      LabelCreate("Conditions",140,97,"CONDITIONS", CORNER_RIGHT_LOWER);
      LabelCreate("MonMan",195,78, MM_label, CORNER_RIGHT_LOWER);
      LabelCreate("MonMan Value",37,78,"", CORNER_RIGHT_LOWER);
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
    }

   return(INIT_SUCCEEDED);
  }

//FUNZIONE DI DEINIZIALIZZAZIONE: QUANDO IL BOT VIENE ARRESTATO VIENE ESEGUITA
void OnDeinit(const int reason)
  {
  if(DeleteObjOnDeinit)
    {
    ObjectsDeleteAll();
    }
  }


//ESECUZIONE AD OGNI TICK
void OnTick()
  { 
  RefreshRates(); //Aggiorna i valori per le funzioni standard, per variabili dichiarate globalmente
    
  Select(); //Selziona l'ultimo ordine
  LastOrderPrice = OrderOpenPrice();

  //CALCOLO DINAMICO DI SOSTEGNO E RESISTENZA
  if(Use_Dyn_Sup_Res)
    {
    DynamicSupAndRes();      
    }
  if(Use_Dyn_Max_Orders)
    {
    DynMax_Orders = (int)MathRound(MainMax_Orders*(DynamicAmp/MainAmp));
    }
  if(Use_Dynamic_TS)
    {
    DynamicTrailing();
    }

  //CALCOLO DINAMICO DEL PIPS GAP
  DynamicPipsGap();

  //AGGIORNAMENTO PARAMETRI
  ParamRefresh(); 
  
  if(Profit<MaxDrawback)
    {
    MaxDrawback = Profit;
    }
   
  if(LastOrderTime !=0) //Se LastOrderTime è 0, allora non c'è alcun ordine aperto
    {
    LastOrderBar = iBarShift(NULL,0,LastOrderTime); //Imposta valore di distanza tra la barra attuale e la barra dell'ultimo ordine
    }
   
  if(Use_Clearance)
    {
    DynamicClearanceLines(); //Aggiornamento linee di Clearance
    }

  //ADVANCED EVALUATION FUNCTION
  //La funzione di tipo double ritorna un valore da -1 ad 1, rispettivamente per una forte valutazione di ordine Sell e Buy
  if(Use_Advanced_Evaluation)
    {
    score = Evaluation();
    Print("Score = ", score);

    if(Use_Dynamic_Max_lot)
      {
      dyn_Max_lot_size = DynamicMaxLotSize();
      }
    }
  else
    {
    //FUNZIONE DI CONTROLLO DELLE CONDIZIONI DI APERTURA ORDINI
    ConditionsCheck();
    }

  //ESECUZIONE FUNZIONE PER LE STATISTICHE SUL GRAFICO
  Stats();
      


  if(!Use_Advanced_Evaluation)
    {
    //STANDARD SELL
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
      LastOrderPrice = OrderOpenPrice(); //Prezzo dell'ultimo ordine selezionato
      }
        
    //STANDARD BUY 
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
      LastOrderPrice = OrderOpenPrice(); //Prezzo dell'ultimo ordine selezionato
      };
    }
  else
    {
    double adj_agg = 1-(Agg/100); //Converte la percentuale di Aggressività in complemento decimale

    if(MathAbs(score)>MathAbs(adj_agg)) //Controlla che adj_score non possa cambiare segno dovuto ad un'aggressività bassa con score basso
      {
      double adj_score = MathAbs(score)-MathAbs(adj_agg); //Calcola valore dell'adj_score sottraendo l'adj_agg, ottenendo un valore da 0 ad 1
      Print("Adjusted Score = ", adj_score);
      dyn_lot_size = dyn_Max_lot_size*(adj_score/(1-MathAbs(adj_agg))); //Definisce il valore del lot_size in base ad adj_score
       
      if(score>0) //Controlla che lo score fosse originariamente positivo per aprire Buy
        {
        SendSell(dyn_lot_size); //Apre posizione Sell      
        Select();  //Seleziona l'ordine appena aperto per il check al prossimo tick
        LastOrderTime = OrderOpenTime();  //Imposta LastOrderTime sul tempo dell'ordine appena aperto
        LastOrderPrice = OrderOpenPrice(); //Prezzo dell'ultimo ordine selezionato
        }
      else if(score<0) //Controlla che lo score fosse originariamente negativo per aprire Sell
        {
        SendBuy(dyn_lot_size); //Apre posizione Buy
        Select(); //Seleziona l'ordine appena aperto per il check al prossimo tick
        LastOrderTime = OrderOpenTime(); //Imposta LastOrderTime sul tempo dell'ordine appena aperto
        LastOrderPrice = OrderOpenPrice(); //Prezzo dell'ultimo ordine selezionato
        }
      }
    else  
      {
      Print("ADVANCED EVALUATION MAIN: Score is too low to open orders");
      }
    }
      
  //TRAILING STOP LOSS
  if((Use_Trailing_Stop == True) && (OrdersTotal() != 0)) //Controlla se il Trailing Stop è abilitato e se ci sono ordini aperti
    {
    TrailingStop(); //Funzione di Trailing Stop
    }
  }
