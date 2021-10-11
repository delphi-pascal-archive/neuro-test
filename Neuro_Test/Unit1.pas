unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Grids, Spin;   // ����������� ����� �������

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
 TNeuron = Record          // ������.
  X: Array of Real;        // ����� �������.
  W: Array of Real;        // ������ ������� ������������� �������.
  dw: Array of Real;       // ������ ��������� ����� �������.
  sigma: Real;             // ������ �������.
  OutN: Real;              // ����� �������.
 end;

 TSloy = Record            // ����.
  Neuron: Array of TNeuron;// ������ �������� ����.
 end;

 TSety = Record            // C���.
  Sloy: Array of TSloy;    // ������ �����.
 end;

 TViborka = Record         // ��������� ��������� �������
  VhodV: Array of Real;    // ������� ������
  VihodV: Array of Real;   // �������� ������
 end;

Var
  Form1: TForm1;
  Sety: TSety;                 // ��������� ����, ������ ���� ��������.
  ParSety: Array of Integer;   // ��������� ����.
  InV: Array of Real;          // ��. ������ ����.
  OutV: Array of Real;         // ���. ������ ����.
  SDraw: Array of Array of TPoint; // ��� ��������� ���� (����������)
  Viborka: Array of TViborka;  // ������ � ��������� ��������.
  ko: Real;                    // ���������� �������� �������� (������ �� 0.1 �� 1.5)
  e: Real;                     // �������� ��������. (������ �� 0.01 �� 0.9)
  Xo: Integer;        // �������������� ���� � +1 � ������� ������� (���� 0 �� ��� ���. �����).
  im: Real;           // ����������� �������� (������ �� 0.1 �� 0.95)

implementation

{$R *.dfm}

Procedure CreateSety(Const Par: Array of Integer);  // ������� ����.
Var
 i, j, k: Integer;            // i - ����.  j - ������. k - ���� �������.
begin
 Randomize;   // ���.
 SetLength(Sety.Sloy, High(Par)+1);  // ������������� ����������� �����.
 For i:= 0 To High(Par) Do           // ���������� ����.
  begin
   SetLength(Sety.Sloy[i].Neuron, Par[i]);  // ������������� ����������� ������ � ����.
   For j:= 0 To High(Sety.Sloy[i].Neuron) Do   // ���������� ������� � ����
    begin  // ���� ���� ������� ��.
     if i = 0 Then SetLength(Sety.Sloy[i].Neuron[j].X, 1)  // � ������� 1 ����.
     Else
      begin // ����������� ������ � ����� ����������� ����� = ����������� ������ ����������� ���� + 1 ��� � ����.
       SetLength(Sety.Sloy[i].Neuron[j].X, (High(Sety.Sloy[i-1].Neuron)+1+1));   // +1 ���� ���������
       SetLength(Sety.Sloy[i].Neuron[j].W, (High(Sety.Sloy[i-1].Neuron)+1+1));   // +1 ��� ��� ���������� �����.
       SetLength(Sety.Sloy[i].Neuron[j].dw, (High(Sety.Sloy[i-1].Neuron)+1+1));  // +1 ���. ��� ��� ���������� �����.
       For k:= 0 To High(Sety.Sloy[i].Neuron[j].W) Do  // ���������� ���� �������.
        begin
         Sety.Sloy[i].Neuron[j].W[k]:= (Random(200)-100)/200; // ���� �������� ��������� ��.(-0,5..0,5).
         Sety.Sloy[i].Neuron[j].dw[k]:= Sety.Sloy[i].Neuron[j].W[k]; // ��������� ���� ������� = ��. ����.
        end;
       Sety.Sloy[i].Neuron[j].X[High(Sety.Sloy[i].Neuron[j].X)]:= Xo; // ������ ������� �� ��������� ����.
      end;
    end;
  end;
  SetLength(OutV, High(Sety.Sloy[High(Sety.Sloy)].Neuron) + 1); // ��������� ������� ���. ������� ����.
end;

Function NeuronSigmoid(Const Xn, Wn: Array of Real): Real;  // ������ �������.
Var
 Sum: Real;    // ���������� �����.
 i: Integer;   // �������.
