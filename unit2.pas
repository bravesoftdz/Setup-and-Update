unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, CheckLst, ExtCtrls, fphttpclient, convutils;

type

  { TForm2 }
  TSarray = array of string;
  TForm2 = class(TForm)

    Exit_Button: TButton;
    Install: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckGroup1: TCheckGroup;
    CheckListBox1: TCheckListBox;
    procedure Exit_ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InstallClick(Sender: TObject);
    procedure search_for_Updates();
    function search_for_Updates(Updatelabe : TLabel; version: Extended;Programmname :String):Boolean;
  private
    { private declarations }
  public
    { public declarations }

    var
       //Programs      : string;   to be remouved?
       //newUpdate     : Boolean;  to be remouved?
       Internet        : Boolean;


  end;

var
  Form2         : TForm2;

implementation

{$R *.lfm}

{ TForm2 }

// Installs the Selected Programms

procedure TForm2.InstallClick(Sender: TObject);
var

  i    : Integer;
  Http : TFPCustomHTTPClient;

begin

  if NOT(Internet) then begin Exit;end;

  Http := TFPCustomHTTPClient.Create(nil);
  for i:= 0 to (CheckListBox1.Count-1) do begin

    if CheckListBox1.Checked[i] then begin

      Http.Get('http://darkpinguin.net/DV/releases/Delphi-Calculator/'+CheckListBox1.Items[i]+'.exe',CheckListBox1.Items[i]+'.exe');  // Downloading the Programm

    end;

  end;

end;



procedure TForm2.FormCreate(Sender: TObject);
begin
  Internet:=True;
  try
    TFPCustomHTTPClient.SimpleGet('http://darkpinguin.net/DV/len.data');
  except
    Internet:=False;
    CheckListBox1.Items.Add('No can not connect to server');
  end;
end;

//Close Update Window

procedure TForm2.Exit_ButtonClick(Sender: TObject);
begin

  Form2.Close;
end;


//Serches for Updates for all Programms on the server

procedure TForm2.search_for_Updates();
var

  i : Integer;
  len : String;
  proname : String;

begin

  if NOT(Internet) then begin Exit;end;

  len := TFPCustomHTTPClient.SimpleGet('http://darkpinguin.net/DV/len.data');                       // Number of Programms

  for i:= 0 to StrtoInt(len[1]) do begin

    proname := TFPCustomHTTPClient.SimpleGet('http://darkpinguin.net/DV/'+InttoStr(i)+'/name.dat'); // Loades the names of the Programms
    CheckListBox1.Items.Add(copy(proname,0,length(proname)-1));                                     // Adds the Progamms to the List

  end;

end;

// Checks for updates for the Programm with the Name in Programmname

function TForm2.search_for_Updates(Updatelabe : TLabel; version: Extended;Programmname :String) : Boolean;
var

  netversion:Extended;
  tmp       :string;

begin

  if NOT(Internet) then begin Exit;end;

  Result:=False;
  tmp:= TFPCustomHTTPClient.SimpleGet('http://darkpinguin.net/DV/releases/'+Programmname+'/version.dat');    // Loads the version Number of the newest version
  netversion:=StrToFloat(copy(tmp,1,length(tmp)-1));                                                         // Formats the respond

  if netversion > version then
  begin

    Updatelabe.Visible:=True;
    Result:=True;

  end;

end;

end.

