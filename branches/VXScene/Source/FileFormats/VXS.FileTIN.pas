//
// VXScene Component Library, based on GLScene http://glscene.sourceforge.net
//
{
  TIN (Triangular Irregular Network) vector file format implementation.
}
unit VXS.FileTIN;

interface

uses
  System.Classes,
  System.SysUtils,

  VXS.VectorTypes,
  VXS.VectorFileObjects,
  VXS.ApplicationFileIO,
  VXS.VectorGeometry,
  VXS.Utils,
  VXS.Types;


type
  { The TIN vector file (triangle irregular network).
    It is a simple text format, with one triangle record per line, no materials,
    no texturing (there may be more, but I never saw anything in this files).
    This format is encountered in the DEM/DTED world and used in place of grids. }
  TVXTINVectorFile = class(TVXVectorFile)
  public
    class function Capabilities: TVXDataFileCapabilities; override;
    procedure LoadFromStream(aStream: TStream); override;
  end;

// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------

// ------------------
// ------------------ TVXTINVectorFile ------------------
// ------------------

class function TVXTINVectorFile.Capabilities: TVXDataFileCapabilities;
begin
  Result := [dfcRead];
end;

procedure TVXTINVectorFile.LoadFromStream(aStream: TStream);
var
  i, j: Integer;
  sl, tl: TStringList;
  mesh: TVXMeshObject;
  v1, v2, v3, n: TAffineVector;
  ActiveTin: Boolean;
  Id_Tin: Integer;
  Tnam: string;
  Id_Mat, NVert, NTri: Integer;

  VertArr: TxPoint3DArray;
  n1, n2, n3: Integer;

begin
  sl := TStringList.Create;
  tl := TStringList.Create;
  try
    sl.LoadFromStream(aStream);
    mesh := TVXMeshObject.CreateOwned(Owner.MeshObjects);
    mesh.Mode := momTriangles;
    if sl[0] <> 'TIN' then
    // the file with single TIN described by vertices only
    begin
      for i := 0 to sl.Count - 1 do
      begin
        tl.CommaText := Copy(sl[i], 0, MaxInt);
        Trim(tl.CommaText);
        if tl.Count = 9 then
        begin
          SetVector(v1, VXS.Utils.StrToFloatDef(tl[0], 0),
            VXS.Utils.StrToFloatDef(tl[1], 0),
            VXS.Utils.StrToFloatDef(tl[2], 0));
          SetVector(v2, VXS.Utils.StrToFloatDef(tl[3], 0),
            VXS.Utils.StrToFloatDef(tl[4], 0),
            VXS.Utils.StrToFloatDef(tl[5], 0));
          SetVector(v3, VXS.Utils.StrToFloatDef(tl[6], 0),
            VXS.Utils.StrToFloatDef(tl[7], 0),
            VXS.Utils.StrToFloatDef(tl[8], 0));
          mesh.Vertices.Add(v1, v2, v3);
          n := CalcPlaneNormal(v1, v2, v3);
          mesh.Normals.Add(n, n, n);
        end;
      end
    end
    else // the file with multiple TINs described by triangles and materials
      while i < sl.Count - 1 do
      begin
        Inc(i);
        tl.DelimitedText := sl[i];
        if (tl.CommaText = 'BEGT') then // the beginning of new tin
        begin
          repeat
            Inc(i);
            tl.DelimitedText := sl[i];
            if (tl[0] = 'ACTIVETIN') then
              ActiveTin := True;
            if (tl[0] = 'ID') then
              Id_Tin := StrToInt(tl[1]);
            if (tl[0] = 'TNAM') then
              Tnam := tl[1];
            if (tl[0] = 'MAT') then
              Id_Mat := StrToInt(tl[1]);
            if (tl[0] = 'VERT') then
              NVert := StrToInt(tl[1]);
          until tl[0] = 'VERT';
          SetLength(VertArr, NVert);
          j := 0;
          repeat
            Inc(i);
            tl.DelimitedText := sl[i];
            VertArr[j].X := StrToFloat(tl[0]);
            VertArr[j].Y := StrToFloat(tl[1]);
            VertArr[j].Z := StrToFloat(tl[2]);
            Inc(j);
          until (j = NVert);
          Inc(i);
          tl.DelimitedText := sl[i];
          NTri := StrToInt(tl[1]);
          j := 0;
          repeat
            Inc(i);
            Inc(j);
            tl.DelimitedText := sl[i];
            n1 := StrToInt(tl[0]);
            n2 := StrToInt(tl[1]);
            n3 := StrToInt(tl[2]);
            SetVector(v1, VertArr[n1 - 1].X, VertArr[n1 - 1].Y,
              VertArr[n1 - 1].Z);
            SetVector(v2, VertArr[n2 - 1].X, VertArr[n2 - 1].Y,
              VertArr[n2 - 1].Z);
            SetVector(v3, VertArr[n3 - 1].X, VertArr[n3 - 1].Y,
              VertArr[n3 - 1].Z);
            mesh.Vertices.Add(v1, v2, v3);
            n := CalcPlaneNormal(v1, v2, v3);
            mesh.Normals.Add(n, n, n);
          until (j = NTri);
          Inc(i);
          tl.DelimitedText := sl[i]; // tl.DelimitedText = 'ENDT';
        end;
      end;
  finally
    tl.Free;
    sl.Free;
  end;
end;

// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------

RegisterVectorFileFormat('tin', 'Triangular Irregular Network',
  TVXTINVectorFile);

end.