begin
 Sum:= 0;
 For i:= 0 To High(Xn) Do Sum:= Sum + Xn[i]*Wn[i];  // ������� ���������� �����.
 if Abs(Sum) < 40 Then            // ������ �������.
  Result:= 1/(1 + Exp(-Sum*ko))    // �-�� ��������.
 Else
  begin
  if Sum >= 40 Then               // ��������� ��� ������ �� ������.
   Result:= 1
  Else
   Result:= 0;
  end; 
end;

Procedure SetNeuroIn(Const InVektor: Array of Real);  // ������ ������� ������ �� ���������.
Var
 j: Integer;  // j - ������.
begin
 For j:= 0 To High(Sety.Sloy[0].Neuron) Do // ���������� ������� �������� ����.
  Sety.Sloy[0].Neuron[j].X[0]:= InVektor[j];  // ����������� ������� ������.
end;

Procedure GetNeuroOut(Var OutVektor: Array of Real);  // ���. ���������.
Var
 j, OutSloy: Integer;  // j - ������. OutSloy - ������ ��������� ����.
begin
 OutSloy:= High(Sety.Sloy);  // ������ ������ ��������� ����.
 For j:= 0 To  High(Sety.Sloy[OutSloy].Neuron) Do // ���������� ������� ��������� ����.
  OutVektor[j]:= Sety.Sloy[OutSloy].Neuron[j].OutN;  // ����������� �������� ������.
end;

Procedure CalculateNeuro;   // ���������� ���� ����.
Var
 i, j, k: Integer;             // i - ����.  j - ������. k - ���� �������.
begin
 For i:= 0 To High(Sety.Sloy) Do  // ���������� ����.
  begin
   For j:= 0 To High(Sety.Sloy[i].Neuron) Do  // ���������� ������� � ����.
    if i = 0 Then                             // ���� ���� ������� ��..
     Sety.Sloy[i].Neuron[j].OutN:= Sety.Sloy[i].Neuron[j].X[0]  // ������� ������ = ������.
    Else                                      // ���� ���� ���������� ��� ���������..
     Sety.Sloy[i].Neuron[j].OutN:= NeuronSigmoid(Sety.Sloy[i].Neuron[j].X, Sety.Sloy[i].Neuron[j].W); // ������� ������.
   if i < High(Sety.Sloy) Then  // ���� �� ��������� ���� ��
    begin
     For j:= 0 To High(Sety.Sloy[i+1].Neuron) Do  // ���������� ������� ���������� ����
      For k:= 0 To High(Sety.Sloy[i].Neuron) Do   // ���������� ����� ������� ���������� ����.
       Sety.Sloy[i+1].Neuron[j].X[k]:= Sety.Sloy[i].Neuron[k].OutN; // ����������� ���. ����������� ��������
    end;                                                            // ������ �������� ���������� ����.
  end;
end;

Function SiSloy(SloyIndex, VesIndex: Integer): Real; // ������ ������ �����. ����.
Var
 j: Integer;   //  j - ������.
 Sum: Real;
begin
 Sum:= 0;      // ������� �����.
 For j:= 0 To  High(Sety.Sloy[SloyIndex].Neuron) Do // ���������� ������� ����.
  Sum:= Sum + Sety.Sloy[SloyIndex].Neuron[j].sigma*Sety.Sloy[SloyIndex].Neuron[j].W[VesIndex]; // �������
 Result:= Sum;                                     // ���������� ����� ������ ����.
end;

Procedure CalculateSigma(Const TselVektor: Array of Real); // ������ ����o� ��������.
Var
 si, nO: Real;      // si - ������� ������ �������. nO - ���. �������.
 i, j: Integer;     // i - ����.  j - ������.
begin
 For i:= High(Sety.Sloy) DownTo 1 Do  // ���������� ���� � ����� �� 1 ���� (0 - ���� ������� sigma ���).
  For j:= 0 To High(Sety.Sloy[i].Neuron) Do   // ���������� ������� � ����.
   begin
    nO:= Sety.Sloy[i].Neuron[j].OutN;        // ������ ���. �������� �������.
    if i = High(Sety.Sloy) Then       // ���� ���� ��������� ��..
     si:= nO*(1 - nO)*(TselVektor[j] - nO) // ���������� ������ ������� ��� ����.
    Else si:= nO*(1 - nO)*SiSloy(i+1, j);       // ���������� ������ ������� ������� �����.
    Sety.Sloy[i].Neuron[j].sigma:= si;     // ��������� ������� ��� ������.
   end;
