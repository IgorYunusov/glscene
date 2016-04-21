//
// GLScene on Vulkan, http://glscene.sourceforge.net 
//
{
  Basic sound manager based on WinMM  
}

unit GLS.SMWaveOut;

interface

{$I GLScene.inc}
{$IFDEF UNIX}{$Message Error 'Unit not supported'}{$ENDIF}

uses 
  System.Classes, System.SysUtils,
  {$IFDEF MSWINDOWS}Winapi.MMSystem,{$ENDIF} 
  GLS.Sound, 
  GLS.SoundFileObjects;

type

	// TVKSMWaveOut
	//
   { Basic sound manager based on WinMM <i>waveOut</i> function. 
      This manager has NO 3D miximing capacity, this is merely a default manager
      that should work on any windows based system, and help showcasing/testing
      basic GLSS core functionality. 
      Apart from 3D, mute, pause, priority and volume are ignored too, and only
      sampling conversions supported by the windows ACM driver are supported
      (ie. no 4bits samples playback etc.). }
	TVKSMWaveOut = class (TVKSoundManager)
	   private
	      { Private Declarations }

	   protected
	      { Protected Declarations }
	      function DoActivate : Boolean; override;
	      procedure DoDeActivate; override;

         procedure KillSource(aSource : TVKBaseSoundSource); override;

      public
	      { Public Declarations }
	      constructor Create(AOwner : TComponent); override;
	      destructor Destroy; override;

        procedure UpdateSources; override;
      published
	      { Published Declarations }
         property MaxChannels default 4;
	end;

procedure PlayOnWaveOut(pcmData : Pointer; lengthInBytes : Integer;
                        sampling : TVKSoundSampling); overload;
function PlayOnWaveOut(pcmData : Pointer; lengthInBytes : Integer;
                        waveFormat : TWaveFormatEx) : HWaveOut; overload;

//-------------------------------------------------------------
//-------------------------------------------------------------
//-------------------------------------------------------------
implementation
//-------------------------------------------------------------
//-------------------------------------------------------------
//-------------------------------------------------------------

type
  TSoundState = (ssPlaying, ssFinished);

  TWaveOutPlayingRec = record
    CurrentState: TSoundState;
    WaveOutDevice: hwaveout;
    WaveHeader: wavehdr;
  end;
  PWaveOutPlayingRec = ^TWaveOutPlayingRec;

procedure _waveOutCallBack2(hwo : HWAVEOUT; uMsg : Cardinal;
                           dwInstance, dwParam1, dwParam2 : Integer); stdcall;
begin
   if uMsg=WOM_DONE then
      waveOutClose(hwo);
end;

// PlayOnWaveOut (waveformat)
//
function PlayOnWaveOut(pcmData : Pointer; lengthInBytes : Integer;
                       waveFormat : TWaveFormatEx) : HWaveOut;
var
   hwo : hwaveout;
   wh : wavehdr;
   mmres : MMRESULT;
begin
   mmres:=waveOutOpen(@hwo, WAVE_MAPPER, @waveFormat, Cardinal(@_waveOutCallBack2),
                      0, CALLBACK_FUNCTION);
   Assert(mmres=MMSYSERR_NOERROR, IntToStr(mmres));
   wh.dwBufferLength:=lengthInBytes;
   wh.lpData:=pcmData;
   wh.dwFlags:=0;
   wh.dwLoops:=1;
   wh.lpNext:=nil;
   mmres:=waveOutPrepareHeader(hwo, @wh, SizeOf(wavehdr));
   Assert(mmres=MMSYSERR_NOERROR, IntToStr(mmres));
   mmres:=waveOutWrite(hwo, @wh, SizeOf(wavehdr));
   Assert(mmres=MMSYSERR_NOERROR, IntToStr(mmres));
   Result:=hwo;
end;

// PlayOnWaveOut (sampling)
//
procedure PlayOnWaveOut(pcmData : Pointer; lengthInBytes : Integer;
                        sampling : TVKSoundSampling);
var
   wfx : TWaveFormatEx;
begin
   wfx:=sampling.WaveFormat;
   PlayOnWaveOut(pcmData, lengthInBytes, wfx);
end;

// ------------------
// ------------------ TVKSMWaveOut ------------------
// ------------------

// Create
//
constructor TVKSMWaveOut.Create(AOwner : TComponent);
begin
	inherited Create(AOwner);
   MaxChannels:=4;
end;

