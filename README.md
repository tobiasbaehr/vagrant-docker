vagrant-docker
==============

----------
HOW TO USE
----------

- Clone this git repository into your local machine
  ``git clone https://github.com/reinblau/vagrant-docker.git``

- Run the following commands to install all required plugins
  - ``vagrant plugin install vagrant-hostsupdater``
  - ``vagrant plugin install vagrant-vbguest``
 
- Create a directory called ``data`` beside this directory

- Copy projects.example.yml to projects.yml

- Start your Virtualbox

- Open your command line and navigate into the *vagrant-docker* directory

- Run the command ``vagrant up`` and drink a coffee or something.

- After vagrant is ready. Open your browser and enter *myproject.dev/phpmyadmin* and *myproject.dev2/phpmyadmin*.  Both are independent docker container. *myproject.dev3* is an alias for *myproject.dev*.

----------
Hints
----------
- In case you need to change *projects.yml* run the command ``vagrant halt`` so that vagrant removes the hosts entries again
- Run the command ``vagrant up`` and then ``vagrant provision``
    -- A docker provisioner downloads the docker images and starts the docker container from *projects.yml*
    -- A shell provisioner creates nginx vhosts inside the vm to proxy incoming http requests to the running container for all projects which are stored in *projects.yml*. But do not removes vhosts.


---------
Bugs
---------

``
Failed to mount folders in Linux guest. This is usually because
the "vboxsf" file system is not available. Please verify that
the guest additions are properly installed in the guest and
can work properly. The command attempted was:

mount -t vboxsf -o ...
``

See https://github.com/mitchellh/vagrant/issues/3341#issuecomment-38887958