end;

Procedure KorectWNeuro;  // ������������ ���� ��������.
Var
 dw: Real;                  //   ��������� ����.
 i, j, k: Integer;          // i - ����.  j - ������. k - ���� �������.
begin
 For i:= 1 To High(Sety.Sloy) Do  // ���������� ���� � 1 ���� (0 - ���� ������� ����� ���).
  For j:= 0 To High(Sety.Sloy[i].Neuron) Do   // ���������� ������� � ����.
   For k:= 0 To High(Sety.Sloy[i].Neuron[j].W) Do // ���������� ���� �������� �������.
    begin
     dw:= e*Sety.Sloy[i].Neuron[j].sigma + im*Sety.Sloy[i].Neuron[j].dw[k]; // ������ ��������� ����
     Sety.Sloy[i].Neuron[j].dw[k]:= dw;   // ���������� ��������� ����.
     Sety.Sloy[i].Neuron[j].W[k]:= Sety.Sloy[i].Neuron[j].W[k] + dw;   // ������������� ����.
    end;
end;

Procedure RandomizeWesaNC;  // ��������� ��������� ������� ������������.
Var
 i, j, k: Integer;  // i - ����.  j - ������. k - ���� �������.
begin
 Randomize;   // ���.
 For i:= 1 To High(Sety.Sloy) Do  // ���������� ���� � 1 ���� (0 - ���� ������� ����� ���).
  For j:= 0 To High(Sety.Sloy[i].Neuron) Do   // ���������� ������� � ����.
   For k:= 0 To High(Sety.Sloy[i].Neuron[j].W) Do // ���������� ���� �������� �������.
    begin
     Sety.Sloy[i].Neuron[j].W[k]:= (Random(200)-100)/200; // ���� �������� ��������� ��.(-0,5..0,5).
     Sety.Sloy[i].Neuron[j].dw[k]:= Sety.Sloy[i].Neuron[j].W[k]; // ��������� ���� ������� = ��. ����.
    end;
end;

Procedure DrawSety(w, h, r, c: Integer; Const Par: Array of Integer); // ������ ����.
Var
 Bmp: TBitmap;                  // �����
 i, j, k, dx, dy: Integer;      // i, j, k - ��������, dx, dy - ���������� ����� ���������
