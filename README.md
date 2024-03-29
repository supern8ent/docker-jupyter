# Summary

Builds a docker image that you can run and access locally. 

Python is installed via pyenv, but then, to save space, pyenv's dependencies are removed, so pyenv in the 
running vm is just a fossil. These pythons live in /root/.pyenv.

Jupyter is installed in a poetry environment. Another poetry environment containing common data science libraries is 
also installed, and its kernel is registered with Jupyter. These environments are installed in 
/home/jovyan/.environments.

# Using it

* Add a `token.txt` file to the base directory (next to Dockerfile).  
    `python3 -c "import secrets; print(secrets.token_urlsafe(32))" > token.txt`
* `./build` to docker build it
* `./run` to launch the docker vm
* Jupyter will be available at localhost:8890
    * Suggest entering your token in the dialog and letting your browser remember it for you (alternatively, bookmark `localhost:8890/lab?token=hummingsquadshoutdeze` (replace token with your token))
* Jupyter starts with access only to the `/home/jovyan/user` directory, and you will not have edit rights to this 
    directory. See the next point about mounting host directories so you can do work *outside* the container's 
    temporary filesystem.  
    (Yes this is sub-optimal. The original way this worked was that the host's entire home 
    directory was mounted at `/home/jovyan/user`, but either docker or Apple changed something around the beginning of 
    2021 and now Docker flips out if you do that.)
* By default your `~/dev` folder will be bind mounted at `/home/jovyan/user/dev` within the container. Add/change what gets
mounted by modifying the bash script named `run`.
* `./hackin` to get a root terminal on the running container
* `./stop` to stop the running container

## Start automatically on Mac OS X

First make a launcher using Automator > New > Application > Run Shell Script > Paste following code, but change 
`~/dev/jupyter/docker-jupyter/run` to the path to `run` command.

```bash
exitCode=0
attempt=1
timeout=1

while [ $attempt -le 6 ]; do
    /usr/local/bin/docker info
    exitCode=$?

    if [ $exitCode -eq 0 ]; then
	    break
    fi

    echo "Failure: docker is not started. Will sleep then retry."
    sleep $timeout
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
done

if [ $exitCode != 0 ]; then
    echo "Docker never got started :( but will try to start jupyter anyways"
fi

~/dev/jupyter/docker-jupyter/run
```

Next, go to System Preferences > Users & Groups > Login Items and add your Automator.

# Other commands

If `./run` gives this error:  
`# docker: Error response from daemon: Conflict. The container name "/docker-jupyter" is already in use by container`  
remove old containers by running  
`docker container prune`

# References

## Examples

* https://hub.docker.com/r/eipdev/alpine-jupyter-notebook/
* https://hub.docker.com/r/janikarh/alpine-jupyter/

## Pyenv

* https://realpython.com/intro-to-pyenv/
* https://github.com/pyenv/pyenv
