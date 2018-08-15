{
  MoShade Automator, a GUI software for creating and automating the execution of batch files for MoShade.

  Author
            Jean R. N. Haler - jean.haler@uliege.be (University of Liège - Mass Spectrometry Laboratory)
  Supervisor
            Prof. Edwin De Pauw - e.depauw@uliege.be (University of Liège - Mass Spectrometry Laboratory)

—————————————————————————————————————————————

  This program is free software: you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation, either version 2 of the License, or (at your option)
  any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along with
  this program. If not, see <http://www.gnu.org/licenses/>.
—————————————————————————————————————————————
}


unit automator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, fileinfo, process, StrUtils
  {$IFDEF LINUX},unix{$ENDIF};

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnBrowseMoshade: TButton;
    BtnBrowseInputs: TButton;
    BtnClearInputs: TButton;
    BtnOutputDirectory: TButton;
    BtnPause: TButton;
    BtnRun: TButton;
    BtnClearBatches: TButton;
    BtnSaveDefaults: TButton;
    BtnLoadDefaults: TButton;
    BtnInfo: TButton;
    BtnAddBatch: TButton;
    BtnLoadBatch: TButton;
    BtnStop: TButton;
    BtnResume: TButton;
    ChkboxVerbose: TCheckBox;
    ChkboxNaive: TCheckBox;
    GBmoshade: TGroupBox;
    GroupBox1: TGroupBox;
    GBParameters: TGroupBox;
    GBOutput: TGroupBox;
    GBBatches: TGroupBox;
    Image1: TImage;
    Logo_ULiege: TImage;
    Label1: TLabel;
    lblAddedBatches: TLabel;
    lblBatchcalc: TLabel;
    lblMoShadeCredits: TLabel;
    lbledtBatchName: TLabeledEdit;
    lblAutomatorCredits: TLabel;
    lbledtPrefix: TLabeledEdit;
    lbledtSuffix: TLabeledEdit;
    lbledtSamples: TLabeledEdit;
    lbledtCPU: TLabeledEdit;
    lblAddedFiles: TLabel;
    lblPercCalc: TLabel;
    lblPercInput: TLabel;
    MemoMoshadePath: TMemo;
    MemoOutputDir: TMemo;
    MemoBatches: TMemo;
    MemoInputs: TMemo;
    ProgBarCalc: TProgressBar;
    ProgBarInput: TProgressBar;
    procedure BtnAddBatchClick(Sender: TObject);
    procedure BtnBrowseInputsClick(Sender: TObject);
    procedure BtnBrowseMoshadeClick(Sender: TObject);
    procedure BtnClearBatchesClick(Sender: TObject);
    procedure BtnClearInputsClick(Sender: TObject);
    procedure BtnInfoClick(Sender: TObject);
    procedure BtnLoadBatchClick(Sender: TObject);
    procedure BtnLoadDefaultsClick(Sender: TObject);
    procedure BtnOutputDirectoryClick(Sender: TObject);
    procedure BtnPauseClick(Sender: TObject);
    procedure BtnResumeClick(Sender: TObject);
    procedure BtnRunClick(Sender: TObject);
    procedure BtnSaveDefaultsClick(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    moshadepath, outputpath:string;
    addedfiles, addedbatches:TStringList;
    PauseOnNext, StopMoshade:boolean;
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.FormCreate(Sender: TObject);
var
  FileVerInfo: TFileVersionInfo;
  version:String;
begin
  FileVerInfo:=TFileVersionInfo.Create(nil);
  try
    FileVerInfo.ReadFileInfo;
    version:='v.' + FileVerInfo.VersionStrings.Values['FileVersion'];
  finally
    FileVerInfo.Free;
  end;
  lblAutomatorCredits.Caption:='Automator '+version+' by J.R.N. Haler';

  addedfiles:=TStringList.Create;
  addedbatches:=TStringList.Create;
  MemoInputs.Clear;
  MemoBatches.Clear;
  MemoMoshadePath.Clear;
  lbledtBatchName.Text:='';

  lblAddedFiles.Caption:='Added Files: '+IntToStr(addedfiles.Count);
  lblAddedBatches.Caption:='Added batches: 0';

  lblPercInput.Parent:=ProgBarInput;
  lblPercInput.Autosize:=False;
  lblPercInput.Transparent:=True;
  lblPercInput.Top:=0;
  lblPercInput.Left:=0;
  lblPercInput.Width:=ProgBarInput.ClientWidth;
  lblPercInput.Height:=ProgBarInput.ClientHeight;
  lblPercInput.BringToFront;
  lblPercInput.Alignment:=taCenter;
  lblPercInput.Layout:=tlCenter;
  lblPercInput.Caption:='';

  lblPercCalc.Parent:=ProgBarCalc;
  lblPercCalc.Autosize:=False;
  lblPercCalc.Transparent:=True;
  lblPercCalc.Top:=0;
  lblPercCalc.Left:=0;
  lblPercCalc.Width:=ProgBarCalc.ClientWidth;
  lblPercCalc.Height:=ProgBarCalc.ClientHeight;
  lblPercCalc.BringToFront;
  lblPercCalc.Alignment:=taCenter;
  lblPercCalc.Layout:=tlCenter;
  lblPercCalc.Caption:='';

  StopMoshade:=False;
  PauseOnNext:=False;
end;

procedure TForm1.BtnBrowseMoshadeClick(Sender: TObject);                       //Browse to get the moshade executable & its full path
var
  Browmoshade:TOpenDialog;
begin
  MemoMoshadePath.Lines.Clear;
  Browmoshade:=TOpenDialog.Create(self);
  {$IFDEF WINDOWS}
  Browmoshade.Filter:='.exe|*.exe';
  Browmoshade.Title:='Select the MoShade executable file';
  {$ENDIF}

  if (Browmoshade.Execute) then
  begin
    moshadepath:=Browmoshade.FileName;
    MemoMoshadePath.Lines.Add(moshadepath);
  end;
  Browmoshade.Free;
end;

procedure TForm1.BtnClearBatchesClick(Sender: TObject);                        //Clear the batch list
begin
  addedbatches.Clear;
  MemoBatches.Clear;
  lblAddedBatches.Caption:='Added batches: '+IntToStr(addedbatches.count);
end;

procedure TForm1.BtnClearInputsClick(Sender: TObject);                         //Clear the input file list
begin
  addedfiles.Clear;
  MemoInputs.Lines.Clear;
  lblAddedFiles.Caption:='Added Files: '+IntToStr(addedfiles.Count);
end;

procedure TForm1.BtnInfoClick(Sender: TObject);                                //Info Button
var
  version:string;
  FileVerInfo: TFileVersionInfo;
begin
  FileVerInfo:=TFileVersionInfo.Create(nil);
  try
    FileVerInfo.ReadFileInfo;
    {writeln('File description: ',FileVerInfo.VersionStrings.Values['FileDescription']);
    writeln('Internal name: ',FileVerInfo.VersionStrings.Values['InternalName']);
    writeln('Legal copyright: ',FileVerInfo.VersionStrings.Values['LegalCopyright']);
    writeln('Original filename: ',FileVerInfo.VersionStrings.Values['OriginalFilename']);
    writeln('Product name: ',FileVerInfo.VersionStrings.Values['ProductName']);
    writeln('File version: ',FileVerInfo.VersionStrings.Values['ProductVersion']);
    writeln('Company name: ',FileVerInfo.VersionStrings.Values['CompanyName']);}
    version:='v.' + FileVerInfo.VersionStrings.Values['FileVersion'];
  finally
    FileVerInfo.Free;
  end;

  ShowMessage(
  'MoShade Automator '+version
  +sLineBreak+
  'GUI software for creating and automating the execution of batch files for MoShade.'
  +sLineBreak+sLineBreak+
  '*  No file paths should contain spaces or special characters.'
  +sLineBreak+
  '*  Input files are either ".stl" ASCII STL files (stereolitography) or composite ".gm" files.'
  +sLineBreak+
  '*  You can set the number of CPU cores to "0" to use all CPU cores.'
  +sLineBreak+
  '*  "verbose" will print all values of the orientations and cross-sections with the following structure:'
  +sLineBreak+
  '   <topological info on the input file>'
  +sLineBreak+
  '   theta1 phi1 #tris cross-section1 projected-area1 ratio1'
  +sLineBreak+
  '   theta2 phi2 #tris cross-section2 projected-area2 ratio2'
  +sLineBreak+
  '   ...'
  +sLineBreak+
  '   min_CS        phimin       thmin'
  +sLineBreak+
  '   max_CS        phimax       thmax'
  +sLineBreak+
  '*  "naive" tells to use a naive n*n integration quadrature instead of an optimized one.'
  +sLineBreak+sLineBreak+
  '*  MoShade Automator creates two types of batches:'
  +sLineBreak+
  '1. for MoShade via terminal/command prompt (without GUI). You can easily render them executable for Linux (see "how_to_use.txt") or Windows (*.bat) terminals.'
  +sLineBreak+
  '2. for MoShade Automator (with GUI). These batches are named with an "_automator" suffix ("YOUR_NAME_automator").'
  +sLineBreak+sLineBreak+
  '*  The calculation progress bar for each input is only approximate.'
  +sLineBreak+sLineBreak+
  '*  You can save and load default parameters for speeding up your parameter encoding.'
  +sLineBreak+sLineBreak+
  '*  Spaces in file paths may cause problems.'
  );

  ShowMessage(
  'MoShade Automator'
  +sLineBreak+
  'MoShade Automator is GPLv2+ licensed. 2018'
  +sLineBreak+
  'Jean R. N. Haler - jean.haler@uliege.be'
  +sLineBreak+
  'Supervisor: Prof. Edwin De Pauw - e.depauw@uliege.be'
  +sLineBreak+
  'Mass Spectrometry Laboratory'
  +sLineBreak+sLineBreak+
  'MoShade - compute average cross sections of complex geometrical shapes.'
  +sLineBreak+
  'MoShade is free software'
  +sLineBreak+
  '(c) 2017 Prof. Eric Bechet - eric.bechet@cadxfem.org'
  +sLineBreak+
  'See the LICENSE file for license information.'
  +sLineBreak+sLineBreak+
  'University of Liège'
  +sLineBreak+
  'The FNRS is recognized for financial support (FRIA)'
  );
end;

procedure TForm1.BtnLoadBatchClick(Sender: TObject);                           //Load/Add existing batches
var
  i:integer;
  Browbatches:TOpenDialog;
begin
  Browbatches:=TOpenDialog.Create(self);
  Browbatches.Filter:='Text files only (.txt)|*.txt';                          //restrict to only open .txt files
  Browbatches.Title:='Select the MoShade Automator batch file(s)';
  Browbatches.Options:=[ofAllowMultiSelect];
  if (addedfiles.count<>0) then                                                //open Browse dialog in last encoded input file directory
    Browbatches.InitialDir:=ExtractFilePath(addedfiles[addedfiles.count-1]);
  if (outputpath<>'') then                                                     //open Browse dialog in last encoded output file directory if encoded
    Browbatches.InitialDir:=outputpath;

  if (Browbatches.Execute) then
  begin
    for i:=0 to (Browbatches.Files.Count-1) do
    begin
      addedbatches.Add(Browbatches.Files.Strings[i]);
      MemoBatches.Lines.Add('Batch#'+IntToStr(addedbatches.count));
      MemoBatches.Lines.Add(Browbatches.Files.Strings[i]);
    end;
  end;
  Browbatches.Free;
  lblAddedBatches.Caption:='Added batches: '+IntToStr(addedbatches.count);
end;

procedure TForm1.BtnLoadDefaultsClick(Sender: TObject);                        //Load default parameters
var
  Def_param:text;
  dir:string;
  params, parsedparams:TStringList;
  tabposition, i:integer;
begin
  MemoMoshadePath.Clear;                                                       //Clear several objects
  MemoOutputDir.Clear;

  dir:=ProgramDirectory;
  SetCurrentDir(dir);
  AssignFile(Def_param,'parameters.par');
  Reset(Def_param);                                                            //opens file; 3 lines of comments
  params:=TStringList.Create;
  parsedparams:=TStringlist.Create;
  params.LoadFromFile('parameters.par');
  CloseFile(Def_param);

  for i:=3 to (params.Count-1) do                                              //3 lines of comments
  begin
    tabposition:=Pos(chr(9),params[i]);
    parsedparams.Add(Copy(params[i],(tabposition+1),Length(params[i])));
  end;

  moshadepath:=parsedparams[0];                                                //load the parameters into GUI
  MemoMoshadePath.Lines.Add(moshadepath);
  if (FileExists(ExtractFileName(moshadepath))=False) then
  begin
    ShowMessage('MoShade exectuable not found.');
    MemoMoshadePath.Clear;
    moshadepath:='';
  end;
  lbledtCPU.Text:=parsedparams[1];
  lbledtSamples.Text:=parsedparams[2];
  ChkboxVerbose.Checked:=StrToBool(parsedparams[3]);
  ChkboxNaive.Checked:=StrToBool(parsedparams[4]);
  lbledtPrefix.Text:=parsedparams[5];
  lbledtSuffix.Text:=parsedparams[6];
  outputpath:=parsedparams[7];
  MemoOutputDir.Lines.Add(outputpath);

  params.Free;
  parsedparams.Free;
end;

procedure TForm1.BtnOutputDirectoryClick(Sender: TObject);                     //Browse to select the output directory and path
var
  BrowOutputDir:TSelectDirectoryDialog;
begin
  MemoOutputDir.Lines.Clear;
  BrowOutputDir:=TSelectDirectoryDialog.Create(self);
  BrowOutputDir.Title:='Select the output directory';
  BrowOutputDir.Options:=[ofCreatePrompt];
  if (addedfiles.count<>0) then
    BrowOutputDir.InitialDir:=ExtractFilePath(addedfiles[addedfiles.count-1]); //open Browse dialog in last encoded input file directory

  if (BrowOutputDir.Execute) then
  begin
    outputpath:=BrowOutputDir.FileName;
    MemoOutputDir.Lines.Add(outputpath);
  end;
  BrowOutputDir.Free;
end;

procedure TForm1.BtnPauseClick(Sender: TObject);                               //Pause MoShade on next input
begin
  PauseOnNext:=True;
  BtnPause.Caption:='Pausing...';
  BtnPause.Enabled:=False;
  BtnResume.Enabled:=True;
end;

procedure TForm1.BtnResumeClick(Sender: TObject);                              //Resume MoShade after Pause on next input
begin
  PauseOnNext:=False;
  BtnResume.Enabled:=False;
  BtnPause.Enabled:=True;
  BtnPause.Caption:='Pause on next';
end;

procedure ActiveInactive(status:boolean);                                      //Control enables/disabled and visible/hiden status of GUI
var
  antistatus:boolean;
begin
  antistatus:=not status;

  Form1.BtnBrowseMoshade.Enabled:=status;
  Form1.BtnBrowseInputs.Enabled:=status;
  Form1.BtnClearInputs.Enabled:=status;
  Form1.lbledtCPU.Enabled:=status;
  Form1.lbledtSamples.Enabled:=status;
  Form1.ChkboxVerbose.Enabled:=status;
  Form1.ChkboxNaive.Enabled:=status;
  Form1.lbledtPrefix.Enabled:=status;
  Form1.lbledtSuffix.Enabled:=status;
  Form1.BtnOutputDirectory.Enabled:=status;
  Form1.lbledtBatchName.Enabled:=status;
  Form1.BtnAddBatch.Enabled:=status;
  Form1.BtnLoadBatch.Enabled:=status;
  Form1.BtnClearBatches.Enabled:=status;
  Form1.BtnRun.Enabled:=status;
  Form1.BtnLoadDefaults.Enabled:=status;
  Form1.BtnSaveDefaults.Enabled:=status;

  Form1.BtnPause.Enabled:=antistatus;
  Form1.BtnStop.Enabled:=antistatus;
  Form1.lblBatchcalc.Enabled:=antistatus;
  Form1.ProgBarInput.Enabled:=antistatus;
  Form1.lblPercInput.Enabled:=antistatus;
  Form1.lblPercCalc.Enabled:=antistatus;
  Form1.ProgBarCalc.Enabled:=antistatus;

  Form1.lblBatchcalc.Visible:=antistatus;
  Form1.ProgBarInput.Visible:=antistatus;
  Form1.lblPercInput.Visible:=antistatus;
  Form1.lblPercCalc.Visible:=antistatus;
  Form1.ProgBarCalc.Visible:=antistatus;
end;

procedure TForm1.BtnRunClick(Sender: TObject);                                 //Run MoShade
const
  Bufsize=2048;
var
  RunMosh:TProcess;
  memstream, stderrmemstream:TMemoryStream;
  batchfile, outputfile:Text;
  batchlines:TStringList;
  bytesread, n, stderrbytesread, stderrn:longint;
  batchinuse, adv:string;
  advancementarray:array [0..1] of AnsiString;
  i, j, readindex, stderrreadindex, advint:integer;
  boolverb:boolean;
begin
  batchlines:=TStringList.Create;
  ActiveInactive(False);
  Application.ProcessMessages;                                                 //Update GUI

  for i:=0 to (addedbatches.Count-1) do
  begin
    boolverb:=False;
    batchinuse:=addedbatches[i];
    AssignFile(batchfile,batchinuse);
    Reset(batchfile);
    batchlines.LoadFromFile(batchinuse);
    CloseFile(batchfile);

    lblBatchcalc.Caption:='Calculations for Batch '+IntToStr(i+1)+'/'+IntToStr(addedbatches.count);
    ProgBarInput.Max:=(batchlines.Count-4) div 2;
    ProgBarInput.Position:=0;
    Application.ProcessMessages;                                               //Update GUI

    j:=5;
    while j<=(batchlines.Count-2) do
    begin
      ProgBarCalc.Max:=100;
      ProgBarCalc.Position:=0;
      lblPercCalc.Caption:='0%';
      lblPercInput.Caption:='Input '+IntToStr((j-3) div 2)+'/'+IntToStr((batchlines.Count-4) div 2);
      ProgBarInput.Position:=ProgBarInput.Position+1;
      Application.ProcessMessages;                                             //Update GUI

      RunMosh:=TProcess.Create(nil);
      RunMosh.Executable:=batchlines[0];                                       //executable
      RunMosh.Parameters.Add(batchlines[j]);                                   //input with input path
      RunMosh.Parameters.Add(batchlines[1]);                                   //number of samples
      RunMosh.Parameters.Add(batchlines[2]);                                   //number of CPUs
      if (batchlines[3]<>'') then                                              //verbose option
      begin
        RunMosh.Parameters.Add(batchlines[3]);
        boolverb:=True;
      end
      else
        boolverb:=False;
      if (batchlines[4]<>'') then                                              //naive option
        RunMosh.Parameters.Add(batchlines[4]);
      if (boolverb=False) then
      begin
        stderrmemstream:=TMemoryStream.Create;
        stderrbytesread:=0;
        stderrreadindex:=0;
        AssignFile(outputfile,batchlines[j+1]);                                //Create outputfile -> for timestamp if verbose off; otherwise file generated only after calculation
        Rewrite(outputfile);
        CloseFile(outputfile);
      end;
      RunMosh.ShowWindow:=swoHide;
      Application.BringToFront;
      RunMosh.Options:=[poUsePipes];
      RunMosh.Execute;

      memstream:=TMemoryStream.Create;
      bytesread:=0;
      readindex:=0;

      while (RunMosh.Running) do
      begin

        if (StopMoshade=True) then                                             //Abort MoShade
        begin
          RunMosh.Terminate(0);
          RunMosh.Free;
          memstream.Free;
          if (boolverb=False) then
            stderrmemstream.Free;
          batchlines.Free;
          ActiveInactive(True);
          StopMoshade:=False;
          exit;
        end;

        Application.ProcessMessages;

        if (boolverb=True) then                                                //verbose on -> only STDout
        begin
          memstream.SetSize(bytesread + Bufsize);
          n:=RunMosh.Output.Read((memstream.Memory + bytesread)^, Bufsize);
          readindex:=readindex+1;
          Application.ProcessMessages;
          if (n>0) then
          begin
            Application.ProcessMessages;
            Inc(bytesread, n);
            memstream.SaveToFile(batchlines[j+1]);                             //Save Stdout output
            if ((readindex mod 5)=0) then                                      //do this every 5 times new bytes are read
            begin                                                              //Follow the calculation progress if verbose was chosen
              memstream.Seek(0,soFromBeginning);
              SetString(advancementarray[0],pAnsiChar(memstream.Memory),memstream.Size);
              if (AnsiContainsStr(advancementarray[0],'%')=True) then
              begin
                adv:=Trim(Copy(advancementarray[0],(RPos('%',advancementarray[0])-3),3));
                if (TryStrToInt(adv,advint)=True) then
                begin
                  lblPercCalc.Caption:=IntToStr(advint)+'%';
                  ProgBarCalc.Position:=advint;
                  Application.ProcessMessages;                                 //Update GUI
                end;
              end;
            end;
          end
          else
          begin                                                                //if nothing in stdout then wait
            Sleep(100);
            Application.ProcessMessages;                                       //Update GUI
          end;
        end;

        if (boolverb=False) then                                               //verbose off -> STDout (afterwards) & STDerr
        begin
          stderrmemstream.SetSize(stderrbytesread + Bufsize);
          stderrn:=RunMosh.Stderr.Read((stderrmemstream.Memory + stderrbytesread)^, Bufsize);
          stderrreadindex:=stderrreadindex+1;
          Application.ProcessMessages;
          if (stderrn>0) then
          begin
            Application.ProcessMessages;
            Inc(stderrbytesread,stderrn);
            //stderrmemstream.SaveToFile('stderr.txt');
            if ((stderrreadindex mod 5)=0) then                                //do this every 5 times new bytes are read
            begin
              //stderrmemstream.Seek(0,soFromBeginning);
              stderrmemstream.Position:=0;
              SetString(advancementarray[0],pAnsiChar(stderrmemstream.Memory),stderrmemstream.Size);
              adv:=Trim(Copy(advancementarray[0],RPos('Done ',advancementarray[0])-30,30)); //read 30 characters before last occurence of 'Done ' (often issues with last 'Done XX %')
              if (Pos('%',adv)<>0) then
              begin
                adv:=Trim(Copy(adv,(RPos('%',adv)-3),3));
                if (TryStrToInt(adv,advint)=True) then
                begin
                  lblPercCalc.Caption:=IntToStr(advint)+'%';
                  ProgBarCalc.Position:=advint;
                  Application.ProcessMessages;                                 //Update GUI
                end;
              end;
              stderrmemstream.Clear;                                           //clear every 5 times; no need to keep everything in memory
              stderrbytesread:=0;
            end;
          end
          else
          begin
            Sleep(100);
            Application.ProcessMessages;                                       //Update GUI
          end;
        end;
      end;

      repeat                                                                   //read last output after finishing
        memstream.SetSize(bytesread + Bufsize);
        n:=RunMosh.Output.Read((memstream.Memory + bytesread)^, Bufsize);
        if (n>0) then
        begin
          Inc(bytesread, n);
        end;
      until (n<=0);

      memstream.SetSize(bytesread);
      lblPercCalc.Caption:='100%';
      ProgBarCalc.Position:=100;
      Application.ProcessMessages;                                             //Update GUI
      memstream.SaveToFile(batchlines[j+1]);                                   //output path & file
      memstream.Free;

      if (boolverb=False) then
      begin
        stderrmemstream.Free;
      end;

      RunMosh.Free;

      j:=j+2;

      if (PauseOnNext=True) then                                               //Pause MoShade
      begin
        BtnPause.Caption:='Paused';
        while (PauseOnNext=True) do
        begin
          Sleep(100);
          Application.ProcessMessages;
        end;
      end;

      {
      {$IFDEF LINUX}                                                           //Pure Linux syntax without feedback
      fpSystem(batchlines[j]);
      {$ENDIF}
      Application.ProcessMessages;                                             //Refresh the interface
      }
    end;
    batchlines.Clear;
  end;
  batchlines.Free;
  ActiveInactive(True);
end;

procedure TForm1.BtnSaveDefaultsClick(Sender: TObject);                        //Save general default parameters
var
  Def_param:text;
  dir, version:string;
  FileVerInfo: TFileVersionInfo;
begin
  dir:=ProgramDirectory;
  SetCurrentDir(dir);
  AssignFile(Def_param,'parameters.par');
  Rewrite(Def_param);

  FileVerInfo:=TFileVersionInfo.Create(nil);
  try
    FileVerInfo.ReadFileInfo;
    {writeln('File description: ',FileVerInfo.VersionStrings.Values['FileDescription']);
    writeln('Internal name: ',FileVerInfo.VersionStrings.Values['InternalName']);
    writeln('Legal copyright: ',FileVerInfo.VersionStrings.Values['LegalCopyright']);
    writeln('Original filename: ',FileVerInfo.VersionStrings.Values['OriginalFilename']);
    writeln('Product name: ',FileVerInfo.VersionStrings.Values['ProductName']);
    writeln('File version: ',FileVerInfo.VersionStrings.Values['ProductVersion']);
    writeln('Company name: ',FileVerInfo.VersionStrings.Values['CompanyName']);}
    version:='v.' + FileVerInfo.VersionStrings.Values['FileVersion'];
  finally
    FileVerInfo.Free;
  end;

  writeln(Def_param,'List of default parameters - MoShade Automator '+version);//3 lines of comments
  writeln(Def_param,DateTimeToStr(Now));
  writeln(Def_param);
  writeln(Def_param,'MoShade executable path:'+chr(9)+moshadepath);
  writeln(Def_param,'Number of CPU cores:'+chr(9)+lbledtCPU.Text);
  writeln(Def_param,'Number of samples:'+chr(9)+lbledtSamples.Text);
  writeln(Def_param,'Option verbose:'+chr(9)+BoolToStr(ChkboxVerbose.Checked));
  writeln(Def_param,'Option naive:'+chr(9)+BoolToStr(ChkboxNaive.Checked));
  writeln(Def_param,'Prefix:'+chr(9)+lbledtPrefix.Text);
  writeln(Def_param,'Suffix:'+chr(9)+lbledtSuffix.Text);
  writeln(Def_param,'Ouput directory path:'+chr(9)+outputpath);

  CloseFile(Def_param);
end;

procedure TForm1.BtnStopClick(Sender: TObject);                                //Stop MoShade entierly
begin
  StopMoshade:=True;
end;

procedure TForm1.BtnBrowseInputsClick(Sender: TObject);                        //Add input files, even from different folders
var
  i:integer;
  Browinputs:TOpenDialog;
begin
  Browinputs:=TOpenDialog.Create(self);
  Browinputs.Filter:='STL or GM files (.stl or .gm)|*.stl;*.gm';               //restrict to only open .stl and .gm files
  Browinputs.Title:='Select the input files';
  Browinputs.Options:=[ofAllowMultiSelect];
  if (addedfiles.count<>0) then                                                //open Browse dialog in last encoded directory
    Browinputs.InitialDir:=ExtractFilePath(addedfiles[addedfiles.count-1]);

  if (Browinputs.Execute) then
  begin
    for i:=0 to (Browinputs.Files.Count-1) do
    begin
      addedfiles.Add(Browinputs.Files.Strings[i]);
      MemoInputs.Lines.Add('File#'+IntToStr(addedfiles.count));
      MemoInputs.Lines.Add(addedfiles[i]);
    end;
  end;
  Browinputs.Free;
  lblAddedFiles.Caption:='Added Files: '+IntToStr(addedfiles.count);
end;

procedure TForm1.BtnAddBatchClick(Sender: TObject);                            //Add newly-created batch to the batch (to-do) list
var
  moshadeinputlist1, moshadeinputlist2:TStringList;
  pref, suf, verb1, verb2, naiv1, naiv2, resultname:string;
  i, nproc, nsamp, delimiterposition, extractlength:integer;
  batchfile:text;
  batch1, batch2, pathdelimiter:string;
begin
  //Securities for complete parameter encodings
  if (lbledtCPU.Text='') then
    lbledtCPU.Text:=inputbox('Missing number of CPU cores to be used','Please specify the number of CPU cores','');
  if (lbledtBatchName.Text='') then
    lbledtBatchName.Text:=inputbox('Missing batch filename','Please insert the name name','');
  if (lbledtSamples.Text='') then
    lbledtSamples.Text:=inputbox('Missing number of samples','Please specify the number of samples to be calculated for each input','');
  if (moshadepath='') then
  begin
    ShowMessage('No moshade executable was loaded.'+sLineBreak+'Please select the moshade executable file.');
    //Form1.BtnBrowseMoshadeClick(Sender);
    exit;
  end;
  if (addedfiles.count=0) then
  begin
    ShowMessage('No input files were selected.'+sLineBreak+'Please select at least one file.');
    //Form1.BtnBrowseInputsClick(Sender);
    exit;
  end;
  if (outputpath='') then
  begin
    ShowMessage('No output directory was selected.'+sLineBreak+'Please select a directory.');
    //Form1.BtnOutputDirectoryClick(Sender);
    exit;
  end;

  //Get the path delimiter
  delimiterposition:=Length(moshadepath)-Length(ExtractFileName(moshadepath));
  pathdelimiter:=Copy(moshadepath,delimiterposition,1);
  //ShowMessage('Delimiterposition= '+IntToStr(delimiterposition)+sLineBreak+'Pathdelimiter= '+pathdelimiter);

  moshadeinputlist1:=TStringlist.Create;
  moshadeinputlist2:=TStringlist.Create;

  moshadeinputlist2.Add(moshadepath);                                          //1st line .exe name

  nsamp:=StrToInt(lbledtSamples.Text);
  moshadeinputlist2.Add(IntToStr(nsamp));                                      //2nd line number of samples

  nproc:=StrToInt(lbledtCPU.Text);
  moshadeinputlist2.Add('nproc '+IntToStr(nproc));                             //3rd line number of CPUs

  if (ChkboxVerbose.Checked=True) then
  begin
    verb1:=' verbose';
    verb2:='verbose';
  end
  else
  begin
    verb1:='';
    verb2:=verb1;
  end;
  moshadeinputlist2.Add(verb2);                                                //4th line verbose option: True or False

  if (ChkboxNaive.Checked=True) then
  begin
    naiv1:=' naive';
    naiv2:='naive';
  end
  else
  begin
    naiv1:='';
    naiv2:=naiv1;
  end;
  moshadeinputlist2.Add(naiv2);                                                //5th line naive option: True or False

  if (lbledtPrefix.Text<>'') then
    pref:=lbledtPrefix.Text+'_'
  else
    pref:='';
  if (lbledtSuffix.Text<>'') then
    suf:='_'+lbledtSuffix.Text
  else
    suf:='';


  for i:=0 to (addedfiles.count-1) do
  begin
    extractlength:=Length(ExtractFileName(addedfiles[i]))-Length(ExtractFileExt(addedfiles[i]));
    resultname:=pref+Copy(ExtractFileName(addedfiles[i]),0,extractlength)+suf+'.txt';
    moshadeinputlist1.Add(moshadepath+' '+addedfiles[i]+' '+IntToStr(nsamp)+' '+'nproc '+IntToStr(nproc)+verb1+naiv1+' > '+outputpath+pathdelimiter+resultname);
    moshadeinputlist2.Add(addedfiles[i]);                                     //first input line=6; line (n); next line output file
    moshadeinputlist2.Add(outputpath+pathdelimiter+resultname);               //first input line=7; line (n+1) output file
  end;

  //write inputs into batch file; save batchfile into result output directory
  //this input file can be launched as a batch file from terminal
  SetCurrentDir(outputpath);
  batch1:=lbledtBatchName.Text+'.txt';
  if FIleExists(batch1) then
  begin
    ShowMessage('Filename already exists.'+sLineBreak+'Please rename the batch file.');
    moshadeinputlist1.Free;
    moshadeinputlist2.Free;
    exit;
  end;
  //this input is specially encoded for MoShade Automator
  SetCurrentDir(outputpath);
  batch2:=lbledtBatchName.Text+'_automator.txt';
  if FIleExists(batch2) then
  begin
    ShowMessage('Filename already exists.'+sLineBreak+'Please rename the batch file.');
    moshadeinputlist1.Free;
    moshadeinputlist2.Free;
    exit;
  end;

  AssignFile(batchfile,batch1);
  Rewrite(batchfile);
  for i:=0 to (moshadeinputlist1.count-1) do
  begin
    writeln(batchfile,moshadeinputlist1[i]);
  end;
  CloseFile(batchfile);

  AssignFile(batchfile,batch2);
  Rewrite(batchfile);
  for i:=0 to (moshadeinputlist2.count-1) do
  begin
    writeln(batchfile,moshadeinputlist2[i]);
  end;
  CloseFile(batchfile);

  addedbatches.Add(outputpath+pathdelimiter+batch2);
  lblAddedBatches.Caption:='Added batches: '+IntToStr(addedbatches.count);
  MemoBatches.Lines.Add('Batch#'+IntToStr(addedbatches.count));
  MemoBatches.Lines.Add(outputpath+pathdelimiter+batch2);

  moshadeinputlist1.Free;
  moshadeinputlist2.Free;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  addedfiles.Free;
  addedbatches.Free;
end;

end.

