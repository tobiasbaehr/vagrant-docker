vagrant-docker
==============

----------
HOW TO USE
----------

 - Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads "Virtualbox download page")

 - Install [Vagrant](http://www.vagrantup.com/downloads.html "Vagrant download page")

- Clone this git repository into your local machine
  ``git clone https://github.com/reinblau/vagrant-docker.git``

- Run the following commands to install all required plugins
  - ``vagrant plugin install vagrant-hostsupdater vagrant-vbguest``
 
- Copy projects.example.yml to projects.yml
    - server_name: The domain/Docker container name.
    - image: The Docker image. More image to play with. [index.docker.io](https://index.docker.io/ "index.docker.io - Docker images repositories")
    - args: Additional arguments for the command ``docker run``. Default is ``--hostname=$server_name``
    - port: The HTTP-Port for the Nginx inside the dockerhost to proxy incoming requests to the right container.
    - cmd: Overwrite the default cmd of the docker image.

- Open your command line and navigate into the *vagrant-docker* directory

- Run the command ``vagrant up`` and drink a coffee or something.

- After vagrant is ready. Open your browser and enter *myproject.dev/phpmyadmin* and *myproject.dev2/phpmyadmin*.  Both are independent docker container. *myproject.dev3* is an alias for *myproject.dev*.

- Adjust the projects.yml for your needs. But do not forget to remove the example docker container with ``docker stop $(docker ps -a -q);docker rm $(docker ps -a -q)`` (Stops and removes all containers).

----------
Hints
----------
- In case you need to change *projects.yml* run the command ``vagrant halt`` so that vagrant removes the hosts entries again
- Run the command ``vagrant up --provision``
    - A docker provisioner downloads the docker images and starts the docker container from *projects.yml*
    - A shell provisioner creates nginx vhosts inside the vm to proxy incoming http requests to the running container for all projects which are stored in *projects.yml*. But do not removes vhosts.

---------
Bugs
---------
* There is a bug with VirtualBox in version 4.3.10, in case you get the message below while running ``vagrant up`` the first time.
  Then run the command to fix it: ``vagrant ssh -c 'sudo ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions'; vagrant reload``.

``Failed to mount folders in Linux guest. This is usually because
the "vboxsf" file system is not available. Please verify that
the guest additions are properly installed in the guest and
can work properly. The command attempted was:

mount -t vboxsf -o ...``

See https://github.com/mitchellh/vagrant/issues/3341#issuecomment-38887958
