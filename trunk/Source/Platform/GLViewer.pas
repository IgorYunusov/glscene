//
// This unit is part of the GLScene Project, http://glscene.org
//
{: GLViewer<p>

   Platform independant viewer.<p>

    History:
      <li>12/09/07 - DaStr - Fixed SetupVSync() function (Bugtracker ID = 1786279)
                             Made cross-platform code easier to read
      <li>12/07/07 - DaStr - Added SetupVSync
      <li>30/03/07 - DaStr - Another update after the previous fix (removed class())
                             Added TVSyncMode type and constants.
      <li>24/03/07 - DaStr - Update for Windows after the previous fix
      <li>21/03/07 - DaStr - Improved Cross-Platform compatibility
                             (thanks Burkhard Carstens) (Bugtracker ID = 1684432)
      <li>17/03/07 - DaStr - Dropped Kylix support in favor of FPC (BugTrackerID=1681585)
      <li>24/01/02 -  EG   - Initial version
}

unit GLViewer;

interface

{$I GLScene.inc}

uses
  OpenGL1x,
  {$IFDEF GLS_DELPHI_OR_CPPB} GLWin32Viewer; {$ENDIF}
  {$IFDEF FPC}                GLLCLViewer;   {$ENDIF}
  {$IFDEF KYLIX}              GLLinuxViewer; {$ENDIF}

type
{$IFDEF FPC}
  TGLSceneViewer = GLLCLViewer.TGLSceneViewer;
  TVSyncMode = GLLCLViewer.TVSyncMode;
{$ENDIF FPC}

{$IFDEF KYLIX}
  TGLSceneViewer = GLLinuxViewer.TGLLinuxSceneViewer;
  TVSyncMode = GLLinuxViewer.TVSyncMode;
{$ENDIF KYLIX}

{$IFDEF GLS_DELPHI_OR_CPPB}
    TGLSceneViewer = GLWin32Viewer.TGLSceneViewer;
    TVSyncMode = GLWin32Viewer.TVSyncMode;
{$ENDIF GLS_DELPHI_OR_CPPB}

const
{$IFDEF FPC}
  // TVSyncMode.
  vsmSync = GLLCLViewer.vsmSync;
  vsmNoSync = GLLCLViewer.vsmNoSync;
{$ENDIF FPC}

{$IFDEF KYLIX}
  // TVSyncMode.
  vsmSync = GLLinuxViewer.vsmSync;
  vsmNoSync = GLLinuxViewer.vsmNoSync;
{$ENDIF KYLIX}

{$IFDEF GLS_DELPHI_OR_CPPB}
  // TVSyncMode.
  vsmSync = GLWin32Viewer.vsmSync;
  vsmNoSync = GLWin32Viewer.vsmNoSync;
{$ENDIF GLS_DELPHI_OR_CPPB}


procedure SetupVSync(const AVSyncMode : TVSyncMode);

implementation

procedure SetupVSync(const AVSyncMode : TVSyncMode);
{$IFNDEF KYLIX}
var
  I: Integer;
begin
  if WGL_EXT_swap_control then
  begin
    I := wglGetSwapIntervalEXT;
    case AVSyncMode of
      vsmSync  : if I <> 1 then wglSwapIntervalEXT(1);
      vsmNoSync: if I <> 0 then wglSwapIntervalEXT(0);
    else
       Assert(False);
    end;
  end;
end;
{$ELSE}
begin
   Assert(False, 'Not implemented for Kylix!')
end;
{$ENDIF}

end.
