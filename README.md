vagrant-docker
==============

----------
PROJECT DESCRIPTION
----------

This project tries to help you to manage your docker containers with a very little footprint.

We [@reinblau](http://reinblau.de) use it for our own most projects. Every project lives in own container but reuse other containers for services like databases etc. and
the project container should store his data outside the container.

We lets build all publicly services/images on docker.io and use it as base for our non-publicly services/images.

You will find in this project a directory called [dockerfiles/](dockerfiles/)
which contains 3 directories [dockerfiles/company/](dockerfiles/company/), [dockerfiles/custom/](dockerfiles/custom/) and [dockerfiles/public/](dockerfiles/public/).

This directories holds the projects/services for your company and your custom projects/services.
The public directory will be filled after vagrant run the first time with the services from https://github.com/reinblau/dockerfiles.

You can create many more of the "namespaces" to manage your project/services.

Every project/service needs at least one shell-script called run.sh, this file is used to start your project (container) while vagrant provision.
To detect an error the script should exit with a none-0 exit code in case of an error. To reuse another service from [dockerfiles/](dockerfiles/) you can call
```
rbrequire directoryname
```
before you start your container. Take a look at https://github.com/reinblau/dockerfiles/tree/master/phpmyadmin for an example.
You will see we use [crane](https://github.com/michaelsauter/crane) to build images or start a container. You can also do so.

----------
HOW TO USE
----------

 - Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads "Virtualbox download page")

 - Install [Vagrant](http://www.vagrantup.com/downloads.html "Vagrant download page")

- Clone/Download this git repository into your local machine
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
Automatically updates
----------
- The shell provisioner updates this project, the OS, and all the [dockerfiles/](dockerfiles/) which contains a git-repository automatically every 24 hours.
  To avoid the update of the dockerfiles, create a file blacklist.txt and enter the directory names of every "namespace". Example:
  ```
  custom
  custom2
  custom3
  ```