begin
 Bmp:= TBitmap.Create;          // �������
 Bmp.Width:= w;                 // ���. ������
 Bmp.Height:= h;
 SetLength(SDraw, SizeOf(Par));  // ���. ������ �����
 dy:= w div (High(Par) + 2) + 1; // ������ ���������� ����� ������
 For i:= 0 To High(Par) Do       // ���������� ����
  begin
   SetLength(SDraw[i], Par[i]);  // ���. �-�� �������� � ����.
   dx:= h div (Par[i] + 1) + 1;  // ������ ���������� ����� ��������� � ����
   For j:= 0 To Par[i] - 1 Do    // ���������� �������
    begin
     SDraw[i, j].X:= (i+1)*dy;   // ����������� ���������� ������� �������
     SDraw[i, j].Y:= (j+1)*dx;
    end;
  end;
 For i:= 0 To High(Par) Do       // ���������� ����
  For j:= 0 To Par[i] - 1 Do     // ���������� �������
   begin
    if i < High(Par) Then        // ���� ���� �� ��������� ��...
     begin
      For k:= 0 To Par[i+1] - 1 Do  // ���������� ������� ���������� ����
       begin
        if i = 0 Then               // ���� ���� ������ ��...
         begin
          Bmp.Canvas.Brush.Color:= clWhite;    // ������� �����
          Bmp.Canvas.TextOut(8, SDraw[i, j].Y - 15, 'X'+IntToStr(j+1)); // ����� �
          Bmp.Canvas.MoveTo(SDraw[i, j].X, SDraw[i, j].Y);  // ������ �����
          Bmp.Canvas.LineTo(0, SDraw[i, j].Y);
         end;
        Bmp.Canvas.MoveTo(SDraw[i, j].X, SDraw[i, j].Y);  // ������ �����.
        Bmp.Canvas.LineTo(SDraw[i+1, k].X, SDraw[i+1, k].Y);
       end;
      end
     Else             // ���� ���������
      begin
       Bmp.Canvas.Brush.Color:= clWhite;     // ������� �����
       Bmp.Canvas.TextOut(w - 25, SDraw[i, j].Y - 15, 'Y'+IntToStr(j+1));  // ����� �
       Bmp.Canvas.MoveTo(SDraw[i, j].X, SDraw[i, j].Y);    // ������ ������
       Bmp.Canvas.LineTo(w, SDraw[i, j].Y);
      end;
    if i = 0 Then Bmp.Canvas.Brush.Color:= clGreen   // ���� ���� ������ �� ������� �������
     Else     // �����
      begin
       if c = 1 Then // ���� ���� �������������� ���� ��...
        begin
         Bmp.Canvas.Brush.Color:= clWhite;  // ������� �����
         Bmp.Canvas.MoveTo(SDraw[i, j].X, SDraw[i, j].Y);   //  ������ ����
         Bmp.Canvas.LineTo(SDraw[i, j].X, SDraw[i, j].Y-2*r);
         if j = 0 Then Bmp.Canvas.TextOut(SDraw[i, j].X-5, SDraw[i, j].Y-3*r-2, '+1'); // ����� +1
        end;
       Bmp.Canvas.Brush.Color:= clRed; // ������� �������
      end;
    Bmp.Canvas.Ellipse(SDraw[i, j].X-r, SDraw[i, j].Y-r, SDraw[i, j].X+r, SDraw[i, j].Y+r);  // ��� �������
   end;
 Form1.Image1.Canvas.Draw(0, 0, Bmp);  // ��������� BMP �� Image.
 Bmp.Free;    // ����������.
end;

procedure TForm1.FormCreate(Sender: TObject);
begin                           // ��������� ���������
 SetLength(ParSety, 4);         // 4 ����
 ParSety[0]:= 2;                // ������� 2 - �������
 ParSety[1]:= 4;                // ������ ������� ���� 4 - �������
 ParSety[2]:= 3;                // ������ ������� ���� 3 - �������
 ParSety[3]:= 1;                // �������� 1 - ������
 SloiCol.Cells[0, 0]:= '����1'; SloiCol.Cells[0, 1]:= '2';   // ������� ��� �������)
 SloiCol.Cells[1, 0]:= '����2'; SloiCol.Cells[1, 1]:= '4';
 SloiCol.Cells[2, 0]:= '����3'; SloiCol.Cells[2, 1]:= '3';
 SloiCol.Cells[3, 0]:= '����4'; SloiCol.Cells[3, 1]:= '1';
 InVector.Cells[0, 0]:= 'X1';   InVector.Cells[1, 0]:= '0';
 InVector.Cells[0, 1]:= 'X2';   InVector.Cells[1, 1]:= '0';
 OutVector.Cells[0, 0]:= 'Y1';  OutVector.Cells[1, 0]:= '0';
 Application.HintHidePause:= 15000;     // ����� ������ ���������.
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
Var
 i: Integer;
begin
 SloiCol.ColCount:= SpinEdit1.Value;  // ���. �-�� �����.
 SetLength(ParSety, SpinEdit1.Value); // ���. �-�� �����.
 For i:= 0 To SloiCol.ColCount - 1 Do
  begin
   SloiCol.Cells[i, 0]:= '����: '+IntToStr(i+1); // ������� ��� �������)
   if SloiCol.Cells[i, 1] = '' Then SloiCol.Cells[i, 1]:= '1'; // ���� ������ ������ �� �������� 1.
  end;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
 i, j, k: Integer;   // ��������
 St: String;         // ������ � ����������
 OutN: Real;         // ���. �������
 Sig: Real;          // ������ �������
