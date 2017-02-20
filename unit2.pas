unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, CheckLst, ExtCtrls, fphttpclient, convutils, process, ShellApi;

type

  { TForm2 }
  TSarray = array of string;
  TForm2 = class(TForm)

    Exit_Button: TButton;
    Install: TButton;
    CheckBox1: TCheckBox;
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

       Internet        : Boolean;


  end;

var
  Form2         : TForm2;
  user          : string;

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

    if NOT(CheckBox1.Checked) then begin

      try

        if NOT(DirectoryExistsUTF8('C:\Program Files\darkpinguin.net'))then begin   //Create Directory if not Exsists

          mkdir('C:\Program Files\darkpinguin.net');

          if NOT(DirectoryExistsUTF8('C:\Program Files\darkpinguin.net\'+user))then begin   //Create Directory if not Exsists

            mkdir('C:\Program Files\darkpinguin.net\'+user);

          end;
          if NOT(DirectoryExistsUTF8('C:\ProgramData\Microsoft\Windows\Start Menu\'+user+'\'))then begin    //Create Directory if not Exsists

            mkdir('C:\ProgramData\Microsoft\Windows\Start Menu\'+user+'\');

          end;

        end else if NOT(DirectoryIsWritable('C:\Program Files\darkpinguin.net\'+user+'\')) then begin      // Admin ?

          ShowMessage('Can not install Programm no Admin run as Admin or choose Portable App');
          CheckBox1.Color:=clRed;
          Exit;
          Close;

        end;

      except

        ShowMessage('Can not install Programm no Admin run as Admin or choose Portable App');
        CheckBox1.Color:=clRed;
        Exit;
        Close;

      end;
      if FileExists('C:\ProgramData\Microsoft\Windows\Start Menu\'+user+'\'+CheckListBox1.Items[i]+'.exe')then begin

        RenameFile('C:\ProgramData\Microsoft\Windows\Start Menu\'+user+'\'+CheckListBox1.Items[i]+'.exe',CheckListBox1.Items[i]+'old.exe');

      end;

       Http.Get('http://darkpinguin.net/DV/'+user+'/'+CheckListBox1.Items[i]+'/'+CheckListBox1.Items[i]+'.exe','C:\ProgramData\Microsoft\Windows\Start Menu\'+user+'\'+CheckListBox1.Items[i]+'.exe');  // Downloading the Programm


      if FileExists('C:\ProgramData\Microsoft\Windows\Start Menu\'+user+'\'+CheckListBox1.Items[i]+'old.exe')then begin

        DeleteFile('C:\ProgramData\Microsoft\Windows\Start Menu\'+user+'\'+CheckListBox1.Items[i]+'old.exe');

      end;

    end;

    if CheckBox1.Checked then begin

      if FileExists(CheckListBox1.Items[i]+'.exe')then begin

        RenameFile(CheckListBox1.Items[i]+'.exe',CheckListBox1.Items[i]+'old.exe');

      end;

       Http.Get('http://darkpinguin.net/DV/'+user+'/'+CheckListBox1.Items[i]+'/'+CheckListBox1.Items[i]+'.exe',CheckListBox1.Items[i]+'-Portable.exe');  // Downloading the Programm  as Portable App

      if FileExists(CheckListBox1.Items[i]+'old.exe')then begin

        DeleteFile(CheckListBox1.Items[i]+'old.exe');

      end;

    end;

  end;
  end;
  ShowMessage('Fertig')
end;




procedure TForm2.FormCreate(Sender: TObject);
var

  userfile :TextFile;

begin

  Internet:=True;
  user:='dark_pin_guin';

  if user = 'notset' then begin

    if FileExists('user.ini')then begin

      AssignFile(userfile,'user.ini');
      Reset(userfile);
      ReadLn(userfile,user);

    end else begin

       ShowMessage('Setup.exe ERROR NO DEVELOPER IS DEFINED Look at www.darkpinguin.net/Programms for your Programm');
       CheckListBox1.Items.Add('ERROR NO DEVELOPER IS DEFINED');
       CheckListBox1.Items.Add('Look at www.darkpinguin.net/Programms');
       CheckListBox1.Items.Add('for your Programm');
       Close;
       Exit;

    end;

  end;

  try

    TFPCustomHTTPClient.SimpleGet('http://darkpinguin.net/DV/'+user+'/len.data');
  except

    Internet:=False;
    CheckListBox1.Items.Add('No can not connect to server');

  end;

  search_for_Updates;

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

  len := TFPCustomHTTPClient.SimpleGet('http://darkpinguin.net/DV/dark_pin_guin/len.data');                       // Number of Programms
  for i:= 0 to StrtoInt(len[1]) do begin

    proname := TFPCustomHTTPClient.SimpleGet('http://darkpinguin.net/DV/'+user+'/'+InttoStr(i)+'/name.dat'); // Loades the names of the Programms
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
  tmp:= TFPCustomHTTPClient.SimpleGet('http://darkpinguin.net/DV/'+user+'/'+Programmname+'/version.dat');    // Loads the version Number of the newest version
  netversion:=StrToFloat(copy(tmp,1,length(tmp)-1));                                                         // Formats the respond

  if netversion > version then
  begin

    Updatelabe.Visible:=True;
    Result:=True;

  end;

end;


end.
