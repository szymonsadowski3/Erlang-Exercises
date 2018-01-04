-- pakzadsporadic.adb

pragma Profile(Ravenscar);

with Ada.Numerics.Discrete_Random;
with Ada.Exceptions;
use Ada.Exceptions;
with Ada.Synchronous_Task_Control;
use  Ada.Synchronous_Task_Control;

package body PakZadSporadic is

  protected body Ekran is
    procedure Pisz(S : String) is
    begin
      Put_Line(S);
    end Pisz;
  end Ekran;

  subtype Do2000 is Integer range 0..100;
  package Losuj is new Ada.Numerics.Discrete_Random(Do2000);

  Sem_Bin: Suspension_Object;

  protected Zdarzenie is
    entry Czekaj(Ok: out Natural);
    procedure Wstaw(Ok: in Natural);
  private
    pragma Priority (System.Default_Priority+4);
    Okres : Natural := 0;
    Jest_Zdarzenie : Boolean := False;
  end Zdarzenie;

  protected body Zdarzenie is
    entry Czekaj(Ok: out Natural) when Jest_Zdarzenie is
    begin
      Jest_Zdarzenie := False;
      Ok := Okres;
    end Czekaj;
    procedure Wstaw(Ok: in Natural) is
    begin
      Jest_Zdarzenie := True;
      Okres := Ok;
    end Wstaw;
  end Zdarzenie;

  task body Te is
    use Losuj;
    Nastepny : Ada.Real_Time.Time;
    Temp  : Natural := 50;
    Przesuniecie : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(10);
    G : Generator;
  begin
    Reset(G);
    Nastepny := Ada.Real_Time.Clock + Przesuniecie;
    loop
      delay until Nastepny;
      Set_True(Sem_Bin);
      Temp := Random(G);


      Ekran.Pisz("Odczyt temperatury: " & Temp'Img);

      if Temp > 80 then
        Zdarzenie.Wstaw(Temp);
      end if;
      Nastepny := Nastepny + Ada.Real_Time.Milliseconds(500);
    end loop;
  exception
    when E:others => Put_Line("Error: Zadanie generujace zdarzenia");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Te;

  task body Ts1 is
  begin
    loop
      Suspend_Until_True(Sem_Bin);
      Set_False(Sem_Bin);
      Ekran.Pisz("Temp");
    end loop;
  exception
    when E:others => Put_Line("Error: Zadanie sporadyczne 1");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Ts1;

  task body Ts2 is
    Ok : Natural := 0;
  begin
    loop
      Zdarzenie.Czekaj(Ok);
      Ekran.Pisz("Krytyczna temperatura=" & Ok'Img);
    end loop;
  exception
    when E:others => Put_Line("Error: Zadanie sporadyczne 2");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Ts2;

begin
  Set_False(Sem_Bin);
end PakZadSporadic;