begin
 For i:= 0 To High(SDraw) Do      // ���������� ����
  For j:= 0 To High(SDraw[i]) Do    // ���������� �������
   begin   // ���� ���� �������� � ������ (8) ������� ��...
    if (Abs(SDraw[i, j].X - X) < 8) and (Abs(SDraw[i, j].Y - Y) < 8) Then
     begin
      Image1.ShowHint:= True;  // ���. ���������
      OutN:= Sety.Sloy[i].Neuron[j].OutN; //������ ����� �������
      Sig:= Sety.Sloy[i].Neuron[j].sigma;  // ������ ������
      St:= '';                           // �������
      if i > 0 Then        // ���� ���� �� ������� ��...
      For k:= 0 To High(Sety.Sloy[i].Neuron[j].X) Do  // ���������� ���� �������
       if k < High(Sety.Sloy[i].Neuron[j].X) Then   // ���� ��� �� �������������� (���������) ��...
        St:= St + '����'+IntToStr(k+1)+' = '+FormatFloat('0.000000', Sety.Sloy[i].Neuron[j].X[k])+';   '+
             '���'+IntToStr(k+1)+' = '+FormatFloat('0.000000', Sety.Sloy[i].Neuron[j].W[k])+#13  // ��������� ���������
       Else   // ��� ���.
        St:= St + '���. ���� = '+FormatFloat('0.000000', Sety.Sloy[i].Neuron[j].X[k])+';   '+
             '���. ��� = '+FormatFloat('0.000000', Sety.Sloy[i].Neuron[j].W[k])+#13;    // ��������� ���������
      if i = 0 Then      // ���� ���� ������� ��..
       Image1.Hint:= St+'����� ����������� = '+FormatFloat('0.000000', OutN) // ��������� ��������� Image
      Else               // �����
       Image1.Hint:= St+'����� ������� = '+FormatFloat('0.000000', OutN)+#13+
        '������ ������� = '+FormatFloat('0.000000', Sig);   // ��������� ��������� Image
      Exit;
     end
    Else Image1.ShowHint:= False; // ����. ���������
   end;
end;

procedure TForm1.CreateNeuroClick(Sender: TObject);
Var
 i: Integer;
begin
 InVector.RowCount:= StrToInt(SloiCol.Cells[0, 1]);  // ���. ������ �������� �������
 For i:= 0 To InVector.RowCount - 1 Do      // ���������� �� ������ �����������.
  begin
   InVector.Cells[0, i]:= 'X'+IntToStr(i+1);  // ��� �������
   if InVector.Cells[1, i] = '' Then InVector.Cells[1, i]:= '0'; //���� ������ ����� �� �������� 0.
  end;
 OutVector.RowCount:= StrToInt(SloiCol.Cells[SpinEdit1.Value-1, 1]);// ���. ������ ��������� �������
 For i:= 0 To OutVector.RowCount - 1 Do      // ���������� ��� ������ �����������.
  begin
   OutVector.Cells[0, i]:= 'Y'+IntToStr(i+1);  // ��� �������
   if OutVector.Cells[1, i] = '' Then OutVector.Cells[1, i]:= '0'; //���� ������ ����� �� �������� 0.
  end;
 if RadioGroup1.ItemIndex = 0 Then Xo:= 1 Else Xo:= 0;  // ������ ���� ��� ��� ��� ����
 For i:= 0 To SloiCol.ColCount - 1 Do ParSety[i]:= StrToInt(SloiCol.Cells[i, 1]); //��������� ������ �� ���������� ����
 ko:= StrToFloat(Edit1.Text);  // �������� �������� ��������.
 im:= StrToFloat(Edit2.Text);  // �������� ���������� ��������.
 e:= StrToFloat(Edit3.Text);   // �������� �������� ��������.
 DrawSety(Image1.Width, Image1.Height, 8, Xo, ParSety); // �������� ����
 CreateSety(ParSety);                      // �������� ����
 ShowMessage('��������� �������!');
 Raschet.Enabled:= True;              // �������� ������� ��������� ������.
 SaveNSris.Enabled:= True;
 SaveVes.Enabled:= True;
 LoadVes.Enabled:= True;
 Obuch.Enabled:= True;
end;

procedure TForm1.SaveNSrisClick(Sender: TObject);
begin
 Image1.Picture.SaveToFile('NeuroTest.bmp');   // ����. ���. ���� � ����
 ShowMessage('���. ��������!');
end;

procedure TForm1.RaschetClick(Sender: TObject);
Var
 i: Integer;    // �������
