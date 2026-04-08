#!/bin/bash

echo "Loading environment variables..."
source app/envs/nosecrets.env

function conditional_kill_port() {
    local search_port=$1
    local do_kill=$2
    echo "Server found on $search_port , do_kill is $do_kill"
    [ "$do_kill" = 1 ] && echo "Killing old servers if they're still open on ports $search_port..."
        PID=$(lsof -t -i tcp:$search_port)
        if [[ -z "$PID" ]]; then
            echo "No PID found for Port $search_port"
        else
            echo "Found PID $PID for Port $search_port"
            [ "$do_kill" = 1 ] && echo "Killing $PID" && xargs kill -9 $PID
        fi
}
conditional_kill_port 8502 $AUTO_KILL_REQUIRED_PORTS
conditional_kill_port 8081 $AUTO_KILL_REQUIRED_PORTS
# [ "$AUTO_KILL_REQUIRED_PORTS" = 1 ] && echo "Killing old servers if they're still open on ports 8502 and 8081..."
# PID8502=$(lsof -t -i tcp:8502)
# if [[ -z "$PID8502" ]]; then
#     echo "No PID found for Port 8502"
# else
#     echo "Found PID $PID8502 for Port 8502"
#     [ "$AUTO_KILL_REQUIRED_PORTS" = 1 ] && echo "Killing $PID8502" && xargs kill -9 $PID8502
# fi
# PID8081=$(lsof -t -i tcp:8081)
# if [[ -z "$PID8081" ]]; then
#     echo "No PID found for Port 8081"
# else
#     echo "Found PID $PID8081 for Port 8081"
#     [ "$AUTO_KILL_REQUIRED_PORTS" = 1 ] && echo "Killing $PID8081" && xargs kill -9 $PID8081
# fi

# [ "$AUTO_KILL_REQUIRED_PORTS" = 1 ] && { if (( -z $PID8502 )); then echo "Nothing found on port 8502"; else ; fi; }
# [ "$AUTO_KILL_REQUIRED_PORTS" = 1 ] && { if (( -z $PID8081 )); then echo "Nothing found on port 8081"; else xargs kill -9; fi; }

[ "$ENABLE_HTTP_AND_HTTPS_PROXY" = 1 ] && echo "Enabling HTTP_PROXY and HTTPS_PROXY"
[ "$ENABLE_HTTP_AND_HTTPS_PROXY" = 1 ] && export HTTP_PROXY=sysproxy.<priv-dom>.com:8080
[ "$ENABLE_HTTP_AND_HTTPS_PROXY" = 1 ] && export HTTPS_PROXY=sysproxy.<priv-dom>.com:8080

echo "Setting up python environment..."
export PYTHONPATH="${PYTHONPATH}:${PWD}"

[ "$COPY_SECRETS_FROM_ETC_SECRETS" = 1 ] && echo "Trying to copy secrets from /etc/secrets/leveragedAI-GenAI-Starter-Kit-Secrets.env if they exist, otherwise using app/envs/secrets.env as-is"
[ "$COPY_SECRETS_FROM_ETC_SECRETS" = 1 ] && cp -n /etc/secrets/leveragedAI-GenAI-Starter-Kit-Secrets.env app/envs/secrets.env || true
[ "$COPY_SECRETS_FROM_ETC_SECRETS" = 1 ] && cp -n /etc/secrets/$GCS_CREDENTIALS_FILENAME $GCS_CREDENTIALS_PATH/$GCS_CREDENTIALS_FILENAME || true
[ "$COPY_SECRETS_FROM_ETC_SECRETS" = 1 ] && cp -n /etc/secrets/signature.properties secrets/signature.properties || true
source app/envs/secrets.env || true


# [ "$POPULATE_VECTOR_STORE_ON_STARTUP" = 1 ] && echo "Starting first time vector store population"
# [ "$POPULATE_VECTOR_STORE_ON_STARTUP" = 1 ] && python app/scripts/create_vector_store.py


[ "$USE_API" = 1 ] && uvicorn app.api.main:app --host 0.0.0.0 --port 8502 &

[ "$USE_FRONT_END" = 1 ] && echo "Starting streamlit app"
[ "$USE_FRONT_END" = 1 ] && streamlit run app/Home.py --server.address "0.0.0.0" --server.port 8082 --browser.serverAddress "0.0.0.0" --browser.gatherUsageStats false --server.fileWatcherType "none" &

[ "$USE_NGINX_PROXY" = 1 ] && nginx -g 'daemon off;' &

[ "$USE_NGINX_PROXY" != 1 ] && echo "Access Front End at http://127.0.0.1:8081/";
[ "$USE_NGINX_PROXY" != 1 ] && echo "Access API Docs at http://127.0.0.1:8502/api/docs";

[ "$USE_NGINX_PROXY" = 1 ] && echo "Access Front End at http://127.0.0.1:8080/";
[ "$USE_NGINX_PROXY" = 1 ] && echo "Access API Docs at http://127.0.0.1:8080/api/docs";

tail -f /dev/null
