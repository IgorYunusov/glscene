//
// GLScene on Vulkan, http://glscene.sourceforge.net 
//
{
  Register TVKXCollection property editor 
 
}
unit RegisterXCollection;

interface

{$I GLScene.inc}

uses
  System.Classes, System.TypInfo,

  //in FMX DesignEditors and DesignIntf not exist

  GLS.XCollection;

type

  TPropertyAttribute = (paValueList, paSubProperties, paDialog, paMultiSelect,
    paAutoUpdate, paSortList, paReadOnly, paRevertable, paFullWidthName,
    paVolatileSubProperties, paVCL, paNotNestable, paDisplayReadOnly,
    paCustomDropDown, paValueEditable);

  TPropertyAttributes = set of TPropertyAttribute;

  TClassProperty = class  //class(TPropertyEditor)
  public
    function GetAttributes: TPropertyAttributes; //override;  <- not found in base class
    procedure GetProperties(Proc: TGetChildProc);
      //in VCL -> (Proc: TGetPropProc) //override; <- not found in base class
    function GetValue: string; //override;  <- not found in base class
  end;

	// TVKXCollectionProperty
	//
	TVKXCollectionProperty = class(TClassProperty)
		public
      function GetAttributes: TPropertyAttributes; //override;  <- not found in base class
			procedure Edit; //override;  <- not found in base class

	end;


function GetOrdValueAt(Index: Integer): Longint;
function GetOrdValue: Longint;
procedure Register;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses
  FXCollectionEditor;

function GetOrdValueAt(Index: Integer): Longint;
var
  FPropList: PInstPropList;
begin
  with FPropList^[Index] do Result := GetOrdProp(Instance, PropInfo);
end;

function GetOrdValue: Longint;
begin
  Result := GetOrdValueAt(0);
end;


procedure Register;
begin
  { TODO : E2003 Undeclared identifier: 'RegisterPropertyEditor' }
  (*
  RegisterPropertyEditor(TypeInfo(TVKXCollection), nil, '', TVKXCollectionProperty);
  *)
end;

//----------------- TVKXCollectionProperty ------------------------------------

// GetAttributes
//
function TVKXCollectionProperty.GetAttributes: TPropertyAttributes;
begin
  Result:=[paDialog];
end;

// Edit
//
procedure TVKXCollectionProperty.Edit;
begin
   with XCollectionEditor do
   begin
      { TODO : E2003 Undeclared identifier: 'Designer' }
      (*SetXCollection(TVKXCollection(GetOrdValue), Self.Designer);*)
      Show;
   end;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
{ TClassProperty }

function TClassProperty.GetAttributes: TPropertyAttributes;
begin

end;

procedure TClassProperty.GetProperties(Proc: TGetChildProc);
begin
  inherited;

end;

function TClassProperty.GetValue: string;
begin

end;

initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

	// class registrations
   
end.