begin
 SetLength(InV, InVector.RowCount); // ���. ������ ��. �������
 For i:= 0 To InVector.RowCount - 1 Do InV[i]:= StrToFloat(InVector.Cells[1, i]); //�������� ��. ������
 SetNeuroIn(InV);   // ������� ��. ������ �� ���� ����
 CalculateNeuro;    // ��������� ����
 GetNeuroOut(OutV); // �������� ��� ������ ����
 For i:= 0 To OutVector.RowCount - 1 Do OutVector.Cells[1, i]:= FormatFloat('0.000000', OutV[i]);// ������� ��� ������ ����
end;

Function LoadFromFile(Fn: String): Boolean;  // �������� ��������� ������� �� ���������� �����
Var
 Sl: TStringList;   // ����� ����� �����
 St, Re: String;    // ������ � ��������� �����
 i, j, k, k1, Xi, Xt, Yi: Integer;  // ��������
begin
 Result:= True;
 if Not FileExists(Fn) Then   // ���� ����� ���
  begin
   Result:= False;
   Exit;                      // �������.
  end;
 Xi:= 0; Yi:= 0;
 Sl:= TStringList.Create;
 Sl.LoadFromFile(Fn);        // ��������� �����
 St:= Sl.Strings[0];         // ������ ������ �������
 Try
 For i:= 0 To Length(St) - 1 Do  // ������� ����������� ������ ������
  begin
   if St[i] = 'X' Then Inc(Xi);  // ������ = � �� �������� ������� �-��
   if St[i] = 'Y' Then Inc(Yi);  // ������ = � �� �������� ������� �-��
  end;
 k:= 1;
 For i:= 1 To Sl.Count - 1 Do   // ���������� ������
  if Sl.Strings[i] <> '' Then   // ���� ������ �� ������ ��..
   begin
    SetLength(Viborka, k);      // ���. ������ �������.
    Inc(k);                     // �������� ������ ������� �� 1.
   end;
 For i:= 0 To High(Viborka) Do  // ���������� �������� �������
  begin
   SetLength(Viborka[i].VhodV, Xi);   // ���. ������ ������
   SetLength(Viborka[i].VihodV, Yi);  // ���. ������ �������
  end;
 For i:= 1 To Sl.Count - 1 Do  // ���������� ������ ������� �� ������.
  begin
   Re:= '';                   // �������
   k:= 0; k1:= 0;
   Xt:= Xi;                   // Xt - �-�� ����� (������)
   St:= Sl.Strings[i];        // ������ ������
   if St <> '' Then           // ���� ������ �� ����� ��..
   begin
   For j:= 1 To Length(St) + 1 Do  // ���������� �����������
    begin  // ���� ������ �� ������ � �� ����� ������ ��..
     if (St[j] <> ' ') and (j <= Length(St)) Then Re:= Re + St[j] // ������� ���� ������
     Else
      begin
       if Re <> '' Then // ���� ���������� ������ �� ����� ��...
        if Xt > 0 Then  // ���� ���� �� ����������� ��..
         begin
          Dec(Xt); // �������� ����
          Viborka[i-1].VhodV[k]:= StrToFloat(Re); // �������� � ������� ����� �
          Inc(k);  // �������� ������� ��������� ������� �
         end
        Else  // ���� �����������
         begin
          Viborka[i-1].VihodV[k1]:= StrToFloat(Re); // �������� � ������� ����� �
          Inc(k1); // �������� ������� ��������� ������� �
         end;
       Re:= ''; // �������
      end;
    end;
   end;
  end;
 Except
  begin
   ShowMessage('������ � ����� � ��������!');
   Result:= False;
  end;
 end;
 Sl.Free;   
end;

procedure TForm1.ObuchClick(Sender: TObject);
Var
 Et, T, En, Ev: Real;  // Ev - ���������� ������. En - ������� ������. T - ����� ���. Et - ����� ��� �� �������
 i, j, Ep, Mp: Integer;   // ��������
