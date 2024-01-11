echo "Reset iptables to ACCEPT all, then flush and delete all other chains";
                        declare -A chains=( [filter]=INPUT:FORWARD:OUTPUT [raw]=PREROUTING:OUTPUT [mangle]=PREROUTING:INPUT:FORWARD:OUTPUT:POSTROUTING [security]=INPUT:FORWARD:OUTPUT [nat]=PREROUTING:INPUT:OUTPUT:POSTROUTING );
                        for table in "${!chains[@]}"; do 
                        echo "${chains[$table]}" | tr : $"\n" | while IFS= read -r;
                        do sudo iptables -t "$table" -P "$REPLY" ACCEPT
                        done
                        sudo iptables -t "$table" -F
                        sudo iptables -t "$table" -X
                        done
