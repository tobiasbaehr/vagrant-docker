vagrant-docker
==============

----------
PROJECT DESCRIPTION
----------

This project helps you manage your [docker](http://www.docker.com/whatisdocker/ "What it docker?") containers with a small footprint.

We [@reinblau](http://reinblau.de) use it for most of our own projects. Every project
lives in its own container but is reusing other containers for services like
a mysql database or mongo db etc. And a very important note a container should stores his data outside the container.

We build all public services/images on [docker.io](https://hub.docker.com/u/tobiasb/) and use it as a basis for our non-public services/images.

In this project you find a directory called [dockerfiles/](dockerfiles/). This is the place where you store your dockerfiles in the following structure:

```
dockerfiles/
dockerfiles/private/
dockerfiles/private/myservice
dockerfiles/private/myproject1
dockerfiles/private/myproject2
dockerfiles/company/
dockerfiles/company/companyservice
dockerfiles/company/companyproject1
dockerfiles/company/companyproject2
```

After vagrant runs for the first time a directory will be filled with services from https://github.com/reinblau/dockerfiles.

Every project/service needs at least one shell-script called run.sh. This file is used to start your project (container) while vagrant starts the shell provisioner.
This means when you run the command ``vagrant up`` or ``vagrant reload`` or simple ``vagrant provision``.

To detect an error the script should exit with a none-0 exit code in case of an error. To reuse another service from [dockerfiles/](dockerfiles/) you can call
``rbrequire directoryname`` before you start your container. Take a look at https://github.com/reinblau/dockerfiles/tree/master/drupal_boilerplate to see an example of it.
As you’ll see we use [crane](https://github.com/michaelsauter/crane) to build images or start a container. You can do that as well!

----------
HOW TO USE
----------

 - Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads "Virtualbox download page")

 - Install [Vagrant](http://www.vagrantup.com/downloads.html "Vagrant download page")

- Clone/download the git repository into your local machine
  ``git clone https://github.com/reinblau/vagrant-docker.git``

- Run the following commands to install all required plugins
  - ``vagrant plugin install vagrant-hostmanager vagrant-vbguest nugrant``

- Copy [projects.txt.dist](projects.txt.dist) to projects.txt
    This text file is just a list of directory names of [dockerfiles/](dockerfiles/)*/NAME.
- (Obtional) Copy [.vagrantuser.dist](.vagrantuser.dist) to .vagrantuser. Change the values for your needs.

```
phpmyadmin
companyproject
mycustomproject
```

- Open your command line and navigate to the *vagrant-docker* directory

- Run the command ``vagrant up`` and drink a coffee or something.

- After vagrant is ready and you have a projects.txt file with at least phpmyadmin. Open your browser and enter *phpmyadmin.dev*

----------
Updates
----------

- The shell provisioner updates this project, the OS, all the [dockerfiles/](dockerfiles/) which contains a git-repository, and all projects which have a crane.yml file automatically every 7 days.
  The container will then be stopped and removed to start the new container from the fresh docker image.

- By default the shell provisioner will not update the system etc automatically, todo this
  change the value of autoupdate to true in your *.vagrantuser*

- To update the system manually: Log in to the VM via ``vagrant ssh`` and run the command ``rbupdate``

  To avoid the update of the dockerfiles or a docker image, create a file blacklist.txt and enter the directory names of every "namespace" or project. Example:
  ```
  public
  custom
  myproject
  ```

----------
Hosts file
----------

Our shell provisioner reads the VIRTUAL_HOST environment variable (provided for the jwilder/nginx-proxy container) from all projects and creates a file called vhosts.txt. The vagrant plugin vagrant-hostmanager use this text file and updates your hosts file.