begin
 if Not LoadFromFile('Viborka.txt') Then  // ��������� �������
  begin
   ShowMessage('�� �������� ���� � ��������� ��������!');
   Exit;
  end;
 Ev:= StrToFloat(Edit4.Text);  // ������ ���������� ������ ����.
 Et:= 0;                       // ��������.
 Ep:= 0;
 Mp:= 0;
 For i:= 0 To High(Viborka) Do  // ������� ��������� �������
  begin
   SetNeuroIn(Viborka[i].VhodV); // ������ �� ���� ���� ������� �������
   CalculateNeuro;               // ��������� ����
   GetNeuroOut(OutV);            // �������� �������� ������.
   T:= 0;                        // �������� �����.
   For j:= 0 To High(OutV) Do T:= T + Sqr(Viborka[i].VihodV[j] - OutV[j]); // ��� ����������
   Et:= Et + 0.5*T;                                                        // �� �������
  end;
 En:= Et/(High(Viborka) + 1); // ������ ���
 Label5.Caption:= '��� ������ ���.:   '+FormatFloat('0.000000', En); // �����������.
 While En > Ev do // ���� ���� ������� ������ ����� ������ ����������
  begin
   Et:= 0;
   For i:= 0 To High(Viborka) Do // ������� ��������� �������
    begin
     SetNeuroIn(Viborka[i].VhodV);  // ������ �� ���� ���� ������� �������
     CalculateNeuro;                // ��������� ����
     CalculateSigma(Viborka[i].VihodV); // ������� ������ ��������
     KorectWNeuro;                  // ��������� ������� ������������
     CalculateNeuro;                // ��������� ����
     GetNeuroOut(OutV);             // �������� �������� ������.
     T:= 0;                         // �������� �����.
     For j:= 0 To High(OutV) Do T:= T + Sqr(Viborka[i].VihodV[j] - OutV[j]); // ��� ����������
     Et:= Et + 0.5*T;                                                        // �� �������
    end;
   En:= Et/(High(Viborka) + 1);  // ������ ���.
   Inc(Ep);                      // �������� ������� ����
   if Ep > 70000 Then            // ���� ���� ������ 70000 ��
    begin                        // ������� ��� ���� ������ � ��������� ���.
     Et:= 0;                     // �������
     Ep:= 0;
     RandomizeWesaNC;            // ����������� ����� ���� �����
     Inc(Mp);                    // �������� ������� ���������.
    end;
  // if Ep > 100000 Then Break;
   Application.ProcessMessages;  // ���� �� ���������.
   Label6.Caption:= '��� ������ ���.:   '+FormatFloat('0.000000', En);  // �����
   Label7.Caption:= '���� ��������:   '+IntToStr(Ep)+' ���.';          // ����������
   Label9.Caption:= '������ � ���:   '+IntToStr(Mp)+' ���.';
  end;
 ShowMessage('��������� �������!');
end;

procedure TForm1.SaveVesClick(Sender: TObject);
Var
 F: File of Real;     // ����
 i, j, k: Integer;    // ��������
begin
 AssignFile(F, 'NeuroVesa.nvs');
 ReWrite(F);                      // ����. �� ����������
 For i:= 1 To High(Sety.Sloy) Do   // ���������� ����
  For j:= 0 To High(Sety.Sloy[i].Neuron) Do  // ���������� �������
   For k:= 0 To High(Sety.Sloy[i].Neuron[j].W) Do // ���������� ����
    Write(F, Sety.Sloy[i].Neuron[j].W[k]);  // ������ �����
 CloseFile(F);   // ������� ����.
 ShowMessage('������� ����������� ��������� ��������!');
end;

procedure TForm1.LoadVesClick(Sender: TObject);
Var
 F: File of Real;     // ����
 i, j, k: Integer;    // ��������
begin
 if Not FileExists('NeuroVesa.nvs') Then  // ���� ��� �����
  begin
   ShowMessage('�� ������ ����!');
   Exit;
  end;
 AssignFile(F, 'NeuroVesa.nvs');
 Reset(F);
 Try
  For i:= 1 To High(Sety.Sloy) Do    // ���������� ����
   For j:= 0 To High(Sety.Sloy[i].Neuron) Do  // ���������� �������
    For k:= 0 To High(Sety.Sloy[i].Neuron[j].W) Do // ���������� ����
     Read(F, Sety.Sloy[i].Neuron[j].W[k]);    // ������ �����
 Except
  begin
   ShowMessage('������ ��������� ����!');
   Exit;
  end;
 end; 
 CloseFile(F);   // ������� ����.
 ShowMessage('������� ����������� ���������!');
end;

end.
