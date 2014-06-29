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

- Copy [projects.txt.dist](projects.txt.dist) to projects.txt
    This text file is just a list of directory names of [dockerfiles/](dockerfiles/)*/NAME.
```
phpmyadmin
companyproject
mycustomproject
```

- Open your command line and navigate into the *vagrant-docker* directory

- Run the command ``vagrant up`` and drink a coffee or something.

- After vagrant is ready and you have a projects.txt file with at least phpmyadmin. Open your browser and enter *phpmyadmin.dev*

----------
Hints
----------
- The shell provisioner updates this project, the OS, and all the [dockerfiles/](dockerfiles/) which contains a git-repository automatically.
- Example: The dockerfiles from https://github.com/reinblau/dockerfiles, will be cloning into [dockerfiles/public/](dockerfiles/public/) while the first setup.
