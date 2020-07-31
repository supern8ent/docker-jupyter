# Summary

Builds a docker image that you can run and access locally. 

Python is installed via pyenv, but then, to save space, pyenv's dependencies are removed, so pyenv in the 
running vm is just a fossil. These pythons live in /root/.pyenv.

# Using it

* `./build` to docker build it
* `./run` to launch the docker vm
* Jupyter will be available at localhost:8890
    * Suggest bookmarking `localhost:8890/lab?token=hummingsquadshoutdeze` to start jupyterlab in your home folder.
    * Your home folder is mounted at `/home/jovyan/user` within the vm.
* `./hackin` to get a root terminal on the running vm

## Start automatically on Mac OS X

First make a launcher using Automator > Run Shell Script > Paste following code, but change 
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

`# docker: Error response from daemon: Conflict. The container name "/docker-jupyter" is already in use by container`  
`docker container prune`

# References

## Examples

* https://hub.docker.com/r/eipdev/alpine-jupyter-notebook/
* https://hub.docker.com/r/janikarh/alpine-jupyter/

## Debian-minimal 

* https://github.com/jgoerzen/docker-debian-base-minimal
* https://changelog.complete.org/archives/9794-fixing-the-problems-with-docker-images
* https://hub.docker.com/r/jgoerzen/debian-base-minimal

## Pyenv

* https://realpython.com/intro-to-pyenv/
* https://github.com/pyenv/pyenv
