with Ada.Text_IO;
use Ada.Text_IO;

procedure Vectorz is
  type Wektor is array (Integer range <>) of Float;
  W1: Wektor(1..100) := (others => 3.0);

  procedure Displayer(V1 : in Wektor) is
  begin
    for E of V1 loop
      Put_Line("Element= " & E'Img);
    end loop;
  end Displayer;

-- poniżej treść procedury głównej
begin
  Displayer(W1);
end Vectorz;
