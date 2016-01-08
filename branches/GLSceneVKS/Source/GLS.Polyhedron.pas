//
// GLScene on Vulkan, http://glscene.sourceforge.net 
//
{
   Standard polyhedrons
   
}
unit GLS.Polyhedron;

interface

uses
  System.Classes,

  GLS.Scene, GLS.Objects, GLS.VectorGeometry, GLS.RenderContextInfo;

type

  // TVKDodecahedron
  //
  { A Dodecahedron. 
     The dodecahedron has no texture coordinates defined, ie. without using
     a texture generation mode, no texture will be mapped. }
  TVKDodecahedron = class(TVKSceneObject)
  public
    { Public Declarations }
    procedure BuildList(var rci: TRenderContextInfo); override;
  end;

  // TVKIcosahedron
  //
  { A Icosahedron. 
     The icosahedron has no texture coordinates defined, ie. without using
     a texture generation mode, no texture will be mapped. }
  TVKIcosahedron = class(TVKSceneObject)
  public
    { Public Declarations }
    procedure BuildList(var rci: TRenderContextInfo); override;
  end;

  // TVKOctahedron
  //
  { A Octahedron. 
     The octahedron has no texture coordinates defined, ie. without using
     a texture generation mode, no texture will be mapped. }
  TVKOctahedron = class(TVKSceneObject)
  public
    { Public Declarations }
    procedure BuildList(var rci: TRenderContextInfo); override;
  end;

  // TVKTetrahedron
  //
  { A Tetrahedron. 
     The tetrahedron has no texture coordinates defined, ie. without using
     a texture generation mode, no texture will be mapped. }
  TVKTetrahedron = class(TVKSceneObject)
  public
    { Public Declarations }
    procedure BuildList(var rci: TRenderContextInfo); override;
  end;


  //-------------------------------------------------------------
  //-------------------------------------------------------------
  //-------------------------------------------------------------
implementation
// ------------------
// ------------------ TVKDodecahedron ------------------
// ------------------

// BuildList
//

procedure TVKDodecahedron.BuildList(var rci: TRenderContextInfo);
begin
  DodecahedronBuildList;
end;

// ------------------
// ------------------ TVKIcosahedron ------------------
// ------------------

// BuildList
//

procedure TVKIcosahedron.BuildList(var rci: TRenderContextInfo);
begin
  IcosahedronBuildList;
end;

//--------------------
//--------------------  TVKOctahedron ------------------------
//--------------------

// BuildList
//
procedure TVKOctahedron.BuildList(var rci: TRenderContextInfo);
begin
  OctahedronBuildList;
end;

//--------------------
//--------------------  TVKTetrahedron ------------------------
//--------------------

// BuildList
//
procedure TVKTetrahedron.BuildList(var rci: TRenderContextInfo);
begin
  TetrahedronBuildList;
end;

initialization
  //-------------------------------------------------------------
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  RegisterClasses([TVKDodecahedron, TVKIcosahedron, TVKOctahedron, TVKTetrahedron]);

end.

