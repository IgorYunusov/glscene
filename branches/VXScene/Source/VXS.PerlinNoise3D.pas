//
// VXScene Component Library, based on GLScene http://glscene.sourceforge.net
//
{
  Classes and function for generation of PerlinNoise.

}
unit VXS.PerlinNoise3D;

interface

{$I VXScene.inc}

uses
  System.Math,

  VXS.VectorTypes,
  VXS.VectorGeometry;

const
  cPERLIN_TABLE_SIZE = 256; // must be a power of two

type
  { Generates Perlin Noise in the [-1; 1] range.
    2D noise requests are taken in the Z=0 slice }
  TVXPerlin3DNoise = class(TObject)
  protected
    FPermutations: packed array [0 .. cPERLIN_TABLE_SIZE - 1] of Integer;
    FGradients: packed array [0 .. cPERLIN_TABLE_SIZE * 3 - 1] of Single;
  protected
    function Lattice(ix, iy, iz: Integer; fx, fy, fz: Single): Single; overload;
    function Lattice(ix, iy: Integer; fx, fy: Single): Single; overload;
  public
    constructor Create(randomSeed: Integer);
    procedure Initialize(randomSeed: Integer);
    // Noise (dual single)
    function Noise(const x, y: Single): Single; overload;
    // Noise (trio single)
    function Noise(const x, y, z: Single): Single; overload;
    function Noise(const v: TAffineVector): Single; overload;
    // Noise (hmg)
    function Noise(const v: TVector): Single; overload;
  end;

// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------

// ------------------
// ------------------ TVXPerlin3DNoise ------------------
// ------------------

constructor TVXPerlin3DNoise.Create(randomSeed: Integer);
begin
  inherited Create;
  Initialize(randomSeed);
end;

procedure TVXPerlin3DNoise.Initialize(randomSeed: Integer);
var
  seedBackup: Integer;
  i, t, j: Integer;
  z, r: Single;
begin
  seedBackup := RandSeed;
  RandSeed := randomSeed;

  // Generate random gradient vectors.
  for i := 0 to cPERLIN_TABLE_SIZE - 1 do
  begin
    z := 1 - 2 * Random;
    r := Sqrt(1 - z * z);
    SinCosine(c2PI * Random, r, FGradients[i * 3], FGradients[i * 3 + 1]);
    FGradients[i * 3 + 2] := z;
  end;
  // Initialize permutations table
  for i := 0 to cPERLIN_TABLE_SIZE - 1 do
    FPermutations[i] := i;
  // Shake up
  for i := 0 to cPERLIN_TABLE_SIZE - 1 do
  begin
    j := Random(cPERLIN_TABLE_SIZE);
    t := FPermutations[i];
    FPermutations[i] := FPermutations[j];
    FPermutations[j] := t;
  end;

  RandSeed := seedBackup;
end;

function TVXPerlin3DNoise.Lattice(ix, iy, iz: Integer; fx, fy, fz: Single): Single;
const
  cMask = cPERLIN_TABLE_SIZE - 1;
var
  g: Integer;
begin
  g := FPermutations[(ix + FPermutations[(iy + FPermutations[iz and cMask]) and cMask]) and cMask] * 3;
  Result := FGradients[g] * fx + FGradients[g + 1] * fy + FGradients[g + 2] * fz;
end;

function TVXPerlin3DNoise.Lattice(ix, iy: Integer; fx, fy: Single): Single;
const
  cMask = cPERLIN_TABLE_SIZE - 1;
var
  g: Integer;
begin
  g := FPermutations[(ix + FPermutations[(iy + FPermutations[0]) and cMask]) and cMask] * 3;
  Result := FGradients[g] * fx + FGradients[g + 1] * fy;
end;

function TVXPerlin3DNoise.Noise(const v: TAffineVector): Single;

  function Smooth(var x: Single): Single;
  begin
    Result := x * x * (3 - 2 * x);
  end;

var
  ix, iy, iz: Integer;
  fx0, fx1, fy0, fy1, fz0, fz1: Single;
  wx, wy, wz: Single;
  vy0, vy1, vz0, vz1: Single;
begin
  ix := Floor(v.x);
  fx0 := v.x - ix;
  fx1 := fx0 - 1;
  wx := Smooth(fx0);

  iy := Floor(v.y);
  fy0 := v.y - iy;
  fy1 := fy0 - 1;
  wy := Smooth(fy0);

  iz := Floor(v.z);
  fz0 := v.z - iz;
  fz1 := fz0 - 1;
  wz := Smooth(fz0);

  vy0 := Lerp(Lattice(ix, iy, iz, fx0, fy0, fz0), Lattice(ix + 1, iy, iz, fx1, fy0, fz0), wx);
  vy1 := Lerp(Lattice(ix, iy + 1, iz, fx0, fy1, fz0), Lattice(ix + 1, iy + 1, iz, fx1, fy1, fz0), wx);
  vz0 := Lerp(vy0, vy1, wy);

  vy0 := Lerp(Lattice(ix, iy, iz + 1, fx0, fy0, fz1), Lattice(ix + 1, iy, iz + 1, fx1, fy0, fz1), wx);
  vy1 := Lerp(Lattice(ix, iy + 1, iz + 1, fx0, fy1, fz1), Lattice(ix + 1, iy + 1, iz + 1, fx1, fy1, fz1), wx);
  vz1 := Lerp(vy0, vy1, wy);

  Result := Lerp(vz0, vz1, wz);
end;

function TVXPerlin3DNoise.Noise(const x, y: Single): Single;

  function Smooth(var x: Single): Single;
  begin
    Result := x * x * (3 - 2 * x);
  end;

var
  ix, iy: Integer;
  fx0, fx1, fy0, fy1: Single;
  wx, wy: Single;
  vy0, vy1: Single;
begin
  ix := Floor(x);
  fx0 := x - ix;
  fx1 := fx0 - 1;
  wx := Smooth(fx0);

  iy := Floor(y);
  fy0 := y - iy;
  fy1 := fy0 - 1;
  wy := Smooth(fy0);

  vy0 := Lerp(Lattice(ix, iy, fx0, fy0), Lattice(ix + 1, iy, fx1, fy0), wx);
  vy1 := Lerp(Lattice(ix, iy + 1, fx0, fy1), Lattice(ix + 1, iy + 1, fx1, fy1), wx);
  Result := Lerp(vy0, vy1, wy);
end;

function TVXPerlin3DNoise.Noise(const x, y, z: Single): Single;
begin
  Result := Noise(AffineVectorMake(x, y, z));
end;

function TVXPerlin3DNoise.Noise(const v: TVector): Single;
begin
  Result := Noise(PAffineVector(@v)^);
end;

end.