// Destroy
//
destructor TVKSMWaveOut.Destroy;
begin
	inherited Destroy;
end;

// DoActivate
//
function TVKSMWaveOut.DoActivate : Boolean;
begin
   Result:=True;
end;

// DoDeActivate
//
procedure TVKSMWaveOut.DoDeActivate;
var
   i : Integer;
begin
   for i:=Sources.Count-1 downto 0 do
      KillSource(Sources[i]);
end;

// KillSource
//
procedure TVKSMWaveOut.KillSource(aSource : TVKBaseSoundSource);
var
  pRec: PWaveOutPlayingRec;
begin
   if aSource.ManagerTag<>0 then begin
      pRec := PWaveOutPlayingRec(aSource.ManagerTag);
      if pRec.CurrentState=ssPlaying then
        waveOutReset(pRec.WaveOutDevice);
      waveOutUnprepareHeader(pRec.WaveOutDevice, @pRec.WaveHeader, sizeof(wavehdr));
      waveOutClose(pRec.WaveOutDevice);
      Dispose(pRec);
      aSource.ManagerTag:=0;
   end;
end;

// Note: This callback function is called from another thread, from MSDN docs:
// "Applications should not call any system-defined functions from inside a
// callback function, except for EnterCriticalSection, LeaveCriticalSection,
// midiOutLongMsg, midiOutShortMsg, OutputDebugString, PostMessage,
// PostThreadMessage, SetEvent, timeGetSystemTime, timeGetTime, timeKillEvent,
// and timeSetEvent. Calling other wave functions will cause deadlock."
procedure _waveOutCallBack(hwo : HWAVEOUT; uMsg : Cardinal;
                           dwInstance, dwParam1, dwParam2 : Integer); stdcall;
begin
   if uMsg=WOM_DONE then begin
      PWaveOutPlayingRec(TVKSoundSource(dwInstance).ManagerTag).CurrentState:=ssFinished;
   end;
end;

// UpdateSource
//
procedure TVKSMWaveOut.UpdateSources;
var
   i, n : Integer;
   wfx : TWaveFormatEx;
   smp : TVKSoundSample;
   wh : wavehdr;
   mmres : MMRESULT;
   hwo : hwaveout;
   pRec: PWaveOutPlayingRec;
begin
   // count nb of playing sources and delete done ones
   n:=0;
   for i:=Sources.Count-1 downto 0 do
     if Sources[i].ManagerTag<>0 then
       if PWaveOutPlayingRec(Sources[i].ManagerTag).currentState=ssPlaying then
         Inc(n)
       else
         Sources.Delete(i);
	// start sources if some capacity remains, and forget the others
   for i:=Sources.Count-1 downto 0 do if Sources[i].ManagerTag=0 then begin
      if n<MaxChannels then begin
         smp:=Sources[i].Sample;
         if Assigned(smp) and (smp.Data<>nil) then begin
            wfx:=smp.Data.Sampling.WaveFormat;
            mmres:=waveOutOpen(@hwo, WAVE_MAPPER, @wfx,
                               Cardinal(@_waveOutCallBack), Integer(Sources[i]),
                               CALLBACK_FUNCTION);
            Assert(mmres=MMSYSERR_NOERROR, IntToStr(mmres));

            FillChar(wh,sizeof(wh),0);
            wh.dwBufferLength:=smp.LengthInBytes;
            wh.lpData:=smp.Data.PCMData;
            wh.dwLoops:=Sources[i].NbLoops;
            if wh.dwLoops>1 then
               wh.dwFlags:=WHDR_BEGINLOOP+WHDR_ENDLOOP
            else wh.dwFlags:=0;
            wh.lpNext:=nil;

            new(pRec);
            pRec.waveoutdevice:=hwo;
            pRec.waveheader:=wh;
            pRec.CurrentState:=ssPlaying;

            mmres:=waveOutPrepareHeader(hwo, @pRec.waveheader, SizeOf(wavehdr));
            Assert(mmres=MMSYSERR_NOERROR, IntToStr(mmres));
            Sources[i].ManagerTag:=Integer(prec);
            mmres:=waveOutWrite(hwo, @pRec.waveheader, SizeOf(wavehdr));
            Assert(mmres=MMSYSERR_NOERROR, IntToStr(mmres));

            Inc(n);
			end else
				Sources.Delete(i);
		end else
			Sources.Delete(i);
	end;
end;

initialization

  RegisterClasses([TVKSMWaveOut]);

end.
