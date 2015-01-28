//
// This unit is part of the GLScene Project, http://glscene.org
//
{
  GLS.ODERegister - Design time registration code for the ODE Manager

  History:

    18/06/03 - SG - Creation.
}
unit GLS.ODERegister;

interface

uses
  System.Classes, GLS.ODEManager;

procedure Register;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

// Register
//
procedure Register;
begin
  RegisterClasses([TGLODEManager, TGLODEJointList, TODEJoints, TODEElements]);
  RegisterComponents('GLScene',[TGLODEManager,TGLODEJointList]);
end;

end.