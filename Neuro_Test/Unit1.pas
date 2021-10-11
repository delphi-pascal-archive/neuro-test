unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Grids, Spin;   // стандартный набор модулей

type
  TForm1 = class(TForm)
    CreateNeuro: TButton;
    InVector: TStringGrid;
    OutVector: TStringGrid;
    SloiCol: TStringGrid;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    SaveNSris: TButton;
    Raschet: TButton;
    Panel1: TPanel;
    Image1: TImage;
    Obuch: TButton;
    SaveVes: TButton;
    LoadVes: TButton;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Edit4: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    procedure CreateNeuroClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SaveNSrisClick(Sender: TObject);
    procedure RaschetClick(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ObuchClick(Sender: TObject);
    procedure SaveVesClick(Sender: TObject);
    procedure LoadVesClick(Sender: TObject);
  private
  public
  end;

Type
 TNeuron = Record          // Нейрон.
  X: Array of Real;        // Входы нейрона.
  W: Array of Real;        // Массив весовых коэффициентов нейрона.
  dw: Array of Real;       // Массив изменений весов нейрона.
  sigma: Real;             // Ошибка нейрона.
  OutN: Real;              // Выход нейрона.
 end;

 TSloy = Record            // Слой.
  Neuron: Array of TNeuron;// Массив нейронов слоя.
 end;

 TSety = Record            // Cеть.
  Sloy: Array of TSloy;    // Массив слоев.
 end;

 TViborka = Record         // Структура обучающей выборки
  VhodV: Array of Real;    // Входной вектор
  VihodV: Array of Real;   // Выходной вектор
 end;

Var
  Form1: TForm1;
  Sety: TSety;                 // Нейронная сеть, массив слоёв нейронов.
  ParSety: Array of Integer;   // Структура сети.
  InV: Array of Real;          // Вх. вектор сети.
  OutV: Array of Real;         // Вых. вектор сети.
  SDraw: Array of Array of TPoint; // Для рисования сети (координаты)
  Viborka: Array of TViborka;  // Массив с обучающей выборкой.
  ko: Real;                    // коэфициент крутизны сигмоида (обычно от 0.1 до 1.5)
  e: Real;                     // скорость обучения. (обычно от 0.01 до 0.9)
  Xo: Integer;        // Дополнительный вход с +1 у каждого нейрона (если 0 то нет доп. входа).
  im: Real;           // Коэффициент импульса (обычно от 0.1 до 0.95)

implementation

{$R *.dfm}

Procedure CreateSety(Const Par: Array of Integer);  // Создает сеть.
Var
 i, j, k: Integer;            // i - слой.  j - нейрон. k - веса нейрона.
begin
 Randomize;   // ГСЧ.
 SetLength(Sety.Sloy, High(Par)+1);  // Устанавливаем колличество слоев.
 For i:= 0 To High(Par) Do           // Перебераем слои.
  begin
   SetLength(Sety.Sloy[i].Neuron, Par[i]);  // Устанавливаем колличество нейрон в слое.
   For j:= 0 To High(Sety.Sloy[i].Neuron) Do   // Перебераем нейроны в слое
    begin  // Если слой входной то.
     if i = 0 Then SetLength(Sety.Sloy[i].Neuron[j].X, 1)  // у нейрона 1 вход.
     Else
      begin // колличество входов и весов последующих слоев = колличеству нейрон предыдущего слоя + 1 вес и вход.
       SetLength(Sety.Sloy[i].Neuron[j].X, (High(Sety.Sloy[i-1].Neuron)+1+1));   // +1 вход еденичный
       SetLength(Sety.Sloy[i].Neuron[j].W, (High(Sety.Sloy[i-1].Neuron)+1+1));   // +1 вес для еденичного входа.
       SetLength(Sety.Sloy[i].Neuron[j].dw, (High(Sety.Sloy[i-1].Neuron)+1+1));  // +1 изм. вес для еденичного входа.
       For k:= 0 To High(Sety.Sloy[i].Neuron[j].W) Do  // Перебераем веса нейрона.
        begin
         Sety.Sloy[i].Neuron[j].W[k]:= (Random(200)-100)/200; // веса нейронов заполняем СЧ.(-0,5..0,5).
         Sety.Sloy[i].Neuron[j].dw[k]:= Sety.Sloy[i].Neuron[j].W[k]; // изменение веса вначале = СЧ. весу.
        end;
       Sety.Sloy[i].Neuron[j].X[High(Sety.Sloy[i].Neuron[j].X)]:= Xo; // подаем еденицу на еденичный вход.
      end;
    end;
  end;
  SetLength(OutV, High(Sety.Sloy[High(Sety.Sloy)].Neuron) + 1); // установка размера вых. вектора сети.
end;

Function NeuronSigmoid(Const Xn, Wn: Array of Real): Real;  // Модель нейрона.
Var
 Sum: Real;    // взвешенная сумма.
 i: Integer;   // счетчик.
begin
 Sum:= 0;
 For i:= 0 To High(Xn) Do Sum:= Sum + Xn[i]*Wn[i];  // подсчет взвешенной суммы.
 if Abs(Sum) < 40 Then            // предел расчета.
  Result:= 1/(1 + Exp(-Sum*ko))    // Ф-ла сигмоида.
 Else
  begin
  if Sum >= 40 Then               // результат при выходе за предел.
   Result:= 1
  Else
   Result:= 0;
  end; 
end;

Procedure SetNeuroIn(Const InVektor: Array of Real);  // Подача входных данных на нейросеть.
Var
 j: Integer;  // j - нейрон.
begin
 For j:= 0 To High(Sety.Sloy[0].Neuron) Do // перебераем нейроны входного слоя.
  Sety.Sloy[0].Neuron[j].X[0]:= InVektor[j];  // Присваеваем входной вектор.
end;

Procedure GetNeuroOut(Var OutVektor: Array of Real);  // Вых. нейросети.
Var
 j, OutSloy: Integer;  // j - нейрон. OutSloy - индекс выходного слоя.
begin
 OutSloy:= High(Sety.Sloy);  // узнаем индекс выходного слоя.
 For j:= 0 To  High(Sety.Sloy[OutSloy].Neuron) Do // перебераем нейроны выходного слоя.
  OutVektor[j]:= Sety.Sloy[OutSloy].Neuron[j].OutN;  // Присваеваем выходной вектор.
end;

Procedure CalculateNeuro;   // Вычисление всей сети.
Var
 i, j, k: Integer;             // i - слой.  j - нейрон. k - веса нейрона.
begin
 For i:= 0 To High(Sety.Sloy) Do  // перебераем слои.
  begin
   For j:= 0 To High(Sety.Sloy[i].Neuron) Do  // перебераем нейроны в слое.
    if i = 0 Then                             // если слой входной то..
     Sety.Sloy[i].Neuron[j].OutN:= Sety.Sloy[i].Neuron[j].X[0]  // входной сигнал = выходу.
    Else                                      // если слой внутренний или последний..
     Sety.Sloy[i].Neuron[j].OutN:= NeuronSigmoid(Sety.Sloy[i].Neuron[j].X, Sety.Sloy[i].Neuron[j].W); // считаем нейрон.
   if i < High(Sety.Sloy) Then  // если не последний слой то
    begin
     For j:= 0 To High(Sety.Sloy[i+1].Neuron) Do  // перебераем нейроны следующего слоя
      For k:= 0 To High(Sety.Sloy[i].Neuron) Do   // перебераем входы нейрона следующего слоя.
       Sety.Sloy[i+1].Neuron[j].X[k]:= Sety.Sloy[i].Neuron[k].OutN; // присваеваем вых. просчитаных нейронов
    end;                                                            // входам нейронов следующего слоя.
  end;
end;

Function SiSloy(SloyIndex, VesIndex: Integer): Real; // расчет ошибки внутр. слоя.
Var
 j: Integer;   //  j - нейрон.
 Sum: Real;
begin
 Sum:= 0;      // обнулим сумму.
 For j:= 0 To  High(Sety.Sloy[SloyIndex].Neuron) Do // перебераем нейроны слоя.
  Sum:= Sum + Sety.Sloy[SloyIndex].Neuron[j].sigma*Sety.Sloy[SloyIndex].Neuron[j].W[VesIndex]; // считаем
 Result:= Sum;                                     // взвешенную сумму ошибок слоя.
end;

Procedure CalculateSigma(Const TselVektor: Array of Real); // расчет ошибoк нейронов.
Var
 si, nO: Real;      // si - текущяя ошибка нейрона. nO - вых. нейрона.
 i, j: Integer;     // i - слой.  j - нейрон.
begin
 For i:= High(Sety.Sloy) DownTo 1 Do  // перебераем слои с конца до 1 слоя (0 - слой входной sigma нет).
  For j:= 0 To High(Sety.Sloy[i].Neuron) Do   // перебераем нейроны в слое.
   begin
    nO:= Sety.Sloy[i].Neuron[j].OutN;        // узнали вых. значение нейрона.
    if i = High(Sety.Sloy) Then       // если слой последний то..
     si:= nO*(1 - nO)*(TselVektor[j] - nO) // подсчитали ошибку нейрона вых слоя.
    Else si:= nO*(1 - nO)*SiSloy(i+1, j);       // подсчитали ошибку нейрона скрытых слоев.
    Sety.Sloy[i].Neuron[j].sigma:= si;     // присвоили нейрону его ошибку.
   end;
end;

Procedure KorectWNeuro;  // корректирует веса нейронов.
Var
 dw: Real;                  //   изменение веса.
 i, j, k: Integer;          // i - слой.  j - нейрон. k - веса нейрона.
begin
 For i:= 1 To High(Sety.Sloy) Do  // перебераем слои с 1 слоя (0 - слой входной весов нет).
  For j:= 0 To High(Sety.Sloy[i].Neuron) Do   // перебераем нейроны в слое.
   For k:= 0 To High(Sety.Sloy[i].Neuron[j].W) Do // перебераем веса текущего нейрона.
    begin
     dw:= e*Sety.Sloy[i].Neuron[j].sigma + im*Sety.Sloy[i].Neuron[j].dw[k]; // расчет изменения веса
     Sety.Sloy[i].Neuron[j].dw[k]:= dw;   // обновление изменения веса.
     Sety.Sloy[i].Neuron[j].W[k]:= Sety.Sloy[i].Neuron[j].W[k] + dw;   // корректировка веса.
    end;
end;

Procedure RandomizeWesaNC;  // Генератор случайных весовых коэфициентов.
Var
 i, j, k: Integer;  // i - слой.  j - нейрон. k - веса нейрона.
begin
 Randomize;   // ГСЧ.
 For i:= 1 To High(Sety.Sloy) Do  // перебераем слои с 1 слоя (0 - слой входной весов нет).
  For j:= 0 To High(Sety.Sloy[i].Neuron) Do   // перебераем нейроны в слое.
   For k:= 0 To High(Sety.Sloy[i].Neuron[j].W) Do // перебераем веса текущего нейрона.
    begin
     Sety.Sloy[i].Neuron[j].W[k]:= (Random(200)-100)/200; // веса нейронов заполняем СЧ.(-0,5..0,5).
     Sety.Sloy[i].Neuron[j].dw[k]:= Sety.Sloy[i].Neuron[j].W[k]; // изменение веса вначале = СЧ. весу.
    end;
end;

Procedure DrawSety(w, h, r, c: Integer; Const Par: Array of Integer); // Рисует сеть.
Var
 Bmp: TBitmap;                  // холст
 i, j, k, dx, dy: Integer;      // i, j, k - счетчики, dx, dy - расстояния между нейронами
begin
 Bmp:= TBitmap.Create;          // создали
 Bmp.Width:= w;                 // уст. размер
 Bmp.Height:= h;
 SetLength(SDraw, SizeOf(Par));  // уст. размер слоев
 dy:= w div (High(Par) + 2) + 1; // узнали расстояние между слоями
 For i:= 0 To High(Par) Do       // перебераем слои
  begin
   SetLength(SDraw[i], Par[i]);  // уст. к-во нейронов в слое.
   dx:= h div (Par[i] + 1) + 1;  // узнаем расстояние между нейронами в слое
   For j:= 0 To Par[i] - 1 Do    // перебераем нейроны
    begin
     SDraw[i, j].X:= (i+1)*dy;   // присваиваим координаты каждому нейрону
     SDraw[i, j].Y:= (j+1)*dx;
    end;
  end;
 For i:= 0 To High(Par) Do       // перебераем слои
  For j:= 0 To Par[i] - 1 Do     // перебераем нейроны
   begin
    if i < High(Par) Then        // если слой не последний то...
     begin
      For k:= 0 To Par[i+1] - 1 Do  // перебераем нейроны следующего слоя
       begin
        if i = 0 Then               // если слой первый то...
         begin
          Bmp.Canvas.Brush.Color:= clWhite;    // заливка белая
          Bmp.Canvas.TextOut(8, SDraw[i, j].Y - 15, 'X'+IntToStr(j+1)); // пишим Х
          Bmp.Canvas.MoveTo(SDraw[i, j].X, SDraw[i, j].Y);  // рисуем входы
          Bmp.Canvas.LineTo(0, SDraw[i, j].Y);
         end;
        Bmp.Canvas.MoveTo(SDraw[i, j].X, SDraw[i, j].Y);  // рисуем связи.
        Bmp.Canvas.LineTo(SDraw[i+1, k].X, SDraw[i+1, k].Y);
       end;
      end
     Else             // слой последний
      begin
       Bmp.Canvas.Brush.Color:= clWhite;     // заливка белая
       Bmp.Canvas.TextOut(w - 25, SDraw[i, j].Y - 15, 'Y'+IntToStr(j+1));  // пишим У
       Bmp.Canvas.MoveTo(SDraw[i, j].X, SDraw[i, j].Y);    // рисуем выходы
       Bmp.Canvas.LineTo(w, SDraw[i, j].Y);
      end;
    if i = 0 Then Bmp.Canvas.Brush.Color:= clGreen   // если слой первый то заливка зеленая
     Else     // иначе
      begin
       if c = 1 Then // если есть дополнительный вход то...
        begin
         Bmp.Canvas.Brush.Color:= clWhite;  // заливка белая
         Bmp.Canvas.MoveTo(SDraw[i, j].X, SDraw[i, j].Y);   //  рисуем вход
         Bmp.Canvas.LineTo(SDraw[i, j].X, SDraw[i, j].Y-2*r);
         if j = 0 Then Bmp.Canvas.TextOut(SDraw[i, j].X-5, SDraw[i, j].Y-3*r-2, '+1'); // пишим +1
        end;
       Bmp.Canvas.Brush.Color:= clRed; // заливка красная
      end;
    Bmp.Canvas.Ellipse(SDraw[i, j].X-r, SDraw[i, j].Y-r, SDraw[i, j].X+r, SDraw[i, j].Y+r);  // рис нейроны
   end;
 Form1.Image1.Canvas.Draw(0, 0, Bmp);  // Переносим BMP на Image.
 Bmp.Free;    // освободили.
end;

procedure TForm1.FormCreate(Sender: TObject);
begin                           // начальные параметры
 SetLength(ParSety, 4);         // 4 слоя
 ParSety[0]:= 2;                // входной 2 - нейрона
 ParSety[1]:= 4;                // первый скрытый слой 4 - нейрона
 ParSety[2]:= 3;                // второй скрытый слой 3 - нейрона
 ParSety[3]:= 1;                // выходной 1 - нейрон
 SloiCol.Cells[0, 0]:= 'Слой1'; SloiCol.Cells[0, 1]:= '2';   // надписи для красоты)
 SloiCol.Cells[1, 0]:= 'Слой2'; SloiCol.Cells[1, 1]:= '4';
 SloiCol.Cells[2, 0]:= 'Слой3'; SloiCol.Cells[2, 1]:= '3';
 SloiCol.Cells[3, 0]:= 'Слой4'; SloiCol.Cells[3, 1]:= '1';
 InVector.Cells[0, 0]:= 'X1';   InVector.Cells[1, 0]:= '0';
 InVector.Cells[0, 1]:= 'X2';   InVector.Cells[1, 1]:= '0';
 OutVector.Cells[0, 0]:= 'Y1';  OutVector.Cells[1, 0]:= '0';
 Application.HintHidePause:= 15000;     // время показа подсказок.
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
Var
 i: Integer;
begin
 SloiCol.ColCount:= SpinEdit1.Value;  // уст. к-во слоев.
 SetLength(ParSety, SpinEdit1.Value); // уст. к-во слоев.
 For i:= 0 To SloiCol.ColCount - 1 Do
  begin
   SloiCol.Cells[i, 0]:= 'Слой: '+IntToStr(i+1); // надпись для красоты)
   if SloiCol.Cells[i, 1] = '' Then SloiCol.Cells[i, 1]:= '1'; // если ячейка пустая то присвоим 1.
  end;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
 i, j, k: Integer;   // счетчики
 St: String;         // строка с подсказкой
 OutN: Real;         // вых. нейрона
 Sig: Real;          // ошибка нейрона
begin
 For i:= 0 To High(SDraw) Do      // перебираем слои
  For j:= 0 To High(SDraw[i]) Do    // перебираем нейроны
   begin   // если мыши попадает в радиус (8) нейрона то...
    if (Abs(SDraw[i, j].X - X) < 8) and (Abs(SDraw[i, j].Y - Y) < 8) Then
     begin
      Image1.ShowHint:= True;  // вкл. подсказки
      OutN:= Sety.Sloy[i].Neuron[j].OutN; //узнали выход нейрона
      Sig:= Sety.Sloy[i].Neuron[j].sigma;  // узнали ошибку
      St:= '';                           // очистка
      if i > 0 Then        // если слой не входной то...
      For k:= 0 To High(Sety.Sloy[i].Neuron[j].X) Do  // перебираем веса нейрона
       if k < High(Sety.Sloy[i].Neuron[j].X) Then   // если вес не дополнительный (последний) то...
        St:= St + 'Вход'+IntToStr(k+1)+' = '+FormatFloat('0.000000', Sety.Sloy[i].Neuron[j].X[k])+';   '+
             'Вес'+IntToStr(k+1)+' = '+FormatFloat('0.000000', Sety.Sloy[i].Neuron[j].W[k])+#13  // формируем подсказку
       Else   // вес доп.
        St:= St + 'Доп. вход = '+FormatFloat('0.000000', Sety.Sloy[i].Neuron[j].X[k])+';   '+
             'Доп. вес = '+FormatFloat('0.000000', Sety.Sloy[i].Neuron[j].W[k])+#13;    // формируем подсказку
      if i = 0 Then      // если слой входной то..
       Image1.Hint:= St+'Выход повторителя = '+FormatFloat('0.000000', OutN) // присвоили подсказку Image
      Else               // иначе
       Image1.Hint:= St+'Выход нейрона = '+FormatFloat('0.000000', OutN)+#13+
        'Ошибка нейрона = '+FormatFloat('0.000000', Sig);   // присвоили подсказку Image
      Exit;
     end
    Else Image1.ShowHint:= False; // выкл. подсказки
   end;
end;

procedure TForm1.CreateNeuroClick(Sender: TObject);
Var
 i: Integer;
begin
 InVector.RowCount:= StrToInt(SloiCol.Cells[0, 1]);  // Уст. размер входного вектора
 For i:= 0 To InVector.RowCount - 1 Do      // перебираем вх вектор поелементно.
  begin
   InVector.Cells[0, i]:= 'X'+IntToStr(i+1);  // для красоты
   if InVector.Cells[1, i] = '' Then InVector.Cells[1, i]:= '0'; //если ячейка пуста то присвоим 0.
  end;
 OutVector.RowCount:= StrToInt(SloiCol.Cells[SpinEdit1.Value-1, 1]);// Уст. размер выходного вектора
 For i:= 0 To OutVector.RowCount - 1 Do      // перебираем вых вектор поелементно.
  begin
   OutVector.Cells[0, i]:= 'Y'+IntToStr(i+1);  // для красоты
   if OutVector.Cells[1, i] = '' Then OutVector.Cells[1, i]:= '0'; //если ячейка пуста то присвоим 0.
  end;
 if RadioGroup1.ItemIndex = 0 Then Xo:= 1 Else Xo:= 0;  // узнаем есть или нет доп вход
 For i:= 0 To SloiCol.ColCount - 1 Do ParSety[i]:= StrToInt(SloiCol.Cells[i, 1]); //формируем массив со структурой сети
 ko:= StrToFloat(Edit1.Text);  // присвоим крутизну сигмоида.
 im:= StrToFloat(Edit2.Text);  // присвоим коэфициент импульса.
 e:= StrToFloat(Edit3.Text);   // присвоим скорость обучения.
 DrawSety(Image1.Width, Image1.Height, 8, Xo, ParSety); // нарисуем сеть
 CreateSety(ParSety);                      // создадим сеть
 ShowMessage('Нейросеть создана!');
 Raschet.Enabled:= True;              // разрешим нажатие остальных кнопок.
 SaveNSris.Enabled:= True;
 SaveVes.Enabled:= True;
 LoadVes.Enabled:= True;
 Obuch.Enabled:= True;
end;

procedure TForm1.SaveNSrisClick(Sender: TObject);
begin
 Image1.Picture.SaveToFile('NeuroTest.bmp');   // сохр. рис. сети в файл
 ShowMessage('Рис. сохранен!');
end;

procedure TForm1.RaschetClick(Sender: TObject);
Var
 i: Integer;    // счетчик
begin
 SetLength(InV, InVector.RowCount); // уст. размер вх. вектора
 For i:= 0 To InVector.RowCount - 1 Do InV[i]:= StrToFloat(InVector.Cells[1, i]); //заполним вх. вектор
 SetNeuroIn(InV);   // подадим вх. вектор на вход сети
 CalculateNeuro;    // прсчитаем сеть
 GetNeuroOut(OutV); // получаем вых вектор сети
 For i:= 0 To OutVector.RowCount - 1 Do OutVector.Cells[1, i]:= FormatFloat('0.000000', OutV[i]);// выводим вых вектор сети
end;

Function LoadFromFile(Fn: String): Boolean;  // загрузка обучающей выборки из текстового файла
Var
 Sl: TStringList;   // набор строк класс
 St, Re: String;    // строка и выдиленое число
 i, j, k, k1, Xi, Xt, Yi: Integer;  // счетчики
begin
 Result:= True;
 if Not FileExists(Fn) Then   // если файла нет
  begin
   Result:= False;
   Exit;                      // выходим.
  end;
 Xi:= 0; Yi:= 0;
 Sl:= TStringList.Create;
 Sl.LoadFromFile(Fn);        // загружаем текст
 St:= Sl.Strings[0];         // узнаем первую строчку
 Try
 For i:= 0 To Length(St) - 1 Do  // перебор посимвольно первой строки
  begin
   if St[i] = 'X' Then Inc(Xi);  // символ = Х то увеличим счетчик Х-ов
   if St[i] = 'Y' Then Inc(Yi);  // символ = У то увеличим счетчик У-ов
  end;
 k:= 1;
 For i:= 1 To Sl.Count - 1 Do   // Перебираем строки
  if Sl.Strings[i] <> '' Then   // если строка не пустая то..
   begin
    SetLength(Viborka, k);      // Уст. размер выборки.
    Inc(k);                     // Увеличим размер выборки на 1.
   end;
 For i:= 0 To High(Viborka) Do  // перебераем елементы выборки
  begin
   SetLength(Viborka[i].VhodV, Xi);   // Уст. размер входов
   SetLength(Viborka[i].VihodV, Yi);  // Уст. размер выходов
  end;
 For i:= 1 To Sl.Count - 1 Do  // перебераем строки начиная со второй.
  begin
   Re:= '';                   // очистка
   k:= 0; k1:= 0;
   Xt:= Xi;                   // Xt - к-во иксов (входов)
   St:= Sl.Strings[i];        // Узнали строку
   if St <> '' Then           // Если строка не пуста то..
   begin
   For j:= 1 To Length(St) + 1 Do  // перебераем посимвольно
    begin  // если символ не пробел и не конец строки то..
     if (St[j] <> ' ') and (j <= Length(St)) Then Re:= Re + St[j] // добавим этот символ
     Else
      begin
       if Re <> '' Then // если выделенная строка не пуста то...
        if Xt > 0 Then  // если иксы не закончились то..
         begin
          Dec(Xt); // уменьшим иксы
          Viborka[i-1].VhodV[k]:= StrToFloat(Re); // поместим в выборку число Х
          Inc(k);  // увеличем счетчик елементов выборки х
         end
        Else  // иксы закончились
         begin
          Viborka[i-1].VihodV[k1]:= StrToFloat(Re); // поместим в выборку число У
          Inc(k1); // увеличем счетчик елементов выборки у
         end;
       Re:= ''; // очистка
      end;
    end;
   end;
  end;
 Except
  begin
   ShowMessage('Ошибка в файле с выборкой!');
   Result:= False;
  end;
 end;
 Sl.Free;   
end;

procedure TForm1.ObuchClick(Sender: TObject);
Var
 Et, T, En, Ev: Real;  // Ev - допустимая ошибка. En - текущая ошибка. T - сумма СКВ. Et - сумма СКВ по выборке
 i, j, Ep, Mp: Integer;   // счетчики
begin
 if Not LoadFromFile('Viborka.txt') Then  // загрузили выборку
  begin
   ShowMessage('Не загружен файл с обучающей выборкой!');
   Exit;
  end;
 Ev:= StrToFloat(Edit4.Text);  // узнали допустимую ошибку сети.
 Et:= 0;                       // обнулили.
 Ep:= 0;
 Mp:= 0;
 For i:= 0 To High(Viborka) Do  // перебор елементов выборки
  begin
   SetNeuroIn(Viborka[i].VhodV); // подали на вход сети елемент выборки
   CalculateNeuro;               // посчитали сеть
   GetNeuroOut(OutV);            // получили выходной вектор.
   T:= 0;                        // обнуляем сумму.
   For j:= 0 To High(OutV) Do T:= T + Sqr(Viborka[i].VihodV[j] - OutV[j]); // СКВ отклонение
   Et:= Et + 0.5*T;                                                        // по выборке
  end;
 En:= Et/(High(Viborka) + 1); // Ошибка Нач
 Label5.Caption:= 'СКВ Ошибка Нач.:   '+FormatFloat('0.000000', En); // отображение.
 While En > Ev do // цикл пока текущяя ошибка будет меньше допустимой
  begin
   Et:= 0;
   For i:= 0 To High(Viborka) Do // перебор елементов выборки
    begin
     SetNeuroIn(Viborka[i].VhodV);  // подали на вход сети елемент выборки
     CalculateNeuro;                // посчитали сеть
     CalculateSigma(Viborka[i].VihodV); // считаем ошибки нейронов
     KorectWNeuro;                  // коррекция весовых коэфициентов
     CalculateNeuro;                // посчитали сеть
     GetNeuroOut(OutV);             // получили выходной вектор.
     T:= 0;                         // обнуляем сумму.
     For j:= 0 To High(OutV) Do T:= T + Sqr(Viborka[i].VihodV[j] - OutV[j]); // СКВ отклонение
     Et:= Et + 0.5*T;                                                        // по выборке
    end;
   En:= Et/(High(Viborka) + 1);  // Ошибка Тек.
   Inc(Ep);                      // Увеличим счетчик эпох
   if Ep > 70000 Then            // если епох прошло 70000 то
    begin                        // считаем что сеть попала в локальный мин.
     Et:= 0;                     // обнулим
     Ep:= 0;
     RandomizeWesaNC;            // сгенерируем новые веса сеити
     Inc(Mp);                    // увеличим счетчик минимумов.
    end;
  // if Ep > 100000 Then Break;
   Application.ProcessMessages;  // чтоб не подвисало.
   Label6.Caption:= 'СКВ Ошибка Тек.:   '+FormatFloat('0.000000', En);  // вывод
   Label7.Caption:= 'Эпох обучения:   '+IntToStr(Ep)+' раз.';          // переменных
   Label9.Caption:= 'Попали в мин:   '+IntToStr(Mp)+' раз.';
  end;
 ShowMessage('Нейросеть обучена!');
end;

procedure TForm1.SaveVesClick(Sender: TObject);
Var
 F: File of Real;     // файл
 i, j, k: Integer;    // счетчики
begin
 AssignFile(F, 'NeuroVesa.nvs');
 ReWrite(F);                      // откр. на перезапись
 For i:= 1 To High(Sety.Sloy) Do   // перебираем слои
  For j:= 0 To High(Sety.Sloy[i].Neuron) Do  // перебираем нейроны
   For k:= 0 To High(Sety.Sloy[i].Neuron[j].W) Do // перебираем веса
    Write(F, Sety.Sloy[i].Neuron[j].W[k]);  // запись весов
 CloseFile(F);   // закрыли файл.
 ShowMessage('Весовые коэфициенты нейросети записаны!');
end;

procedure TForm1.LoadVesClick(Sender: TObject);
Var
 F: File of Real;     // файл
 i, j, k: Integer;    // счетчики
begin
 if Not FileExists('NeuroVesa.nvs') Then  // если нет файла
  begin
   ShowMessage('Не найден файл!');
   Exit;
  end;
 AssignFile(F, 'NeuroVesa.nvs');
 Reset(F);
 Try
  For i:= 1 To High(Sety.Sloy) Do    // перебираем слои
   For j:= 0 To High(Sety.Sloy[i].Neuron) Do  // перебираем нейроны
    For k:= 0 To High(Sety.Sloy[i].Neuron[j].W) Do // перебираем веса
     Read(F, Sety.Sloy[i].Neuron[j].W[k]);    // чтение весов
 Except
  begin
   ShowMessage('Ошибка структуры сети!');
   Exit;
  end;
 end; 
 CloseFile(F);   // закрыли файл.
 ShowMessage('Весовые коэфициенты загружены!');
end;

end.
