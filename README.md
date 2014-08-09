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

In this project you find a directory called [dockerfiles/](dockerfiles/) which contains 3 directories [dockerfiles/company/](dockerfiles/company/), [dockerfiles/custom/](dockerfiles/custom/) and [dockerfiles/public/](dockerfiles/public/).

These directories hold the projects/services for your company and your custom projects/services.
After vagrant runs for the first time the public directory will be filled with services from https://github.com/reinblau/dockerfiles.

You can create more "namespaces" to manage your own project/services.

Every project/service needs at least one shell-script called run.sh. This file is used to start your project (container) while vagrant starts the shell provisioner.
This means when you run the command ``vagrant up`` or ``vagrant reload`` or simple ``vagrant provision``.

To detect an error the script should exit with a none-0 exit code in case of an error. To reuse another service from [dockerfiles/](dockerfiles/) you can call
``rbrequire directoryname`` before you start your container. Take a look at https://github.com/reinblau/dockerfiles/tree/master/drupal_boilerplate to see an example of it.
As you’ll see we use [crane](https://github.com/michaelsauter/crane) to build images or start a container. You can do that as well!

In case your project needs a shared ssh key (located in this directory level), add ``rbrequire --sshconfig`` to your run.sh script. Same for the gitconfig (/home/dev/.gitconfig), just add ``rbrequire --gitconfig``.
The drupal_boilerplate contains also for this an example. Both needs to configure via crane.yml as volumn to use it. Once again take a look at drupal_boilerplate to see a example.

----------
HOW TO USE
----------

 - Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads "Virtualbox download page")

 - Install [Vagrant](http://www.vagrantup.com/downloads.html "Vagrant download page")

- Clone/download the git repository into your local machine
  ``git clone https://github.com/reinblau/vagrant-docker.git``

- Run the following commands to install all required plugins
  - ``vagrant plugin install vagrant-hostmanager vagrant-vbguest nugrant vagrant-triggers``

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
Automatic updates
----------
- The shell provisioner updates this project, the OS, all the [dockerfiles/](dockerfiles/) which contains a git-repository, and all projects which have a crane.yml file automatically every 7 days.
  The container will then be stopped and removed to start the new container from the fresh docker image.

  To avoid the update of the dockerfiles or a docker image, create a file blacklist.txt and enter the directory names of every "namespace" or project. Example:
  ```
  public
  custom
  myproject
  ```

----------
Hosts file
----------

Our shell provisioner reads the VIRTUAL_HOST environment variable (provided for the jwilder/nginx-proxy container) from all projects and creates a file called vhosts.txt. The vagrant plugin vagrant-hostmanager get this vhosts config and updates your hosts file.

----------
SSH Config
----------

In order to connect to your container with the right ssh port. The shell provisioner reads the current used port (ssh port) for all projects
and creates a file called ssh_config.txt which will then be used to add the connection info to your ssh config from your user account.

At the end you can connected to your project via ``ssh docker/myproject.dev``.
