{
  �������� ������ �� freeform'� ��� ��� ����������

  ����������:
  ASWDZX - �������� ������
  ��� - �������� ������
  ��� - �������� ���
  Shift - ���������� ������
}
program GroundDigging;

uses
  Forms,
  main in 'main.pas' {main_form};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(Tmain_form, main_form);
  Application.Run;
end.
