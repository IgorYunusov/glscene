//
// GLScene on Vulkan, http://glscene.sourceforge.net 
//
{
  FMOD based sound-manager (http://www.fmod.org/, free for freeware). 

  Unsupported feature(s) : 
       sound source velocity
       looping (sounds are played either once or forever)
       sound cones
    
 
}
unit GLS.SMFMOD;

interface

{$I GLScene.inc}

uses
  System.Classes, System.SysUtils,
  //GLS
  FMod, FmodTypes, FmodPresets,
  GLS.Sound, GLS.Scene, GLS.VectorGeometry;

type

	// TVKSMFMOD
	//
	TVKSMFMOD = class (TVKSoundManager)
	   private
	      { Private Declarations }
         FActivated : Boolean;
         FEAXCapable : Boolean; // not persistent

	   protected
	      { Protected Declarations }
	      function DoActivate : Boolean; override;
	      procedure DoDeActivate; override;
         procedure NotifyMasterVolumeChange; override;
         procedure Notify3DFactorsChanged; override;
         procedure NotifyEnvironmentChanged; override;

         procedure KillSource(aSource : TVKBaseSoundSource); override;
         procedure UpdateSource(aSource : TVKBaseSoundSource); override;
         procedure MuteSource(aSource : TVKBaseSoundSource; muted : Boolean); override;
         procedure PauseSource(aSource : TVKBaseSoundSource; paused : Boolean); override;

         function GetDefaultFrequency(aSource : TVKBaseSoundSource) : Integer;

      public
	      { Public Declarations }
	      constructor Create(AOwner : TComponent); override;
	      destructor Destroy; override;

         procedure UpdateSources; override;

         function CPUUsagePercent : Single; override;
         function EAXSupported : Boolean; override;

	   published
	      { Published Declarations }
         property MaxChannels default 32;
	end;

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
implementation
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------


type
   TFMODInfo =  record
      channel : Integer;
      pfs : PFSoundSample;
   end;
   PFMODInfo = ^TFMODInfo;

// VectorToFMODVector
//
procedure VectorToFMODVector(const aVector : TVector; var aFMODVector : TFSoundVector);
begin
  aFMODVector.x:=aVector.X;
  aFMODVector.y:=aVector.Y;
  aFMODVector.z:=-aVector.Z;
end;

// ------------------
// ------------------ TVKSMFMOD ------------------
// ------------------

// Create
//
constructor TVKSMFMOD.Create(AOwner : TComponent);
begin
	inherited Create(AOwner);
   MaxChannels:=32;
end;

// Destroy
//
destructor TVKSMFMOD.Destroy;
begin
	inherited Destroy;
end;

// DoActivate
//
function TVKSMFMOD.DoActivate : Boolean;
var
   cap : Cardinal;
begin
   FMOD_Load(nil);
   {$IFDEF MSWindows}
   if not FSOUND_SetOutput(FSOUND_OUTPUT_DSOUND) then begin
      Result:=False;
      Exit;
   end;
  {$ENDIF}
  {$IFDEF LINUX}
  if not FSOUND_SetOutput(FSOUND_OUTPUT_ALSA) then begin
     Result:=False;
     Exit;
  end;
  {$ENDIF}
   if not FSOUND_SetDriver(0) then begin
      Result:=False;
      Exit;
   end;
   cap:=0;
   if FSOUND_GetDriverCaps(0, cap) then
      FEAXCapable:=((cap and (FSOUND_CAPS_EAX2 or FSOUND_CAPS_EAX3))>0)
   else Assert(False, 'Failed to retrieve driver Caps.');
   if not FSOUND_Init(OutputFrequency, MaxChannels, 0) then
      Assert(False, 'FSOUND_Init failed.');
   FActivated:=True;
   NotifyMasterVolumeChange;
   Notify3DFactorsChanged;
   if Environment<>seDefault then
      NotifyEnvironmentChanged;
   Result:=True;
end;

// DoDeActivate
//
procedure TVKSMFMOD.DoDeActivate;
begin
   FSOUND_StopSound(FSOUND_ALL);
   FSOUND_Close;
   FMOD_Unload;
   FEAXCapable:=False;
end;

// NotifyMasterVolumeChange
//
procedure TVKSMFMOD.NotifyMasterVolumeChange;
begin
   if FActivated then
      FSOUND_SetSFXMasterVolume(Round(MasterVolume*255));
end;

// Notify3DFactorsChanged
//
procedure TVKSMFMOD.Notify3DFactorsChanged;
begin
   if FActivated then begin
      FSOUND_3D_SetDistanceFactor(DistanceFactor);
      FSOUND_3D_SetRolloffFactor(RollOffFactor);
      FSOUND_3D_SetDopplerFactor(DopplerFactor);
   end;
end;

// NotifyEnvironmentChanged
//
procedure TVKSMFMOD.NotifyEnvironmentChanged;
var
   SoundRevProps:TFSoundReverbProperties;
begin
   if FActivated and EAXSupported then begin
      case Environment of
         seDefault :          SoundRevProps := FSOUND_PRESET_GENERIC;
         sePaddedCell :       SoundRevProps := FSOUND_PRESET_PADDEDCELL;
         seRoom :             SoundRevProps := FSOUND_PRESET_ROOM;
         seBathroom :         SoundRevProps := FSOUND_PRESET_BATHROOM;
         seLivingRoom :       SoundRevProps := FSOUND_PRESET_LIVINGROOM;
         seStoneroom :        SoundRevProps := FSOUND_PRESET_STONEROOM;
         seAuditorium :       SoundRevProps := FSOUND_PRESET_AUDITORIUM;
         seConcertHall :      SoundRevProps := FSOUND_PRESET_CONCERTHALL;
         seCave :             SoundRevProps := FSOUND_PRESET_CAVE;
         seArena :            SoundRevProps := FSOUND_PRESET_ARENA;
         seHangar :           SoundRevProps := FSOUND_PRESET_HANGAR;
         seCarpetedHallway :  SoundRevProps := FSOUND_PRESET_CARPETTEDHALLWAY;
         seHallway :          SoundRevProps := FSOUND_PRESET_HALLWAY;
         seStoneCorridor :    SoundRevProps := FSOUND_PRESET_STONECORRIDOR;
         seAlley :            SoundRevProps := FSOUND_PRESET_ALLEY;
         seForest :           SoundRevProps := FSOUND_PRESET_FOREST;
         seCity :             SoundRevProps := FSOUND_PRESET_CITY;
         seMountains :        SoundRevProps := FSOUND_PRESET_MOUNTAINS;
         seQuarry :           SoundRevProps := FSOUND_PRESET_QUARRY;
         sePlain :            SoundRevProps := FSOUND_PRESET_PLAIN;
         seParkingLot :       SoundRevProps := FSOUND_PRESET_PARKINGLOT;
         seSewerPipe :        SoundRevProps := FSOUND_PRESET_SEWERPIPE;
         seUnderWater :       SoundRevProps := FSOUND_PRESET_UNDERWATER;
         seDrugged :          SoundRevProps := FSOUND_PRESET_DRUGGED;
         seDizzy :            SoundRevProps := FSOUND_PRESET_DIZZY;
         sePsychotic :        SoundRevProps := FSOUND_PRESET_PSYCHOTIC;
      else
         Assert(False);
      end;
      FSOUND_Reverb_SetProperties(SoundRevProps);
   end;
end;

// KillSource
//
procedure TVKSMFMOD.KillSource(aSource : TVKBaseSoundSource);
var
   p : PFMODInfo;
begin
   if aSource.ManagerTag<>0 then begin
      p:=PFMODInfo(aSource.ManagerTag);
      aSource.ManagerTag:=0;
      if p.channel<>-1 then
         if not FSOUND_StopSound(p.channel) then
            Assert(False, IntToStr(Integer(p)));
      FSOUND_Sample_Free(p.pfs);
      FreeMem(p);
   end;
end;

// UpdateSource
//
procedure TVKSMFMOD.UpdateSource(aSource : TVKBaseSoundSource);
var
   p : PFMODInfo;
   objPos, objVel : TVector;
   position, velocity : TFSoundVector;
begin
   if (sscSample in aSource.Changes) then
   begin
     KillSource(aSource);
   end;

   if (aSource.Sample=nil) or (aSource.Sample.Data=nil) or
      (aSource.Sample.Data.WAVDataSize=0) then Exit;
   if aSource.ManagerTag<>0 then begin
      p:=PFMODInfo(aSource.ManagerTag);
      if not FSOUND_IsPlaying(p.channel) then begin
         p.channel:=-1;
         aSource.Free;
         Exit;
      end;
   end else begin
      p:=AllocMem(SizeOf(TFMODInfo));
      p.channel:=-1;
      p.pfs:=FSOUND_Sample_Load(FSOUND_FREE, aSource.Sample.Data.WAVData,
                                FSOUND_HW3D+FSOUND_LOOP_OFF+FSOUND_LOADMEMORY,
                                0, aSource.Sample.Data.WAVDataSize);

      if aSource.NbLoops>1 then
         FSOUND_Sample_SetMode(p.pfs, FSOUND_LOOP_NORMAL);
      FSOUND_Sample_SetMinMaxDistance(p.pfs, aSource.MinDistance, aSource.MaxDistance);
      aSource.ManagerTag:=Integer(p);
   end;
   if aSource.Origin<>nil then begin
      objPos:=aSource.Origin.AbsolutePosition;
      objVel:=NullHmgVector;
   end else begin
      objPos:=NullHmgPoint;
      objVel:=NullHmgVector;
   end;
   VectorToFMODVector(objPos, position);
   VectorToFMODVector(objVel, velocity);
   if p.channel=-1 then
      p.channel:=FSOUND_PlaySound(FSOUND_FREE, p.pfs);
   if p.channel<>-1 then begin
      FSOUND_3D_SetAttributes(p.channel, @position, @velocity);
      FSOUND_SetVolume(p.channel, Round(aSource.Volume*255));
      FSOUND_SetMute(p.channel, aSource.Mute);
      FSOUND_SetPaused(p.channel, aSource.Pause);
      FSOUND_SetPriority(p.channel, aSource.Priority);
      if aSource.Frequency>0 then
         FSOUND_SetFrequency(p.channel, aSource.Frequency);
   end else aSource.Free;

   inherited UpdateSource(aSource);
end;

// MuteSource
//
procedure TVKSMFMOD.MuteSource(aSource : TVKBaseSoundSource; muted : Boolean);
var
   p : PFMODInfo;
begin
   if aSource.ManagerTag<>0 then begin
      p:=PFMODInfo(aSource.ManagerTag);
      FSOUND_SetMute(p.channel, muted);
   end;
end;

// PauseSource
//
procedure TVKSMFMOD.PauseSource(aSource : TVKBaseSoundSource; paused : Boolean);
var
   p : PFMODInfo;
begin
   if aSource.ManagerTag<>0 then begin
      p:=PFMODInfo(aSource.ManagerTag);
      FSOUND_SetPaused(p.channel, paused);
   end;
end;

// UpdateSources
//
procedure TVKSMFMOD.UpdateSources;
var
   objPos, objVel, objDir, objUp : TVector;
   position, velocity, fwd, top : TFSoundVector;
begin
   // update listener
   ListenerCoordinates(objPos, objVel, objDir, objUp);
   VectorToFMODVector(objPos, position);
   VectorToFMODVector(objVel, velocity);
   VectorToFMODVector(objDir, fwd);
   VectorToFMODVector(objUp, top);
   FSOUND_3D_Listener_SetAttributes(@position, @velocity,
                                    fwd.x, fwd.y, fwd.z,
                                    top.x, top.y, top.z);
   // update sources
   inherited;
   FSOUND_Update;
end;

// CPUUsagePercent
//
function TVKSMFMOD.CPUUsagePercent : Single;
begin
   Result:=FSOUND_GetCPUUsage;
end;

// EAXSupported
//
function TVKSMFMOD.EAXSupported : Boolean;
begin
   Result:=FEAXCapable;
end;

// GetDefaultFrequency
//
function TVKSMFMOD.GetDefaultFrequency(aSource : TVKBaseSoundSource): integer;
var
   p : PFMODInfo;
   dfreq, dVol, dPan, dPri : Integer;
begin
   try
      p:=PFMODInfo(aSource.ManagerTag);
      FSOUND_Sample_GetDefaults(p.pfs, dFreq, dVol, dPan, dPri);
      Result:=dFreq;
   except
      Result:=-1;
   end;
end;

end.

